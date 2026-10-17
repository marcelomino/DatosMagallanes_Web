# ═════════════════════════════════════════════════════════════════════════════
# _dev/agregar_fichas.R  —  Regenera indicadores/indicadores.yaml
#
# QUE HACE
#   Lee las 69 indicadores/{id}_{slug}/ficha.yaml y las escribe apiladas en
#   indicadores/indicadores.yaml, ordenadas por id y agrupadas por dimension.
#
# POR QUE EXISTE UN AGREGADO SI LA APP NO LO LEE
#   Porque una carpeta por indicador es buena para editar y mala para leer: ver
#   el catalogo entero, o revisar en un diff de git que una fuente cambio en
#   ocho fichas, exige abrir 69 archivos. El agregado es esa vista unica. Es
#   derivado y desechable: si se pierde, se regenera; si se edita a mano, el
#   cambio se pierde en la proxima corrida.
#
# QUE NO LLEVA
#   Los bloques de aparato interno (procesamiento, notas_calidad, historial).
#   Son bitacora de mantenimiento y se quedan en la carpeta de su indicador.
#
# USO
#   Rscript _dev/agregar_fichas.R              escribe indicadores/indicadores.yaml
#   Rscript _dev/agregar_fichas.R /ruta.yaml   escribe en otra parte
#
#   Correrlo cada vez que se agrega o edita una ficha. Es idempotente: dos
#   corridas seguidas sin tocar nada dejan el archivo byte a byte igual.
#
#   El destino alternativo existe para el validador, que compara el agregado del
#   repo contra uno recien generado en un temporal. Un validador que escribe en
#   el repo puede dejar un archivo malo cuando justamente algo esta fallando.
# ═════════════════════════════════════════════════════════════════════════════

suppressPackageStartupMessages({
  library(purrr); library(stringr); library(cli)
})

RAIZ    <- "indicadores"
DESTINO <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(DESTINO)) DESTINO <- file.path(RAIZ, "indicadores.yaml")

# Los campos publicables, en el orden en que se emiten. Mismo contrato que
# .CAMPOS_FICHA_OBLIGATORIOS en R/00_data.R, mas fuente_id.
CAMPOS <- c("id", "nombre", "seccion", "definicion", "unidad", "tipo_dato",
            "calculo", "fuente", "fuente_id", "desagregaciones",
            "disponibilidad", "comentario")

PLEGADOS <- c("definicion", "comentario")

# Las cinco dimensiones y el rango de ids de cada una, para los separadores.
DIMENSIONES <- list(
  list(rotulo = "POBLACION",          desde = 100, hasta = 199),
  list(rotulo = "ECONOMIA",           desde = 200, hasta = 299),
  list(rotulo = "POBREZA E INGRESOS", desde = 300, hasta = 399),
  list(rotulo = "BIENESTAR",          desde = 400, hasta = 499),
  list(rotulo = "COHESION SOCIAL",    desde = 500, hasta = 599)
)


# ─────────────────────────────────────────────────────────────────────────────
# Lectura
# ─────────────────────────────────────────────────────────────────────────────

carpetas <- list.dirs(RAIZ, full.names = FALSE, recursive = FALSE) |>
  keep(\(x) str_detect(x, "^\\d+_"))

fichas <- carpetas |>
  map(\(c) {
    ruta <- file.path(RAIZ, c, "ficha.yaml")
    if (!file.exists(ruta)) return(NULL)
    yaml::yaml.load(paste(readLines(ruta, encoding = "UTF-8", warn = FALSE),
                          collapse = "\n"))
  }) |>
  compact()

if (!length(fichas)) cli_abort("No se encontro ninguna ficha.yaml en {.path {RAIZ}}")

fichas <- fichas[order(map_int(fichas, \(f) as.integer(f$id)))]


# ─────────────────────────────────────────────────────────────────────────────
# Emision
# ─────────────────────────────────────────────────────────────────────────────
# Se emite a mano y no con yaml::as.yaml() por lo mismo que en la ficha: importa
# el orden de los campos, los bloques plegados de la prosa y los separadores de
# dimension. as.yaml() ordena alfabeticamente y no conserva comentarios.

comillas <- function(x)
  paste0('"', str_replace_all(as.character(x), '([\\\\"])', '\\\\\\1'), '"')

plegado <- function(clave, texto, sangria = "      ") {
  palabras <- str_split_1(str_squish(texto), " ")
  lineas <- character(); actual <- ""
  for (w in palabras) {
    if (nchar(actual) == 0) actual <- w
    else if (nchar(actual) + 1 + nchar(w) <= 78 - nchar(sangria))
      actual <- paste(actual, w)
    else { lineas <- c(lineas, actual); actual <- w }
  }
  c(paste0("    ", clave, ": >"), paste0(sangria, c(lineas, actual)))
}

L <- c(
  "# ═════════════════════════════════════════════════════════════════════════",
  "# ARCHIVO GENERADO — no editar a mano.",
  "#",
  "# Es la vista unica del catalogo, apilada desde las fichas individuales. La",
  "# app NO lo lee: la fuente de verdad de cada indicador es su propia ficha en",
  "# indicadores/{id}_{slug}/ficha.yaml, que es donde hay que editar.",
  "#",
  "# Regenerar:  Rscript _dev/agregar_fichas.R",
  "# ═════════════════════════════════════════════════════════════════════════",
  "",
  "indicadores:"
)

dimension_abierta <- NULL

for (f in fichas) {
  id <- as.integer(f$id)

  dim <- detect(DIMENSIONES, \(d) id >= d$desde && id <= d$hasta)
  if (!is.null(dim) && !identical(dim$rotulo, dimension_abierta)) {
    L <- c(L, "",
           paste0("  # ── ", dim$rotulo, " ",
                  strrep("─", max(0, 66 - nchar(dim$rotulo)))))
    dimension_abierta <- dim$rotulo
  }

  primero <- TRUE
  for (campo in CAMPOS) {
    valor <- f[[campo]]
    if (is.null(valor)) next

    if (campo %in% PLEGADOS) {
      L <- c(L, plegado(campo, valor))
    } else {
      # El primer campo emitido lleva el guion de la lista.
      prefijo <- if (primero) "  - " else "    "
      emitido <- if (campo == "id") as.character(as.integer(valor))
                 else if (campo %in% c("seccion", "fuente_id")) as.character(valor)
                 else comillas(valor)
      L <- c(L, paste0(prefijo, campo, ": ", emitido))
    }
    primero <- FALSE
  }
  L <- c(L, "")
}

# Una sola linea en blanco al final, no dos.
while (length(L) && !nzchar(L[length(L)])) L <- L[-length(L)]

con <- file(DESTINO, open = "wt", encoding = "UTF-8")
writeLines(L, con)
close(con)

cli_alert_success("{.path {DESTINO}}: {length(fichas)} fichas")

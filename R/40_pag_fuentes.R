# ═════════════════════════════════════════════════════════════════════════════
# R/40_pag_fuentes.R — Capitulo VII: Fuentes
#
# PAGINA: fuentes.html
#
# QUE PUBLICA
#   VII.1  Sankey capitulo -> fuente primaria, ancho = numero de indicadores.
#   Tabla  Una fila por fuente de indicadores/fuentes.yaml, con su numero de
#          indicadores y cuantos tienen datos compilados.
#
# DE DONDE SALE CADA COSA
#   d_fuentes  el registro de fuentes con sus conteos, derivados de las 69
#              fichas en cada construccion (R/00_data.R)
#   d_red      las aristas capitulo -- fuente, tambien derivadas
#
# POR QUE LA LAMINA SE DIBUJA EN LA PAGINA
#   No cuelga de ningun indicador: dibuja el catalogo entero, y R/20_graficos.R
#   aborta ante una lamina sin ficha propia. Se publica con lienzo_fijo(), que
#   le da el mismo lienzo diferido que a las laminas de LAM.
#
# LAS DESCARGAS
#   datos/fuentes.csv y datos/red_capitulo_fuente.csv, que escribe
#   escribir_sitio() (R/50_sitio.R) junto con los CSV de cada pieza.
# ═════════════════════════════════════════════════════════════════════════════

pag_fuentes <- function() {
  tagList(
    portadilla(
      "VII", "Fuentes",
      "Fuentes primarias de los indicadores del catalogo.",
      # La cuenta se lee del registro, nunca se escribe a mano.
      rango = paste(nrow(d_fuentes), "fuentes")),

    pliego(
      # ── VII.1 Capitulos y fuentes ─────────────────────────────────────────
      # Vertical a proposito: 16 fuentes apiladas a la derecha piden alto, no
      # ancho, y a todo el pliego las cintas quedaban casi horizontales.
      cuadro(
        "VII.1", "Indicadores por capitulo y fuente",
        div(class = "lamina-vertical",
            lienzo_fijo("lienzo-VII-1", .tejido(), "860px",
                        "Cuadro VII.1 - Indicadores por capitulo y fuente")),
        unidad = "Numero de indicadores",
        definicion = paste(
          "Fuente primaria (fuente_id) declarada en la ficha de cada indicador.",
          "Ancho de cinta = numero de indicadores del par capitulo-fuente."),
        fuente = .PROCEDENCIA,
        descarga = boton_descarga("red_capitulo_fuente")),

      # ── Registro de fuentes ───────────────────────────────────────────────
      .tabla_fuentes(),
      div(class = "ficha-descarga", boton_descarga("fuentes"))
    )
  )
}

#' VII.1 Sankey capitulo -> fuente
#'
#' Se ordena por capitulo y, dentro de cada uno, por carga: las cintas gruesas
#' quedan arriba y el dibujo se lee sin perseguir hilos.
.tejido <- function() {
  d_red |>
    dplyr::mutate(capitulo = .rotulo_capitulo(seccion),
                  fuente   = .nombre_corto(fuente_id)) |>
    dplyr::arrange(capitulo, dplyr::desc(piezas)) |>
    dplyr::select(capitulo, fuente, piezas) |>
    e_charts() |>
    e_sankey(capitulo, fuente, piezas,
             # Margen derecho para los rotulos de las fuentes, que quedan
             # por fuera de la ultima columna de nodos.
             left = 8, right = 150, top = 8, bottom = 8,
             nodeWidth = 14, nodeGap = 12,
             # Sin iteraciones de disposicion: ECharts reordenaria los
             # nodos (IV antes que III) y el orden de los datos se perderia.
             layoutIterations = 0,
             label = list(fontFamily = "Asap, sans-serif", fontSize = 12,
                          color = PAL$tinta),
             lineStyle = list(color = "source", opacity = 0.34, curveness = 0.5),
             itemStyle = list(borderWidth = 0)) |>
    e_lamina() |>
    e_tooltip(trigger = "item")
}


# ─────────────────────────────────────────────────────────────────────────────
# Mobiliario del capitulo
# ─────────────────────────────────────────────────────────────────────────────

# Procedencia de la lamina y de la tabla: los dos se derivan del mismo par de
# registros.
.PROCEDENCIA <- paste(
  "Elaboracion propia sobre indicadores/{id}_{slug}/ficha.yaml",
  "e indicadores/fuentes.yaml.")

#' Tabla resumen del registro de fuentes
#'
#' Mismo chasis que el inventario de los capitulos (.inv-tabla): una fila por
#' fuente, en el orden de d_fuentes (mas indicadores primero). Un campo vacio
#' en el YAML se publica como "Sin dato", no como celda en blanco.
.tabla_fuentes <- function() {
  celda <- function(v)
    if (!nzchar(trimws(v))) marca_estado("nodisponible", "Sin dato") else v

  filas <- purrr::pmap(d_fuentes, function(fuente_id, nombre, institucion, tipo,
                                           periodicidad, url, piezas,
                                           compiladas, ...) {
    tags$tr(
      tags$td(class = "inv-id inv-sigla", .nombre_corto(fuente_id)),
      tags$th(scope = "row", class = "inv-pieza",
              if (nzchar(url))
                tags$a(href = url, target = "_blank", rel = "noopener", nombre)
              else nombre,
              tags$span(class = "inv-glosa", fuente_id)),
      tags$td(class = "inv-fuente", celda(institucion)),
      tags$td(class = "inv-unidad", celda(tipo)),
      # Periodicidad es una palabra ("Bienal"), no un periodo: va en Asap.
      tags$td(class = "inv-unidad", celda(periodicidad)),
      tags$td(class = "inv-valor", fmt_n(piezas)),
      tags$td(class = "inv-valor", fmt_n(compiladas)))
  })

  tags$section(
    class = "inventario",
    div(class = "inv-cabecera", h2(class = "inv-caption", "Registro de fuentes")),
    div(class = "tabla-desplazable",
      tags$table(
        class = "inv-tabla", `aria-label` = "Registro de fuentes",
        tags$thead(tags$tr(
          tags$th(scope = "col", "Sigla"),
          tags$th(scope = "col", "Operacion estadistica"),
          tags$th(scope = "col", "Institucion"),
          tags$th(scope = "col", "Tipo"),
          tags$th(scope = "col", "Periodicidad"),
          tags$th(scope = "col", class = "es-num", "Indicadores"),
          tags$th(scope = "col", class = "es-num", "Con datos"))),
        tags$tbody(filas))))
}

#' Capitulo con su numeral romano, como se cita
#'
#' El numeral sale de .CAPITULOS (R/40_pag_presentacion.R), que es la fuente unica
#' de la navegacion: si un capitulo cambia de numero, cambia aqui tambien.
.rotulo_capitulo <- function(seccion) {
  vapply(seccion, function(s) {
    cap <- purrr::detect(.CAPITULOS, \(c) identical(c$seccion, s))
    if (is.null(cap)) s else paste0(cap$num, " · ", cap$nombre)
  }, character(1), USE.NAMES = FALSE)
}

#' Forma corta de cada fuente, para rotular un nodo o una cabecera
#'
#' "Encuesta de Caracterizacion Socioeconomica Nacional" no cabe en el nodo de un
#' grafo ni en la cabecera de un asiento. La forma corta es una DECISION
#' EDITORIAL y no un dato —por eso se declara aqui y no en fuentes.yaml, igual
#' que las siglas de los organismos en el umbral de la portada—, y la clave es el
#' `fuente_id`, que es como se cita una fuente en todo el catalogo.
#'
#' Derivarla del nombre no sirve: la sigla mas usada del catalogo, CASEN, no
#' aparece en el nombre de su propia operacion.
.NOMBRE_CORTO <- c(
  casen             = "CASEN",
  censo             = "Censo",
  ine_proyecciones  = "Proyecciones INE",
  ine_vitales       = "Vitales",
  ine_ene           = "ENE",
  ine_enut          = "ENUT",
  ine_medioambiente = "Medio Ambiente",
  banco_central     = "Cuentas Nacionales",
  sii               = "Empresas SII",
  servel            = "SERVEL",
  cead              = "CEAD",
  mineduc_sige      = "SIGE",
  mineduc_sies      = "SIES",
  obs_homicidios    = "Obs. Homicidios",
  uer_encuesta      = "Encuesta UER",
  minvu_ceut        = "Deficit habitacional"
)

#' Nombre corto de una fuente por su id
#'
#' Una fuente nueva sin entrada en .NOMBRE_CORTO no rompe nada: se publica su
#' id en mayusculas. Se vera pobre, pero nunca vacio ni ilegible.
.nombre_corto <- function(fuente_id) {
  corto <- unname(.NOMBRE_CORTO[fuente_id])
  ifelse(is.na(corto), toupper(fuente_id), corto)
}

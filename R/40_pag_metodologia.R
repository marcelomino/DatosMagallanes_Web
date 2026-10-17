# ═════════════════════════════════════════════════════════════════════════════
# R/40_pag_metodologia.R — Capitulo VI: Metodologia
#
# PAGINA: metodologia.html
#
# QUE HACE
#   Es el catalogo razonado propiamente tal: el asiento completo de cada pieza.
#   La portada tiene el REGISTRO (direccion y estado de cada pieza); esta
#   seccion tiene el CATALOGO (la ficha entera de cada una). La distincion es la
#   clasica entre indice y catalogo, y evita que las dos secciones se dupliquen.
#
#   La fuente es d_indicadores, que R/00_data.R arma barriendo las fichas de
#   indicadores/{id}_{slug}/ficha.yaml. Para agregar o corregir una ficha NO se
#   toca este archivo: se edita la ficha de esa carpeta. Aqui solo se maqueta.
#
# ESTRUCTURA
#   portadilla   umbral violeta del capitulo
#   .filtros     selector de dimension + busqueda + cuenta de resultados
#   .fichas      acordeon con un asiento por pieza: los 69, siempre
#
# EL FILTRO OCULTA, NO RECONSTRUYE
#   En el dashboard Shiny el servidor reconstruia el acordeon con cada busqueda.
#   Aqui los 69 asientos se escriben una vez y js/sitio.js oculta los que no
#   calzan, comparando contra data-seccion y data-buscar. Por eso refinar la
#   busqueda tampoco cierra los asientos que el lector tenia abiertos.
#
#   metodologia.html?pieza=215 deja esa pieza sola en la busqueda y la abre: es
#   el destino del enlace "Ver ficha tecnica detallada" de cada cuadro.
# ═════════════════════════════════════════════════════════════════════════════

# ── Campos del asiento y su rotulo visible ───────────────────────────────────
# Lista blanca ordenada: define QUE campos del YAML se publican y EN QUE ORDEN.
# Es deliberadamente explicita y no un names(d_indicadores): asi una columna
# nueva en el YAML, o derivada en data.R como `tiene_datos`, no se cuela en el
# asiento sin que alguien lo decida.
.CAMPOS_FICHA <- c(
  definicion      = "Definicion",
  unidad          = "Unidad",
  calculo         = "Calculo",
  tipo_dato       = "Tipo de dato",
  fuente          = "Fuente",
  desagregaciones = "Desagregaciones",
  disponibilidad  = "Disponibilidad",
  comentario      = "Comentario"
)

pag_metodologia <- function() {
  df <- dplyr::arrange(d_indicadores, id)

  paneles <- purrr::map(seq_len(nrow(df)), function(i) {
    fila <- df[i, ]
    bslib::accordion_panel(
      # La cabecera lleva numero de acceso, dimension, nombre y estado del
      # dato: se puede citar una pieza sin abrir su asiento, y se ve de
      # inmediato si tiene datos compilados o solo ficha.
      title = div(
        class = "ficha-cabeza",
        span(class = "ficha-id", fila$id),
        span(class = "ficha-seccion", fila$seccion),
        span(class = "ficha-nombre", fila$nombre),
        if (isTRUE(fila$tiene_datos)) marca_estado("compilado")
        else marca_estado("nodisponible")
      ),
      value = paste0("ind_", fila$id),
      # SIN GRAFICO, a proposito. El cuadro vive en su capitulo, que publica al
      # pie su definicion y su fuente y enlaza hasta aqui. Este capitulo es la
      # ficha tecnica detallada; repetir la lamina lo convertiria en una
      # segunda version del capitulo en vez de su complemento.
      .tabla_ficha(fila),
      # La descarga va DENTRO del cuerpo, nunca en la cabecera: la cabecera
      # entera es el boton que abre y cierra el asiento. Solo si hay datos.csv.
      if (isTRUE(fila$tiene_datos))
        div(class = "ficha-descarga", boton_descarga(fila$carpeta)),
      # Lo que compara el filtro: la dimension y, en minusculas, el numero de
      # acceso, el nombre, la dimension y la definicion. Un salto de linea los
      # separa para que una busqueda no calce a caballo entre dos campos.
      # bslib deja estos atributos en el .accordion-body del asiento.
      `data-seccion` = fila$seccion,
      `data-buscar`  = tolower(paste(fila$id, fila$nombre, fila$seccion,
                                     fila$definicion %||% "", sep = "\n"))
    )
  })

  tagList(
    portadilla("VI", "Metodologia",
      "El asiento completo de cada indicador: definicion, calculo, fuente, desagregaciones y notas de comparabilidad.",
      # La cuenta se lee del registro y no se escribe a mano.
      rango = paste(nrow(df), "asientos")),

    pliego(
      # Las opciones de dimension salen del propio YAML: si aparece una nueva,
      # el selector la ofrece sin tocar codigo.
      div(
        class = "filtros",
        control_select("met-filtro_sec", "Dimension",
                       c("Todas", sort(unique(df$seccion))), "Todas"),
        control_texto("met-busqueda", "Buscar indicador",
                      "Numero de acceso, nombre o palabra clave"),
        # Cuenta de resultados: le dice al lector si el filtro dejo algo fuera.
        div(class = "filtros-cuenta",
            span(id = "met-cuenta", `aria-live` = "polite",
                 paste(nrow(df), "asientos")))
      ),

      div(
        class = "fichas",
        # multiple = TRUE permite comparar dos asientos abiertos.
        do.call(bslib::accordion,
                c(paneles, list(id = "met-acc", open = FALSE, multiple = TRUE,
                                class = "fichas-acc"))),
        div(class = "vacio", hidden = NA, "Ningun indicador coincide con ese criterio.")
      )
    )
  )
}

# Mobiliario fijo: todos los asientos muestran los mismos campos en el mismo
# orden. Un campo vacio no se omite: se publica como "Sin dato". Omitirlo
# dejaria al lector sin saber si el dato falta o si el campo no aplica.
.tabla_ficha <- function(fila) {
  filas <- lapply(names(.CAMPOS_FICHA), function(campo) {
    valor <- fila[[campo]]
    # Tres formas de estar vacio: ausente, NA, o solo espacios en blanco.
    if (is.null(valor) || is.na(valor) || !nzchar(trimws(as.character(valor))))
      valor <- tags$span(class = "marca-estado es-nodisponible", "Sin dato")
    else
      valor <- trimws(as.character(valor))
    tags$tr(
      tags$th(class = "ficha-campo", .CAMPOS_FICHA[[campo]]),
      tags$td(class = "ficha-valor", valor)
    )
  })
  tags$table(class = "ficha-tabla", tags$tbody(filas))
}

# Operador de respaldo: `a %||% b` devuelve b si a es NULL. Tolera campos
# ausentes en el YAML.
`%||%` <- function(a, b) if (is.null(a)) b else a

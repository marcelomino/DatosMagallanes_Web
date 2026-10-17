# ═════════════════════════════════════════════════════════════════════════════
# _dev/ver.R  —  Previsualizar una lamina con el formato real, sin la app
#
# POR QUE HACE FALTA
#   e_lamina() no pinta nada: solo escribe el NOMBRE de un tema ("catalogo").
#   Quien lo registra es script_tema_echarts(), inyectado en el <head> de la
#   app (ui.R). Fuera de la app ese <head> no existe, y el Viewer de RStudio
#   dibuja con el tema por defecto de ECharts: colores ajenos, tipografia del
#   sistema y —peor— los rotulos en blanco, porque eje_cifra() y tip_eje()
#   llaman a DM.n, que define script_formato().
#
#   Este archivo reconstruye ese <head> en una pagina suelta. Son las mismas
#   cuatro piezas que carga ui.R, en el mismo orden:
#     fonts/asap.css  ·  script_formato()  ·  script_tema_echarts()  ·  el papel
#
# USO — desde la raiz del proyecto
#   source("_dev/ver.R")
#
#   ver("112_poblacion_migrante")        dibuja y abre en el navegador
#   ver("301_pobreza", "III.1")          cuando la carpeta publica varias
#   ver("112_poblacion_migrante", df = head(d_migracion, 2))   datos a mano
#
#   Editas indicadores/{carpeta}/grafico.R, guardas, repites la llamada. ver()
#   relee el archivo cada vez: no hay que reiniciar nada.
#
# POR QUE EL NAVEGADOR Y NO EL VIEWER
#   El Viewer sirve la pagina desde un temporal, donde www/fonts/asap.css no
#   se alcanza. La vista se escribe en _preview/ dentro del proyecto, a un
#   nivel de www/, y por eso la tipografia Asap carga de verdad.
#
#   _dev/ y _preview/ son taller: no se sourcean desde app.R y no viajan al
#   despliegue.
# ═════════════════════════════════════════════════════════════════════════════

# Contexto de la app: datos, PAL, e_lamina() y los formateadores. Se carga una
# sola vez; volver a sourcear este archivo no repite el trabajo.
if (!exists("PAL")) {
  suppressPackageStartupMessages({
    library(echarts4r); library(dplyr); library(glue)
    library(yaml); library(shiny); library(bslib)
  })
  source("R/00_data.R")
  source("R/10_utils.R")
}


#' Dibujar una lamina en el navegador, con el formato del catalogo
#'
#' @param carpeta Carpeta del indicador, ej. "112_poblacion_migrante".
#' @param numero  Numero de cuadro ("I.4"). Solo hace falta si la carpeta
#'                publica mas de una lamina.
#' @param df      Datos. Por defecto el CSV del propio indicador, que es lo que
#'                le pasa el modulo; se puede sustituir para probar un caso
#'                limite sin tocar el archivo.
#' @param ...     Argumentos extra del dibujo, si la lamina los acepta.
ver <- function(carpeta, numero = NULL, df = NULL, ...) {

  # Releer el grafico.R en su propio entorno, igual que hace R/20_graficos.R: asi
  # una variable auxiliar no queda suelta en el global entre llamada y llamada.
  env <- new.env(parent = globalenv())
  source(file.path("indicadores", carpeta, "grafico.R"), local = env, encoding = "UTF-8")
  laminas <- purrr::set_names(env$laminas, purrr::map_chr(env$laminas, "numero"))

  lam <- if (is.null(numero)) laminas[[1]] else laminas[[numero]]
  if (is.null(lam))
    stop("La carpeta no publica el cuadro '", numero, "'. Tiene: ",
         paste(names(laminas), collapse = ", "))

  if (is.null(df)) df <- IND[[carpeta]]
  grafico <- lam$dibujo(df, ...)

  # La ficha es la de la carpeta, resuelta por el mismo helper que usa la app.
  ficha <- ficha_de(carpeta)

  # El <head> de la app, reconstruido. El orden importa: la fuente antes del
  # estilo, y los dos scripts antes de que se dibuje nada.
  pagina <- htmltools::tagList(
    htmltools::tags$head(
      htmltools::tags$meta(charset = "utf-8"),
      htmltools::tags$link(rel = "stylesheet", href = "../www/fonts/asap.css"),
      htmltools::tags$style(sprintf(
        "body{background:%s;font-family:Asap,sans-serif;margin:0;padding:40px}
         .marco{max-width:820px;margin:auto;background:%s;padding:24px;border:1px solid %s}
         .num{font:12px/1.4 monospace;color:%s}
         h1{font:600 17px/1.3 Asap,sans-serif;color:%s;margin:4px 0 16px}
         .pie{font:11px/1.4 Asap,sans-serif;color:%s;margin-top:12px}",
        PAL$papel, PAL$lamina, PAL$regla, PAL$tinta3, PAL$tinta, PAL$tinta3)),
      script_formato(),
      script_tema_echarts()
    ),
    htmltools::tags$div(
      class = "marco",
      htmltools::tags$div(class = "num", paste(lam$numero, "·", carpeta)),
      # Titulo y fuente salen de la ficha, no del grafico.R: la vista cita la
      # pieza igual que el catalogo.
      htmltools::tags$h1(ficha$nombre),
      grafico,
      htmltools::tags$div(class = "pie", paste("Fuente:", ficha$fuente))
    )
  )

  dir.create("_preview", showWarnings = FALSE)
  ruta <- file.path("_preview", "vista.html")
  htmltools::save_html(pagina, file = ruta, libdir = "lib")
  utils::browseURL(normalizePath(ruta))
  invisible(ruta)
}

cli::cli_alert_success('Listo. {.code ver("112_poblacion_migrante")}')

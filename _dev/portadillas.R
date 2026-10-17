# ═════════════════════════════════════════════════════════════════════════════
# _dev/portadillas.R  —  Tine las fotos de portadilla y la del portal
#
# QUE HACE
#   Toma las fotos originales del Boletin de Estudios Regionales N.2 (UER-UMAG,
#   marzo 2026), recorta cada una a la franja de su portadilla y la tine en el
#   duotono de su capitulo. Deja el resultado en www/img/ como WebP, con su
#   procedencia escrita en el propio archivo (campo de comentario).
#
#   El registro de que foto va en que capitulo, con que bano y con que credito,
#   NO vive aqui: es .PORTADILLAS en R/10_utils.R, que tambien lee portadilla().
#   Aqui solo se declara DE DONDE sale cada foto y DONDE se recorta.
#
# POR QUE NO SE HACE EN LA APP
#   Un duotono es una transformacion de pixeles; hacerla en el navegador con
#   filtros CSS cuesta en cada carga y no se ve igual en todos los motores. Se
#   hace una vez, se revisa una vez y queda.
#
# DEPENDENCIA DE TALLER
#   ImageMagick 7 (`magick`) en el PATH. No es dependencia de la app.
#
# USO
#   Rscript _dev/portadillas.R
#
#   -strip borra lo que el archivo traia embebido, incluida la procedencia que
#   registra impeccable. Despues de correrlo, volver a estamparla:
#     impeccable embed-prompt www/img/cap-i.webp --prompt "sourced: <comentario>"
#   (el comentario lo deja este script: magick identify -format '%c' <archivo>).
# ═════════════════════════════════════════════════════════════════════════════
suppressPackageStartupMessages({ library(shiny); library(purrr); library(cli) })
source("R/10_utils.R")

ORIGEN <- "../_Logos_Plantillas/Plantilla_presentacion_impacto/assets/images/boletin"
DESTINO <- "www/img"
dir.create(DESTINO, showWarnings = FALSE)

# De donde sale cada foto y donde cae su franja.
#   archivo  original del Boletin (ver CREDITOS.md en ORIGEN)
#   pagina   pagina del Boletin, para la procedencia
#   centro   altura del centro de la franja, en fraccion de la foto (0 = arriba)
#   tenida   TRUE si el original ya viene en duotono (la plantilla ya lo tino)
#   realce   opcional: -level que levanta los medios ANTES de tenir. Para fotos
#            oscuras (la estepa del indice), que sin el caen al tono sombra del
#            bano y se leen como noche.
FUENTES <- list(
  I   = list(archivo = "cap_azul.jpg",      pagina = 33, centro = 0.50, tenida = TRUE),
  II  = list(archivo = "cap_rojo.jpg",      pagina = 47, centro = 0.50, tenida = TRUE),
  III = list(archivo = "boletin_portada.jpg", pagina = 1, centro = 0.50, tenida = FALSE),
  IV  = list(archivo = "contraportada.jpg", pagina = 56, centro = 0.58, tenida = FALSE),
  V   = list(archivo = "cap_violeta.jpg",   pagina = 37, centro = 0.58, tenida = TRUE),
  VI  = list(archivo = "archivo.jpg",       pagina = 52, centro = 0.62, tenida = FALSE),
  VII = list(archivo = "indice.jpg",        pagina = 2,  centro = 0.30, tenida = FALSE, realce = "0%,72%")
)

ANCHO <- 1920; ALTO <- 640

magick <- function(...) {
  r <- system2("magick", shQuote(c(...)), stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(r, "status"))) cli_abort(c("magick fallo", i = paste(r, collapse = "\n")))
  invisible(r)
}

# La tabla de color del duotono: sombra -> medio -> luz del bano, en 256 pasos.
clut <- function(bano) {
  f <- tempfile(fileext = ".png")
  magick(paste0("xc:", PAL$bano[[bano]]), "+append", "-filter", "triangle",
         "-resize", "256x1!", f)
  f
}

iwalk(FUENTES, function(src, num) {
  cap <- .PORTADILLAS[[num]]
  entrada <- file.path(ORIGEN, src$archivo)
  salida  <- file.path(DESTINO, cap$foto)
  dims <- as.integer(strsplit(magick("identify", "-format", "%w %h", entrada), " ")[[1]])
  alto_escalado <- round(dims[2] * ANCHO / dims[1])
  y <- max(0, min(alto_escalado - ALTO, round(alto_escalado * src$centro - ALTO / 2)))

  tono <- if (src$tenida) character() else
    c("-colorspace", "gray", if (!is.null(src$realce)) c("-level", src$realce),
      "-colorspace", "sRGB", "-type", "TrueColor",
      "-sigmoidal-contrast", "3x50%", clut(cap$bano), "-clut")
  magick(entrada, "-resize", paste0(ANCHO, "x"),
         "-crop", sprintf("%dx%d+0+%d", ANCHO, ALTO, y), "+repage",
         tono, "-strip",
         "-set", "comment",
         sprintf("origen: Boletin de Estudios Regionales N.2 (UER-UMAG, marzo 2026), p. %d, %s; %s; recorte %dx%d y duotono %s por _dev/portadillas.R",
                 src$pagina, src$archivo, cap$credito, ANCHO, ALTO, cap$bano),
         "-quality", "78", salida)
  cli_alert_success("{num}  {salida}")
})

# La foto del portal: la del indice del Boletin, EN COLOR y en su formato
# vertical. Es la columna izquierda del umbral.
magick(file.path(ORIGEN, "indice.jpg"), "-resize", "900x", "-strip",
       "-set", "comment",
       "origen: Boletin de Estudios Regionales N.2 (UER-UMAG, marzo 2026), p. 2, indice.jpg; fotografias del boletin (creditos p. 2); sin tenir, redimensionada por _dev/portadillas.R",
       "-quality", "80", file.path(DESTINO, "portal-indice.webp"))
cli_alert_success("portal  {file.path(DESTINO, 'portal-indice.webp')}")

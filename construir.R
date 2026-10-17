# ═════════════════════════════════════════════════════════════════════════════
# construir.R — Datos Magallanes
# Plataforma de informacion sobre bienestar y desarrollo regional
# UER · Universidad de Magallanes
#
#   Rscript construir.R          escribe el sitio en _site/
#
# PUNTO DE ENTRADA. Lo corre tambien el GitHub Action que publica el sitio
# (.github/workflows/publicar.yml) en cada push a master.
#
# QUE PRODUCE
#   _site/ es un sitio estatico: paginas HTML, CSS, JS y CSV. No necesita un
#   servidor R; se abre con doble clic o se sube tal cual a cualquier hosting.
#
# COMO SE CARGA EL CODIGO
#   R/ se carga en el orden de sus prefijos, y el orden se ve en el directorio:
#
#     R/00_data.R          registros IND/FICHA/FUENTE/RED, alias d_*, validacion
#     R/10_utils.R         paleta, temas, formateadores, mobiliario, CSV y JSON
#     R/20_graficos.R      barrido de indicadores/*/grafico.R y registro LAM
#     R/30_ui_components.R piezas de interfaz: cuadro, pieza, lienzo, controles
#     R/40_pag_*.R         una funcion por seccion del sitio
#     R/50_sitio.R         chasis de pagina y escritura de _site/
#
#   Regla que esto impone: NINGUN archivo de R/ puede usar, en codigo de nivel
#   superior, algo definido en un archivo de prefijo mayor. Dentro de una
#   funcion (que corre despues, cuando todo ya cargo) no hay restriccion.
#
# NINGUNA CIFRA SE CALCULA EN EL NAVEGADOR
#   Cada dibujo lo hace dibujar() aqui, al construir. El conmutador del cero y
#   los rangos de anos eligen entre dibujos ya hechos (ver lienzo() en
#   R/30_ui_components.R).
#
# DEPENDENCIAS (todas de CRAN): bslib, htmltools, echarts4r, dplyr, purrr,
# stringr, tidyr, yaml, jsonlite, glue, cli, sass, htmlwidgets. Shiny no hace
# falta. igraph solo lo usa _dev/red_fuentes.R, que es de taller.
# ═════════════════════════════════════════════════════════════════════════════

suppressPackageStartupMessages({
  library(htmltools)
  library(bslib)
  library(echarts4r)
  library(dplyr)
  library(glue)
  library(yaml)
})

cli::cli_h1("Datos Magallanes")

for (f in sort(list.files("R", "^[0-9]{2}_.*\\.R$", full.names = TRUE)))
  source(f, encoding = "UTF-8")

escribir_sitio("_site")

local({
  f <- list.files("_site", recursive = TRUE, full.names = TRUE)
  cli::cli_alert_success("Sitio escrito en {.path _site/} ({round(sum(file.size(f)) / 1024^2, 1)} MB)")
})

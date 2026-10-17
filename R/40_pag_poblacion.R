# ═════════════════════════════════════════════════════════════════════════════
# R/40_pag_poblacion.R — Capitulo I: Poblacion
#
# PAGINA: poblacion.html
#
# PIEZAS DE ESTE CAPITULO  (el numero es la direccion de cita del indicador)
#   101  d_pob_total       Poblacion total, serie censal + estimaciones
#   102  d_edad            Distribucion por sexo y grupo de edad
#   103  d_crecimiento     Tasa de crecimiento intercensal, publicada por el INE
#   104  d_natalidad       Tasa de natalidad
#   105  d_mortalidad_general  Tasa de mortalidad general
#   106  d_fecundidad      Tasa global de fecundidad
#   107  d_envejecimiento  Tasa e indice de envejecimiento
#   108  d_densidad        Densidad poblacional
#   112  d_migracion       Poblacion inmigrante internacional
#   113  d_pob_comunas     Poblacion total por comuna
#   Procedencia de cualquiera: ind_carpeta(d_pob_total) (ver R/00_data.R)
#
# DONDE ESTAN LOS GRAFICOS
#   No aqui. Cada lamina vive en la carpeta de su indicador y se alcanza por LAM.
#
#     I.1  indicadores/101_poblacion_total/grafico.R
#     I.2  indicadores/113_poblacion_comunas/grafico.R
#     I.3  indicadores/102_distribucion_sexo_edad/grafico.R
#     I.4  indicadores/112_poblacion_migrante/grafico.R
#     I.5  indicadores/107_envejecimiento/grafico.R
#     I.6  indicadores/104_tasa_natalidad/grafico.R
#     I.7  indicadores/105_tasa_mortalidad_general/grafico.R
#     I.8  indicadores/106_tasa_global_fecundidad/grafico.R
#     I.9  indicadores/108_densidad_poblacional/grafico.R
#
# LA MEDIDA DE VARIACION ES LA QUE PUBLICA LA FUENTE
#   El mundo anterior calculaba un delta en la interfaz para cada fila del
#   resumen. Se retiro: un delta calculado aqui no tiene procedencia. El
#   crecimiento de la poblacion lo publica el INE como indicador propio (103) y
#   es esa cifra la que aparece, citada a su fuente.
# ═════════════════════════════════════════════════════════════════════════════

# Atajo local: las nueve laminas del capitulo, por numero de cuadro.
.I <- list(
  "I.1" = LAM[["101_poblacion_total"]][["I.1"]],
  "I.2" = LAM[["113_poblacion_comunas"]][["I.2"]],
  "I.3" = LAM[["102_distribucion_sexo_edad"]][["I.3"]],
  "I.4" = LAM[["112_poblacion_migrante"]][["I.4"]],
  "I.5" = LAM[["107_envejecimiento"]][["I.5"]],
  "I.6" = LAM[["104_tasa_natalidad"]][["I.6"]],
  "I.7" = LAM[["105_tasa_mortalidad_general"]][["I.7"]],
  "I.8" = LAM[["106_tasa_global_fecundidad"]][["I.8"]],
  "I.9" = LAM[["108_densidad_poblacional"]][["I.9"]]
)

pag_poblacion <- function() {

  # ── Cifras del inventario ──────────────────────────────────────────────────
  # Ultimo valor publicado de cada pieza, tomado en el ano maximo y no en la
  # ultima fila del CSV (ver ultimo_valor() en R/10_utils.R). Cada periodo es
  # el de su propia serie.
  .pob  <- ultimo_valor(d_pob_total, "total")
  .crec <- ultimo_valor(d_crecimiento, "tasa_crecimiento")
  .migr <- ultimo_valor(d_migracion, "inmigrantes")
  .env  <- ultimo_valor(d_envejecimiento, "tasa_env")
  # El indice del MISMO ano que la tasa: califica la cifra de su fila.
  .env_idx <- d_envejecimiento$indice_env[d_envejecimiento$anio == .env$anio]
  .nat  <- ultimo_valor(d_natalidad, "natalidad")
  .mortg <- ultimo_valor(d_mortalidad_general, "mortalidad")
  .fec  <- ultimo_valor(d_fecundidad, "fecundidad")
  .dens <- ultimo_valor(d_densidad, "densidad")

  tagList(
    portadilla("I", "Poblacion",
      "Region de Magallanes y de la Antartica Chilena. Series censales y estimaciones INE.",
      rango = "Indicadores 101-113"),

    pliego(
      # ── Inventario del capitulo ──────────────────────────────────────────
      inventario(
        # La misma advertencia que la portada, en cada capitulo: el navegador
        # recuerda la ultima seccion visitada, asi que un lector habitual puede
        # no volver a pasar por la portada nunca. La advertencia no se retira
        # mientras siga siendo cierta.
        marca = marca_estado("ilustrativo",
                             "Series de prototipo, no cifras oficiales"),
        fila_inventario(101, "Poblacion total", fmt_n(.pob$valor),
          unidad = "habitantes", periodo = .pob$anio,
          # La medida no se calcula: es el indicador 103, publicado por el INE.
          medida = medida_publicada(.crec$valor, "%", "intercensal, indicador 103")),
        fila_inventario(102, "Estructura por sexo y edad", "—",
          glosa = "Se lee en el cuadro I.3; no se resume en una cifra",
          periodo = "Censo 2017"),
        fila_inventario(107, "Tasa de envejecimiento", fmt_n(.env$valor, 1),
          unidad = "%", periodo = .env$anio,
          glosa = "Poblacion de 60 anos y mas",
          # El indice de envejecimiento es la otra medida que la fuente publica
          # para esta misma pieza: no es una variacion, es un segundo angulo.
          medida = tags$span(class = "medida",
            tags$span(class = "medida-cifra", fmt_n(.env_idx, 1)),
            tags$span(class = "medida-glosa", "indice 60+ / 100 menores de 15"))),
        fila_inventario(112, "Poblacion inmigrante", fmt_n(.migr$valor, 1),
          unidad = "%", periodo = .migr$anio,
          glosa = "Sobre la poblacion regional total"),
        fila_inventario(104, "Tasa de natalidad", fmt_n(.nat$valor, 1),
          unidad = "por 1.000 hab.", periodo = .nat$anio),
        fila_inventario(105, "Tasa de mortalidad general", fmt_n(.mortg$valor, 1),
          unidad = "por 1.000 hab.", periodo = .mortg$anio),
        fila_inventario(106, "Tasa global de fecundidad", fmt_n(.fec$valor, 1),
          unidad = "hijos/mujer", periodo = .fec$anio),
        fila_inventario(108, "Densidad poblacional", fmt_n(.dens$valor, 1),
          unidad = "hab/km²", periodo = .dens$anio)
      ),

      # ── Las nueve piezas, plegadas ───────────────────────────────────────
      # Una entrada por pieza, sin excepciones: el catalogo dejo de agrupar
      # cuadros en pares (los antiguos X.a / X.b) y cada indicador se presenta
      # solo, con su propio numero.
      # El valor de cada entrada es el ancla de su cuadro: asi el indice del
      # menu puede abrirla ademas de desplazarse hasta ella.
      piezas_capitulo(
        "acc-pob",
        pieza_cuadro(.I[["I.1"]]),
        pieza_cuadro(.I[["I.2"]]),
        pieza_cuadro(.I[["I.3"]]),
        pieza_cuadro(.I[["I.4"]]),
        pieza_cuadro(.I[["I.5"]]),
        pieza_cuadro(.I[["I.6"]]),
        pieza_cuadro(.I[["I.7"]]),
        pieza_cuadro(.I[["I.8"]]),
        pieza_cuadro(.I[["I.9"]])
      )
    )
  )
}

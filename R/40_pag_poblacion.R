# ═════════════════════════════════════════════════════════════════════════════
# R/40_pag_poblacion.R — Capitulo I: Poblacion
#
# PAGINA: poblacion.html
#
# PIEZAS DE ESTE CAPITULO  (el numero es la direccion de cita del indicador)
#   101  d_pob_total       Poblacion regional segun sexo, serie censal desde 1907
#   102  d_comuna_sexo     Poblacion por comuna y sexo, censos 1992-2024
#   103  d_piramide        Piramide por sexo y edad quinquenal, censos 1992-2024
#   104  d_dependencia     Tasa de dependencia demografica (total, infantil, mayores)
#   105  d_envejecimiento  Indice de envejecimiento (60+ y 65+ por 100 menores de 15)
#   106  d_fecundidad      Tasa global de fecundidad
#   107  d_natalidad       Tasa bruta de natalidad
#   108  d_esperanza_vida  Esperanza de vida al nacer, segun sexo
#   109  d_mortalidad_general  Tasa bruta de mortalidad
#   110  d_mortalidad_infantil  Tasa de mortalidad infantil, por sexo
#   111  d_mortalidad_menores5  Tasa de mortalidad en menores de 5 anos, por sexo
#   112  d_urbana_rural    Poblacion urbana y rural, censos 1992-2024
#   113  d_crecimiento     Tasa de crecimiento intercensal, publicada por el INE
#   114  d_densidad        Densidad poblacional
#   117  d_migracion       Poblacion inmigrante internacional
#   Procedencia de cualquiera: ind_carpeta(d_pob_total) (ver R/00_data.R)
#
# DONDE ESTAN LOS GRAFICOS
#   No aqui. Cada lamina vive en la carpeta de su indicador y se alcanza por LAM.
#
#     I.1  indicadores/101_poblacion_regional_segun_sexo/grafico.R
#     I.2  indicadores/103_poblacion_regional_piramide/grafico.R
#     I.3  indicadores/102_poblacion_segun_comuna_sexo/grafico.R
#     I.4  indicadores/104_tasa_dependencia_demografica/grafico.R
#     I.5  indicadores/105_envejecimiento/grafico.R
#     I.6  indicadores/106_tasa_global_fecundidad/grafico.R
#     I.7  indicadores/107_tasa_bruta_natalidad/grafico.R
#     I.8  indicadores/108_esperanza_vida/grafico.R
#     I.9  indicadores/109_tasa_bruta_mortalidad/grafico.R
#     I.10 indicadores/110_tasa_mortalidad_infantil/grafico.R
#     I.11 indicadores/111_tasa_mortalidad_menores_5/grafico.R
#     I.12 indicadores/112_poblacion_urbana_rural/grafico.R
#     I.13 indicadores/114_densidad_poblacional/grafico.R
#     I.14 indicadores/117_poblacion_migrante/grafico.R
#
# LA MEDIDA DE VARIACION ES LA QUE PUBLICA LA FUENTE
#   El mundo anterior calculaba un delta en la interfaz para cada fila del
#   resumen. Se retiro: un delta calculado aqui no tiene procedencia. El
#   crecimiento de la poblacion lo publica el INE como indicador propio (113) y
#   es esa cifra la que aparece, citada a su fuente.
# ═════════════════════════════════════════════════════════════════════════════

# Atajo local: las catorce laminas del capitulo, por numero de cuadro.
.I <- list(
  "I.1" = LAM[["101_poblacion_regional_segun_sexo"]][["I.1"]],
  "I.2" = LAM[["103_poblacion_regional_piramide"]][["I.2"]],
  "I.3" = LAM[["102_poblacion_segun_comuna_sexo"]][["I.3"]],
  "I.4" = LAM[["104_tasa_dependencia_demografica"]][["I.4"]],
  "I.5" = LAM[["105_envejecimiento"]][["I.5"]],
  "I.6" = LAM[["106_tasa_global_fecundidad"]][["I.6"]],
  "I.7" = LAM[["107_tasa_bruta_natalidad"]][["I.7"]],
  "I.8" = LAM[["108_esperanza_vida"]][["I.8"]],
  "I.9" = LAM[["109_tasa_bruta_mortalidad"]][["I.9"]],
  "I.10" = LAM[["110_tasa_mortalidad_infantil"]][["I.10"]],
  "I.11" = LAM[["111_tasa_mortalidad_menores_5"]][["I.11"]],
  "I.12" = LAM[["112_poblacion_urbana_rural"]][["I.12"]],
  "I.13" = LAM[["114_densidad_poblacional"]][["I.13"]],
  "I.14" = LAM[["117_poblacion_migrante"]][["I.14"]]
)

pag_poblacion <- function() {

  # ── Cifras del inventario ──────────────────────────────────────────────────
  # Ultimo valor publicado de cada pieza, tomado en el ano maximo y no en la
  # ultima fila del CSV (ver ultimo_valor() en R/10_utils.R). Cada periodo es
  # el de su propia serie.
  .pob  <- ultimo_valor(d_pob_total, "total")
  .crec <- ultimo_valor(d_crecimiento, "tasa_crecimiento")
  .migr <- ultimo_valor(d_migracion, "inmigrantes")
  # La proporcion urbana la publica el censo; los conteos del MISMO censo la califican.
  .urb  <- ultimo_valor(d_urbana_rural, "pct_urbana")
  .urb_fila <- d_urbana_rural[d_urbana_rural$anio == .urb$anio, ]
  .env  <- ultimo_valor(d_envejecimiento, "indice_60")
  # El umbral 65+ del MISMO ano: califica la cifra de su fila.
  .env_65 <- d_envejecimiento$indice_65[d_envejecimiento$anio == .env$anio]
  .nat  <- ultimo_valor(d_natalidad, "natalidad")
  .mortg <- ultimo_valor(d_mortalidad_general, "mortalidad")
  .fec  <- ultimo_valor(d_fecundidad, "fecundidad")
  .dens <- ultimo_valor(d_densidad, "densidad")
  # Las tres series por sexo publican el total; hombres y mujeres del MISMO
  # ano califican la cifra de su fila.
  .esp  <- ultimo_valor(d_esperanza_vida, "total")
  .minf <- ultimo_valor(d_mortalidad_infantil, "total")
  .m5   <- ultimo_valor(d_mortalidad_menores5, "total")
  .por_sexo <- function(df, anio) {
    fila <- df[df$anio == anio, ]
    paste0("Hombres ", fmt_n(fila$hombres, 1), " · mujeres ", fmt_n(fila$mujeres, 1))
  }
  .dep  <- ultimo_valor(d_dependencia, "dep_total")
  # Las dos componentes del MISMO ano que la total: califican la cifra de su fila.
  .dep_inf <- d_dependencia$dep_infantil[d_dependencia$anio == .dep$anio]
  .dep_may <- d_dependencia$dep_mayores[d_dependencia$anio == .dep$anio]

  # ── Selectores de censo de I.2 y I.3 ───────────────────────────────────────
  # Cada censo se dibuja aqui, al construir; el navegador solo elige cual
  # mostrar (ver corte_anio() en R/30_ui_components.R). La piramide suma la
  # opcion de ver los cuatro censos superpuestos.
  .piramide <- corte_anio("pob_piramide", d_piramide$anio, "Censo",
                          todos = "Superpuestos")
  .censo <- corte_anio("pob_censo", d_comuna_sexo$anio, "Censo")

  tagList(
    portadilla("I", "Poblacion",
      "Region de Magallanes y de la Antartica Chilena. Series censales y estimaciones INE.",
      rango = "Indicadores 101-117"),

    pliego(
      # ── Inventario del capitulo ──────────────────────────────────────────
      inventario(
        # La misma advertencia que la portada, en cada capitulo: el navegador
        # recuerda la ultima seccion visitada, asi que un lector habitual puede
        # no volver a pasar por la portada nunca. La advertencia no se retira
        # mientras siga siendo cierta.
        marca = if (isTRUE(.PROTOTIPO)) marca_estado("ilustrativo",
                                                 "Series de prototipo, no cifras oficiales"),
        # Una fila por cuadro, en el orden de los cuadros: el numero de la fila
        # es el del cuadro que resume (lo toma de la lamina).
        fila_inventario(.I[["I.1"]], "Poblacion regional segun sexo", fmt_n(.pob$valor),
          unidad = "habitantes", periodo = .pob$anio, glosa = "Total, ambos sexos",
          # La medida no se calcula: es el indicador 113, publicado por el INE.
          medida = medida_publicada(.crec$valor, "%", "intercensal, indicador 113")),
        fila_inventario(.I[["I.2"]], "Piramide de poblacion regional", "—",
          glosa = "Se lee en el cuadro I.2: % por sexo y edad quinquenal",
          periodo = "Censos 1992-2024"),
        fila_inventario(.I[["I.3"]], "Poblacion segun comuna y sexo", "—",
          glosa = "Se lee en el cuadro I.3; no se resume en una cifra",
          periodo = "Censos 1992-2024"),
        fila_inventario(.I[["I.4"]], "Tasa de dependencia demografica", fmt_n(.dep$valor, 1),
          unidad = "por 100 de 15-64", periodo = .dep$anio,
          glosa = paste0("Infantil ", fmt_n(.dep_inf, 1), " · adultos mayores ",
                         fmt_n(.dep_may, 1))),
        fila_inventario(.I[["I.5"]], "Tasa de envejecimiento", fmt_n(.env$valor, 1),
          unidad = "por 100 menores de 15", periodo = .env$anio,
          glosa = "Personas de 60 anos y mas",
          # El umbral 65+ es la otra serie que publica esta misma pieza: no es
          # una variacion, es un segundo corte de la misma razon.
          medida = tags$span(class = "medida",
            tags$span(class = "medida-cifra", fmt_n(.env_65, 1)),
            tags$span(class = "medida-glosa", "con umbral de 65 anos y mas"))),
        fila_inventario(.I[["I.6"]], "Tasa global de fecundidad", fmt_n(.fec$valor, 1),
          unidad = "hijos/mujer", periodo = .fec$anio),
        fila_inventario(.I[["I.7"]], "Tasa bruta de natalidad", fmt_n(.nat$valor, 1),
          unidad = "por 1.000 hab.", periodo = .nat$anio),
        fila_inventario(.I[["I.8"]], "Esperanza de vida al nacer", fmt_n(.esp$valor, 1),
          unidad = "anos", periodo = .esp$anio,
          glosa = .por_sexo(d_esperanza_vida, .esp$anio)),
        fila_inventario(.I[["I.9"]], "Tasa bruta de mortalidad", fmt_n(.mortg$valor, 1),
          unidad = "por 1.000 hab.", periodo = .mortg$anio),
        fila_inventario(.I[["I.10"]], "Tasa de mortalidad infantil", fmt_n(.minf$valor, 1),
          unidad = "por mil nacidos vivos", periodo = .minf$anio,
          glosa = .por_sexo(d_mortalidad_infantil, .minf$anio)),
        fila_inventario(.I[["I.11"]], "Tasa de mortalidad en menores de 5 anos", fmt_n(.m5$valor, 1),
          unidad = "por mil nacidos vivos", periodo = .m5$anio,
          glosa = .por_sexo(d_mortalidad_menores5, .m5$anio)),
        fila_inventario(.I[["I.12"]], "Poblacion urbana", fmt_n(.urb$valor, 1),
          unidad = "%", periodo = .urb$anio,
          glosa = paste0("Urbana ", fmt_n(.urb_fila$urbana), " hab. · rural ",
                         fmt_n(.urb_fila$rural), " hab. (", fmt_n(.urb_fila$pct_rural, 1), "%)")),
        fila_inventario(.I[["I.13"]], "Densidad poblacional", fmt_n(.dens$valor, 1),
          unidad = "hab/km²", periodo = .dens$anio),
        fila_inventario(.I[["I.14"]], "Poblacion inmigrante", fmt_n(.migr$valor, 1),
          unidad = "%", periodo = .migr$anio,
          glosa = "Sobre la poblacion regional total")
      ),

      # ── Las catorce piezas, plegadas ────────────────────────────────────
      # Una entrada por pieza, sin excepciones: el catalogo dejo de agrupar
      # cuadros en pares (los antiguos X.a / X.b) y cada indicador se presenta
      # solo, con su propio numero.
      # El valor de cada entrada es el ancla de su cuadro: asi el indice del
      # menu puede abrirla ademas de desplazarse hasta ella.
      piezas_capitulo(
        "acc-pob",
        pieza_cuadro(.I[["I.1"]]),
        pieza_cuadro(.I[["I.2"]], controles = .piramide$controles, rango = .piramide),
        pieza_cuadro(.I[["I.3"]], controles = .censo$controles, rango = .censo),
        pieza_cuadro(.I[["I.4"]]),
        pieza_cuadro(.I[["I.5"]]),
        pieza_cuadro(.I[["I.6"]]),
        pieza_cuadro(.I[["I.7"]]),
        pieza_cuadro(.I[["I.8"]]),
        pieza_cuadro(.I[["I.9"]]),
        pieza_cuadro(.I[["I.10"]]),
        pieza_cuadro(.I[["I.11"]]),
        pieza_cuadro(.I[["I.12"]]),
        pieza_cuadro(.I[["I.13"]]),
        pieza_cuadro(.I[["I.14"]])
      )
    )
  )
}

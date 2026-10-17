# ═════════════════════════════════════════════════════════════════════════════
# indicadores/107_envejecimiento/grafico.R
#
# Laminas del indicador 107, Tasa de envejecimiento demografico.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.5",
    nota   = paste("Tasa: porcentaje de poblacion de 60 anos y mas.",
                   "Indice: personas de 60+ por cada 100 menores de 15."),

    # Dos medidas, dos escalas: tasa (%) e indice (razon) no comparten unidad,
    # de ahi el eje secundario.
    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(tasa_env,   name = "Tasa (% de 60+)", symbol = "circle") |>
        e_line(indice_env, name = "Indice (60+ por 100 menores de 15)",
               symbol = "circle", y_index = 1) |>   # y_index 1 = eje derecho
        e_lamina() |>
        e_x_axis(type = "category") |>
        e_y_axis(index = 0, min = 0, axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_y_axis(index = 1, min = 0) |>
        e_legend(bottom = 0) |>
        # Con dos unidades distintas, un sufijo unico mentiria sobre una de las
        # dos series: tip_eje() admite un sufijo por serie.
        e_tooltip(trigger = "axis", formatter = tip_eje(1, c("%", "")))
    }
  )
)

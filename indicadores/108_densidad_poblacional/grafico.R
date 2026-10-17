# ═════════════════════════════════════════════════════════════════════════════
# indicadores/108_densidad_poblacional/grafico.R
#
# Laminas del indicador 108, Densidad poblacional.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.9",
    nota   = "Serie 2017-2024 segun los Informes Anuales de Medio Ambiente del INE.",

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(densidad, name = "Densidad", symbol = "circle") |>
        # Area con el cero como base: la densidad no puede ser negativa y el
        # cero es su referencia real.
        e_lamina(area = TRUE) |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(1))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, " hab./km²"))
    }
  )
)

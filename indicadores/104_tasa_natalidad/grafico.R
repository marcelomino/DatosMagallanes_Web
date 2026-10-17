# ═════════════════════════════════════════════════════════════════════════════
# indicadores/104_tasa_natalidad/grafico.R
#
# Laminas del indicador 104, Tasa bruta de natalidad.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.6",
    nota   = paste("Tasa bruta: nacidos vivos por 1.000 habitantes, sin",
                   "ajustar por edad de la madre."),

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(natalidad, name = "Natalidad", symbol = "circle") |>
        # Area con el cero como base: la tasa por 1.000 habitantes no puede
        # ser negativa y el cero es su referencia real.
        e_lamina(area = TRUE) |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(1))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, " por mil hab."))
    }
  )
)

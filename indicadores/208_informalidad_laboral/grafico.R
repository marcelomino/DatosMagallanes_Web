# ═════════════════════════════════════════════════════════════════════════════
# indicadores/208_informalidad_laboral/grafico.R
#
# Laminas del indicador 208, Tasa de informalidad laboral.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "II.7",

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(informalidad, name = "Informalidad", symbol = "circle") |>
        e_lamina() |>
        # Eje de categorias: las rondas CASEN no estan igualmente espaciadas.
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, "%"))
    }
  )
)

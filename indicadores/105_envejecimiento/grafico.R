# ═════════════════════════════════════════════════════════════════════════════
# indicadores/105_envejecimiento/grafico.R
#
# Laminas del indicador 105, Tasa de envejecimiento demografico.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.5",
    nota   = paste("Personas mayores por cada 100 menores de 15 anos, con dos",
                   "umbrales de persona mayor: 60 y 65 anos."),

    # Las dos series comparten unidad (por 100 menores de 15): un solo eje. El
    # 100 es el punto en que mayores y menores de 15 se igualan.
    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(indice_60, name = "60 anos y mas", symbol = "circle") |>
        e_line(indice_65, name = "65 anos y mas", symbol = "circle") |>
        e_datum(100, "Paridad") |>
        e_lamina() |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(0))) |>
        e_legend(bottom = 0) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, " por 100"))
    }
  )
)

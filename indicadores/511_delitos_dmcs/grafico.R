# ═════════════════════════════════════════════════════════════════════════════
# indicadores/511_delitos_dmcs/grafico.R
#
# Laminas del indicador 511, Delitos de mayor connotacion social.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "V.3",
    nota   = "Tasa por cada 100.000 habitantes.",

    # Barras y no linea: son conteos anuales discretos, no una magnitud que
    # evolucione de forma continua entre anos.
    dibujo = function(df) {
      df |>
        # Eje de categorias: los anos no siempre vienen a intervalos regulares
        # y un eje de valor los espaciaria de forma enganosa.
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_bar(tasa, name = "Tasa", itemStyle = list(color = PAL$azul)) |>
        e_lamina() |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(0))) |>
        e_labels(show = TRUE, color = PAL$tinta, position = "top",
                 formatter = rotulo_cifra(1)) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, " por 100.000 hab."))
    }
  )
)

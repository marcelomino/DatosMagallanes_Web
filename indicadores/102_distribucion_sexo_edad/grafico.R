# ═════════════════════════════════════════════════════════════════════════════
# indicadores/102_distribucion_sexo_edad/grafico.R
#
# Laminas del indicador 102, Distribucion de la poblacion por sexo y edad.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.3",
    nota   = "Porcentaje sobre la poblacion total regional.",

    dibujo = function(df) {
      df |>
        # El truco de la piramide: los hombres se grafican en negativo para que
        # sus barras crezcan hacia la izquierda del cero.
        dplyr::mutate(hombre_neg = -hombre) |>
        e_charts(grupo) |>
        # barGap "-100%": las dos series se superponen en la misma fila.
        e_bar(hombre_neg, name = "Hombres", barGap = "-100%") |>
        e_bar(mujer,      name = "Mujeres", barGap = "-100%") |>
        e_flip_coords() |>
        e_lamina() |>
        e_color(tintas_serie(2)) |>
        # Eje simetrico y rotulos en valor absoluto: el signo negativo es un
        # recurso de dibujo, no un dato que el lector deba ver.
        e_x_axis(min = -18, max = 18,
                 axisLabel = list(formatter = eje_cifra(0, "%", abs = TRUE))) |>
        e_y_axis(axisLabel = list(interval = 0)) |>
        e_legend(bottom = 0) |>
        # idx = 0 porque el grafico esta volteado, y abs porque los hombres se
        # graficaron en negativo: el lector lee dos porcentajes positivos, uno
        # por sexo. El signo es un recurso de dibujo, no un dato.
        e_tooltip(trigger = "axis", axisPointer = list(type = "shadow"),
                  formatter = tip_eje(1, "%", idx = 0, abs = TRUE))
    }
  )
)

# ═════════════════════════════════════════════════════════════════════════════
# indicadores/404_anos_escolaridad/grafico.R
#
# Laminas del indicador 404, Promedio de anos de escolaridad de la poblacion
# adulta. El titulo del cuadro y la fuente al pie salen de la ficha.yaml de
# esta misma carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "IV.4",

    dibujo = function(df) {
      eje <- eje_holgado(df$escolaridad, 1)
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(escolaridad, name = "Escolaridad promedio", symbol = "circle") |>
        # Sin area: el eje no parte en cero y un relleno sobre esa base leeria
        # como magnitud lo que solo es el recorte del eje.
        e_lamina() |>
        e_x_axis(type = "category") |>
        # El eje no ancla en cero: la escolaridad promedio se mueve en un
        # rango estrecho (10 a 13 anos) y el cero la aplastaria contra el
        # techo.
        e_y_axis(min = eje$min, max = eje$max, interval = eje$interval,
                 axisLabel = list(formatter = eje_cifra(0, " a"))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, " anos"))
    }
  )
)

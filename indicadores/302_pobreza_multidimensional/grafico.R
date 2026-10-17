# ═════════════════════════════════════════════════════════════════════════════
# indicadores/302_pobreza_multidimensional/grafico.R
#
# Laminas del indicador 302, Tasa de pobreza multidimensional.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
#
# El eje fijo 0-12 es el mismo que declara la lamina III.1: las dos series
# compartian un cuadro hasta septiembre de 2026 y el rango comun es lo que
# conserva la comparacion. Ver el encabezado de 301_pobreza/grafico.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "III.2",

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(pobreza_multi, name = "Multidimensional", symbol = "circle") |>
        e_lamina() |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, max = 12, interval = 3,
                 axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, "%"))
    }
  )
)

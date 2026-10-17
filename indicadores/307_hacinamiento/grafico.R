# ═════════════════════════════════════════════════════════════════════════════
# indicadores/307_hacinamiento/grafico.R
#
# Lamina del indicador 307, Tasa de hacinamiento habitacional.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
#
# SERIE IRREGULAR, EJE DE CATEGORIAS
#   Los levantamientos CASEN de esta serie (2013, 2015, 2017, 2020, 2022) no
#   estan igualmente espaciados en el tiempo, asi que el eje declara
#   type = "category" en vez de dejar que ECharts infiera un eje temporal
#   continuo -- el mismo tratamiento que usa 301_pobreza para su serie CASEN.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "III.5",

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(hacinamiento, name = "Hacinamiento", symbol = "circle") |>
        e_lamina() |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, "%"))
    }
  )
)

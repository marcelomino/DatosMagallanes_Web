# ═════════════════════════════════════════════════════════════════════════════
# indicadores/308_deficit_habitacional/grafico.R
#
# Lamina del indicador 308, Proporcion de hogares con deficit habitacional
# cuantitativo. El titulo del cuadro y la fuente al pie salen de la
# ficha.yaml de esta misma carpeta; aqui no se escriben. Ver R/20_graficos.R.
#
# SERIE LARGA E IRREGULAR, EJE DE CATEGORIAS
#   Trece levantamientos CASEN entre 1996 y 2024, sin espaciado regular (los
#   intervalos van de 2 a 3 anos), asi que el eje declara type = "category"
#   -- el mismo tratamiento que 301_pobreza y 307_hacinamiento para sus series
#   CASEN.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "III.6",

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(deficit_habitacional, name = "Deficit habitacional", symbol = "circle") |>
        e_lamina() |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, "%"))
    }
  )
)

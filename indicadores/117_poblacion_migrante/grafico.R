# ═════════════════════════════════════════════════════════════════════════════
# indicadores/117_poblacion_migrante/grafico.R
#
# Laminas del indicador 117, Proporcion de poblacion migrante.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.14",

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(inmigrantes, name = "% de la poblacion", symbol = "circle") |>
        e_lamina(area = TRUE) |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, "%"))
    }
  )
)

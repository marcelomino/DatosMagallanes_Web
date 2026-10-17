# ═════════════════════════════════════════════════════════════════════════════
# indicadores/203_empresas/grafico.R
#
# Laminas del indicador 203, Numero de empresas por area de actividad economica.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "II.6",

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(empresas, name = "Empresas", symbol = "circle") |>
        e_lamina(area = TRUE) |>
        e_x_axis(type = "category") |>
        e_y_axis(axisLabel = list(formatter = eje_cifra(0, "k", div = 1000))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(0, " empresas"))
    }
  )
)

# ═════════════════════════════════════════════════════════════════════════════
# indicadores/112_poblacion_urbana_rural/grafico.R
#
# Laminas del indicador 112, Poblacion urbana y rural.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.12",
    nota   = "Censos de intervalo irregular: la distancia entre barras no es constante.",

    # Barras apiladas: urbana y rural son las dos partes del total censal, y la
    # altura de cada barra es la poblacion regional del cuadro I.1.
    dibujo = function(df) {
      df |>
        # El censo como texto + eje de categorias, como en la I.1.
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_bar(urbana, name = "Urbana", stack = "area") |>
        e_bar(rural,  name = "Rural",  stack = "area") |>
        e_lamina() |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(0, "k", div = 1000))) |>
        e_legend(bottom = 0) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(0, " hab."))
    }
  )
)

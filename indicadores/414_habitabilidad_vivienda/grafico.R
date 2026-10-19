# ═════════════════════════════════════════════════════════════════════════════
# indicadores/414_habitabilidad_vivienda/grafico.R
#
# Laminas del indicador 414, Indice de habitabilidad de la vivienda.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "IV.2",

    # Categorias SIN orden intrinseco: tono plano. El grafico se ordena por
    # magnitud, que ya se lee en el largo de la barra.
    dibujo = function(df) {
      df |>
        dplyr::arrange(valor) |>
        e_charts(categoria) |>
        e_bar(valor, name = "% de hogares", itemStyle = list(color = PAL$azul)) |>
        e_flip_coords() |>
        e_lamina() |>
        e_y_axis(axisLabel = list(interval = 0)) |>
        e_x_axis(max = 50, axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_labels(show = TRUE, color = PAL$tinta, position = "right",
                 formatter = rotulo_cifra(1, "%", idx = 0)) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "item", formatter = tip_item(1, "%", idx = 0))
    }
  )
)

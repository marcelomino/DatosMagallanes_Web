# ═════════════════════════════════════════════════════════════════════════════
# indicadores/402_matricula/grafico.R
#
# Laminas del indicador 402, Tasa neta de matricula por nivel educativo.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "IV.1",
    # 250px y no los 270 de antes: al separarse la mortalidad infantil, el
    # capitulo paso de tres cuadros a cuatro, en dos filas de dos. Los cuatro
    # comparten alto para que cada fila quede pareja.

    # Niveles CON orden (basica -> media -> superior): rampa_orden() acompana esa
    # progresion. El orden del grafico es el del CSV, no por magnitud.
    dibujo = function(df) {
      df |>
        e_charts(nivel) |>
        e_bar(cobertura, name = "Cobertura",
              itemStyle = list(color = color_por_barra(rampa_orden(nrow(df))))) |>
        e_lamina() |>
        e_x_axis(type = "category", axisLabel = list(interval = 0)) |>
        # Eje fijo 0-100: es una cobertura, y el techo del 100% es informacion.
        e_y_axis(min = 0, max = 100, axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_labels(show = TRUE, color = PAL$tinta, position = "top",
                 formatter = rotulo_cifra(1, "%")) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "item", formatter = tip_item(1, "%"))
    }
  )
)

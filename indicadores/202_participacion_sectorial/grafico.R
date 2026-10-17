# ═════════════════════════════════════════════════════════════════════════════
# indicadores/202_participacion_sectorial/grafico.R
#
# Laminas del indicador 202, Participacion sectorial en el PIB.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "II.5",
    nota   = "Participacion porcentual en el PIB regional.",

    dibujo = function(df) {
      df |>
        # Ascendente: con e_flip_coords() el sector mayor queda arriba.
        dplyr::arrange(valor) |>
        e_charts(sector) |>
        # Tono plano: los sectores no tienen orden intrinseco, y graduar el
        # color inventaria una jerarquia que el dato no tiene. El orden del
        # grafico es por magnitud, que ya se lee en el largo de la barra.
        e_bar(valor, name = "% del PIB", itemStyle = list(color = PAL$azul)) |>
        e_flip_coords() |>
        e_lamina() |>
        e_y_axis(axisLabel = list(interval = 0)) |>   # rotular todos los sectores
        e_x_axis(max = 30, axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        # left 34%: los nombres de sector son largos y necesitan margen.
        # Valor al final de cada barra: con pocas categorias es mas legible que
        # obligar al lector a estimar contra el eje.
        # Sin decimales: la fuente publica esta participacion en enteros
        # (22, 15, 18, ...). Un "25,0%" seria precision que el dato no trae.
        e_labels(show = TRUE, color = PAL$tinta, position = "right",
                 formatter = rotulo_cifra(0, "%", idx = 0)) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "item", formatter = tip_item(0, "%", idx = 0))
    }
  )
)

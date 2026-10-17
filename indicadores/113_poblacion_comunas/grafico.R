# ═════════════════════════════════════════════════════════════════════════════
# indicadores/113_poblacion_comunas/grafico.R
#
# Laminas del indicador 113, Poblacion total por comuna.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.2",

    # Barras horizontales ordenadas: categorias CON orden, asi que rampa_orden()
    # de clara a plena, y no un tono plano.
    dibujo = function(df) {
      df |>
        # Ascendente porque e_flip_coords() invierte el eje: la barra mayor
        # queda arriba.
        dplyr::arrange(pob) |>
        e_charts(comuna) |>
        e_bar(pob, name = "Habitantes",
              # ECharts pinta la serie de un color; variar barra a barra exige
              # una funcion JS que resuelva el color por indice de dato.
              itemStyle = list(color = color_por_barra(rampa_orden(nrow(df))))) |>
        e_flip_coords() |>
        e_lamina() |>
        e_y_axis(axisLabel = list(interval = 0)) |>   # rotular todas las comunas
        e_x_axis(axisLabel = list(formatter = eje_cifra(0, "k", div = 1000))) |>
        # left 22% para los nombres de comuna, que son largos; right 17% para
        # la cifra al final de la barra.
        # Sin esta cifra, las seis comunas menores se leen como cero: sus barras
        # miden menos de un pixel frente a Punta Arenas. La escala no se toca
        # —transformarla seria publicar un nivel que la fuente no publica—, se
        # declara el valor. Es ademas el trato que ya reciben los otros tres
        # graficos de barras volteados del catalogo.
        e_labels(show = TRUE, color = PAL$tinta, position = "right",
                 formatter = rotulo_cifra(0, idx = 0)) |>
        e_legend(show = FALSE) |>
        # idx = 0: e_flip_coords() ya intercambio los ejes, y el valor quedo
        # en la primera posicion del par.
        e_tooltip(trigger = "item", formatter = tip_item(0, " hab.", idx = 0))
    }
  )
)

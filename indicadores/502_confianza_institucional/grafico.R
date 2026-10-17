# ═════════════════════════════════════════════════════════════════════════════
# indicadores/502_confianza_institucional/grafico.R
#
# Laminas del indicador 502, Confianza declarada en instituciones.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "V.1",
    nota   = paste("Porcentaje que declara mucha o bastante confianza.",
                   "La linea marca el 50%."),

    # LA LINEA DEL 50%
    #   Es el datum contra el que se lee la barra, no un dato mas. En este mundo
    #   el violeta no baja al cuerpo de la pagina, asi que la linea va en tinta
    #   suave punteada: se distingue por trazo, no por color.
    dibujo = function(df) {
      df |>
        # Ascendente: con e_flip_coords() la institucion mas confiable queda
        # arriba. Al ordenar por magnitud, la rampa acompana un orden real.
        dplyr::arrange(confianza) |>
        e_charts(institucion) |>
        e_bar(confianza, name = "Confianza",
              itemStyle = list(color = color_por_barra(rampa_orden(nrow(df))))) |>
        e_flip_coords() |>
        e_lamina() |>
        e_y_axis(axisLabel = list(interval = 0)) |>   # rotular todas las instituciones
        # Eje fijo 0-100: es un porcentaje de respuestas y el marco completo
        # importa para juzgar cuan alta es cada barra.
        e_x_axis(min = 0, max = 100, axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_labels(show = TRUE, color = PAL$tinta, position = "right",
                 formatter = rotulo_cifra(0, "%", idx = 0)) |>
        # El datum del grafico. Va en xAxis porque el grafico esta volteado.
        e_mark_line(data = list(xAxis = 50), symbol = "none", silent = TRUE,
                    lineStyle = list(color = PAL$tinta3, type = "dashed", width = 1.2),
                    label = list(show = TRUE, formatter = "50%", color = PAL$tinta2,
                                 fontSize = 11, fontFamily = "Asap, sans-serif")) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "item", formatter = tip_item(0, "%", idx = 0))
    }
  )
)

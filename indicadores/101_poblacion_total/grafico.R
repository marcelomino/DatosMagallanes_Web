# ═════════════════════════════════════════════════════════════════════════════
# indicadores/101_poblacion_total/grafico.R
#
# Laminas del indicador 101, Poblacion total.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.1",
    nota   = paste("Serie censal de intervalo irregular: la distancia entre",
                   "puntos no es constante."),

    # Serie unica: se rellena con area para darle cuerpo sin agregar un dato
    # que no existe.
    dibujo = function(df) {
      df |>
        # El ano como texto + eje de categorias: los saltos censales son
        # irregulares y un eje temporal continuo los espaciaria enganosamente.
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(total, name = "Habitantes", symbol = "circle") |>
        e_lamina(area = TRUE) |>
        e_x_axis(type = "category") |>
        # Los habitantes se abrevian en miles sobre el eje; el tooltip da la
        # cifra completa, que es la que el lector se lleva al informe.
        e_y_axis(axisLabel = list(formatter = eje_cifra(0, "k", div = 1000))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(0, " hab."))
    }
  )
)

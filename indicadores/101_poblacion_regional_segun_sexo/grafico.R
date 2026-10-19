# ═════════════════════════════════════════════════════════════════════════════
# indicadores/101_poblacion_regional_segun_sexo/grafico.R
#
# Laminas del indicador 101, Poblacion regional segun sexo.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.1",
    nota   = paste("Serie censal de intervalo irregular: la distancia entre",
                   "puntos no es constante."),

    # Tres series en la misma unidad y la misma escala. El total va primero para
    # tomar el magenta de serie protagonista; hombres y mujeres siguen en el
    # orden de PAL$serie. Sin area apilada: apilar obligaria a leer cada serie
    # como diferencia de la anterior.
    dibujo = function(df) {
      df |>
        # El ano como texto + eje de categorias: los saltos censales son
        # irregulares y un eje temporal continuo los espaciaria enganosamente.
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(total,   name = "Total",   symbol = "circle") |>
        e_line(hombres, name = "Hombres", symbol = "circle") |>
        e_line(mujeres, name = "Mujeres", symbol = "circle") |>
        e_lamina() |>
        e_x_axis(type = "category") |>
        # Los habitantes se abrevian en miles sobre el eje; el tooltip da la
        # cifra completa, que es la que el lector se lleva al informe.
        e_y_axis(axisLabel = list(formatter = eje_cifra(0, "k", div = 1000))) |>
        e_legend(bottom = 0) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(0, " hab."))
    }
  )
)

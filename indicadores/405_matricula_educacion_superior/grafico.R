# ═════════════════════════════════════════════════════════════════════════════
# indicadores/405_matricula_educacion_superior/grafico.R
#
# Laminas del indicador 405, Matricula total en educacion superior.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "IV.7",
    nota   = paste("Registros de matricula, no personas unicas: 1984-2006 con",
                   "bases DIVESUP, desde 2007 con recoleccion directa SIES."),

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(matricula, name = "Matricula", symbol = "circle") |>
        # Area con el eje anclado en cero: la matricula es un conteo, y el
        # relleno si lee como magnitud cuando la base es el cero real.
        e_lamina(area = TRUE) |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(0))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(0, " registros"))
    }
  )
)

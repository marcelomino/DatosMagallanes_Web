# ═════════════════════════════════════════════════════════════════════════════
# indicadores/216_tasa_ocupacion/grafico.R
#
# Laminas del indicador 216, Tasa de ocupacion.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
#
# POR QUE NO COMPARTE EJE CON EL DESEMPLEO
#   Ocupacion (~57%) y desempleo (~6%) no son complementarias: la primera se
#   calcula sobre la poblacion en edad de trabajar y la segunda sobre la fuerza
#   de trabajo, de modo que no suman cien. Un eje comun invitaria a leerlas como
#   partes de un mismo total. Cada cuadro declara su propia escala.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "II.3",

    dibujo = function(df) {
      eje <- eje_holgado(df$ocupacion, 5)
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(ocupacion, name = "Tasa de ocupacion", symbol = "circle") |>
        # Sin area: el eje no parte en cero y un relleno sobre esa base leeria
        # como magnitud lo que solo es el recorte del eje.
        e_lamina() |>
        e_x_axis(type = "category") |>
        # El eje no ancla en cero: la tasa se mueve en un tramo alto y
        # estrecho (52-59%) y el cero la aplastaria contra el techo.
        e_y_axis(min = eje$min, max = eje$max, interval = eje$interval,
                 axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, "%"))
    }
  )
)

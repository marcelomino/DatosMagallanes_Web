# ═════════════════════════════════════════════════════════════════════════════
# indicadores/301_pobreza/grafico.R
#
# Laminas del indicador 301, Tasa de pobreza por ingresos.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
#
# EL EJE FIJO 0-12 NO ES CAPRICHO
#   Hasta septiembre de 2026 esta serie y la pobreza multidimensional (302)
#   compartian un solo cuadro y, por lo tanto, un solo eje: el lector veia de
#   una vez que la pobreza por ingresos corre muy por debajo de la
#   multidimensional. Al separarlas en dos cuadros, un eje ajustado a cada serie
#   las dibujaria con el mismo aspecto pese a diferir por un factor de cuatro.
#   Ambas laminas declaran el mismo rango, que es lo que conserva la
#   comparacion que el cuadro unico daba gratis.
#
# LAMINA CON CONTROL
#   El selector de rango de anos vive en el modulo del capitulo, que filtra y
#   pasa aqui el data.frame ya recortado. Es el mismo selector para las dos
#   laminas, para que no puedan quedar mostrando periodos distintos.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "III.1",

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(pobreza_ingreso, name = "Por ingresos", symbol = "circle") |>
        # Sin area pese a que el eje ancla en cero: el relleno daria cuerpo a la
        # serie mas baja del par y la haria pesar visualmente mas que la
        # multidimensional, que es justo la comparacion que el cuadro cuida.
        e_lamina() |>
        # Eje de categorias: las rondas CASEN no estan igualmente espaciadas.
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, max = 12, interval = 3,
                 axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, "%"))
    }
  )
)

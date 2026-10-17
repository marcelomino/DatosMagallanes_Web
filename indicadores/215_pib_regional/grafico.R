# ═════════════════════════════════════════════════════════════════════════════
# indicadores/215_pib_regional/grafico.R
#
# Laminas del indicador 215, Producto interno bruto regional (nivel).
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
#
# LAMINA CON CONTROL
#   El selector de rango de anos vive en el modulo del capitulo, que filtra y
#   pasa aqui el data.frame ya recortado. Es el mismo selector que gobierna la
#   lamina II.2, la variacion del mismo PIB, para que nivel y variacion no
#   queden mostrando periodos distintos.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "II.1",
    nota   = "Millones de pesos chilenos, a precios corrientes.",

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(pib, name = "PIB", symbol = "circle") |>
        e_lamina(area = TRUE) |>
        e_x_axis(type = "category") |>
        # Los millones se abrevian en miles de millones ("k" sobre MM CLP).
        e_y_axis(axisLabel = list(formatter = eje_cifra(1, "k", div = 1000))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(0, " MM"))
    }
  )
)

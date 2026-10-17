# ═════════════════════════════════════════════════════════════════════════════
# indicadores/205_empleo/grafico.R
#
# Laminas del indicador 205, Tasa de desempleo.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
#
# Hasta septiembre de 2026 este cuadro mostraba ocupacion y desempleo con tres
# botones excluyentes. La tasa de ocupacion no tenia ficha: se publicaba fuera
# del catalogo. Ahora es la pieza 216, con su carpeta y su cuadro propios. Sobre
# por que no comparten eje, ver el encabezado de 216_tasa_ocupacion/grafico.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "II.4",

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(desempleo, name = "Tasa de desempleo", symbol = "circle") |>
        e_lamina(area = TRUE) |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, "%"))
    }
  )
)

# ═════════════════════════════════════════════════════════════════════════════
# indicadores/201_variacion_pib/grafico.R
#
# Laminas del indicador 201, Tasa de variacion anual del PIB regional.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
#
# LA CIFRA ES DEL BANCO CENTRAL, NO SE CALCULA AQUI
#   Esta lamina publica la columna `variacion_pib` tal como viene de la fuente.
#   El nivel del PIB es la pieza 215, en su propia carpeta: la variacion NO se
#   deriva de el en la interfaz, porque seria una cifra sin procedencia.
#
# EL PRIMER ANO VIENE VACIO
#   2018 no tiene variacion porque no hay ano anterior en la serie. Se publica
#   como hueco, no como cero: el cero seria afirmar que el PIB no se movio.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "II.2",
    nota   = "Variacion publicada por el Banco Central. 2018 no tiene ano previo en la serie.",

    # Barras y no linea: es una medida discreta por periodo, no una magnitud
    # que evolucione de forma continua entre anos. Y porque la variacion cruza
    # el cero, que con barras se lee de inmediato.
    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_bar(variacion_pib, name = "Variacion anual",
              itemStyle = list(color = PAL$azul)) |>
        e_lamina() |>
        e_x_axis(type = "category") |>
        # El eje NO ancla en cero por abajo: la serie tiene valores negativos y
        # forzar el cero como minimo los dejaria fuera del cuadro.
        e_y_axis(axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_labels(show = TRUE, color = PAL$tinta, position = "top",
                 formatter = rotulo_cifra(1, "%")) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, "%"))
    }
  )
)

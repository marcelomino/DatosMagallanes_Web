# ═════════════════════════════════════════════════════════════════════════════
# indicadores/415_mortalidad_infantil/grafico.R
#
# Laminas del indicador 415, Tasa de mortalidad infantil.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
#
# Esta serie viajaba como una columna del CSV de la esperanza de vida (401) y se
# publicaba en el cuadro IV.1 sin ficha propia. Desde septiembre de 2026 es un
# indicador del catalogo, con su carpeta y su cuadro.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "IV.2",

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(mortalidad, name = "Mortalidad infantil", symbol = "circle") |>
        e_lamina(area = TRUE) |>
        e_x_axis(type = "category") |>
        # Aqui si min = 0: la mortalidad tiene el cero como referencia real.
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(1))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, " por mil"))
    }
  )
)

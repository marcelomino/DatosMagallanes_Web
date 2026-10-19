# ═════════════════════════════════════════════════════════════════════════════
# indicadores/111_tasa_mortalidad_menores_5/grafico.R
#
# Laminas del indicador 111, Tasa de mortalidad en menores de 5 anos, por sexo.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.11",
    nota   = "Registro administrativo con rezago de uno a dos anos.",

    # Total, hombres y mujeres en la misma unidad y la misma escala.
    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(total,   name = "Total",   symbol = "circle") |>
        e_line(hombres, name = "Hombres", symbol = "circle") |>
        e_line(mujeres, name = "Mujeres", symbol = "circle") |>
        e_lamina() |>
        e_x_axis(type = "category") |>
        # min = 0: la mortalidad tiene el cero como referencia real.
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(0))) |>
        e_legend(bottom = 0) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, " por mil"))
    }
  )
)

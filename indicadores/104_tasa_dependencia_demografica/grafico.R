# ═════════════════════════════════════════════════════════════════════════════
# indicadores/104_tasa_dependencia_demografica/grafico.R
#
# Laminas del indicador 104, Tasa de dependencia demografica.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.4",
    nota   = paste("Personas de 0-14 y de 65 anos y mas por cada 100 de 15 a 64.",
                   "La total es la suma de la infantil y la de adultos mayores."),

    # Las tres medidas comparten unidad (por 100 de 15-64): un solo eje, con
    # el cero como base real de una razon.
    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(dep_total,    name = "Total",           symbol = "circle") |>
        e_line(dep_infantil, name = "Infantil (0-14)", symbol = "circle") |>
        e_line(dep_mayores,  name = "Adultos mayores (65+)", symbol = "circle") |>
        e_lamina() |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(0))) |>
        e_legend(bottom = 0) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, " por 100"))
    }
  )
)

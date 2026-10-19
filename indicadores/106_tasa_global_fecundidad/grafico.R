# ═════════════════════════════════════════════════════════════════════════════
# indicadores/106_tasa_global_fecundidad/grafico.R
#
# Laminas del indicador 106, Tasa global de fecundidad.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
#
# 2017 VIENE VACIO
#   El anuario consultado publica la TGF nacional para ese ano, pero no un
#   valor regional para Magallanes. Se publica como hueco, no como cero.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.6",
    nota   = paste("2017 sin dato regional. 2024 y 2025 son cifras",
                   "provisionales."),

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(fecundidad, name = "Fecundidad", symbol = "circle",
               connectNulls = FALSE) |>
        # Area con el cero como base: hijos por mujer no puede ser negativo y
        # el cero es su referencia real.
        e_lamina(area = TRUE) |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(2))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(2, " hijos/as por mujer"))
    }
  )
)

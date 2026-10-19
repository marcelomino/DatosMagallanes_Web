# ═════════════════════════════════════════════════════════════════════════════
# indicadores/108_esperanza_vida/grafico.R
#
# Laminas del indicador 108, Esperanza de vida al nacer, segun sexo.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
#
# Hasta octubre de 2026 fue el indicador 401, en el capitulo IV Bienestar.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.8",
    nota   = "Registro administrativo con rezago de uno a dos anos.",

    # Total, hombres y mujeres en la misma unidad: el total primero para tomar
    # el color protagonista, como en la I.1.
    dibujo = function(df) {
      eje <- eje_holgado(c(df$hombres, df$mujeres), 1)
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(total,   name = "Total",   symbol = "circle") |>
        e_line(hombres, name = "Hombres", symbol = "circle") |>
        e_line(mujeres, name = "Mujeres", symbol = "circle") |>
        # Sin area: el eje no parte en cero y un relleno sobre esa base leeria
        # como magnitud lo que solo es el recorte del eje.
        e_lamina() |>
        e_x_axis(type = "category") |>
        # El eje no ancla en cero: la esperanza de vida se mueve en un rango
        # estrecho y el cero la aplastaria contra el techo.
        e_y_axis(min = eje$min, max = eje$max, interval = eje$interval,
                 axisLabel = list(formatter = eje_cifra(0, " a"))) |>
        e_legend(bottom = 0) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, " anos"))
    }
  )
)

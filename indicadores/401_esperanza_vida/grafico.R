# ═════════════════════════════════════════════════════════════════════════════
# indicadores/401_esperanza_vida/grafico.R
#
# Laminas del indicador 401, Esperanza de vida al nacer.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
#
# Hasta septiembre de 2026 este cuadro conmutaba con botones entre esperanza de
# vida y mortalidad infantil. La segunda no tenia ficha: se publicaba fuera del
# catalogo. Ahora es el indicador 415, con su carpeta y su cuadro propios.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "IV.1",

    dibujo = function(df) {
      eje <- eje_holgado(df$esperanza, 0.5)
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(esperanza, name = "Esperanza de vida", symbol = "circle") |>
        # Sin area: el eje no parte en cero y un relleno sobre esa base leeria
        # como magnitud lo que solo es el recorte del eje.
        e_lamina() |>
        e_x_axis(type = "category") |>
        # El eje no ancla en cero: la esperanza de vida se mueve en un rango
        # estrecho y el cero la aplastaria contra el techo. Un decimal en el
        # rotulo porque los cortes van de media en media unidad; con cero
        # decimales se repetiria el mismo rotulo seis veces.
        e_y_axis(min = eje$min, max = eje$max, interval = eje$interval,
                 axisLabel = list(formatter = eje_cifra(1, " a"))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, " anos"))
    }
  )
)

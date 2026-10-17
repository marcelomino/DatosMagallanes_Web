# ═════════════════════════════════════════════════════════════════════════════
# indicadores/515_participacion_electoral/grafico.R
#
# Laminas del indicador 515, Participacion electoral.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "V.2",
    # El cambio de regimen de voto es imprescindible para leer el salto de la
    # serie: sin esta nota, la subida parece un cambio de conducta.
    nota   = "El voto es voluntario entre 2012 y 2022, y obligatorio desde 2023.",

    dibujo = function(df) {
      eje <- eje_holgado(df$electoral, 5)
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(electoral, name = "Participacion", symbol = "circle") |>
        # Sin area, a diferencia de las demas series unicas del catalogo: el eje
        # de este cuadro no parte en cero, y un relleno sobre una base falsa
        # dibujaria como magnitud lo que solo es el recorte del eje.
        e_lamina() |>
        # Eje de categorias: las elecciones no ocurren a intervalos regulares.
        e_x_axis(type = "category") |>
        # El eje no ancla en cero —la participacion se mueve en un tramo alto y
        # el cero borraria las diferencias entre elecciones— pero sus cortes si
        # son redondos, porque el cuadro vecino de la misma fila va de 10 en 10.
        e_y_axis(min = eje$min, max = eje$max, interval = eje$interval,
                 axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, "%"))
    }
  )
)

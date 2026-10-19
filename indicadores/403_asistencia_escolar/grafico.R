# ═════════════════════════════════════════════════════════════════════════════
# indicadores/403_asistencia_escolar/grafico.R
#
# Laminas del indicador 403, Tasa neta de asistencia escolar.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "IV.3",
    nota   = paste("Poblacion en edad teorica de cada nivel: 6 a 13 anos para",
                   "basica, 14 a 17 para media."),

    # datos.csv viene en formato largo (anio, nivel, asistencia) porque el
    # catalogo trata basica y media como una sola serie con una categoria, no
    # como dos columnas ad-hoc. Se separa en dos vectores y se unen por anio
    # para que e_charts() reciba una fila por periodo, con una columna por
    # nivel.
    dibujo = function(df) {
      basica <- df |>
        dplyr::filter(nivel == "Basica") |>
        dplyr::select(anio, asistencia_basica = asistencia)
      media <- df |>
        dplyr::filter(nivel == "Media") |>
        dplyr::select(anio, asistencia_media = asistencia)
      ancho <- dplyr::inner_join(basica, media, by = "anio") |>
        dplyr::arrange(anio) |>
        dplyr::mutate(anio = as.character(anio))

      # El eje no ancla en cero: las dos series se mueven en un tramo alto y
      # estrecho (76-95%) y el cero las aplastaria contra el techo.
      eje <- eje_holgado(c(ancho$asistencia_basica, ancho$asistencia_media), 10)

      ancho |>
        e_charts(anio) |>
        e_line(asistencia_basica, name = "Basica", symbol = "circle") |>
        e_line(asistencia_media,  name = "Media",  symbol = "circle") |>
        # Series distintas dentro de un mismo grafico: tintas_serie(), no
        # colores escritos a mano.
        e_color(tintas_serie(2)) |>
        e_lamina() |>
        e_x_axis(type = "category") |>
        e_y_axis(min = eje$min, max = eje$max, interval = eje$interval,
                 axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        # Mas de una serie: la leyenda va abajo, no oculta.
        e_legend(bottom = 0) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, "%"))
    }
  )
)

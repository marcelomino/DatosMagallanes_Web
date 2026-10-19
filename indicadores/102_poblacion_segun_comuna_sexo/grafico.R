# ═════════════════════════════════════════════════════════════════════════════
# indicadores/102_poblacion_segun_comuna_sexo/grafico.R
#
# Laminas del indicador 102, Poblacion segun comuna y sexo.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.3",
    nota   = "El selector Censo elige el censo que muestra el cuadro.",

    # La pagina del capitulo pasa un censo por dibujo (corte_anio()). El filtro
    # al ultimo ano no cambia nada en ese caso; sirve para que la lamina dibuje
    # un solo censo tambien desde la consola, con el CSV completo.
    dibujo = function(df) {
      df |>
        dplyr::filter(anio == max(anio)) |>
        # Ascendente porque e_flip_coords() invierte el eje: la comuna mayor
        # queda arriba.
        dplyr::arrange(total) |>
        e_charts(comuna) |>
        e_bar(hombres, name = "Hombres") |>
        e_bar(mujeres, name = "Mujeres") |>
        e_flip_coords() |>
        e_lamina() |>
        e_color(tintas_serie(2)) |>
        e_y_axis(axisLabel = list(interval = 0)) |>   # rotular todas las comunas
        e_x_axis(axisLabel = list(formatter = eje_cifra(0, "k", div = 1000))) |>
        # Sin la cifra al final de la barra, las comunas menores se leen como
        # cero frente a Punta Arenas. La escala no se toca: transformarla seria
        # publicar un nivel que la fuente no publica. Se declara el valor.
        e_labels(show = TRUE, color = PAL$tinta, position = "right",
                 formatter = rotulo_cifra(0, idx = 0)) |>
        e_legend(bottom = 0) |>
        # idx = 0: e_flip_coords() ya intercambio los ejes.
        e_tooltip(trigger = "axis", axisPointer = list(type = "shadow"),
                  formatter = tip_eje(0, " hab.", idx = 0))
    }
  )
)

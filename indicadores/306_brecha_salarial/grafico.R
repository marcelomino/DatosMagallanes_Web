# ═════════════════════════════════════════════════════════════════════════════
# indicadores/306_brecha_salarial/grafico.R
#
# Laminas del indicador 306, Brecha salarial entre sexos.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
#
# Sin nota que cite la brecha: el CSV trae los dos ingresos y no la brecha, y
# derivarla en la interfaz publicaria una cifra sin procedencia. El cuadro
# muestra los dos niveles que la fuente publica; la comparacion la hace el ojo.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "III.3",

    # Dos categorias sin orden: dos valores del azul del manual, no una rampa,
    # porque hombre y mujer no son una escala.
    dibujo = function(df) {
      df |>
        e_charts(categoria) |>
        e_bar(ingreso, name = "Ingreso promedio",
              itemStyle = list(color = color_por_barra(tintas_serie(2)))) |>
        e_lamina() |>
        e_x_axis(type = "category") |>
        e_y_axis(axisLabel = list(formatter = eje_cifra(0, "k", pre = "$", div = 1000))) |>
        e_labels(show = TRUE, color = PAL$tinta, position = "top",
                 formatter = rotulo_cifra(0, pre = "$")) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "item", formatter = tip_item(0, pre = "$"))
    }
  )
)

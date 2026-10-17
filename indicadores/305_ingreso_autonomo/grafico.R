# ═════════════════════════════════════════════════════════════════════════════
# indicadores/305_ingreso_autonomo/grafico.R
#
# Laminas del ingreso autonomo per capita del hogar, por quintil.
#
# HISTORIA DE ESTA CARPETA
#   Hasta septiembre de 2026 se llamaba 304_quintiles, pero la ficha 304 es
#   "Razon de ingresos entre quintiles (indice 20/20)", que NO es este dato.
#   Mientras duro el desajuste, la lamina declaraba `ficha = 305` para enganchar
#   con el registro correcto, y el catalogo publicaba la 304 como compilada y la
#   305 como pendiente: exactamente al reves. Se resolvio renombrando la carpeta
#   con el id que le corresponde. Ya no hay campo `ficha`: la lamina hereda la
#   de su propia carpeta.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "III.4",
    nota   = "Ingreso autonomo mensual per capita del hogar, en pesos chilenos.",

    # Categorias CON orden (Q1 a Q5): aqui si corresponde rampa_orden(), porque
    # la gradacion acompana una jerarquia real del dato.
    dibujo = function(df) {
      df |>
        e_charts(quintil) |>
        e_bar(ingreso, name = "Ingreso",
              itemStyle = list(color = color_por_barra(rampa_orden(nrow(df))))) |>
        e_lamina() |>
        e_x_axis(type = "category", axisLabel = list(interval = 0)) |>
        e_y_axis(axisLabel = list(formatter = eje_cifra(0, "k", pre = "$", div = 1000))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "item", formatter = tip_item(0, pre = "$"))
    }
  )
)

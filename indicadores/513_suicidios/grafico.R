# ═════════════════════════════════════════════════════════════════════════════
# indicadores/513_suicidios/grafico.R
#
# Laminas del indicador 513, Tasa de mortalidad por suicidios y lesiones
# autoinfligidas. El titulo del cuadro y la fuente al pie salen de la
# ficha.yaml de esta misma carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "V.5",
    # El 0,0 de 2010 es el valor que publica el SIIT, no un dato faltante:
    # la nota lo deja dicho para que no se lea como un ano sin registro.
    nota   = "Defunciones por 100.000 habitantes. El SIIT publica 0,0 para 2010.",

    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(suicidios, name = "Tasa", symbol = "circle") |>
        # Aqui si min = 0: la tasa tiene el cero como referencia real.
        e_lamina(area = TRUE) |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(1))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, " por 100.000 hab."))
    }
  )
)

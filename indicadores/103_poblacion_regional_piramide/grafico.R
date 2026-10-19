# ═════════════════════════════════════════════════════════════════════════════
# indicadores/103_poblacion_regional_piramide/grafico.R
#
# Laminas del indicador 103, Piramide de poblacion regional.
# El titulo del cuadro y la fuente al pie salen de la ficha.yaml de esta misma
# carpeta; aqui no se escriben. Ver R/20_graficos.R.
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "I.2",
    nota   = paste("Porcentaje sobre la poblacion total de cada censo: hombres y",
                   "mujeres suman 100. El selector Censo elige un censo;",
                   "«Superpuestos» dibuja los cuatro como contorno, sobre la misma",
                   "escala, para leer el cambio de la estructura por edad."),
    # 21 grupos de edad: a 400 px cada fila mide 15 px y los rotulos del eje se
    # tocan. 560 px les da 22.
    altura = "560px",

    # UNA LAMINA, DOS LECTURAS. La pagina del capitulo pasa un censo o los
    # cuatro (corte_anio(todos =)). Con uno, piramide de barras: hombres a la
    # izquierda, mujeres a la derecha. Con varios, un contorno escalonado por
    # censo, del claro (el mas antiguo) al oscuro (el mas reciente): el orden
    # de los censos es real, por eso rampa_orden() y no tintas_serie(). Cada
    # censo son dos series con el mismo nombre, asi la leyenda los prende y
    # apaga de a pares.
    #
    # LAS CIFRAS SON PORCENTAJES QUE TRAE EL CSV, sobre la poblacion total de
    # cada censo. No se calculan aqui: por eso censos de tamano distinto se
    # comparan por su forma y no por su volumen.
    #
    # `todo` son los datos completos: la escala se fija con ellos para que
    # cambiar de censo no mueva el eje. Desde la consola, con el CSV entero,
    # `todo` es el mismo df y se dibujan los cuatro superpuestos.
    dibujo = function(df, todo = df) {
      # El orden de los grupos es el de la edad, no el alfabetico: "100 y mas"
      # ordenaria antes que "15-19".
      edad_de <- function(g) as.integer(stringr::str_extract(g, "^[0-9]+"))
      grupos <- unique(todo$grupo_edad)
      grupos <- grupos[order(edad_de(grupos))]

      # Eje simetrico y redondo, desde el mayor grupo de cualquier censo.
      pico <- max(todo$hombres, todo$mujeres)
      paso <- .paso_lindo(pico)
      tope <- ceiling(pico * 1.05 / paso) * paso

      anios <- sort(unique(df$anio))
      ancho <- df |>
        dplyr::mutate(grupo_edad = factor(grupo_edad, levels = grupos),
                      hombres = -hombres) |>   # el signo es recurso de dibujo
        dplyr::select(anio, grupo_edad, hombres, mujeres) |>
        tidyr::pivot_wider(names_from = anio, values_from = c(hombres, mujeres)) |>
        dplyr::arrange(grupo_edad) |>
        dplyr::mutate(grupo_edad = as.character(grupo_edad))

      e <- ancho |> e_charts(grupo_edad)
      if (length(anios) == 1) {
        e <- e |>
          e_bar_(paste0("hombres_", anios), name = "Hombres", stack = "p",
                 barCategoryGap = "14%") |>
          e_bar_(paste0("mujeres_", anios), name = "Mujeres", stack = "p")
        colores <- tintas_serie(2)
        tip <- tip_eje(2, "%", idx = 0, abs = TRUE)
      } else {
        # El censo mas reciente, con el trazo mas grueso: es el que se lee
        # contra los anteriores.
        grosor <- seq(1.2, 2.6, length.out = length(anios))
        for (i in seq_along(anios))
          for (s in c("hombres", "mujeres"))
            e <- e |> e_line_(paste0(s, "_", anios[[i]]), name = as.character(anios[[i]]),
                              step = "middle", symbol = "none",
                              lineStyle = list(width = grosor[[i]]))
        # Un color por censo. NO se repite por lado: ECharts reparte la paleta
        # por NOMBRE de serie, y las dos series de un censo comparten nombre.
        colores <- rampa_orden(length(anios))
        # El tooltip agrupa por censo: dos lineas con el mismo nombre por censo
        # se leerian como un dato repetido.
        tip <- htmlwidgets::JS(
          "function(p){
             var out = [p[0].name], vistos = {};
             p.forEach(function(s){
               var c = s.seriesName, v = Math.abs(Number(s.value[0]));
               if (!vistos[c]) { vistos[c] = {}; out.push(c); }
               if (Number(s.value[0]) < 0) vistos[c].h = v; else vistos[c].m = v;
             });
             return [out[0]].concat(out.slice(1).map(function(c){
               var d = vistos[c];
               return c + DM.gap + 'H ' + DM.n(d.h, 2) + '% · M ' + DM.n(d.m, 2) + '%';
             })).join('<br/>');
           }")
      }

      e <- e |>
        e_flip_coords() |>
        e_lamina() |>
        e_color(colores) |>
        e_x_axis(min = -tope, max = tope, interval = paso,
                 axisLabel = list(formatter = eje_cifra(0, "%", abs = TRUE))) |>
        e_y_axis(axisLabel = list(interval = 0)) |>   # rotular todos los grupos
        e_legend(bottom = 0) |>
        # idx = 0: e_flip_coords() ya intercambio los ejes.
        e_tooltip(trigger = "axis", axisPointer = list(type = "shadow"),
                  formatter = tip)

      # En la vista superpuesta el color es el censo, asi que el sexo lo dice
      # el lado. Se rotula arriba en los dos modos, para que no cambie de lugar.
      rotulo <- function(texto, lado) c(
        list(type = "text", top = 0,
             style = list(text = texto, fill = PAL$tinta2, fontSize = 12,
                          fontFamily = "Asap, sans-serif", fontWeight = 600)),
        stats::setNames(list(if (lado == "left") "12%" else "4%"), lado))
      e$x$opts$graphic <- list(rotulo("Hombres", "left"), rotulo("Mujeres", "right"))
      e
    }
  )
)

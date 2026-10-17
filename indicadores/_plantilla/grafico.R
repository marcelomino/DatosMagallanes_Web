# ═════════════════════════════════════════════════════════════════════════════
# PLANTILLA — indicadores/{id}_{slug}/grafico.R
#
# Copia este archivo a la carpeta de tu indicador y editalo. No hay sintaxis
# nueva que aprender: el grafico se escribe en echarts4r, igual que siempre.
# Lo unico que agrega este archivo es un envoltorio de cuatro campos para que
# el catalogo sepa donde publicar la lamina y como citarla.
#
# EL CONTRATO
#   Define un unico objeto llamado `laminas`: una lista de laminas. R/20_graficos.R
#   lo lee al arrancar la app y lo deja en LAM[["{id}_{slug}"]].
#
# CAMPOS
#   numero    obligatorio  La direccion del cuadro: "II.3". Encoda el capitulo
#                          y es la cita de la pieza. No se repite en el catalogo.
#   dibujo    obligatorio  function(df) que devuelve un objeto echarts4r.
#   altura    opcional     Alto del area de dibujo. NO se declara: el catalogo
#                          tiene una sola relacion de aspecto para los 36 cuadros
#                          (.ALTURA_CUADRO en R/10_utils.R, justificada en
#                          .identificar() de R/20_graficos.R). Se pone aqui solo si
#                          una lamina tiene una razon medida para apartarse.
#   nota      opcional     La nota al pie, si es un texto fijo de esta lamina.
#                          Si depende de una cifra, ponla en el modulo.
#
# EL TITULO Y LA FUENTE NO SE ESCRIBEN
#   Salen de la ficha.yaml de esta misma carpeta. No hay campo para declarar
#   otra ficha: si la lamina deberia colgar de un indicador distinto, entonces
#   esta en la carpeta equivocada. (Hubo un campo `ficha` hasta septiembre de
#   2026, cuando el prefijo de la carpeta no era confiable; era el parche de un
#   problema de identidad y desaparecio con el.)
#
# LO QUE NO VA AQUI
#   Los controles interactivos. Si el cuadro lleva un selector o botones, esos
#   viven en el modulo del capitulo, que filtra los datos o resuelve la
#   seleccion y le pasa el resultado a `dibujo`. Asi la lamina no depende de
#   Shiny y se puede probar sola:
#
#     dibujar(LAM[["511_delitos_dmcs"]][["V.3"]], d_crimen)
#
# LO QUE SI DEBE IR
#   Todo lo del grafico: geometria, colores, ejes, rotulos y tooltip. Usa
#   siempre los helpers de R/10_utils.R —PAL para el color, e_lamina() para el
#   tema, eje_cifra()/rotulo_cifra()/tip_eje()/tip_item() para los numeros— y
#   nunca un color escrito a mano.
#
# CRITERIOS DE FORMA Y COLOR
#   Estan en DESIGN.md, seccion "Graficos (echarts4r)". En resumen:
#     - rampa_orden() solo si la categoria tiene un orden real; si no, PAL$magenta
#       plano. Graduar el color donde no hay orden inventa una jerarquia.
#     - tintas_serie() para series distintas dentro de un mismo grafico.
#     - area (e_lamina(area = TRUE)) SOLO si el eje ancla en cero. Sobre un eje
#       recortado, el relleno dibuja como magnitud lo que es solo el recorte.
#     - Series temporales: anio como texto + e_x_axis(type = "category"), porque
#       censos y CASEN no vienen a intervalos regulares.
#     - Con e_flip_coords(), los formateadores llevan idx = 0.
#     - Una serie: e_legend(show = FALSE). Varias: e_legend(bottom = 0).
# ═════════════════════════════════════════════════════════════════════════════

laminas <- list(

  list(
    numero = "X.1",
    nota   = "Texto fijo al pie, si corresponde.",

    # Comenta aqui por que esta forma y no otra. El comentario es para quien
    # mantenga la lamina; no se publica en la interfaz.
    dibujo = function(df) {
      df |>
        dplyr::mutate(anio = as.character(anio)) |>
        e_charts(anio) |>
        e_line(mi_columna, name = "Mi serie", symbol = "circle") |>
        e_lamina() |>
        e_x_axis(type = "category") |>
        e_y_axis(min = 0, axisLabel = list(formatter = eje_cifra(0, "%"))) |>
        e_legend(show = FALSE) |>
        e_tooltip(trigger = "axis", formatter = tip_eje(1, "%"))
    }
  )
)

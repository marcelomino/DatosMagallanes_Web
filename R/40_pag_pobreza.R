# ═════════════════════════════════════════════════════════════════════════════
# R/40_pag_pobreza.R — Capitulo III: Pobreza e Ingresos
#
# PAGINA: pobreza.html
#
# PIEZAS DE ESTE CAPITULO
#   301  d_pobreza                Pobreza por ingresos (CASEN)
#   302  d_pobreza_multi          Pobreza multidimensional (CASEN)
#   305  d_quintiles              Ingreso autonomo per capita del hogar, por quintil
#   306  d_genero                 Brecha salarial por sexo
#   307  d_hacinamiento           Tasa de hacinamiento habitacional (CASEN)
#   308  d_deficit_habitacional   Deficit habitacional cuantitativo (CASEN)
#
# DONDE ESTAN LOS GRAFICOS
#   No aqui. Cada lamina vive en la carpeta de su indicador y se alcanza por LAM.
#
#     III.1  indicadores/301_pobreza/grafico.R
#     III.2  indicadores/302_pobreza_multidimensional/grafico.R
#     III.3   indicadores/306_brecha_salarial/grafico.R
#     III.4   indicadores/305_ingreso_autonomo/grafico.R
#     III.5   indicadores/307_hacinamiento/grafico.R
#     III.6   indicadores/308_deficit_habitacional/grafico.R
#
# NINGUNA MEDIDA PUBLICADA
#   Los cuatro CSV de este capitulo traen niveles, no medidas de variacion. La
#   columna "Medida de la fuente" queda vacia en las cuatro filas, y eso es
#   correcto: antes se rellenaba con un delta calculado en la interfaz, que era
#   una cifra sin procedencia.
#
# ADVERTENCIA DE LECTURA
#   Todo el capitulo viene de CASEN, que es bienal e irregular: la ronda 2020 no
#   es comparable y la serie salta de 2019 a 2022. Por eso el eje siempre es de
#   categorias, nunca temporal continuo, y la nota del cuadro III.1 lo declara.
# ═════════════════════════════════════════════════════════════════════════════

# Atajo local: las seis laminas del capitulo, por numero de cuadro.
.III <- list(
  "III.1" = LAM[["301_pobreza"]][["III.1"]],
  "III.2" = LAM[["302_pobreza_multidimensional"]][["III.2"]],
  "III.3"  = LAM[["306_brecha_salarial"]][["III.3"]],
  "III.4"  = LAM[["305_ingreso_autonomo"]][["III.4"]],
  "III.5"  = LAM[["307_hacinamiento"]][["III.5"]],
  "III.6"  = LAM[["308_deficit_habitacional"]][["III.6"]]
)

pag_pobreza <- function() {
  # Un solo rango para las dos medidas de pobreza (III.1 y III.2): si cada
  # cuadro tuviera el suyo podrian quedar mostrando periodos distintos, y la
  # comparacion que el eje comun protege se perderia igual.
  .rango <- rango_anios("pob_ing", d_pobreza$anio)

  # Cada medida de pobreza con su propia ronda CASEN (ver ultimo_valor()).
  .multi <- ultimo_valor(d_pobreza_multi, "pobreza_multi")
  .ingr  <- ultimo_valor(d_pobreza, "pobreza_ingreso")
  .hacin <- ultimo_valor(d_hacinamiento, "hacinamiento")
  .defic <- ultimo_valor(d_deficit_habitacional, "deficit_habitacional")
  # Quintil 3 como aproximacion del ingreso mediano: es el quintil central de
  # la distribucion. La glosa lo declara para no pasarlo por una mediana
  # calculada, que es otra cosa. Se busca por etiqueta y no por posicion, para
  # que reordenar el CSV no publique otro quintil con este nombre.
  .ingr_med <- d_quintiles$ingreso[d_quintiles$quintil == "Q3"]

  # LA BRECHA SALARIAL NO SE CALCULA AQUI. Hasta octubre de 2026 este modulo
  # derivaba (hombre - mujer) / hombre y la publicaba en el inventario y en la
  # nota de III.3: una cifra sin procedencia, que la regla del catalogo prohibe.
  # El CSV de la 306 trae los dos ingresos, no la brecha; mientras la fuente no
  # la publique, la fila remite al cuadro, como la 102.

  tagList(
    portadilla("III", "Pobreza e Ingresos",
      "Pobreza multidimensional y por ingresos, desigualdad y brechas salariales.",
      rango = "Indicadores 301-308"),

    pliego(
      inventario(
        # La misma advertencia que la portada, en cada capitulo: el navegador
        # recuerda la ultima seccion visitada, asi que un lector habitual puede
        # no volver a pasar por la portada nunca. La advertencia no se retira
        # mientras siga siendo cierta.
        marca = if (isTRUE(.PROTOTIPO)) marca_estado("ilustrativo",
                                                 "Series de prototipo, no cifras oficiales"),
        # Una fila por cuadro, en el orden de los cuadros: el numero de la fila
        # es el del cuadro que resume (lo toma de la lamina).
        fila_inventario(.III[["III.1"]], "Pobreza por ingresos", fmt_n(.ingr$valor, 1),
          unidad = "%", periodo = paste("CASEN", .ingr$anio)),
        fila_inventario(.III[["III.2"]], "Pobreza multidimensional", fmt_n(.multi$valor, 1),
          unidad = "%", periodo = paste("CASEN", .multi$anio)),
        fila_inventario(.III[["III.3"]], "Brecha salarial por sexo", "—",
          glosa = "Se lee en el cuadro III.3; la fuente no publica la brecha"),
        fila_inventario(.III[["III.4"]], "Ingreso autonomo por quintil", fmt_n(.ingr_med),
          unidad = "CLP",
          glosa = "Quintil 3 (central), mensual per capita del hogar"),
        fila_inventario(.III[["III.5"]], "Hacinamiento habitacional", fmt_n(.hacin$valor, 1),
          unidad = "%", periodo = paste("CASEN", .hacin$anio)),
        fila_inventario(.III[["III.6"]], "Deficit habitacional cuantitativo",
          fmt_n(.defic$valor, 1),
          unidad = "%", periodo = paste("CASEN", .defic$anio))
      ),

      # ── Las seis piezas, plegadas ────────────────────────────────────────
      # Una entrada por pieza, como en el capitulo I. Un solo selector de rango
      # gobierna III.1 y III.2, para que las dos medidas de pobreza no puedan
      # quedar mostrando periodos distintos. Va en la primera, que es donde el
      # lector lo encuentra al empezar, y la nota de III.2 lo declara: con las
      # entradas plegadas se puede abrir la segunda sin ver el control.
      piezas_capitulo(
        "acc-pob_ing",
        pieza_cuadro(.III[["III.1"]], controles = .rango$controles, rango = .rango,
          nota = "CASEN 2020 no se levanto en formato comparable; la serie salta de 2019 a 2022."),
        pieza_cuadro(.III[["III.2"]], rango = .rango,
          nota = paste("Mismo eje que el cuadro III.1, para que las dos medidas",
                       "sigan siendo comparables. El rango de anos lo fija el",
                       "selector del cuadro III.1.")),
        pieza_cuadro(.III[["III.3"]]),
        pieza_cuadro(.III[["III.4"]]),
        pieza_cuadro(.III[["III.5"]]),
        pieza_cuadro(.III[["III.6"]])
      ),

      # La procedencia se declara, no se asume: cuando una pieza se separa de
      # otra o cambia de numero, el lector que la cito antes tiene que poder
      # seguirle el rastro.
      nota_aparato(
        tags$dl(
          tags$dt("Numeracion de este capitulo"),
          tags$dd(paste(
            "El cuadro III.4 publica el indicador 305, ingreso autonomo per capita",
            "del hogar. Hasta septiembre de 2026 sus datos vivian en una",
            "carpeta numerada 304, de modo que el catalogo daba por compilada",
            "la ficha 304 —la razon de ingresos 20/20, que sigue sin datos— y",
            "por pendiente la 305, que es la que efectivamente se dibujaba.",
            "La carpeta se renumero y ambas fichas quedan correctamente",
            "marcadas.",
            "La carpeta 301 contenia ademas las dos series de pobreza que las",
            "fichas numeran por separado; se dividieron en septiembre de 2026,",
            "de modo que el indicador 302 ya tiene datos propios."))
        )
      )
    )
  )
}

# ═════════════════════════════════════════════════════════════════════════════
# R/40_pag_economia.R — Capitulo II: Economia
#
# PAGINA: economia.html
#
# PIEZAS DE ESTE CAPITULO
#   201  d_variacion_pib  Variacion anual del PIB, publicada por el Banco Central
#   202  d_sectores       Participacion sectorial en el PIB
#   203  d_empresas       Numero de empresas
#   205  d_empleo         Tasa de desempleo (ENE, promedio anual)
#   208  d_informalidad   Tasa de informalidad laboral (CASEN)
#   215  d_pib            PIB regional a precios corrientes (nivel)
#   216  d_ocupacion      Tasa de ocupacion (ENE, promedio anual)
#
# LA MEDIDA DE VARIACION ES LA QUE PUBLICA LA FUENTE
#   La pieza 201 ES la variacion anual del PIB que calcula el Banco Central, y
#   desde septiembre de 2026 tiene su propio cuadro (II.2). NO se deriva del
#   nivel (215) en la interfaz: seria una cifra sin procedencia. Ocupacion y
#   desempleo no traen medida publicada, asi que su celda del inventario queda
#   vacia — que es la respuesta honesta, no una omision.
#
# INTERACTIVIDAD PROPIA DE ESTE CAPITULO
#   Un solo rango de anos (rango_anios(), dos selectores) gobierna los dos
#   cuadros del PIB: si cada uno tuviera el suyo podrian quedar mostrando
#   periodos distintos. Vive en la entrada II.1 y la nota de II.2 lo declara.
#
#   El control se declara aqui a proposito: es comportamiento del capitulo. La
#   lamina recibe el data.frame ya recortado —cada rango se dibuja al construir,
#   ver lienzo()— y sigue siendo una funcion pura, llamable desde la consola.
#
# DONDE ESTAN LOS GRAFICOS
#   No aqui. Cada lamina vive en la carpeta de su indicador y se alcanza por LAM.
#
#     II.1  indicadores/215_pib_regional/grafico.R
#     II.2  indicadores/201_variacion_pib/grafico.R
#     II.3  indicadores/216_tasa_ocupacion/grafico.R
#     II.4  indicadores/205_empleo/grafico.R
#     II.5   indicadores/202_participacion_sectorial/grafico.R
#     II.6   indicadores/203_empresas/grafico.R
#     II.7   indicadores/208_informalidad_laboral/grafico.R
# ═════════════════════════════════════════════════════════════════════════════

# Atajo local: las siete laminas del capitulo, por numero de cuadro.
.II <- list(
  "II.1" = LAM[["215_pib_regional"]][["II.1"]],
  "II.2" = LAM[["201_variacion_pib"]][["II.2"]],
  "II.3" = LAM[["216_tasa_ocupacion"]][["II.3"]],
  "II.4" = LAM[["205_empleo"]][["II.4"]],
  "II.5"  = LAM[["202_participacion_sectorial"]][["II.5"]],
  "II.6"  = LAM[["203_empresas"]][["II.6"]],
  "II.7"  = LAM[["208_informalidad_laboral"]][["II.7"]]
)

pag_economia <- function() {
  # Las opciones del selector salen del propio CSV del PIB.
  .rango <- rango_anios("eco", d_pib$anio)

  # Ultimo valor de cada serie en su propio ano maximo (ver ultimo_valor()):
  # cada fila del inventario publica el periodo de SU pieza, no el de otra.
  .pib    <- ultimo_valor(d_pib, "pib")
  # La variacion que publica el Banco Central para el MISMO ano del nivel: si
  # las dos series terminaran en anos distintos, la medida no calificaria la
  # cifra de su fila. Sin ese ano, la celda queda vacia.
  .pib_var <- d_variacion_pib$variacion_pib[d_variacion_pib$anio == .pib$anio]
  .var    <- ultimo_valor(d_variacion_pib, "variacion_pib")
  .ocup   <- ultimo_valor(d_ocupacion, "ocupacion")
  .desemp <- ultimo_valor(d_empleo, "desempleo")
  .idx    <- which.max(d_sectores$valor)    # sector de mayor peso
  .emp    <- ultimo_valor(d_empresas, "empresas")
  .inform <- ultimo_valor(d_informalidad, "informalidad")

  tagList(
    portadilla("II", "Economia",
      "Producto interno bruto regional, mercado laboral y composicion sectorial.",
      rango = "Indicadores 201-216"),

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
        fila_inventario(.II[["II.1"]], "Producto interno bruto", fmt_n(.pib$valor),
          unidad = "MM CLP", periodo = .pib$anio,
          # La medida no se calcula: es la pieza 201 (cuadro II.2), publicada
          # por el Banco Central.
          medida = medida_publicada(.pib_var, "%", "variacion anual, cuadro II.2")),
        fila_inventario(.II[["II.2"]], "Variacion anual del PIB", fmt_n(.var$valor, 1),
          unidad = "%", periodo = .var$anio,
          glosa = "La que publica el Banco Central; no se deriva del nivel"),
        fila_inventario(.II[["II.3"]], "Tasa de ocupacion", fmt_n(.ocup$valor, 1),
          unidad = "%", periodo = .ocup$anio,
          glosa = "Promedio anual de la Encuesta Nacional de Empleo"),
        fila_inventario(.II[["II.4"]], "Tasa de desempleo", fmt_n(.desemp$valor, 1),
          unidad = "%", periodo = .desemp$anio,
          glosa = "Promedio anual de la Encuesta Nacional de Empleo"),
        fila_inventario(.II[["II.5"]], "Sector de mayor peso", d_sectores$sector[.idx],
          unidad = paste0(fmt_n(d_sectores$valor[.idx]), "% del PIB")),
        fila_inventario(.II[["II.6"]], "Numero de empresas", fmt_n(.emp$valor),
          unidad = "empresas", periodo = .emp$anio),
        fila_inventario(.II[["II.7"]], "Tasa de informalidad laboral", fmt_n(.inform$valor, 1),
          unidad = "%", periodo = .inform$anio,
          glosa = "Segun el ano de levantamiento de la CASEN, no es serie continua")
      ),

      # ── Las siete piezas, plegadas ───────────────────────────────────────
      # Una entrada por pieza, como en el capitulo I. El valor de cada entrada
      # es el ancla de su cuadro, para que el indice del menu pueda abrirla.
      #
      # Un solo rango de anos gobierna II.1 y II.2, para que el nivel y su
      # variacion no queden mostrando periodos distintos. Vive en II.1 —la
      # primera de las dos que se lee— y la nota de II.2 lo declara, porque
      # con las entradas plegadas se puede abrir la segunda sin ver el control.
      # Las opciones del selector salen del propio CSV: al actualizar datos se
      # ajustan solas.
      piezas_capitulo(
        "acc-eco",
        pieza_cuadro(.II[["II.1"]], controles = .rango$controles, rango = .rango),
        pieza_cuadro(.II[["II.2"]], rango = .rango,
          nota = paste(.II[["II.2"]]$nota,
                       "El rango de anos lo fija el selector del cuadro II.1.")),
        # Ocupacion y desempleo son dos piezas y no un conmutador: no son
        # complementarias y cada una declara su propia escala. Ver el
        # encabezado de 216_tasa_ocupacion/grafico.R.
        pieza_cuadro(.II[["II.3"]],
          nota = "Sobre la poblacion en edad de trabajar. Promedio anual."),
        pieza_cuadro(.II[["II.4"]],
          nota = "Sobre la fuerza de trabajo. Promedio anual."),
        pieza_cuadro(.II[["II.5"]]),
        pieza_cuadro(.II[["II.6"]]),
        pieza_cuadro(.II[["II.7"]])
      )
    )
  )
}

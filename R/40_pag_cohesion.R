# ═════════════════════════════════════════════════════════════════════════════
# R/40_pag_cohesion.R — Capitulo V: Cohesion Social
#
# PAGINA: cohesion.html
#
# PIEZAS DE ESTE CAPITULO
#   502  d_confianza   Confianza declarada en instituciones (encuesta regional)
#   511  d_crimen      Delitos de mayor connotacion social, tasa por 100.000
#   512  d_homicidios  Tasa de homicidios
#   513  d_suicidios   Tasa de mortalidad por suicidios
#   515  d_electoral   Participacion electoral
#
# DONDE ESTAN LOS GRAFICOS
#   No aqui. Cada lamina vive en la carpeta de su indicador, en
#   indicadores/{carpeta}/grafico.R, y se alcanza por el registro LAM. Este
#   archivo compone el capitulo; no dibuja.
#
#     V.1  indicadores/502_confianza_institucional/grafico.R
#     V.2  indicadores/515_participacion_electoral/grafico.R
#     V.3  indicadores/511_delitos_dmcs/grafico.R
#     V.4  indicadores/512_homicidios/grafico.R
#     V.5  indicadores/513_suicidios/grafico.R
# ═════════════════════════════════════════════════════════════════════════════

# Atajo local: las cinco laminas del capitulo, para no repetir la carpeta en la
# pagina. El numero de cuadro es la clave, como en la cita impresa.
.V <- list(
  "V.1" = LAM[["502_confianza_institucional"]][["V.1"]],
  "V.2" = LAM[["515_participacion_electoral"]][["V.2"]],
  "V.3" = LAM[["511_delitos_dmcs"]][["V.3"]],
  "V.4" = LAM[["512_homicidios"]][["V.4"]],
  "V.5" = LAM[["513_suicidios"]][["V.5"]]
)

pag_cohesion <- function() {

  # Las dos primeras filas no son un indicador fijo sino los extremos de la
  # distribucion de confianza: que institucion encabeza y cual cierra.
  .max_i <- which.max(d_confianza$confianza)
  .min_i <- which.min(d_confianza$confianza)
  # Cada serie con su propio ano maximo (ver ultimo_valor()).
  .elec <- ultimo_valor(d_electoral, "electoral")
  .crim <- ultimo_valor(d_crimen, "tasa")
  .homi <- ultimo_valor(d_homicidios, "homicidios")
  .suic <- ultimo_valor(d_suicidios, "suicidios")

  tagList(
    portadilla("V", "Cohesion Social",
      "Confianza institucional, participacion ciudadana y seguridad.",
      rango = "Indicadores 502-515"),

    pliego(
      inventario(
        # La misma advertencia que la portada, en cada capitulo: el navegador
        # recuerda la ultima seccion visitada, asi que un lector habitual puede
        # no volver a pasar por la portada nunca. La advertencia no se retira
        # mientras siga siendo cierta.
        marca = marca_estado("ilustrativo",
                             "Series de prototipo, no cifras oficiales"),
        # Una fila por cuadro, en el orden de los cuadros: el numero de la fila
        # es el del cuadro que resume (lo toma de la lamina). V.1 lleva dos: la
        # confianza mayor y la menor del mismo cuadro.
        fila_inventario(.V[["V.1"]], "Mayor confianza declarada",
          fmt_n(d_confianza$confianza[.max_i]), unidad = "%",
          periodo = "2023",
          glosa = d_confianza$institucion[.max_i]),
        fila_inventario(.V[["V.1"]], "Menor confianza declarada",
          fmt_n(d_confianza$confianza[.min_i]), unidad = "%",
          periodo = "2023",
          glosa = d_confianza$institucion[.min_i]),
        fila_inventario(.V[["V.2"]], "Participacion electoral", fmt_n(.elec$valor, 1),
          unidad = "%", periodo = .elec$anio,
          glosa = "Sobre el padron habilitado"),
        fila_inventario(.V[["V.3"]], "Delitos de mayor connotacion social",
          # La unidad la manda la ficha 511 del YAML ("Por 100.000 habitantes"),
          # no el modulo. Publicaba "por mil", que es la misma cifra leida con
          # un factor de 100 de diferencia.
          fmt_n(.crim$valor, 1), unidad = "por 100.000 hab.",
          periodo = .crim$anio),
        fila_inventario(.V[["V.4"]], "Tasa de homicidios", fmt_n(.homi$valor, 1),
          unidad = "por 100.000 hab.", periodo = .homi$anio),
        fila_inventario(.V[["V.5"]], "Tasa de mortalidad por suicidios",
          fmt_n(.suic$valor, 1), unidad = "por 100.000 hab.",
          periodo = .suic$anio)
      ),

      # ── Las cinco piezas, plegadas ───────────────────────────────────────
      # Una entrada por pieza, como en el capitulo I. Numero, titulo, fuente y
      # nota salen de la lamina, ya resueltos contra su ficha metodologica.
      piezas_capitulo(
        "acc-coh",
        pieza_cuadro(.V[["V.1"]]),
        pieza_cuadro(.V[["V.2"]]),
        pieza_cuadro(.V[["V.3"]]),
        pieza_cuadro(.V[["V.4"]]),
        pieza_cuadro(.V[["V.5"]])
      )
    )
  )
}

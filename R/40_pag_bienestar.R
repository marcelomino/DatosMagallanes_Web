# ═════════════════════════════════════════════════════════════════════════════
# R/40_pag_bienestar.R — Capitulo IV: Bienestar
#
# PAGINA: bienestar.html
#
# PIEZAS DE ESTE CAPITULO
#   402  d_educacion           Cobertura (tasa neta de matricula) por nivel
#   403  d_asistencia          Tasa neta de asistencia escolar (Basica y Media)
#   404  d_escolaridad         Promedio de anos de escolaridad
#   405  d_matricula_superior  Matricula en educacion superior
#   406  d_titulados_superior  Titulacion en educacion superior
#   414  d_vivienda            Tenencia de la vivienda
#
# LA SALUD SE FUE A POBLACION
#   Esperanza de vida (antes 401) y mortalidad infantil (antes 415) pasaron en
#   octubre de 2026 al capitulo I como 108 y 110, junto a la mortalidad en
#   menores de 5 anos (111): son indicadores demograficos, desagregados por sexo.
#
# NINGUNA MEDIDA PUBLICADA
#   Los CSV traen niveles. La columna "Medida de la fuente" queda vacia.
#
# DONDE ESTAN LOS GRAFICOS
#   No aqui. Cada lamina vive en la carpeta de su indicador y se alcanza por LAM.
#
#     IV.1  indicadores/402_matricula/grafico.R
#     IV.2  indicadores/414_habitabilidad_vivienda/grafico.R
#     IV.3  indicadores/403_asistencia_escolar/grafico.R
#     IV.4  indicadores/404_anos_escolaridad/grafico.R
#     IV.5  indicadores/405_matricula_educacion_superior/grafico.R
#     IV.6  indicadores/406_titulados_educacion_superior/grafico.R
# ═════════════════════════════════════════════════════════════════════════════

# Atajo local: las laminas del capitulo, por numero de cuadro.
.IV <- list(
  "IV.1" = LAM[["402_matricula"]][["IV.1"]],
  "IV.2" = LAM[["414_habitabilidad_vivienda"]][["IV.2"]],
  "IV.3" = LAM[["403_asistencia_escolar"]][["IV.3"]],
  "IV.4" = LAM[["404_anos_escolaridad"]][["IV.4"]],
  "IV.5" = LAM[["405_matricula_educacion_superior"]][["IV.5"]],
  "IV.6" = LAM[["406_titulados_educacion_superior"]][["IV.6"]]
)

pag_bienestar <- function() {

  # Cortes transversales: se busca por etiqueta, no por posicion, para que
  # reordenar el CSV no cambie la cifra publicada.
  .educ_media <- d_educacion$cobertura[d_educacion$nivel == "Ed. Media"]
  # LA VIVIENDA PROPIA NO SE SUMA AQUI. Hasta octubre de 2026 este modulo
  # sumaba "Propia pagada" y "Propia pagando" y publicaba el total: una cifra
  # que la fuente no publica. La fila remite al cuadro IV.2, como la 102.
  # d_asistencia es formato largo (Basica y Media): el inventario publica el
  # nivel medio, que es el que arrastra la escolaridad y la matricula superior.
  .asist_media <- d_asistencia$asistencia[
    d_asistencia$nivel == "Media" & d_asistencia$anio == max(d_asistencia$anio)
  ]
  .escol <- ultimo_valor(d_escolaridad, "escolaridad")
  .matr  <- ultimo_valor(d_matricula_superior, "matricula")
  .titul <- ultimo_valor(d_titulados_superior, "titulados")

  tagList(
    portadilla("IV", "Bienestar",
      "Salud, educacion y condiciones de habitabilidad de la poblacion regional.",
      rango = "Indicadores 402-414"),

    pliego(
      inventario(
        # La misma advertencia que la portada, en cada capitulo: el navegador
        # recuerda la ultima seccion visitada, asi que un lector habitual puede
        # no volver a pasar por la portada nunca. La advertencia no se retira
        # mientras siga siendo cierta.
        marca = marca_estado("ilustrativo",
                             "Series de prototipo, no cifras oficiales"),
        fila_inventario(.IV[["IV.1"]], "Cobertura de educacion media", fmt_n(.educ_media, 1),
          unidad = "%",
          glosa = "Tasa neta de matricula"),
        fila_inventario(.IV[["IV.2"]], "Tenencia de la vivienda", "—",
          glosa = "Se lee en el cuadro IV.2, por condicion de tenencia",
          periodo = "CASEN 2022"),
        fila_inventario(.IV[["IV.3"]], "Asistencia escolar", fmt_n(.asist_media, 1),
          unidad = "%", periodo = max(d_asistencia$anio),
          glosa = "Nivel medio (14 a 17 anos)"),
        fila_inventario(.IV[["IV.4"]], "Anos de escolaridad", fmt_n(.escol$valor, 1),
          unidad = "anos", periodo = .escol$anio),
        fila_inventario(.IV[["IV.5"]], "Matricula en educacion superior",
          fmt_n(.matr$valor, 0),
          unidad = "matriculas", periodo = .matr$anio),
        fila_inventario(.IV[["IV.6"]], "Titulados de educacion superior",
          fmt_n(.titul$valor, 0),
          unidad = "titulaciones", periodo = .titul$anio)
      ),

      # ── Las seis piezas, plegadas ────────────────────────────────────────
      # Una entrada por pieza, como en el capitulo I.
      piezas_capitulo(
        "acc-bien",
        pieza_cuadro(.IV[["IV.1"]],
          nota = "Tasa neta: matriculados en el nivel sobre poblacion en edad teorica."),
        pieza_cuadro(.IV[["IV.2"]],
          nota = "Porcentaje de hogares por condicion de tenencia."),
        pieza_cuadro(.IV[["IV.3"]]),
        pieza_cuadro(.IV[["IV.4"]]),
        pieza_cuadro(.IV[["IV.5"]]),
        pieza_cuadro(.IV[["IV.6"]])
      )
    )
  )
}

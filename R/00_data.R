# ═════════════════════════════════════════════════════════════════════════════
# R/00_data.R  —  Carga de datos del catalogo "Datos Magallanes"
#
# QUE HACE ESTE ARCHIVO
#   Barre indicadores/, carga los CSV y las fichas metodologicas, los deja
#   disponibles en memoria para las paginas del sitio, y verifica que la identidad
#   de cada indicador sea consistente.
#
# ARQUITECTURA — cuatro capas, de abajo hacia arriba:
#
#   1. .csv()          Lector base. Lee un datos.csv y le ESTAMPA su procedencia
#                      (id numerico + carpeta de origen) como atributos del
#                      data.frame. Esto es lo que preserva la trazabilidad: el
#                      dato "sabe" de que indicador viene, aunque despues se le
#                      asigne un nombre de variable distinto.
#
#   2. IND             Registro de datos. Una lista nombrada por CARPETA
#                      (ej. IND[["301_pobreza"]]) construida barriendo el
#                      directorio indicadores/.
#
#   3. FICHA           Registro de fichas, tambien por carpeta, leido de cada
#                      indicadores/{carpeta}/ficha.yaml. d_indicadores es su
#                      version rectangular, que es lo que consumen los modulos.
#
#   4. d_*             Capa de alias legibles (d_pobreza, d_pib, ...). Existe
#                      porque los capitulos (R/40_pag_*.R) leen mejor con
#                      ellos, y son los nombres heredados del dashboard Shiny. Cada alias declara explicitamente de que
#                      carpeta sale, asi que el mapeo nombre -> indicador queda
#                      documentado en un solo lugar (seccion 4, mas abajo).
#
# LA REGLA DE IDENTIFICACION — una carpeta, un indicador, una ficha, un id
#   El id de ficha.yaml manda, y el nombre de la carpeta debe llevarlo de
#   prefijo. La validacion de la seccion 6 aborta si no calzan, si dos carpetas
#   declaran el mismo id, o si una carpeta no trae ficha.
#
#   La regla se escribio despues de dos accidentes que costaron datos publicados
#   bajo el nombre equivocado. 101_poblacion_comunas compartia el 101 con
#   101_poblacion_total, y dos cuadros distintos colgaban de una misma ficha
#   (resuelto dandole la 113). Y 304_quintiles contenia el indicador 305, de
#   modo que el catalogo publicaba la ficha 304 como compilada —sin tener un
#   solo dato— y la 305 como pendiente mientras se dibujaba en el cuadro III.3
#   (resuelto renombrando la carpeta a 305_ingreso_autonomo). Ninguno de los dos
#   produjo un error: produjeron una cifra correcta con la ficha equivocada, que
#   es peor. De ahi que estos chequeos aborten en vez de avisar.
#
# COMO ACTUALIZAR DATOS (sin tocar codigo)
#   1. Editar o reemplazar indicadores/{id}_{slug}/datos.csv
#   2. Guardar como CSV con codificacion UTF-8
#   3. Reiniciar el dashboard -> los cambios aparecen automaticamente
#
# COMO AGREGAR UN INDICADOR NUEVO
#   1. Crear indicadores/{id}_{slug}/ con su ficha.yaml (copiar la plantilla en
#      indicadores/_plantilla/ficha.yaml) y su datos.csv
#   2. Si algun modulo lo va a graficar, agregar su alias en la seccion 4
#   3. Regenerar el agregado: Rscript _dev/agregar_fichas.R
#   4. Al arrancar, la validacion de la seccion 6 avisa si algo no calza
# ═════════════════════════════════════════════════════════════════════════════


# ─────────────────────────────────────────────────────────────────────────────
# 1. LECTOR BASE — lee un CSV y le estampa su procedencia
# ─────────────────────────────────────────────────────────────────────────────

# Raiz de los datos. Centralizada para que un cambio de ubicacion sea de 1 linea.
.RUTA_INDICADORES <- "indicadores"

#' Leer el CSV de un indicador dejando rastro de su origen
#'
#' Lee indicadores/{carpeta}/{archivo} y adjunta al data.frame resultante dos
#' atributos que sobreviven a las operaciones habituales de dplyr (filter,
#' mutate, arrange conservan los atributos del data.frame de entrada):
#'
#'   attr(df, "carpeta") -> "301_pobreza"   clave unica del origen
#'   attr(df, "id")      -> 301L            id de la ficha metodologica
#'
#' @param carpeta Nombre de la carpeta del indicador, ej. "301_pobreza".
#' @param archivo Nombre del CSV dentro de esa carpeta. Por defecto "datos.csv".
#' @return data.frame con atributos "carpeta" e "id".
.csv <- function(carpeta, archivo = "datos.csv") {

  ruta <- file.path(.RUTA_INDICADORES, carpeta, archivo)

  # Fallar temprano y con un mensaje util: si esto revienta en produccion,
  # el log debe decir QUE archivo falta, no "cannot open connection".
  if (!file.exists(ruta))
    cli::cli_abort("No existe el archivo de datos {.path {ruta}}")

  # Se mantiene read.csv (base) en vez de readr::read_csv a proposito:
  # devuelve un data.frame clasico, que es lo que los modulos ya consumen.
  # readr devolveria un tibble y cambiaria el comportamiento de indexado.
  df <- read.csv(ruta, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

  # ── El estampado de procedencia: el corazon de la trazabilidad ──
  attr(df, "carpeta") <- carpeta
  # El id son los digitos iniciales del nombre de carpeta ("301_pobreza" -> 301).
  attr(df, "id") <- as.integer(stringr::str_extract(carpeta, "^\\d+"))

  df
}


# ─────────────────────────────────────────────────────────────────────────────
# 2. REGISTRO CENTRAL — barrido automatico de indicadores/
# ─────────────────────────────────────────────────────────────────────────────

# Carpetas candidatas: solo las que siguen el patron {digitos}_{slug}.
# Esto excluye archivos sueltos del directorio (indicadores.yaml, fuentes.yaml)
# y cualquier carpeta auxiliar que no sea un indicador.
.carpetas_indicador <- list.dirs(.RUTA_INDICADORES,
                                 full.names = FALSE,
                                 recursive  = FALSE) |>
  purrr::keep(\(x) stringr::str_detect(x, "^\\d+_"))

# De esas, solo las que efectivamente tienen datos compilados. Las fichas que
# aun estan en estado "Documentado" pueden tener carpeta sin datos.csv todavia;
# eso no es un error, se reporta en la validacion (seccion 6).
.carpetas_con_datos <- .carpetas_indicador |>
  purrr::keep(\(x) file.exists(file.path(.RUTA_INDICADORES, x, "datos.csv")))

#' Registro de datos: lista nombrada carpeta -> data.frame
#'
#' Se carga todo de una vez al arrancar la app (los CSV son chicos; releer por
#' sesion no aportaria nada y multiplicaria I/O).
#'
#' Uso directo:  IND[["301_pobreza"]]
IND <- .carpetas_con_datos |>
  purrr::set_names() |>
  purrr::map(.csv)

#' Obtener el data.frame de un indicador por su carpeta
#'
#' Se prefiere sobre IND[["..."]] porque falla con un mensaje explicito en vez
#' de devolver NULL silenciosamente (un NULL se propaga hasta el grafico y ahi
#' el error es incomprensible).
#'
#' @param carpeta Nombre de carpeta, ej. "301_pobreza".
.dato <- function(carpeta) {
  if (is.null(IND[[carpeta]]))
    cli::cli_abort(c(
      "No hay datos cargados para el indicador {.val {carpeta}}.",
      "i" = "Se esperaba {.path {file.path(.RUTA_INDICADORES, carpeta, 'datos.csv')}}"
    ))
  IND[[carpeta]]
}


# ─────────────────────────────────────────────────────────────────────────────
# 3. ACCESORES DE PROCEDENCIA — para usar desde los modulos
# ─────────────────────────────────────────────────────────────────────────────
# Permiten recuperar la identidad del indicador desde cualquier data.frame que
# haya salido de .csv(), sin tener que volver a este archivo. Utiles, por
# ejemplo, para que una nota al pie de un grafico cite la fuente correcta.

#' Id numerico del indicador del que proviene un data.frame
ind_id <- function(df) attr(df, "id")

#' Carpeta (clave unica) de la que proviene un data.frame
ind_carpeta <- function(df) attr(df, "carpeta")

#' Ficha metodologica completa del indicador de un data.frame
#'
#' Resuelve por CARPETA, no por id: la carpeta es la clave del registro y su
#' ficha es la que esta dentro de ella, asi que no hay busqueda que pueda dar
#' con la ficha de otro indicador. Devuelve NULL si el data.frame no trae
#' procedencia estampada.
ind_ficha <- function(df) {
  carpeta <- ind_carpeta(df)
  if (is.null(carpeta)) return(NULL)
  ficha_de(carpeta)
}


# ─────────────────────────────────────────────────────────────────────────────
# 4. ALIAS LEGIBLES — mapeo nombre de variable -> indicador de origen
# ─────────────────────────────────────────────────────────────────────────────
# Esta es la unica tabla de equivalencias del proyecto. Los nombres cortos se
# conservan porque son los que leen los modulos (d_pobreza dentro de
# mod_pobreza.R se entiende solo; d_301 no). La trazabilidad esta garantizada
# por partida doble: la carpeta aparece aqui al lado del alias, y ademas viaja
# estampada dentro del propio data.frame (ver seccion 1).
#
# El comentario al final de cada linea lista las columnas del CSV.

# ── Poblacion (100-199) ──────────────────────────────────────────────────────
d_pob_total      <- .dato("101_poblacion_total")        # anio, total
d_pob_comunas    <- .dato("113_poblacion_comunas")      # comuna, pob
d_crecimiento    <- .dato("103_tasa_crecimiento")       # anio, total, tasa_crecimiento
d_edad           <- .dato("102_distribucion_sexo_edad") # grupo, hombre, mujer
d_natalidad      <- .dato("104_tasa_natalidad")         # anio, natalidad
d_mortalidad_general <- .dato("105_tasa_mortalidad_general") # anio, mortalidad
d_fecundidad     <- .dato("106_tasa_global_fecundidad") # anio, fecundidad
d_densidad       <- .dato("108_densidad_poblacional")   # anio, densidad
d_envejecimiento <- .dato("107_envejecimiento")         # anio, tasa_env, indice_env
d_migracion      <- .dato("112_poblacion_migrante")     # anio, inmigrantes

# ── Economia (200-299) ───────────────────────────────────────────────────────
d_variacion_pib  <- .dato("201_variacion_pib")          # anio, variacion_pib
d_sectores       <- .dato("202_participacion_sectorial")# sector, valor
d_empresas       <- .dato("203_empresas")               # anio, empresas
d_informalidad   <- .dato("208_informalidad_laboral")   # anio, informalidad
d_empleo         <- .dato("205_empleo")                 # anio, desempleo
d_pib            <- .dato("215_pib_regional")           # anio, pib
d_ocupacion      <- .dato("216_tasa_ocupacion")         # anio, ocupacion

# ── Pobreza e Ingresos (300-399) ─────────────────────────────────────────────
d_pobreza        <- .dato("301_pobreza")                # anio, pobreza_ingreso
d_pobreza_multi  <- .dato("302_pobreza_multidimensional")# anio, pobreza_multi
d_quintiles      <- .dato("305_ingreso_autonomo")       # quintil, ingreso
d_genero         <- .dato("306_brecha_salarial")        # categoria, ingreso
d_hacinamiento   <- .dato("307_hacinamiento")           # anio, hacinamiento
d_deficit_habitacional <- .dato("308_deficit_habitacional") # anio, deficit_habitacional

# ── Bienestar (400-499) ──────────────────────────────────────────────────────
d_salud          <- .dato("401_esperanza_vida")         # anio, esperanza
d_educacion      <- .dato("402_matricula")              # nivel, cobertura
d_asistencia     <- .dato("403_asistencia_escolar")     # anio, nivel, asistencia
d_escolaridad    <- .dato("404_anos_escolaridad")       # anio, escolaridad
d_matricula_superior <- .dato("405_matricula_educacion_superior") # anio, matricula
d_titulados_superior <- .dato("406_titulados_educacion_superior") # anio, titulados
d_vivienda       <- .dato("414_habitabilidad_vivienda") # categoria, valor
d_mortalidad     <- .dato("415_mortalidad_infantil")    # anio, mortalidad

# ── Cohesion Social (500-599) ────────────────────────────────────────────────
d_confianza      <- .dato("502_confianza_institucional")# institucion, confianza
d_homicidios     <- .dato("512_homicidios")             # anio, homicidios
d_suicidios      <- .dato("513_suicidios")              # anio, suicidios
d_crimen         <- .dato("511_delitos_dmcs")           # anio, tasa
d_electoral      <- .dato("515_participacion_electoral")# anio, electoral

# Carpeta con datos que aun no tiene alias (no la grafica ningun modulo
# todavia): 110_indice_masculinidad. Se carga igual en IND y esta disponible
# via .dato("110_indice_masculinidad").


# ─────────────────────────────────────────────────────────────────────────────
# 5. FICHAS METODOLOGICAS — una ficha.yaml por carpeta
# ─────────────────────────────────────────────────────────────────────────────
# Para agregar o editar una ficha: abrir indicadores/{id}_{slug}/ficha.yaml.
# La ficha vive junto a los datos que describe y al grafico que los publica, y
# es la que define el id del indicador.
#
# indicadores/indicadores.yaml SIGUE EXISTIENDO pero es un AGREGADO GENERADO:
# una vista unica de las 69 fichas, util para leer el catalogo entero de corrido
# y para que el diff de git sea legible. La app no lo lee. Se regenera con
# Rscript _dev/agregar_fichas.R cada vez que cambia una ficha.

# Los campos que toda ficha debe declarar. Es el contrato del formato, y por eso
# esta escrito aqui y no solo en el validador: la app avisa al arrancar cuando
# una ficha se queda corta.
.CAMPOS_FICHA_OBLIGATORIOS <- c(
  "id", "nombre", "seccion", "definicion", "unidad", "tipo_dato",
  "calculo", "fuente", "desagregaciones", "disponibilidad", "comentario"
)

# Los tres bloques de aparato interno (bitacora de quien mantiene el indicador).
# No se publican y no son rectangulares —son listas anidadas—, asi que se
# excluyen de d_indicadores y se consultan por ficha_de().
.BLOQUES_INTERNOS <- c("procesamiento", "notas_calidad", "historial")

#' Leer la ficha de una carpeta
#'
#' readLines + yaml.load en vez de yaml::read_yaml() para forzar la lectura como
#' UTF-8 de forma explicita: read_yaml depende del locale del sistema, que en el
#' servidor de despliegue no necesariamente es UTF-8.
#'
#' @param carpeta Nombre de carpeta del indicador, ej. "301_pobreza".
#' @return Lista con los campos de la ficha, o NULL si la carpeta no la trae.
.leer_ficha <- function(carpeta) {
  ruta <- file.path(.RUTA_INDICADORES, carpeta, "ficha.yaml")
  if (!file.exists(ruta)) return(NULL)
  ficha <- yaml::yaml.load(
    paste(readLines(ruta, encoding = "UTF-8", warn = FALSE), collapse = "\n"))
  ficha$carpeta <- carpeta
  ficha
}

# Registro de fichas, indexado por carpeta igual que IND y LAM.
FICHA <- .carpetas_indicador |>
  purrr::set_names() |>
  purrr::map(.leer_ficha) |>
  purrr::compact()

#' Ficha completa de un indicador, bloques internos incluidos
#'
#' Es el unico lugar donde se resuelve carpeta -> ficha. Antes este lookup
#' estaba escrito tres veces (aqui, en R/20_graficos.R y en _dev/ver.R), las tres
#' por id y las tres susceptibles al mismo desajuste entre carpeta y ficha.
#'
#' @param carpeta Nombre de carpeta, ej. "301_pobreza".
ficha_de <- function(carpeta) {
  if (is.null(FICHA[[carpeta]]))
    cli::cli_abort(c(
      "El indicador {.val {carpeta}} no tiene ficha.",
      "i" = "Se esperaba {.path {file.path(.RUTA_INDICADORES, carpeta, 'ficha.yaml')}}"
    ))
  FICHA[[carpeta]]
}

#' Las 69 fichas como data.frame, que es lo que consumen los modulos
#'
#' Conserva una fila por ficha y las mismas columnas de siempre, mas `carpeta`.
d_indicadores <- local({

  # Se apilan solo los campos rectangulares; los bloques internos son listas
  # anidadas y convertirian columnas enteras en columnas-lista.
  planas <- purrr::map(FICHA, \(f) f[setdiff(names(f), .BLOQUES_INTERNOS)])

  df <- dplyr::bind_rows(planas)
  df$id <- as.integer(df$id)

  # Columna derivada, no declarada en la ficha: ¿este indicador tiene datos
  # compilados en disco? Se calcula en vez de mantenerse a mano para que no
  # pueda quedar desactualizada — y se compara POR CARPETA, no por id. Cuando se
  # comparaba por id, la carpeta 304_quintiles (que contenia el indicador 305)
  # marcaba como compilada a la ficha 304 y dejaba a la 305 como pendiente.
  df$tiene_datos <- df$carpeta %in% .carpetas_con_datos

  dplyr::arrange(df, id)
})


# ─────────────────────────────────────────────────────────────────────────────
# 5b. REGISTRO DE FUENTES — de donde viene cada cifra
# ─────────────────────────────────────────────────────────────────────────────
# indicadores/fuentes.yaml es al capitulo VII lo que las fichas son al VI: el
# asiento de cada operacion estadistica que alimenta el catalogo. Hasta ahora
# solo se leia para validar los `fuente_id` (seccion 6) y para contar organismos
# en la portada; el lector no tenia donde ver que es CASEN ni cada cuanto sale.
#
# EL VINCULO VA EN UN SOLO SENTIDO
#   La ficha apunta a su fuente con `fuente_id`. La fuente NO lista sus piezas:
#   esa lista se deriva aqui de las 69 fichas, y por eso no puede quedar
#   desfasada. Antes iba al reves —cada fuente enumeraba los ids que la usaban— y
#   como nada lo validaba, los arrays cubrian 40 de 69 fichas.
#
# QUE SE DERIVA Y QUE NO
#   Todo lo de aqui son CONTEOS sobre las fichas, y se recalculan en cada
#   arranque: agregar una ficha mueve estas cifras solo. Las medidas que piden
#   teoria de grafos (intermediacion, articulaciones, comunidades) no se calculan
#   aqui: las congela _dev/red_fuentes.R en indicadores/red.yaml y se leen mas
#   abajo, estampadas con su fecha.

.RUTA_FUENTES <- file.path(.RUTA_INDICADORES, "fuentes.yaml")
.RUTA_RED     <- file.path(.RUTA_INDICADORES, "red.yaml")

#' Lectura UTF-8 explicita de un YAML del catalogo
#'
#' Mismo motivo que .leer_ficha(): yaml::read_yaml() depende del locale del
#' sistema, que en el servidor de despliegue no necesariamente es UTF-8.
.leer_yaml <- function(ruta) {
  if (!file.exists(ruta)) return(NULL)
  yaml::yaml.load(
    paste(readLines(ruta, encoding = "UTF-8", warn = FALSE), collapse = "\n"))
}

#' Registro de fuentes, indexado por id (FUENTE[["casen"]])
#'
#' Misma forma que FICHA e IND: lista nombrada por la clave que se cita.
FUENTE <- local({
  reg <- .leer_yaml(.RUTA_FUENTES)$fuentes
  if (is.null(reg)) list() else purrr::set_names(reg, purrr::map_chr(reg, "id"))
})

#' Asiento completo de una fuente por su id
#'
#' Falla con mensaje explicito, igual que ficha_de(): un NULL silencioso se
#' propagaria hasta el cuadro y ahi el error ya no se entiende.
fuente_de <- function(fuente_id) {
  if (is.null(FUENTE[[fuente_id]]))
    cli::cli_abort(c(
      "La fuente {.val {fuente_id}} no esta en el registro.",
      "i" = "Agregarla en {.path indicadores/fuentes.yaml}."
    ))
  FUENTE[[fuente_id]]
}

#' Las 16 fuentes como data.frame, con su carga derivada de las fichas
#'
#' Una fila por fuente. Las cuatro ultimas columnas no estan en el YAML: salen
#' de contar las fichas que apuntan a ella.
#'   piezas     cuantos indicadores declaran esta fuente como primaria
#'   compiladas cuantos de esos ya tienen datos.csv
#'   capitulos  en cuantas dimensiones aparece (1 = fuente de un solo capitulo)
#'   cuota      que fraccion del catalogo carga, en porcentaje
d_fuentes <- local({
  if (length(FUENTE) == 0) return(NULL)

  # Un campo ausente en el YAML se publica como cadena vacia y NO como NA: el
  # asiento del capitulo VII lo convierte en "Sin dato", que le dice al lector
  # algo distinto que una fila en blanco.
  campo <- function(f, nombre) {
    v <- f[[nombre]]
    if (is.null(v)) "" else paste(as.character(v), collapse = ", ")
  }

  base <- purrr::map_dfr(FUENTE, \(f) data.frame(
    stringsAsFactors = FALSE,
    fuente_id       = f$id,
    nombre          = campo(f, "nombre"),
    institucion     = campo(f, "institucion"),
    tipo            = campo(f, "tipo"),
    periodicidad    = campo(f, "periodicidad"),
    url             = campo(f, "url"),
    ediciones       = campo(f, "ediciones_disponibles")
  ))

  carga <- d_indicadores |>
    dplyr::filter(!is.na(fuente_id)) |>
    dplyr::group_by(fuente_id) |>
    dplyr::summarise(
      piezas     = dplyr::n(),
      compiladas = sum(tiene_datos),
      capitulos  = dplyr::n_distinct(seccion),
      .groups    = "drop")

  base |>
    dplyr::left_join(carga, by = "fuente_id") |>
    # coalesce y no tidyr::replace_na: el proyecto no declara tidyr y una fuente
    # registrada que todavia no alimenta ninguna ficha es legitima —queda en
    # cero, no en NA, para que el registro la publique igual.
    dplyr::mutate(
      piezas     = dplyr::coalesce(piezas, 0L),
      compiladas = dplyr::coalesce(compiladas, 0L),
      capitulos  = dplyr::coalesce(capitulos, 0L),
      cuota      = 100 * piezas / nrow(d_indicadores)) |>
    dplyr::arrange(dplyr::desc(piezas), nombre)
})

#' Las aristas del catalogo: cuantas piezas unen un capitulo con una fuente
#'
#' Es la tabla que dibujan las dos laminas del capitulo VII. Se deriva entera de
#' las fichas; no hay ninguna relacion declarada a mano.
d_red <- d_indicadores |>
  dplyr::filter(!is.na(fuente_id)) |>
  dplyr::count(seccion, fuente_id, name = "piezas") |>
  dplyr::arrange(seccion, dplyr::desc(piezas))

#' Medidas y posiciones del grafo, congeladas por _dev/red_fuentes.R
#'
#' NULL si el archivo no esta (la app funciona igual: el capitulo VII publica el
#' registro y las laminas, y omite el aparato de grafo). `al_dia` compara la
#' cuenta de piezas con que se calculo contra la de hoy: si el catalogo crecio y
#' nadie regenero el archivo, el capitulo lo declara en vez de publicar una
#' cifra vieja como si fuera de hoy.
RED <- local({
  red <- .leer_yaml(.RUTA_RED)
  if (is.null(red)) return(NULL)
  red$al_dia <- identical(as.integer(red$generado$piezas), nrow(d_indicadores))
  red
})


# ─────────────────────────────────────────────────────────────────────────────
# 6. VALIDACION — que el id mande de verdad
# ─────────────────────────────────────────────────────────────────────────────
# La regla del catalogo es: una carpeta, un indicador, una ficha, un id. Los
# tres primeros chequeos la hacen cumplir y ABORTAN, porque una identidad
# ambigua no produce un error visible sino un dato publicado bajo el nombre
# equivocado — que es lo que estuvo pasando con 304/305. Los demas son avisos
# de mantenimiento y no detienen la app.

local({

  # (a) Carpeta de indicador sin ficha.yaml. Sin ficha el indicador no es
  #     citable: no tiene nombre, ni fuente, ni asiento en el capitulo VI.
  sin_ficha <- setdiff(.carpetas_indicador, names(FICHA))
  if (length(sin_ficha) > 0)
    cli::cli_abort(c(
      "Carpeta{?s} de indicador sin ficha.yaml: {.val {sin_ficha}}",
      "i" = "Copiar {.path indicadores/_plantilla/ficha.yaml} y completarla."
    ))

  # (b) El id de la ficha debe ser el prefijo de su carpeta. Es LA regla: si se
  #     permite que difieran, vuelve a haber dos ids para la misma pieza.
  descalce <- purrr::keep(FICHA, \(f)
    !identical(as.integer(f$id),
               as.integer(stringr::str_extract(f$carpeta, "^\\d+"))))

  if (length(descalce) > 0) {
    detalle <- purrr::map_chr(descalce, \(f)
      sprintf("%s declara id: %s", f$carpeta, f$id))
    cli::cli_abort(c(
      "El id de la ficha no coincide con el prefijo de su carpeta:",
      stats::setNames(detalle, rep("*", length(detalle))),
      "i" = "Renombrar la carpeta o corregir el id. El id manda."
    ))
  }

  # (c) Dos carpetas con el mismo id. Historicamente paso: 101_poblacion_total y
  #     101_poblacion_comunas compartian el 101, y dos cuadros distintos
  #     colgaban de una misma ficha. Se resolvio dandole la 113 a la segunda.
  ids <- purrr::map_int(FICHA, \(f) as.integer(f$id))
  repetidos <- unique(ids[duplicated(ids)])
  if (length(repetidos) > 0)
    cli::cli_abort(
      "Id{?s} repetido{?s} en varias carpetas: {.val {repetidos}}")

  # (d) Campos obligatorios ausentes o vacios. Aviso, no error: una ficha a
  #     medio redactar debe poder convivir con el resto mientras se completa.
  incompletas <- purrr::imap(FICHA, \(f, carpeta) {
    faltan <- purrr::keep(.CAMPOS_FICHA_OBLIGATORIOS, \(campo) {
      v <- f[[campo]]
      is.null(v) || !nzchar(trimws(as.character(v)))
    })
    if (length(faltan)) sprintf("%s: %s", carpeta, paste(faltan, collapse = ", "))
  }) |> purrr::compact()

  if (length(incompletas) > 0) {
    cli::cli_alert_warning("Fichas con campos sin completar ({length(incompletas)}):")
    for (x in incompletas) cli::cli_li(x)
  }

  # (e) fuente_id que no existe en el registro de fuentes. El vinculo entre la
  #     ficha y su fuente es el unico que cruza archivos, asi que es el unico
  #     que puede quedar colgando.
  if (length(FUENTE) > 0) {
    colgadas <- purrr::keep(FICHA, \(f)
      !is.null(f$fuente_id) && !f$fuente_id %in% names(FUENTE))

    if (length(colgadas) > 0)
      cli::cli_alert_warning(
        "Fichas con fuente_id que no esta en fuentes.yaml: {.val {names(colgadas)}}")

    # (e2) Fuente registrada que ninguna ficha usa. No es un error —puede estar
    #      abierta para un indicador que viene—, pero el capitulo VII la publica
    #      con cero piezas y conviene saberlo.
    ociosas <- setdiff(names(FUENTE), stats::na.omit(d_indicadores$fuente_id))
    if (length(ociosas) > 0)
      cli::cli_alert_info(
        "Fuente{?s} registrada{?s} que ninguna ficha usa: {.val {ociosas}}")
  }

  # (g) El aparato de grafo del capitulo VII se calcula fuera de la app y se
  #     congela en indicadores/red.yaml. Si el catalogo crecio despues de esa
  #     corrida, el archivo describe otro grafo: el capitulo lo publica marcado
  #     como desactualizado, y este aviso dice como ponerlo al dia.
  if (!is.null(RED) && !isTRUE(RED$al_dia))
    cli::cli_alert_warning(c(
      "indicadores/red.yaml se calculo con {RED$generado$piezas} piezas y hoy hay {nrow(d_indicadores)}. ",
      "Regenerar con: Rscript _dev/red_fuentes.R"))

  # (f) Carpetas sin datos.csv. Normal: son las fichas documentadas cuyos datos
  #     estan pendientes de compilar. Se reportan para saber que falta.
  sin_datos <- setdiff(.carpetas_indicador, .carpetas_con_datos)
  if (length(sin_datos) > 0)
    cli::cli_alert_info(
      "Fichas sin datos.csv ({length(sin_datos)}), pendientes de compilar")

  cli::cli_alert_success(
    "Datos cargados: {length(IND)} archivo{?s} en {sum(d_indicadores$tiene_datos)} de {nrow(d_indicadores)} indicadores documentados")
})

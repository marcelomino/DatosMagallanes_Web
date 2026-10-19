# ═════════════════════════════════════════════════════════════════════════════
# R/20_graficos.R  —  Registro de laminas del catalogo
#
# QUE HACE ESTE ARCHIVO
#   Barre indicadores/*/grafico.R y arma LAM, el registro de laminas. Es a los
#   graficos lo que R/00_data.R es a los datos: un barrido de carpetas que deja
#   todo en memoria al arrancar.
#
#     IND[["511_delitos_dmcs"]]          el data.frame     (R/00_data.R)
#     LAM[["511_delitos_dmcs"]][["V.3"]] la lamina         (este archivo)
#
# POR QUE EXISTE
#   Cada grafico se escribia dentro del modulo de su capitulo, de modo que cada
#   indicador nuevo engordaba un modulo. La ingesta de datos ya era granular
#   —una carpeta por indicador— y el codigo de sus graficos no seguia esa regla.
#   Ahora si: el grafico de un indicador vive en la carpeta de ese indicador, y
#   agregar un indicador no obliga a tocar ningun modulo.
#
# QUE NO HACE — y es deliberado
#   No interpreta el grafico. No hay vocabulario declarativo ni constructor de
#   formas: cada lamina es echarts4r plano, escrito por quien la publica. Este
#   archivo solo la ubica, la identifica contra su ficha y la entrega. Quien
#   sepa R y echarts4r puede editar una lamina sin aprender nada de este
#   archivo.
#
# ORDEN DE CARGA — importa
#   Va DESPUES de R/00_data.R (usa .RUTA_INDICADORES, .carpetas_con_datos y
#   ficha_de()) y DESPUES de R/10_utils.R (los grafico.R usan PAL, e_lamina()
#   y los formateadores). Ver el encabezado de construir.R.
#
# EFICIENCIA
#   Los grafico.R se evaluan UNA VEZ al construir el sitio. Cada variante que
#   el lector puede pedir (rango de anos, eje desde cero) se dibuja entonces con
#   dibujar() y viaja ya hecha en la pagina: el navegador no recalcula nada.
# ═════════════════════════════════════════════════════════════════════════════


# ─────────────────────────────────────────────────────────────────────────────
# 1. CARGA DE UN grafico.R
# ─────────────────────────────────────────────────────────────────────────────

#' El entorno donde se cargo el catalogo
#'
#' construir.R sourcea R/ en el entorno global, pero no se da por supuesto: se
#' captura el entorno de carga de este archivo y de el se cuelgan los entornos
#' de cada grafico.R. Asi PAL, e_lamina() y los formateadores de R/10_utils.R
#' quedan a la vista de las laminas donde sea que se cargue el catalogo (el
#' dashboard Shiny los cargaba en un entorno propio de runApp()).
#'
#' Con globalenv() fijo, cargar R/ en otro entorno haria que las laminas
#' cargaran sin error y fallaran recien al dibujar, con un "could not find
#' function tip_eje".
.ENTORNO_APP <- environment()

#' Cargar las laminas declaradas en la carpeta de un indicador
#'
#' Lee indicadores/{carpeta}/grafico.R, que debe definir un unico objeto
#' `laminas`: una lista de laminas (ver la plantilla en
#' indicadores/_plantilla/grafico.R).
#'
#' Cada archivo se evalua en su PROPIO entorno, colgado del entorno de la app.
#' Asi una variable auxiliar de un indicador no se filtra ni pisa la de otro,
#' pero el archivo sigue viendo PAL, e_lamina() y los formateadores.
#'
#' @param carpeta Nombre de carpeta del indicador, ej. "511_delitos_dmcs".
#' @return Lista de laminas nombrada por numero de cuadro, o NULL si la carpeta
#'   no declara graficos (un indicador puede tener datos y no publicarse aun).
cargar_laminas <- function(carpeta) {

  ruta <- file.path(.RUTA_INDICADORES, carpeta, "grafico.R")
  if (!file.exists(ruta)) return(NULL)

  env <- new.env(parent = .ENTORNO_APP)
  source(ruta, local = env, encoding = "UTF-8")

  if (is.null(env$laminas))
    cli::cli_abort(c(
      "{.path {ruta}} no define el objeto {.code laminas}.",
      "i" = "Debe ser una lista de laminas. Ver {.path indicadores/_plantilla/grafico.R}"
    ))

  laminas <- purrr::map(env$laminas, .identificar, carpeta = carpeta)
  purrr::set_names(laminas, purrr::map_chr(laminas, "numero"))
}


# ─────────────────────────────────────────────────────────────────────────────
# 2. IDENTIFICACION — lo que manda la ficha
# ─────────────────────────────────────────────────────────────────────────────

# Alto de TODA lamina, y por lo tanto la unica relacion de aspecto del catalogo:
# el ancho lo da el pliego, que es comun a los 36 cuadros. La justificacion
# medida esta en .identificar(), unas lineas mas abajo.
#
# VIVE AQUI Y NO EN R/10_utils.R, aunque ahi estarian sus vecinas naturales:
# .identificar() la necesita en tiempo de carga, y asi la constante esta junto
# a la unica funcion que la usa.
.ALTURA_CUADRO <- "400px"

#' Completar una lamina con lo que manda su ficha metodologica
#'
#' El titulo del cuadro y la fuente al pie NO se escriben en el grafico.R: se
#' derivan de la ficha de la carpeta. Dos razones:
#'
#'   - El titulo debe coincidir con el asiento del capitulo VI, que es el
#'     catalogo. Si se escribieran a mano, el catalogo y el cuadro podrian
#'     nombrar distinto a la misma pieza.
#'   - Ya paso una vez con la unidad: un modulo publicaba "por mil" donde la
#'     ficha 511 dice "Por 100.000 habitantes" — la misma cifra leida con un
#'     factor de 100 de diferencia (ver R/40_mod_cohesion.R).
#'
#' La ficha es la de la CARPETA y no se declara. Hasta septiembre de 2026 cada
#' lamina traia un campo `ficha` con el id, porque el prefijo de la carpeta no
#' era confiable. Ese campo era el parche de un problema de identidad, no una
#' funcion: mientras existio, 304_quintiles pudo apuntar a la ficha 305 y el
#' resto del sistema siguio creyendo que era la 304. Ahora la regla la hace
#' cumplir R/00_data.R al arrancar, y la lamina hereda la ficha de donde vive.
#'
#' @param lam     La lamina tal como viene del grafico.R.
#' @param carpeta Carpeta de origen, que es tambien la que aporta la ficha.
.identificar <- function(lam, carpeta) {

  # Los dos obligatorios. Se falla aqui, al arrancar, y no en el primer
  # redibujo: un NULL que viaja hasta echarts produce un error incomprensible.
  for (campo in c("numero", "dibujo"))
    if (is.null(lam[[campo]]))
      cli::cli_abort(c(
        "Lamina sin {.code {campo}} en {.path {carpeta}/grafico.R}.",
        "i" = "Campos obligatorios: numero, dibujo."
      ))

  # Un `ficha` residual es una intencion que ya no se cumple: quien lo escribio
  # esperaba colgar la lamina de OTRA ficha. Ignorarlo en silencio reintroduce
  # exactamente el desajuste que el renombre de carpetas vino a cerrar.
  if (!is.null(lam$ficha))
    cli::cli_abort(c(
      "La lamina {.val {lam$numero}} ({carpeta}) declara {.code ficha = {lam$ficha}}.",
      "x" = "El campo {.code ficha} ya no existe.",
      "i" = "La lamina toma la ficha de su propia carpeta. Si querias otra, la
             lamina esta en la carpeta equivocada."
    ))

  if (!is.function(lam$dibujo))
    cli::cli_abort(
      "El {.code dibujo} de la lamina {.val {lam$numero}} ({carpeta}) no es una funcion.")

  ficha <- ficha_de(carpeta)

  lam$carpeta <- carpeta
  lam$titulo  <- ficha$nombre
  lam$fuente  <- ficha$fuente
  # La unidad viaja con el titulo por la misma razon que el titulo viaja con la
  # ficha: el cuadro no puede leerse sin ella, y si cada modulo la escribiera a
  # mano volveria a pasar lo de la nota de arriba — un cuadro publicando "por
  # mil" donde la ficha dice "Por 100.000 habitantes".
  lam$unidad  <- ficha$unidad
  # La definicion baja al pie del cuadro. El lector ya no tiene que cruzar al
  # capitulo VI para saber QUE esta mirando: la pieza se explica donde se
  # dibuja, y el asiento queda para la ficha tecnica completa.
  lam$definicion <- ficha$definicion
  # UNA SOLA RELACION DE ASPECTO PARA TODO EL CATALOGO.
  #
  # Antes cada lamina declaraba su alto y habia cinco valores distintos, puestos
  # a ojo. Ahora es uno: a ancho completo del pliego (~1292px) da 3,23:1.
  #
  # DE DONDE SALE ESE NUMERO. No del banking a 45 grados de Cleveland: Talbot,
  # Gerth y Hanrahan (An Empirical Model of Slope Ratio Comparisons, InfoVis
  # 2012) muestran que el error NO se minimiza en 45 grados —el minimo se corre
  # por debajo de 30— y que conviene preferir relaciones mas planas; su modelo
  # elige consistentemente mas plano que el median absolute slope. Aplicado a
  # estas series, el banking pedia entre 646 y 2.541 pixeles de alto.
  #
  # El criterio que si se aplico es el suyo: el error sube fuerte pasados los 45
  # grados de angulo medio. Medido sobre las 23 series de linea del catalogo con
  # el eje anclado en cero, 400px deja el angulo mediano en 8,3 grados —dentro
  # de la region de error bajo, que su segundo experimento muestra aun mas baja
  # cuando hay una linea base visible, como es nuestro caso— y solo una serie
  # (V.5, con su 2010 en cero) llega a 49.
  if (is.null(lam$altura)) lam$altura <- .ALTURA_CUADRO

  # QUE LAMINAS ADMITEN EL CONMUTADOR DEL CERO.
  # Las de barras NO, y no es una omision: en una barra la LONGITUD es el valor,
  # asi que mover la base recorta la barra y la magnitud que dibuja deja de ser
  # la del dato. En una linea el cero es contexto —se puede quitar declarandolo—;
  # en una barra es constitutivo. Por eso el control ni siquiera se ofrece ahi.
  # "e_bar_?" cubre tambien la forma con nombre de columna en texto (e_bar_()).
  lam$admite_cero <- !any(grepl("e_bar_?\\(", deparse(lam$dibujo)))

  lam
}


# ─────────────────────────────────────────────────────────────────────────────
# 3. EL REGISTRO
# ─────────────────────────────────────────────────────────────────────────────

#' Registro de laminas: lista nombrada carpeta -> laminas de esa carpeta
#'
#' Uso:  LAM[["511_delitos_dmcs"]][["V.3"]]
#'
#' purrr::compact() descarta las carpetas que aun no publican grafico, para que
#' LAM contenga solo lo que efectivamente se dibuja.
LAM <- .carpetas_con_datos |>
  purrr::set_names() |>
  purrr::map(cargar_laminas) |>
  purrr::compact()


# ─────────────────────────────────────────────────────────────────────────────
# 4. DIBUJO
# ─────────────────────────────────────────────────────────────────────────────

#' Dibujar una lamina
#'
#' La lamina es una funcion pura: recibe datos y devuelve un objeto echarts4r.
#' No conoce Shiny, no guarda estado y no tiene controles. Cuando un cuadro es
#' interactivo, el modulo del capitulo conserva los inputs y le pasa aqui el
#' resultado: el data.frame ya filtrado, o la seleccion por `...`.
#'
#' Por eso mismo se puede llamar desde la consola de R sin levantar la app:
#'   dibujar(LAM[["511_delitos_dmcs"]][["V.3"]], d_crimen)
#'
#' @param lam Lamina del registro.
#' @param df  Datos ya listos para graficar.
#' @param ... Argumentos extra del dibujo, en las laminas que eligen serie.
#' @param cero TRUE ancla el eje de valor en el cero; FALSE lo ajusta al dato.
#'   Lo decide el lector, cuadro por cuadro, con el conmutador que el modulo
#'   pone sobre el grafico. NULL dibuja el estado que la lamina declara
#'   (lam$cero_inicial, ver la seccion 5). Ver .anclar_cero().
dibujar <- function(lam, df, ..., cero = NULL) {
  cero <- cero %||% lam$cero_inicial %||% TRUE
  .encuadrar(.anclar_cero(lam$dibujo(df, ...), cero))
}

#' Anclar el eje de valor en el cero, o ajustarlo al dato
#'
#' POR QUE EL CERO ES EL DEFECTO, Y POR QUE ADEMAS SE PUEDE APAGAR
#'   Anclar en cero dice la magnitud: 7,9 nacidos por mil se lee contra la
#'   escala completa y no contra un recorte. Esa es la razon de catalogo.
#'   Hay ademas una razon perceptual medida: Talbot, Gerth y Hanrahan (InfoVis
#'   2012) encuentran que una LINEA BASE VISIBLE reduce sustancialmente el error
#'   al juzgar pendientes —"practicamente elimina el error para angulos medios
#'   menores a 45 grados"—, y el cero es esa linea base.
#'
#'   Apagarlo es legitimo y por eso se ofrece: sobre un tramo alto y estrecho el
#'   cero aplasta la serie contra el techo. Pero no es gratis, y el lector debe
#'   saberlo: al recortar el eje se pierde la linea base y con ella parte de esa
#'   exactitud. De ahi la glosa junto al conmutador.
#'
#' SE APLICA AQUI Y NO EN CADA grafico.R porque son 35 laminas con cinco formas
#' distintas de declarar su eje. Post-procesar el objeto ya construido es la
#' unica manera de que el conmutador valga para todas sin reescribir ninguna.
#'
#' EL EJE QUE LA LAMINA DECLARA GANA SI YA CUMPLE LO PEDIDO. III.1 y III.2
#' declaran el mismo 0-12 para que las dos pobrezas sigan siendo comparables;
#' II.3 declara un eje holgado que no toca el cero. Reescribirlos siempre
#' borraba esas decisiones en el primer dibujo. Solo se reescribe el eje que
#' contradice el estado del conmutador (ver .eje_cumple()).
#'
#' CADA EJE SE AJUSTA CON SUS PROPIAS SERIES. En un grafico de doble eje (I.5:
#' tasa en % a la izquierda, indice a la derecha) un rango comun aplastaba la
#' serie chica contra el piso y dejaba el segundo eje sin oficio.
.anclar_cero <- function(e, cero) {
  ejes <- .eje_de_valor(e)
  if (is.null(ejes)) return(e)

  for (k in ejes) {
    v <- .valores_de_serie(e, k)
    if (!length(v)) next
    eje <- e$x$opts[[k[[1]]]][[k[[2]]]]
    if (.eje_cumple(eje, v, cero)) next

    if (isTRUE(cero)) {
      # min(0, ...) y no 0 a secas: la variacion del PIB tiene anos negativos y
      # anclarla en cero duro recortaria las barras hacia abajo.
      eje$min      <- min(0, min(v))
      eje$max      <- NULL
      eje$interval <- NULL
    } else {
      paso <- .paso_lindo(diff(range(v)))
      # El paso no puede ser mas fino que lo que el rotulo sabe mostrar. La
      # densidad poblacional se mueve entre 1,3 y 1,4 y su formateador imprime
      # un decimal: con paso 0,05 el eje publicaba "1.4 / 1.4 / 1.3", dos
      # rotulos iguales para dos cortes distintos.
      paso <- max(paso, .paso_minimo(eje$axisLabel$formatter))
      h <- eje_holgado(v, paso)
      eje$min      <- h$min
      eje$max      <- h$max
      eje$interval <- h$interval
    }
    e$x$opts[[k[[1]]]][[k[[2]]]] <- eje
  }
  e
}

# Si el eje que la lamina declaro ya cumple el estado pedido, se deja intacto.
#   Anclado: su min es numerico, no pasa del cero y no recorta ningun dato.
#   Ajustado: su min esta sobre el cero (ver .min_sobre_cero()).
# Un eje sin min declarado nunca cumple: es el que el conmutador debe resolver.
.eje_cumple <- function(eje, v, cero) {
  if (!isTRUE(cero)) return(.min_sobre_cero(eje))
  m <- eje$min
  is.numeric(m) && length(m) == 1 && m <= min(0, min(v))
}

# LA UNICA DEFINICION DE "este eje no ancla en cero": un min numerico mayor que
# cero. La usan .eje_cumple() y el estado inicial del conmutador (seccion 5),
# para que el control y el dibujo no puedan discrepar sobre lo mismo.
.min_sobre_cero <- function(eje) {
  m <- eje$min
  is.numeric(m) && length(m) == 1 && m > 0
}

# El eje de valor es el que NO es de categorias. Se busca en los dos porque
# e_flip_coords() los intercambia: en un grafico de barras horizontales el valor
# vive en el eje x. Devuelve pares (nombre_de_eje, indice).
.eje_de_valor <- function(e) {
  out <- list()
  for (nm in c("yAxis", "xAxis")) {
    ejes <- e$x$opts[[nm]]
    if (is.null(ejes)) next
    if (!is.null(names(ejes))) ejes <- list(ejes)   # un solo eje, sin envolver
    for (i in seq_along(ejes))
      if (!identical(ejes[[i]]$type, "category")) out[[length(out)+1]] <- list(nm, i)
  }
  if (length(out)) out else NULL
}

# Los valores que la lamina efectivamente dibuja. echarts4r entrega cada dato
# como el par [categoria, valor], asi que el valor es el ULTIMO elemento.
#
# EL ORDEN DE ESTAS DOS LINEAS IMPORTA. Hay que tomar la ultima posicion y
# DESPUES descartar lo que no sea finito, nunca al reves: la fecundidad no tiene
# dato para 2017 y su par es ("2017", NA). Filtrando primero, el NA desaparecia
# y la "ultima posicion" pasaba a ser el ANO — 2017 entraba como si fuera un
# valor y el eje ajustado de ese cuadro salia de 0 a 3000.
#
# `eje` es un par de .eje_de_valor(): se toman solo las series que cuelgan de
# ese eje, por su yAxisIndex o xAxisIndex; echarts4r los numera desde cero.
.valores_de_serie <- function(e, eje) {
  campo  <- if (eje[[1]] == "yAxis") "yAxisIndex" else "xAxisIndex"
  series <- purrr::keep(e$x$opts$series, \(s) (s[[campo]] %||% 0) == eje[[2]] - 1)
  v <- unlist(lapply(series, function(s) {
    lapply(s$data, function(d) {
      n <- suppressWarnings(as.numeric(unlist(d)))
      if (!length(n)) return(NULL)
      n[length(n)]
    })
  }))
  v[is.finite(v)]
}

# El corte mas fino que el rotulo del eje puede distinguir. Los formateadores
# del proyecto se arman todos con eje_cifra(), que termina llamando a
# DM.n(x, <decimales>) — asi que los decimales se leen del propio JS en vez de
# mantener una segunda declaracion que podria discrepar. Si el formateador no
# es de los nuestros, no se impone minimo: mejor no adivinar.
.paso_minimo <- function(formateador) {
  if (is.null(formateador)) return(0)
  m <- regmatches(as.character(formateador),
                  regexpr("DM\\.n\\([^,]+,\\s*([0-9]+)\\)", as.character(formateador)))
  if (!length(m)) return(0)
  dec <- as.numeric(sub(".*,\\s*([0-9]+)\\)", "\\1", m))
  if (!is.finite(dec)) 0 else 10^(-dec)
}

# Paso de corte redondo para un rango dado: 1, 2 o 5 por la potencia de diez
# que corresponda. Sin esto el eje ajustado quedaria con cortes como 3,7 / 7,4.
.paso_lindo <- function(rango) {
  if (!is.finite(rango) || rango <= 0) return(1)
  crudo <- rango / 4
  mag   <- 10^floor(log10(crudo))
  norm  <- crudo / mag
  mag * if (norm <= 1) 1 else if (norm <= 2) 2 else if (norm <= 5) 5 else 10
}

#' Llevar el area de dibujo a los bordes del cuadro
#'
#' ECharts reserva por defecto 60px arriba y 60px abajo, mas un 10% a cada
#' lado, para un titulo y una leyenda que en este catalogo no existen: el
#' titulo vive en la cabecera del cuadro y casi toda lamina oculta su leyenda.
#' Sobre un lienzo de 280px eso son 120px —el 43% de la tarjeta— gastados en
#' margen, que es lo que hacia ver el grafico pequeno dentro de su cuadro.
#'
#' UNA SOLA REGLA PARA LAS 35 LAMINAS. Antes cada lamina de barras llevaba su
#' propio `e_grid()` en porcentajes medidos a ojo —14%, 22%, 26%, 34% a la
#' izquierda segun el largo de sus rotulos— y ninguna coincidia con otra. Eso
#' es exactamente lo que `containLabel` resuelve solo: el margen se mide
#' INCLUYENDO los rotulos de eje, asi que "Punta Arenas" y "Pesca y
#' Acuicultura" reservan su ancho sin que nadie lo calcule.
#'
#' LO QUE containLabel NO MIDE son las cifras que la serie dibuja fuera de la
#' barra, porque no son rotulos de eje sino etiquetas de dato. Son los tres
#' casos que esta funcion reconoce y compensa:
#'   - `position = "right"`  cifra al costado de una barra horizontal
#'   - `position = "top"`    cifra sobre una barra vertical
#'   - `markLine` rotulada   el "50%" del datum de confianza institucional
#' A eso se suma la leyenda al pie, que vive fuera del grid.
#'
#' Va en `dibujar()` y no en `e_lamina()` porque `e_grid()` de echarts4r
#' APPENDEA en vez de fusionar: un grid puesto antes del pipe convivira con el
#' de la lamina como dos regiones, no como una. Aqui el pipe ya termino.
.encuadrar <- function(e) {
  series <- e$x$opts$series
  if (is.null(series)) series <- list()

  # La etiqueta de dato existe y apunta a `p`. e_labels() la pone en todas las
  # series de la lamina, pero basta con que una la traiga para tener que abrir
  # el margen de ese lado.
  etiqueta_en <- function(p) any(purrr::map_lgl(series, function(s)
    !identical(s$label$show, FALSE) && identical(s$label$position, p)))

  datum_rotulado <- any(purrr::map_lgl(series, function(s)
    isTRUE(s$markLine$label$show)))

  leyenda <- !identical(e$x$opts$legend$show, FALSE)
  al_pie  <- leyenda && !is.null(e$x$opts$legend$bottom)

  e$x$opts$grid <- list(list(
    left   = 8,
    right  = if (etiqueta_en("right")) 56 else 14,
    top    = if (etiqueta_en("top") || datum_rotulado || (leyenda && !al_pie)) 34 else 16,
    bottom = if (al_pie) 38 else 8,
    containLabel = TRUE
  ))
  e
}


# ─────────────────────────────────────────────────────────────────────────────
# 5. CON QUE ESTADO ARRANCA EL CONMUTADOR DEL CERO
# ─────────────────────────────────────────────────────────────────────────────
# Algunas laminas declaran un eje que NO ancla en cero (participacion electoral,
# esperanza de vida: un tramo alto y estrecho que el cero aplastaria contra el
# techo). El conmutador tiene que arrancar en ese estado; si arrancara marcado,
# el primer dibujo desharia la decision del grafico.R antes de que el lector
# toque nada.
#
# SE LEE DEL EJE DIBUJADO, no del codigo de la lamina: cada una se dibuja una
# vez con sus propios datos y se mira su eje de valor con .min_sobre_cero(),
# la misma prueba que usa .anclar_cero(). Buscar "eje_holgado(" en el texto
# fallaba con un min escrito a mano y se dejaba enganar por un comentario.
# Va aqui y no en .identificar() porque necesita las funciones de la seccion 4.
.cero_declarado <- function(lam) {
  e <- tryCatch(lam$dibujo(IND[[lam$carpeta]]), error = \(err) NULL)
  ejes <- if (!is.null(e)) .eje_de_valor(e)
  !any(purrr::map_lgl(ejes, \(k) .min_sobre_cero(e$x$opts[[k[[1]]]][[k[[2]]]])))
}

LAM <- purrr::map(LAM, \(laminas) purrr::map(laminas, \(lam) {
  lam$cero_inicial <- .cero_declarado(lam)
  lam
}))


# ─────────────────────────────────────────────────────────────────────────────
# 6. VALIDACION AL ARRANCAR
# ─────────────────────────────────────────────────────────────────────────────
# Aviso de mantenimiento, no error: una carpeta con datos y sin grafico.R es
# legitima mientras el indicador no se publique. Los errores de verdad (falta
# un campo obligatorio, la ficha no existe) ya abortaron en .identificar().

local({
  sin_grafico <- setdiff(.carpetas_con_datos, names(LAM))
  if (length(sin_grafico) > 0)
    cli::cli_alert_info(
      "Carpetas con datos y sin grafico.R ({length(sin_grafico)}): {.val {sin_grafico}}")

  cli::cli_alert_success(
    "Laminas cargadas: {sum(purrr::map_int(LAM, length))} en {length(LAM)} indicador{?es}")
})

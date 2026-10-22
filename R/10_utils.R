# ═════════════════════════════════════════════════════════════════════════════
# R/10_utils.R — El Boletin de campo
#
# Cada indicador es una pieza acatalogada: su numero de acceso es su identidad
# y viaja con la cifra. La interfaz es el mobiliario del catalogo — portadilla,
# cuadro, asiento — vestido como el Boletin de Estudios Regionales N.2 y leido
# como una hoja de campo: curvas de nivel, coordenadas, mono en lo que se cita.
#
# QUE CONTIENE ESTE ARCHIVO
#   1. Paleta (PAL) y los dos colores del manual UMAG
#   2. Tema bslib y tema de grafico echarts4r
#   3. Tintas de serie y helpers de color para graficos
#   4. Formato numerico chileno (en R)
#   4b. El mismo formato dentro del grafico (en el navegador)
#   5. Mobiliario del catalogo: portadilla, inventario, CSV y JSON del sitio
#   6. La cifra vigente y su fuente
#
# LA REGLA DE COLOR DE ESTE MUNDO
#   Papel blanco y tinta violeta-negra, como el Boletin. Cada color tiene UN
#   trabajo y no hace otro:
#     magenta         la banda (una palabra por titular, la cobertura de la
#                     portadilla) y la serie protagonista de todo grafico
#     magenta_prof    toda numeracion en texto chico: numero de acceso,
#                     direccion de cuadro, numeral de capitulo
#     azul            SOLO lo accionable: enlace, pestana activa, foco, control
#     violeta         segunda serie de grafico
#     teal            SOLO la pestana de edicion (y el trazo del paisaje)
#     bano            el duotono de la foto de cada portadilla
#
# QUE YA NO ESTA
#   El aparato de referencia del mundo anterior (conmutador nivel / indice /
#   variacion, ano base, linea de reduccion y re_referir) se retiro por completo.
#   Ninguna cifra se transforma en la interfaz: se publica la que trae la fuente,
#   y la medida de variacion es la que la fuente misma publica, cuando existe.
# ═════════════════════════════════════════════════════════════════════════════

library(echarts4r)

# ─────────────────────────────────────────────────────────────────────────────
# 1. PALETA
# ─────────────────────────────────────────────────────────────────────────────
# Los dos colores del Breve Manual de Normas Graficas UMAG y lo derivado de
# ellos. Regla del proyecto: ningun color se escribe a mano fuera de aqui y de
# las variables de :root en www/styles.css.

AZUL    <- "#4A5CAB"   # Pantone 2728 C — la tinta de trabajo
VIOLETA <- "#593D80"   # Pantone 268 C  — el campo institucional

# ── Edicion: fuente unica de verdad ──────────────────────────────────────────
# La version, el ano de desarrollo y la fecha de actualizacion aparecen en dos
# umbrales distintos (el pie de la cubierta y el colofon de cada pagina). Se
# declaran una sola vez aqui para que actualizar una edicion sea un solo cambio.
.EDICION <- list(
  version     = "v0.13.0",
  anio        = 2026,
  actualizado = "17-10-2026",
  mes         = "Oct 2026"     # la pestana de edicion de la barra de marca
)

# ── Datos de prototipo: un solo interruptor ──────────────────────────────────
# Mientras las series publicadas sean de prototipo, lo declaran el inventario de
# cada capitulo, el pie de cada cuadro y el CSV que se descarga: la
# advertencia viaja con todo lo que puede salir del sitio. Cuando lleguen las
# cifras oficiales verificadas se pone en FALSE y sale de todas partes a la vez.
# (La entrada y la portada la llevan escrita en su propio texto.)
.PROTOTIPO       <- TRUE
.AVISO_PROTOTIPO <- "Serie de prototipo, no cifra oficial"

# ── La descripcion que viaja fuera del sitio ─────────────────────────────────
# La usan a la vez meta description, Open Graph y Twitter Card (ver R/50_sitio.R). Se
# declara una sola vez porque tres copias de la misma frase terminan
# discrepando, y la que se desactualiza es siempre la que nadie mira.
# SI lleva tildes, a diferencia de los textos de UI: no la dibuja Shiny, la lee
# un rastreador y se publica en un chat o un correo.
.DESCRIPCION_SOCIAL <- paste(
  "Los indicadores de población, economía, pobreza, bienestar y cohesión social",
  "de la Región de Magallanes, reunidos en un solo lugar y con su fuente,",
  "definición y cálculo declarados."
)

MAGENTA <- "#E82D88"   # el magenta de imprenta del Boletin de Estudios Regionales N.2

PAL <- list(
  # Superficies. Papel blanco, como el Boletin: el catalogo es un impreso de la
  # misma familia editorial. El campo es el unico escalon tonal, tenido del
  # violeta y no gris, para el pie de cuadro, la fila en hover y el colofon.
  papel      = "#ffffff",   # fondo de pagina
  lamina     = "#ffffff",   # superficie de trabajo (cuadros, asientos)
  campo      = "#f5f3f7",   # pie de cuadro, colofon, hover
  fila       = "#efecf2",   # fila en hover sobre lamina
  # Tinta violeta-negra del Boletin.
  tinta      = "#1D1320",   # texto principal            (17,6:1 sobre papel)
  tinta2     = "#5A4E60",   # texto secundario            (7,9:1)
  tinta3     = "#6c6272",   # texto terciario y rotulos   (6,0:1)
  # Filetes: el unico recurso estructural del sistema.
  regla      = "#dcd6e0",
  regla_fina = "#ece8ef",
  # Los dos del manual
  azul       = AZUL,        # SOLO lo accionable: enlaces, pestana activa, foco, control activo
  violeta    = VIOLETA,     # segunda serie de grafico
  # El Boletin
  magenta      = MAGENTA,   # banda y serie protagonista      (4,1:1: solo grande o grafico)
  magenta_prof = "#C2186B", # toda numeracion en texto chico  (5,8:1)
  teal         = "#037686", # SOLO la pestana de edicion      (5,3:1 con blanco)
  # Filete de paisaje: curvas de nivel y perfil del Paine. Es trazo, no texto.
  curva        = "#037686",
  # Todo lo que no es protagonista en un grafico.
  contexto   = "#b9b1c0",
  # Reservados a significado. El rojo es el color de la ATENCION: cubre el
  # deterioro de una serie y tambien la advertencia metodologica.
  conforme   = "#1c6b52",   # (6,4:1)
  atencion   = "#a32a22",   # (7,3:1)
  # Secuencia de series: el orden del Boletin. Magenta protagonista, violeta del
  # manual, gris de contexto y tinta. El azul NO entra: es la tinta de lo
  # accionable y un dato pintado en azul se leeria como un enlace.
  serie      = c(MAGENTA, VIOLETA, "#8f8597", "#3a2d42"),
  # Banos de portadilla: sombra, medio y luz del duotono de cada capitulo. Los
  # usa _dev/portadillas.R para tenir las fotos; el sombra es ademas el fondo
  # bajo la foto (styles.css lo repite en --bano-*).
  bano = list(
    azul    = c("#0B1230", "#2F5BC8", "#DCE6FF"),
    violeta = c("#1A0A2A", "#7B2FC4", "#EBDDFF"),
    rojo    = c("#1E0504", "#B81E16", "#F2907E")
  )
)


# ─────────────────────────────────────────────────────────────────────────────
# 2. TEMAS
# ─────────────────────────────────────────────────────────────────────────────

#' Tema Bootstrap 5 de la pagina
#'
#' Sombras y gradientes desactivados por contrato: en este mundo la profundidad
#' se construye con filete capilar y un escalon tonal, nunca con relieve.
#'
#' LA TIPOGRAFIA NO SE PIDE A GOOGLE. Aqui solo se NOMBRA la familia; los
#' @font-face que la traen viven en www/fonts/asap.css, que R/50_sitio.R carga como una
#' hoja de estilo mas. Antes decia font_google("Asap") y eso tenia dos costos
#' que se midieron:
#'   a) con el cache de sass vacio, el arranque salia a fonts.googleapis.com
#'      por el CSS y tres woff2 — unos 500 ms mas, y si Google no respondia el
#'      tema no compilaba y la app no arrancaba. Un tercero en el camino
#'      critico de algo que debe estar disponible.
#'   b) font_google("Asap") pide la familia a secas, y Google devuelve solo la
#'      instancia del peso 400. El diseno usa cuatro pesos (700 en 22 reglas de
#'      styles.css, mas 600, 500 y 400), asi que las negritas eran SINTETICAS:
#'      el navegador engordando el 400 por su cuenta. El archivo variable de
#'      www/fonts/ cubre el rango 100-900 y las dibuja de verdad.
#'
#' La lista de respaldo corre mientras Asap carga (font-display: swap) y es la
#' que ve quien tenga los woff2 bloqueados. system-ui va primera a proposito:
#' es la fuente de interfaz del sistema, la que menos desentona con el resto.
tema_umag <- function() {
  .fuente <- sass::font_collection(
    "Asap",
    "system-ui", "-apple-system", "Segoe UI", "Roboto",
    "Helvetica Neue", "Arial", "sans-serif"
  )

  bslib::bs_theme(
    version      = 5,
    base_font    = .fuente,
    heading_font = .fuente,
    code_font    = .fuente,
    `enable-shadows`   = FALSE,
    `enable-gradients` = FALSE,
    # Sin radios, como manda DESIGN.md: lo que styles.css no pisa (inputs,
    # selects, botones, menus) heredaria el radio de Bootstrap.
    `border-radius`    = "0",
    `body-bg`          = PAL$papel,
    `body-color`       = PAL$tinta,
    primary            = PAL$azul
  )
}

#' JSON del tema ECharts, armado desde PAL
#'
#' Los %s siguen el orden en que aparecen en la plantilla; leerlos en paralelo
#' con la lista de argumentos del final.
.tema_echarts <- function() {
  sprintf('{
    "backgroundColor": "transparent",
    "textStyle": {"color": "%s", "fontFamily": "Asap, sans-serif", "fontSize": 12},
    "title":    {"textStyle": {"color": "%s", "fontSize": 13, "fontWeight": 700}},
    "legend":   {"textStyle": {"color": "%s", "fontSize": 12}, "icon": "rect",
                 "itemWidth": 12, "itemHeight": 2},
    "tooltip":  {"backgroundColor": "%s", "borderColor": "%s", "borderWidth": 1,
                 "extraCssText": "border-radius:0;box-shadow:none;",
                 "textStyle": {"color": "%s", "fontSize": 12, "fontFamily": "Asap, sans-serif"}},
    "categoryAxis": {"axisLine":  {"show": true, "lineStyle": {"color": "%s"}},
                     "axisTick":  {"show": true, "lineStyle": {"color": "%s"}, "length": 3},
                     "splitLine": {"show": false},
                     "axisLabel": {"color": "%s", "fontFamily": "JetBrains Mono, monospace", "fontSize": 10.5}},
    "valueAxis":    {"axisLine":  {"show": false},
                     "axisTick":  {"show": false},
                     "splitLine": {"show": true, "lineStyle": {"color": "%s", "width": 1}},
                     "axisLabel": {"color": "%s", "fontFamily": "JetBrains Mono, monospace", "fontSize": 10.5}},
    "line": {"smooth": false, "symbolSize": 6, "lineStyle": {"width": 2.2}},
    "bar":  {"itemStyle": {"borderRadius": 0}},
    "animation": true,
    "animationDuration": 420,
    "animationEasing": "cubicOut",
    "color": [%s]
  }',
    PAL$tinta2, PAL$tinta, PAL$tinta2,           # texto base, titulo, leyenda
    PAL$lamina, PAL$regla, PAL$tinta,            # tooltip: fondo, borde, texto
    PAL$regla, PAL$regla, PAL$tinta2,            # eje de categorias
    PAL$regla_fina, PAL$tinta3,                  # eje de valor
    paste0('"', PAL$serie, '"', collapse = ", ")  # ciclo de series
  )
}

#' Etiqueta <script> que registra el tema "catalogo" en el navegador
#'
#' Se inyecta una vez en el <head>. El reintento cada 40 ms cubre el caso de que
#' el script corra antes de que echarts.js haya cargado. El tema queda ademas en
#' DM.tema: js/sitio.js lo registra antes de su primer dibujo, que puede llegar
#' antes que el reintento (el sankey VII.1 se dibuja al cargar).
#'
#' La animacion de entrada se apaga cuando el sistema declara
#' prefers-reduced-motion. El bloque equivalente de www/styles.css solo alcanza a
#' las transiciones CSS; la animacion de echarts es JavaScript y hay que
#' apagarla aqui o la preferencia del usuario queda a medias.
script_tema_echarts <- function() {
  tags$script(HTML(sprintf(
    "(function(){var T=%s;
       window.DM = window.DM || {}; DM.tema = T;
       try { if (window.matchMedia &&
                 window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
               T.animation = false; } } catch(e) {}
       function reg(){ if(window.echarts&&echarts.registerTheme){ echarts.registerTheme('catalogo',T); }
         else { setTimeout(reg,40); } }
       reg();})();",
    .tema_echarts()
  )))
}


# ─────────────────────────────────────────────────────────────────────────────
# 3. GRAFICOS
# ─────────────────────────────────────────────────────────────────────────────

#' Aplicar el tema del catalogo a un grafico echarts4r
#'
#' Se llama en TODOS los graficos; es la regla del proyecto.
#'
#' @param e           Objeto echarts4r.
#' @param altura_grid Margen superior del area de dibujo, si la leyenda lo pide.
#' @param area        TRUE rellena bajo la linea con un degradado muy tenue, para
#'                    dar cuerpo a una serie unica sin anadir un dato que no esta.
e_lamina <- function(e, altura_grid = NULL, area = FALSE) {
  # La animacion NO se fija aqui: viene del tema, que la apaga cuando el sistema
  # declara prefers-reduced-motion. Fijarla por grafico pisaria esa preferencia.
  out <- e
  out$x$theme <- "catalogo"
  if (!is.null(altura_grid)) out <- out |> e_grid(top = altura_grid)
  if (isTRUE(area)) {
    out$x$opts$series <- purrr::imap(out$x$opts$series, function(s, i) {
      if (!identical(s$type, "line")) return(s)   # las barras no llevan area
      col <- PAL$serie[[((i - 1) %% length(PAL$serie)) + 1]]
      s$areaStyle <- list(color = list(
        type = "linear", x = 0, y = 0, x2 = 0, y2 = 1,
        colorStops = list(
          list(offset = 0, color = .mezclar(col, PAL$lamina, 0.82)),
          list(offset = 1, color = .mezclar(col, PAL$lamina, 0.98)))))
      s
    })
  }
  out
}

#' Linea de referencia dentro de un grafico
#'
#' En tinta terciaria y discontinua: es una referencia, no un dato, y por eso no
#' toma ninguno de los colores de serie.
e_datum <- function(e, valor, rotulo) {
  e |> e_mark_line(
    data = list(yAxis = valor),
    symbol = "none",
    title = rotulo,
    lineStyle = list(color = PAL$tinta3, type = "dashed", width = 1.2),
    label = list(formatter = rotulo, color = PAL$tinta2,
                 fontSize = 11, fontFamily = "Asap, sans-serif",
                 position = "insideEndTop"),
    silent = TRUE)   # es referencia, no dato consultable
}

#' Mezclar dos colores hex en proporcion p (0 = solo `a`, 1 = solo `b`)
.mezclar <- function(a, b, p) {
  ca <- grDevices::col2rgb(a); cb <- grDevices::col2rgb(b)
  grDevices::rgb(t(round(ca * (1 - p) + cb * p)), maxColorValue = 255)
}

# Categorias sin orden dentro de una sola serie: un tono plano, el de la serie
# protagonista. Variar el valor donde no hay orden inventa una jerarquia que el
# dato no tiene.
tinta_plana <- function(n = 1) rep(PAL$magenta, length.out = n)

# Series distintas dentro de un mismo grafico: el orden del Boletin.
tintas_serie <- function(n) rep(PAL$serie, length.out = n)

# Categorias con orden: rampa del magenta claro al violeta del manual, que es
# el par de tintas del Boletin. La luminosidad baja de punta a punta, asi que el
# orden se lee tambien impreso en gris.
rampa_orden <- function(n) {
  clara <- .mezclar(PAL$magenta, PAL$lamina, 0.55)
  oscura <- .mezclar(PAL$violeta, PAL$tinta, 0.35)
  # max(n, 2) porque colorRampPalette necesita al menos dos pasos.
  grDevices::colorRampPalette(c(clara, PAL$magenta, oscura))(max(n, 2))[seq_len(n)]
}

#' Colorear cada barra por su posicion
#'
#' ECharts pinta toda una serie de un color; para variar barra a barra hay que
#' entregarle una funcion JavaScript que resuelva el color por indice de dato.
color_por_barra <- function(cols) {
  htmlwidgets::JS(sprintf(
    "function(p){ var c=%s; return c[p.dataIndex %% c.length]; }",
    jsonlite::toJSON(unname(cols))))
}


# ─────────────────────────────────────────────────────────────────────────────
# 4. FORMATO CHILENO — punto para miles, coma para decimales
# ─────────────────────────────────────────────────────────────────────────────
# Ninguna cifra llega a pantalla sin pasar por aqui.

fmt_n <- function(x, dec = 0) {
  format(round(x, dec), big.mark = ".", decimal.mark = ",",
         nsmall = dec, scientific = FALSE, trim = TRUE)
}
fmt_pct <- function(x, dec = 1) paste0(fmt_n(x, dec), "%")

#' Medida de variacion PUBLICADA POR LA FUENTE
#'
#' El mundo anterior calculaba un delta en la interfaz para todos los
#' indicadores por igual. Un delta calculado aqui es una cifra sin procedencia:
#' la celda de fuente cita el origen del nivel, no el de la variacion. Se
#' retiro por completo.
#'
#' Esta funcion solo formatea una medida que la propia fuente publica y que
#' viene en el CSV del indicador. Si el valor no existe, devuelve NULL y la
#' celda queda vacia — que es la respuesta honesta.
#'
#' @param valor  Valor publicado por la fuente. NA o NULL producen NULL.
#' @param unidad Unidad de esa medida ("%", "pp", ...).
#' @param glosa  Que mide, en pocas palabras ("variacion anual").
medida_publicada <- function(valor, unidad = "%", glosa = NULL) {
  if (is.null(valor) || length(valor) != 1 || !is.finite(valor)) return(NULL)
  signo <- if (valor > 0) "+" else if (valor < 0) "−" else ""
  cifra <- paste0(signo, fmt_n(abs(valor), 1), unidad)
  clase <- if (valor > 0) "medida es-alza" else if (valor < 0) "medida es-baja" else "medida"
  tags$span(class = clase,
            tags$span(class = "medida-cifra", cifra),
            if (!is.null(glosa)) tags$span(class = "medida-glosa", glosa))
}


# ─────────────────────────────────────────────────────────────────────────────
# 4b. EL MISMO FORMATO, DENTRO DEL GRAFICO
# ─────────────────────────────────────────────────────────────────────────────
# fmt_n() alcanza a todo lo que R escribe en el HTML, pero no a lo que escribe
# ECharts. El rotulo de un eje, la etiqueta sobre una barra y el tooltip son
# cadenas que se arman en el navegador y que R nunca ve: sin un equivalente en
# JavaScript, toda cifra dentro de un cuadro se escapaba del formato chileno y
# salia con punto decimal ingles y sin separador de miles. DM.n() es ese
# equivalente, y estas cuatro funciones son la unica manera de invocarlo.
#
# Y HAY UNA TRAMPA QUE COSTO DOS CUADROS EN BLANCO
#   echarts4r entrega cada dato como el par [categoria, valor], y R colapsa ese
#   par a TEXTO en cuanto la categoria es texto — que es el caso de todo grafico
#   construido con as.character(anio) y de toda barra por categoria. En el
#   navegador, por lo tanto, p.value[1] no es 42.1 sino la cadena "42.1":
#
#     "42.1".toFixed(1)               -> TypeError: no es una funcion
#     "42.1".toLocaleString("es-CL")  -> "42.1", devuelve la cadena intacta
#
#   El segundo caso solo pierde el formato. El primero es fatal y no es local:
#   la excepcion se lanza dentro del pipeline de dibujo de ECharts, aborta el
#   lote de salidas que Shiny esta entregando y deja EN BLANCO a los graficos
#   que venian detras en ese mismo lote, sin dejar rastro en la consola de R ni
#   marcar de error el cuadro culpable. Asi desaparecieron V.1 y V.2 por una
#   etiqueta de V.3.
#
#   Por eso DM.n() normaliza con Number() ANTES de formatear, siempre, y por eso
#   ningun formateador de este proyecto se escribe a mano: se pide aqui.

#' Etiqueta <script> que define el formateador de cifras del navegador
#'
#' Se inyecta en el <head> junto al tema de grafico. Es sincrono, de modo que
#' DM existe antes de que se dibuje el primer cuadro.
script_formato <- function() {
  tags$script(HTML(
    "window.DM = window.DM || {};
     // La separacion entre el nombre de una pieza y su cifra en el tooltip.
     // Va en entidades y no en espacios: el tooltip de ECharts es HTML y una
     // corrida de espacios se colapsa a uno solo.
     DM.gap = '&nbsp;&nbsp;&nbsp;';
     // Toda cifra que ECharts escriba pasa por aqui. Number() normaliza porque
     // el par [categoria, valor] llega como texto (ver el comentario en
     // R/10_utils.R). El dato ausente se declara con una raya, no se omite.
     DM.n = function(v, dec){
       if (v === null || v === undefined || v === '') return '\\u2014';
       var x = Number(v);
       if (!isFinite(x)) return '\\u2014';
       return x.toLocaleString('es-CL', { minimumFractionDigits: dec,
                                          maximumFractionDigits: dec });
     };"
  ))
}

#' Cifra chilena en el rotulo de un eje de valor
#'
#' @param dec Decimales.
#' @param suf Sufijo pegado a la cifra ("%", " a", "k").
#' @param pre Prefijo pegado a la cifra ("$").
#' @param div Divisor de escala: 1000 para abreviar en miles.
#' @param abs TRUE imprime el valor absoluto. Lo usa la piramide, donde el signo
#'            negativo es un recurso de dibujo y no un dato que el lector deba
#'            ver.
eje_cifra <- function(dec = 0, suf = "", pre = "", div = 1, abs = FALSE) {
  htmlwidgets::JS(sprintf(
    "function(v){ var x = Number(v) / %s; %sreturn '%s' + DM.n(x, %d) + '%s'; }",
    format(div, scientific = FALSE),
    if (abs) "x = Math.abs(x); " else "",
    pre, dec, suf))
}

#' Cifra chilena en la etiqueta de un dato (e_labels)
#'
#' @param idx Posicion del valor dentro del par [x, y]: 1 en un grafico normal,
#'            0 cuando e_flip_coords() ya intercambio los ejes.
#' @inheritParams eje_cifra
rotulo_cifra <- function(dec = 0, suf = "", pre = "", idx = 1) {
  htmlwidgets::JS(sprintf(
    "function(p){ return '%s' + DM.n(p.value[%d], %d) + '%s'; }",
    pre, idx, dec, suf))
}

#' Tooltip de un dato suelto (trigger = "item")
#'
#' Una sola linea: nombre de la categoria y su cifra.
#' @inheritParams rotulo_cifra
tip_item <- function(dec = 0, suf = "", pre = "", idx = 1) {
  htmlwidgets::JS(sprintf(
    "function(p){ return p.name + DM.gap + '%s' + DM.n(p.value[%d], %d) + '%s'; }",
    pre, idx, dec, suf))
}

#' Tooltip de un nodo del grafo del catalogo (trigger = "item")
#'
#' El grafo del capitulo VII dibuja tres clases de nodo —pieza, fuente y
#' capitulo— y ECharts las entrega por el mismo canal. El tipo viaja dentro del
#' objeto del nodo, junto con las dos lineas de texto que el modulo ya preparo:
#' `glosa` es el nombre y `detalle` la linea de estado.
#'
#' Las aristas no dicen nada que el dibujo no muestre —unen una pieza con su
#' fuente o con su capitulo, siempre— asi que no abren tooltip.
tip_red <- function() {
  htmlwidgets::JS(
    "function(p){
       if (p.dataType === 'edge') return '';
       var d = p.data;
       var cab = d.tipo === 'pieza'   ? 'Indicador ' + d.name
               : d.tipo === 'fuente'  ? 'Fuente'
               :                        'Capitulo';
       return [cab, d.glosa, d.detalle].filter(Boolean).join('<br/>');
     }")
}

#' Tooltip de una columna del eje (trigger = "axis")
#'
#' Con una sola serie es una linea; con varias, el periodo encabeza y cada serie
#' baja a su propia linea con su nombre. Esa es la unica forma honesta de leer
#' un grafico de dos series: la cifra sin el nombre de su serie no dice nada.
#'
#' @param suf,pre Se admiten VECTORES, uno por serie, para el caso de dos
#'                series con unidades distintas (por ejemplo, un porcentaje
#'                con una razon). Se reciclan si faltan.
#' @inheritParams rotulo_cifra
tip_eje <- function(dec = 1, suf = "", pre = "", idx = 1, abs = FALSE) {
  htmlwidgets::JS(sprintf(
    "function(p){
       var suf = %s, pre = %s;
       var linea = function(s, i){
         var v = s.value[%d]; %s
         return pre[i %% pre.length] + DM.n(v, %d) + suf[i %% suf.length];
       };
       if (p.length === 1) return p[0].name + DM.gap + linea(p[0], 0);
       var out = [p[0].name];
       p.forEach(function(s, i){ out.push(s.seriesName + DM.gap + linea(s, i)); });
       return out.join('<br/>');
     }",
    jsonlite::toJSON(as.character(suf)), jsonlite::toJSON(as.character(pre)),
    idx, if (abs) "v = Math.abs(Number(v));" else "", dec))
}


# ─────────────────────────────────────────────────────────────────────────────
# 5. MOBILIARIO DEL CATALOGO
# ─────────────────────────────────────────────────────────────────────────────

#' La foto de cada portadilla
#'
#' Cada capitulo abre como un articulo del Boletin de Estudios Regionales N.2:
#' una foto del propio Boletin a sangre, banada en UN color (azul, violeta o
#' rojo) que se alterna de capitulo en capitulo. Las fotos las tine una sola vez
#' `Rscript _dev/portadillas.R` a partir de los originales del Boletin y quedan
#' en www/img/. El credito es obligatorio y se publica sobre la foto.
#'
#'   foto    archivo en www/img/
#'   bano    clave de PAL$bano
#'   credito como lo publica el Boletin (CREDITOS.md de la plantilla)
.PORTADILLAS <- list(
  I   = list(foto = "cap-i.webp",   bano = "azul",    credito = "Foto: Andrea Barria · Boletin N.2"),
  II  = list(foto = "cap-ii.webp",  bano = "rojo",    credito = "Foto: Rafael Cheuquelaf · Boletin N.2"),
  III = list(foto = "cap-iii.webp", bano = "violeta", credito = "Foto: portada del Boletin N.2"),
  IV  = list(foto = "cap-iv.webp",  bano = "azul",    credito = "Foto: Boletin N.2, contraportada"),
  V   = list(foto = "cap-v.webp",   bano = "violeta", credito = "Foto: Rafael Cheuquelaf · Boletin N.2"),
  VI  = list(foto = "cap-vi.webp",  bano = "rojo",    credito = "Foto: memoriachilena.gob.cl"),
  VII = list(foto = "cap-vii.webp", bano = "azul",    credito = "Foto: Boletin N.2, p. 2")
)

#' Portadilla: la apertura de un capitulo
#'
#' La foto banada del capitulo a sangre y, sobre ella, el numeral liviano en
#' mono sobre un filete blanco, el nombre en Asap liviana y la linea de
#' cobertura sobre la banda magenta que se dibuja al entrar. El numeral romano
#' no es un rotulo decorativo: es la primera mitad de la direccion de cita de
#' todo cuadro del capitulo (Cuadro II.3 vive en el capitulo II).
#'
#' @param numero    Numeral romano del capitulo; elige la foto en .PORTADILLAS.
#' @param titulo    Nombre del capitulo.
#' @param cobertura Linea de alcance y periodo.
#' @param rango     Rango de numeros de acceso que cubre el capitulo.
portadilla <- function(numero, titulo, cobertura = NULL, rango = NULL) {
  foto <- .PORTADILLAS[[numero]]
  tags$header(
    class = paste0("portadilla bano-", if (is.null(foto)) "violeta" else foto$bano),
    if (!is.null(foto))
      tags$img(class = "portadilla-foto", src = paste0("img/", foto$foto),
               alt = "", `aria-hidden` = "true", decoding = "async"),
    div(
      class = "portadilla-interior",
      # El numeral solo, liviano y a escala de display sobre su filete: es la
      # masa del divisor del Boletin, no un rotulo sobre el titulo.
      div(class = "portadilla-numero", numero),
      # El unico h1 de la pagina: el nombre del capitulo. Lo que sigue (el
      # inventario, los cuadros) cuelga de el en h2 y h3.
      h1(class = "portadilla-titulo", titulo),
      div(
        class = "portadilla-pie",
        if (!is.null(cobertura))
          p(class = "portadilla-cobertura", span(class = "banda", cobertura)),
        if (!is.null(rango)) div(class = "portadilla-rango", rango)
      )
    ),
    if (!is.null(foto)) div(class = "credito", foto$credito)
  )
}

#' Una fila del inventario del capitulo
#'
#' El inventario es el resumen del capitulo: una linea por cuadro, en el orden
#' de los cuadros y con su numero (I.1, I.2...) a la izquierda. El id del
#' indicador es orden interno y no se publica aqui. No lleva delta calculado;
#' lleva, cuando existe, la medida que la fuente publica (ver medida_publicada()).
#'
#' LA FILA RECIBE LA LAMINA, NO UN NUMERO. Escribir el numero a mano permitia
#' que inventario y cuadros se numeraran distinto; tomandolo de la lamina, la
#' fila no puede citar un cuadro que no es el suyo. La fuente sale de la ficha
#' de la carpeta de esa misma lamina.
#'
#' @param lam       La lamina del registro LAM cuyo cuadro resume la fila.
#' @param indicador Nombre de la pieza.
#' @param valor     Valor ya formateado.
#' @param unidad    Unidad publicada.
#' @param periodo   Ano o ronda del valor. Se omite cuando el CSV es un corte
#'                  sin columna de ano, y la celda publica "—": nunca se toma
#'                  prestado el ano de otra serie.
#' @param fuente    Sigla de la fuente. Por defecto se deriva de la ficha;
#'                  declararla a mano es la excepcion.
#' @param medida    Salida de medida_publicada(), o NULL.
#' @param glosa     Precision opcional bajo el nombre.
#' @param estado    Marca de estado del dato, opcional.
fila_inventario <- function(lam, indicador, valor, unidad = NULL, periodo = NULL,
                            fuente = NULL, medida = NULL, glosa = NULL,
                            estado = NULL) {
  if (is.null(lam$numero) || is.null(lam$carpeta))
    cli::cli_abort("fila_inventario() recibe una lamina de LAM, no un id: {.val {indicador}}.")
  # La fuente NO se escribe a mano en el modulo: se deriva de la ficha del
  # indicador, via su fuente_id (ver fuente_de_indicador en la seccion 6).
  # Un argumento explicito sigue ganando, para el caso excepcional.
  if (is.null(fuente)) fuente <- fuente_de_indicador(ficha_de(lam$carpeta)$id)
  tags$tr(
    tags$td(class = "inv-id", lam$numero),
    tags$th(scope = "row", class = "inv-pieza",
            indicador,
            if (!is.null(glosa)) tags$span(class = "inv-glosa", glosa),
            if (!is.null(estado)) estado),
    tags$td(class = "inv-valor", valor),
    tags$td(class = "inv-unidad", unidad),
    tags$td(class = "inv-periodo", periodo %||% "—"),
    tags$td(class = "inv-medida", medida),
    tags$td(class = "inv-fuente", fuente)
  )
}

#' Inventario: el cuadro resumen de un capitulo
#'
#' Siete columnas fijas, en el mismo orden en las cinco secciones. El chasis no
#' se mueve entre capitulos: quien aprendio a leerlo una vez lo lee en todos.
#' @param marca Marca de estado que rige para TODO el capitulo, opcional. Va
#'   aqui y no en la portadilla por dos razones: la portadilla es una foto
#'   banada donde el rojo de la atencion no se leeria, y la advertencia tiene
#'   que viajar pegada a las cifras que califica.
inventario <- function(..., titulo = "Inventario del capitulo", marca = NULL) {
  tags$section(
    class = "inventario",
    # La cabecera vive FUERA del elemento <table>, como en el registro: dentro
    # de un <caption> se desplazaria con la tabla en pantalla angosta y
    # desapareceria de la vista justo donde mas se necesita. El nombre
    # accesible de la tabla lo repone aria-label.
    div(
      class = "inv-cabecera",
      h2(class = "inv-caption", titulo),
      if (!is.null(marca)) marca
    ),
    tags$table(
      class = "inv-tabla",
      `aria-label` = titulo,
      tags$thead(tags$tr(
        tags$th(scope = "col", class = "es-num", "N.º"),
        tags$th(scope = "col", "Indicador"),
        tags$th(scope = "col", class = "es-num", "Valor"),
        tags$th(scope = "col", "Unidad"),
        tags$th(scope = "col", "Periodo"),
        tags$th(scope = "col", "Medida de la fuente"),
        tags$th(scope = "col", "Fuente")
      )),
      tags$tbody(...)
    )
  )
}

#' CSV para Excel en configuracion chilena: el archivo de cada boton de descarga
#'
#' Excel es-CL espera punto y coma entre campos y coma decimal, y lee un CSV sin
#' BOM como Windows-1252: con write.csv cada fila caia entera en una columna y
#' "Ed. Básica" se leia "Ed. BÃ¡sica". write.csv2 pone `;` y `,`; la BOM
#' delante le avisa a Excel que el archivo es UTF-8. Se hace con base y no con
#' readr::write_excel_csv2 para no sumar una dependencia a la construccion.
#'
#' @param df    data.frame a escribir.
#' @param ruta  Archivo de destino.
#' @param aviso Linea de advertencia antes de la cabecera (aviso_csv()), o NULL.
escribir_csv <- function(df, ruta, aviso = NULL) {
  writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), ruta)
  con <- file(ruta, open = "a", encoding = "UTF-8")
  on.exit(close(con))
  if (!is.null(aviso)) writeLines(aviso, con)
  utils::write.csv2(df, con, row.names = FALSE)
}

#' La advertencia de prototipo como primera linea del CSV
#'
#' El CSV es lo que mas lejos viaja: se abre en Excel sin el cuadro al lado. Va
#' como una linea propia y no como columna porque es lo primero que se ve en la
#' celda A1. Empieza con "#" para que readr (`comment = "#"`) y pandas
#' (`comment="#"`) la salten; no lleva ";" para no partirse en columnas.
#' Devuelve NULL cuando los datos son oficiales (ver .PROTOTIPO).
aviso_csv <- function() {
  if (!isTRUE(.PROTOTIPO)) return(NULL)
  paste0("# Dato ilustrativo. ", .AVISO_PROTOTIPO, ". Datos Magallanes, UER-UMAG, ",
         .EDICION$version)
}

#' El mismo CSV como texto y sin la BOM
#'
#' Para los cuadros con rango de anos (II.1/II.2, III.1/III.2): el archivo que
#' se descarga es el del rango que el cuadro muestra, asi que no existe de
#' antemano. Se embebe uno por rango y js/sitio.js arma el archivo al hacer
#' clic, agregando la BOM.
texto_csv <- function(df, aviso = NULL) {
  salida <- character()
  con <- textConnection("salida", "w", local = TRUE)
  utils::write.csv2(df, con, row.names = FALSE)
  close(con)
  paste0(paste(c(aviso, salida), collapse = "\n"), "\n")
}

#' Las opciones que un htmlwidget de echarts4r le entregaria a setOption()
#'
#' `evals` son las rutas de los formateadores (htmlwidgets::JS) dentro de las
#' opciones, como "yAxis.0.axisLabel.formatter". Es lo que htmlwidgets envia
#' junto al widget para que el navegador evalue esos textos como funciones antes
#' de dibujar; js/sitio.js hace lo mismo.
opciones_grafico <- function(e) list(opts = e$x$opts, evals = htmlwidgets::JSEvals(e$x$opts))

#' JSON con los mismos criterios con que htmlwidgets serializa un widget
#'
#' "</" se escapa porque el JSON viaja dentro de un <script>: un "</script>" en
#' un texto cerraria la etiqueta.
a_json <- function(x) {
  json <- jsonlite::toJSON(x, dataframe = "columns", null = "null", na = "null",
                           auto_unbox = TRUE, digits = 16, use_signif = TRUE,
                           force = TRUE, rownames = FALSE, keep_vec_names = TRUE,
                           strict_atomic = TRUE)
  gsub("</", "<\\/", json, fixed = TRUE)
}

#' Extremos redondos para un eje de valor que NO debe anclar en cero
#'
#' Dos cuadros del catalogo se mueven en un tramo alto y estrecho —participacion
#' electoral, esperanza de vida— y anclarlos en cero aplasta la serie contra el
#' techo. Omitir `min` no basta: el eje de valor de ECharts incluye el cero por
#' defecto. Y `scale = TRUE`, que si lo libera, deja los cortes donde caiga el
#' dato: 39 / 44 / 49 / 54 / 57 junto a un cuadro vecino que va de 10 en 10.
#'
#' Esto redondea los extremos hacia afuera al paso pedido, de modo que los
#' cortes son redondos, el eje no toca el cero y los limites salen del CSV: al
#' actualizar los datos el eje se reajusta solo, como el slider de anos.
#'
#' @param x    Valores de la serie.
#' @param paso Tamano del corte.
#' @return Lista con `min`, `max` e `interval`, lista para `e_y_axis()`.
eje_holgado <- function(x, paso) {
  x <- x[is.finite(x)]
  list(min      = floor(min(x) / paso) * paso,
       max      = ceiling(max(x) / paso) * paso,
       interval = paso)
}

# ─────────────────────────────────────────────────────────────────────────────
# 6. LA CIFRA VIGENTE Y SU FUENTE
# ─────────────────────────────────────────────────────────────────────────────

#' Ultimo valor de una serie anual, por ANO y no por posicion de fila
#'
#' tail(x, 1) devuelve la ultima FILA del CSV, y solo coincide con el ultimo
#' ano si el archivo viene ordenado — un supuesto que nada hacia cumplir:
#' read.csv() no ordena, y un CSV reordenado publicaria silenciosamente una
#' cifra vieja como vigente en los cinco inventarios de capitulo. Esto toma el
#' valor en el ano maximo, que es lo que "ultimo" quiere decir.
#'
#' Los anos sin dato no cuentan: una fila con el valor en NA no es la ultima
#' cifra publicada, y el inventario mostraria una celda vacia con un ano.
#'
#' @param df       Data.frame del indicador.
#' @param col      Columna del valor.
#' @param col_anio Columna del ano.
#' @return Lista con `valor` y `anio` de la fila mas reciente.
ultimo_valor <- function(df, col, col_anio = "anio") {
  con_dato <- which(!is.na(df[[col]]))
  i <- con_dato[which.max(df[[col_anio]][con_dato])]
  list(valor = df[[col]][i], anio = df[[col_anio]][i])
}

# Sigla de cada fuente para la columna Fuente del inventario. La ficha declara
# la fuente en forma larga ("Banco Central de Chile — Cuentas Nacionales
# Regionales") y ese es el texto que cita el pie del cuadro; en la columna del
# inventario no cabe, y ahi va la sigla.
#
# Es una decision EDITORIAL declarada en una tabla, como .SIGLAS del umbral
# (40_pag_presentacion.R) y .NOMBRE_CORTO del capitulo VII (40_pag_fuentes.R):
# la vez que se derivo con una expresion regular produjo dos rotulos "INE".
# La clave es el `fuente_id` que declara la ficha, de modo que si una ficha se
# corrige para apuntar a otra fuente, el inventario la sigue solo.
.SIGLA_FUENTE <- c(
  censo             = "INE",
  ine_proyecciones  = "INE",
  ine_vitales       = "INE · DEIS-MINSAL",
  ine_ene           = "INE · ENE",
  ine_medioambiente = "INE",
  banco_central     = "Banco Central",
  sii               = "SII",
  servel            = "SERVEL",
  cead              = "Subsecretaria de Prevencion del Delito",
  obs_homicidios    = "Observatorio de Homicidios",
  casen             = "MIDESO · CASEN",
  mineduc_sige      = "MINEDUC",
  mineduc_sies      = "MINEDUC · SIES",
  ine_enut          = "INE",
  uer_encuesta      = "Encuesta regional",
  minvu_ceut        = "MINVU"
)

#' Sigla de una fuente por su id
#'
#' Una fuente nueva sin entrada en .SIGLA_FUENTE no rompe nada: se publica su
#' id en mayusculas. Se vera pobre, pero nunca vacio ni ilegible.
sigla_fuente <- function(fuente_id) {
  s <- unname(.SIGLA_FUENTE[fuente_id])
  ifelse(is.na(s), toupper(fuente_id), s)
}

#' La fuente que el inventario publica para un indicador
#'
#' Se deriva de la ficha, via su fuente_id. Antes cada modulo la escribia a
#' mano en cada fila —34 copias repartidas en cinco archivos— y podia discrepar
#' de la ficha sin que nadie lo notara: es el mismo desajuste que publico "por
#' mil" donde la ficha 511 dice "Por 100.000 habitantes", una linea mas abajo.
#'
#' @param id Numero de acceso del indicador (101, 215, ...).
fuente_de_indicador <- function(id) {
  i <- match(as.integer(id), d_indicadores$id)
  if (is.na(i)) return(NULL)
  f <- ficha_de(d_indicadores$carpeta[i])
  if (!is.null(f$fuente_id)) return(sigla_fuente(f$fuente_id))
  # Sin fuente_id: el prefijo de la forma larga, que por contrato es la
  # institucion ("INE — Censos de Poblacion y Vivienda; ...").
  sub("\\s*[—–-].*$", "", f$fuente)
}

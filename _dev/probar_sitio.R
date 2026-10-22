# ═════════════════════════════════════════════════════════════════════════════
# _dev/probar_sitio.R — Recorre el sitio construido en un Chrome sin ventana
#
#   Rscript construir.R && Rscript _dev/probar_sitio.R
#
# QUE COMPRUEBA
#   1. Enlaces: todo href/src interno de las paginas existe en _site/.
#   2. En cada pagina, a 1360 y a 390 px: abre todas las entradas plegadas y
#      exige que cada lienzo haya dibujado, cero excepciones de JS y ningun
#      desborde horizontal.
#   3. Los controles: el conmutador del cero cambia el eje; los rangos de anos
#      recortan sus dos cuadros y el CSV que se descarga; el selector de censo
#      de I.3 cambia el dibujo y su CSV; un ancla de cuadro
#      despliega su entrada y aterriza en su cabecera; la advertencia de
#      prototipo esta en todos los pies y CSV o en ninguno; la busqueda y
#      ?pieza= filtran las fichas.
#   4. El menu de telefono: a 390 px reemplaza la franja, trae las 8 secciones
#      y todos los cuadros, lleva al cuadro, y la barra queda fija.
#   5. La entrada (index.html): sus enlaces existen, no desborda ni lanza
#      errores a 1360 y a 390 px, y "Entrar" lleva a inicio.html.
#
#   Termina con status 1 si algo falla, para poder usarlo antes de publicar.
#
# DEPENDENCIA DE TALLER: chromote y un Chrome instalado. No viaja al Action.
# ═════════════════════════════════════════════════════════════════════════════

suppressPackageStartupMessages(library(chromote))

SITIO <- normalizePath("_site", mustWork = TRUE)
PAGINAS <- c("inicio.html", "poblacion.html", "economia.html", "pobreza.html",
             "bienestar.html", "cohesion.html", "metodologia.html", "fuentes.html",
             "creditos.html", "contacto.html")

fallas <- character()
fallar <- function(...) {
  m <- paste0(...)
  fallas <<- c(fallas, m)
  cli::cli_alert_danger(m)
}
ok <- function(...) cli::cli_alert_success(paste0(...))

url <- function(p) paste0("file://", utils::URLencode(file.path(SITIO, p)))


# ── 1. Enlaces internos ──────────────────────────────────────────────────────
cli::cli_h2("Enlaces internos")
for (p in PAGINAS) {
  html <- paste(readLines(file.path(SITIO, p), warn = FALSE), collapse = "\n")
  refs <- stringr::str_match_all(html, '(?:href|src)="([^"#?]+)')[[1]][, 2]
  refs <- unique(refs[!grepl("^(https?:|mailto:|data:|//)", refs)])
  rotos <- refs[!file.exists(file.path(SITIO, refs))]
  # El colofon es la unica entrada a las paginas del pie: tiene que estar en todas.
  pie <- c("creditos.html", "contacto.html")
  nav_pie <- stringr::str_extract(html, '(?s)<nav class="colofon-enlaces".*?</nav>')
  sin_pie <- pie[is.na(nav_pie) | !stringr::str_detect(dplyr::coalesce(nav_pie, ""), stringr::fixed(paste0('href="', pie, '"')))]
  if (length(rotos)) {
    fallar(p, ": enlaces rotos ", paste(rotos, collapse = ", "))
  } else if (length(sin_pie)) {
    fallar(p, ": el colofon no enlaza ", paste(sin_pie, collapse = ", "))
  } else ok(p, ": ", length(refs), " enlaces internos")
}


# ── 1b. Inventario y cuadros con la misma numeracion ─────────────────────────
# Cada capitulo numera sus cuadros I.1, I.2... sin saltos, y su inventario cita
# esos mismos numeros en el mismo orden (una fila por cuadro; dos filas
# seguidas del mismo cuadro valen como una).
cli::cli_h2("Numeracion de inventario y cuadros")
for (p in PAGINAS) {
  html <- paste(readLines(file.path(SITIO, p), warn = FALSE), collapse = "\n")
  cuadros <- stringr::str_match_all(html, '<span class="pieza-numero">([^<]+)</span>')[[1]][, 2]
  if (!length(cuadros)) next
  inv <- stringr::str_match_all(html, '<td class="inv-id">([^<]+)</td>')[[1]][, 2]
  inv <- inv[c(TRUE, inv[-1] != inv[-length(inv)])]
  romano <- sub("\\..*$", "", cuadros[[1]])
  esperado <- paste0(romano, ".", seq_along(cuadros))
  if (!identical(cuadros, esperado)) {
    fallar(p, ": cuadros fuera de serie: ", paste(cuadros, collapse = " "))
  } else if (!identical(inv, cuadros)) {
    fallar(p, ": el inventario cita ", paste(inv, collapse = " "),
           "; los cuadros son ", paste(cuadros, collapse = " "))
  } else ok(p, ": ", romano, ".1-", romano, ".", length(cuadros), " en inventario y cuadros")
}


# ── Un navegador por prueba ──────────────────────────────────────────────────
# Las excepciones de JS se juntan en un entorno y no en el objeto de sesion: el
# callback corre en otro marco, y asignarle un campo a `b` desde ahi no llega.
# Los callbacks de chromote corren cuando R atiende su bucle de eventos (en
# cada js()), no durante un Sys.sleep(): por eso excepciones() pregunta antes.
EXC <- new.env()
abrir <- function(pagina, ancho = 1360) {
  EXC$v <- character()
  b <- ChromoteSession$new(width = ancho, height = 900)
  b$Runtime$enable()
  b$Runtime$exceptionThrown(callback = function(m) {
    d <- m[["exceptionDetails"]]
    EXC$v <- c(EXC$v, paste(d[["text"]], d[["exception"]][["description"]]))
  })
  invisible(b$Page$navigate(url(pagina)))
  invisible(b$Page$loadEventFired())
  Sys.sleep(1)
  b
}
js <- function(b, codigo) b$Runtime$evaluate(codigo, returnByValue = TRUE)$result$value
excepciones <- function(b) { js(b, "1"); EXC$v }
opcion <- function(b, lienzo, ruta)
  js(b, sprintf("JSON.stringify(echarts.getInstanceByDom(document.getElementById('%s')).getOption().%s)",
                lienzo, ruta))


# ── 2. Cada pagina, a dos anchos ─────────────────────────────────────────────
cli::cli_h2("Laminas, errores y desborde")
for (ancho in c(1360, 390)) for (p in PAGINAS) {
  b <- abrir(p, ancho)
  js(b, "document.querySelectorAll('.piezas-acc .accordion-button.collapsed').forEach(function(x){x.click()}); 1")
  Sys.sleep(2)
  n  <- js(b, "document.querySelectorAll('.lamina-lienzo').length")
  nd <- js(b, "document.querySelectorAll('.lamina-lienzo canvas').length")
  desborde <- js(b, "document.documentElement.scrollWidth > window.innerWidth")
  if (nd != n) fallar(p, " @", ancho, ": ", nd, " de ", n, " laminas dibujadas")
  if (isTRUE(desborde)) fallar(p, " @", ancho, ": desborde horizontal")
  exc <- excepciones(b)
  if (length(exc)) fallar(p, " @", ancho, ": ", paste(exc, collapse = " | "))
  if (nd == n && !isTRUE(desborde) && !length(exc))
    ok(p, " @", ancho, "px: ", n, " laminas")
  b$close()
}


# ── 3. Controles ─────────────────────────────────────────────────────────────
cli::cli_h2("Controles")

# El cero: I.1 arranca anclado; al soltarlo el eje deja de partir de cero o
# cambia su maximo, segun lo que decida .anclar_cero().
b <- abrir("poblacion.html#cuadro-I-1")
Sys.sleep(1)
antes <- opcion(b, "lienzo-I-1", "yAxis[0]")
js(b, "document.getElementById('cero-I-1').click(); 1"); Sys.sleep(0.6)
despues <- opcion(b, "lienzo-I-1", "yAxis[0]")
if (is.null(antes)) {
  fallar("#cuadro-I-1 no desplego su entrada")
} else if (identical(antes, despues)) {
  fallar("El conmutador del cero no cambio el eje de I.1")
} else ok("Ancla #cuadro-I-1 y conmutador del cero")
b$close()

# El ancla aterriza sobre la cabecera de la entrada (direccion y nombre a la
# vista) y deja el foco en su boton.
b <- abrir("economia.html#cuadro-II-1")
Sys.sleep(1.2)
aterrizaje <- js(b, paste0(
  "(function(){var i=document.getElementById('cuadro-II-1');",
  "var t=i.getBoundingClientRect().top;",
  "return {item: i.classList.contains('accordion-item'), top: t, alto: innerHeight,",
  "foco: document.activeElement === i.querySelector('.accordion-button')};})()"))
if (!isTRUE(aterrizaje$item)) {
  fallar("#cuadro-II-1 no es la entrada plegada")
} else if (aterrizaje$top < 0 || aterrizaje$top > aterrizaje$alto / 3) {
  fallar("#cuadro-II-1: la cabecera quedo fuera de la vista (top ", round(aterrizaje$top), ")")
} else if (!isTRUE(aterrizaje$foco)) {
  fallar("#cuadro-II-1: el foco no quedo en el boton de la entrada")
} else ok("Ancla #cuadro-II-1 aterriza en su cabecera, con el foco en su boton")
b$close()

# La estructura accesible: en cada pagina un enlace para saltar la barra, un
# <main> al que apunta, un solo h1, y cada entrada plegada es un h3.
estructura_ok <- 0
for (p in PAGINAS) {
  html <- paste(readLines(file.path(SITIO, p), warn = FALSE), collapse = "\n")
  n_h1 <- stringr::str_count(html, "<h1[ >]")
  salto <- stringr::str_detect(html, '<body class="bslib-page-navbar">\\s*<a class="salto" href="#contenido">')
  main <- stringr::str_count(html, '<main id="contenido"')
  div_cab <- stringr::str_count(html, '<div class="accordion-header"')
  # Las paginas del pie (creditos, contacto) todavia no tienen h1 propio.
  h1_esperados <- if (p %in% c("creditos.html", "contacto.html")) 0:1 else 1
  if (!salto || main != 1 || !n_h1 %in% h1_esperados || div_cab > 0)
    fallar(p, ": salto ", salto, ", main ", main, ", h1 ", n_h1, ", cabeceras sin h3 ", div_cab)
  else estructura_ok <- estructura_ok + 1
}
if (estructura_ok == length(PAGINAS)) ok("Salto, main, h1 y h3 en ", length(PAGINAS), " paginas")

# Abrir una pieza a mano: su cabecera sube a la vista y la URL toma su
# direccion; al plegarla, la direccion se retira.
b <- abrir("economia.html")
Sys.sleep(0.8)
js(b, "document.querySelector('#cuadro-II-4 .accordion-button').click(); 1")
Sys.sleep(1.2)
abierta <- js(b, paste0(
  "JSON.stringify({hash: location.hash, alto: innerHeight,",
  "top: document.getElementById('cuadro-II-4').getBoundingClientRect().top})"))
abierta <- jsonlite::fromJSON(abierta)
js(b, "document.querySelector('#cuadro-II-4 .accordion-button').click(); 1")
Sys.sleep(0.8)
plegada <- js(b, "location.hash")
if (!identical(abierta$hash, "#cuadro-II-4")) {
  fallar("II.4 abierto a mano: la URL quedo en '", abierta$hash, "'")
} else if (abierta$top < 0 || abierta$top > abierta$alto / 3) {
  fallar("II.4 abierto a mano: la cabecera quedo en ", round(abierta$top), " px")
} else if (!identical(plegada, "")) {
  fallar("II.4 plegado: la URL conservo '", plegada, "'")
} else ok("II.4 abierto a mano sube a la vista y deja su direccion en la URL")
b$close()

# La advertencia de prototipo: si un cuadro la lleva, la llevan todos los
# cuadros de indicador y todo CSV de indicador (un solo interruptor,
# .PROTOTIPO).
pies_ind <- avisos <- 0
for (p in PAGINAS) {
  html <- paste(readLines(file.path(SITIO, p), warn = FALSE), collapse = "\n")
  n <- stringr::str_count(html, 'class="cuadro-pie"')
  pies_ind <- pies_ind + if (stringr::str_detect(html, stringr::fixed('piezas-acc'))) n else 0
  avisos   <- avisos   + stringr::str_count(html, 'class="cuadro-aviso"')
}
csvs <- setdiff(list.files(file.path(SITIO, "datos"), "\\.csv$", full.names = TRUE),
                file.path(SITIO, "datos", c("fuentes.csv", "red_capitulo_fuente.csv")))
con_aviso <- purrr::map_lgl(csvs, \(f) startsWith(sub("^\ufeff", "", readLines(f, n = 1, encoding = "UTF-8")), "# "))
if (avisos > 0 && (avisos != pies_ind || !all(con_aviso))) {
  fallar("Prototipo a medias: ", avisos, " de ", pies_ind, " pies de indicador, ",
         sum(con_aviso), " de ", length(csvs), " CSV")
} else if (avisos == 0 && any(con_aviso)) {
  fallar("Sin marca en los pies, pero el CSV sigue marcado")
} else ok("Advertencia de prototipo ",
          if (avisos) paste0("en los ", avisos, " pies de indicador y en ", length(csvs), " CSV") else "apagada")

# Los rangos: el primer ano se sube y los DOS cuadros del par se recortan.
for (par in list(c("economia.html", "eco", "II-1", "II-2"),
                 c("pobreza.html", "pob_ing", "III-1", "III-2"))) {
  b <- abrir(par[1])
  js(b, sprintf("['cuadro-%s','cuadro-%s'].forEach(function(a){document.querySelector('[data-value=\"'+a+'\"] .accordion-button').click()}); 1",
                par[3], par[4]))
  Sys.sleep(1.5)
  sel <- sprintf("document.getElementById('%s-anio_desde')", par[2])
  anios <- js(b, sprintf("Array.prototype.map.call(%s.options, function(o){return o.value})", sel))
  nuevo <- anios[[2]]
  js(b, sprintf("var d=%s; d.value='%s'; d.dispatchEvent(new Event('change',{bubbles:true})); 1", sel, nuevo))
  Sys.sleep(0.8)
  for (cuadro in par[3:4]) {
    eje <- jsonlite::fromJSON(opcion(b, paste0("lienzo-", cuadro), "xAxis[0].data"))
    if (min(as.numeric(eje)) != as.numeric(nuevo))
      fallar(cuadro, ": el rango no recorto el eje (empieza en ", min(eje), ")")
    else ok(cuadro, ": rango desde ", nuevo)
  }
  csv <- js(b, sprintf("(function(){var l=document.getElementById('lienzo-%s'); var d=JSON.parse(document.querySelector('script[data-for=\"lienzo-%s\"]').textContent); var k=%s.value+'-'+document.getElementById('%s-anio_hasta').value; return d.csv[k];})()",
                       par[3], par[3], sel, par[2]))
  # La advertencia de prototipo (aviso_csv()) va comentada con "#" antes de
  # la cabecera: la primera fila de datos es la segunda linea sin "#".
  lineas <- strsplit(csv, "\n")[[1]]
  primera <- lineas[!startsWith(lineas, "#")][2]
  if (!startsWith(primera, paste0(nuevo, ";"))) {
    fallar(par[3], ": el CSV del rango no empieza en ", nuevo)
  } else ok(par[3], ": CSV del rango")
  b$close()
}

# El selector de censo de I.3: un rango de un solo ano. Al elegir el primer
# censo cambia el dibujo y el CSV que se descarga es el de ese censo.
b <- abrir("poblacion.html#cuadro-I-3")
Sys.sleep(1)
sel <- "document.getElementById('pob_censo-anio')"
antes <- opcion(b, "lienzo-I-3", "series[0].data")
anios <- js(b, sprintf("Array.prototype.map.call(%s.options, function(o){return o.value})", sel))
nuevo <- anios[[1]]
js(b, sprintf("var d=%s; d.value='%s'; d.dispatchEvent(new Event('change',{bubbles:true})); 1", sel, nuevo))
Sys.sleep(0.8)
despues <- opcion(b, "lienzo-I-3", "series[0].data")
csv <- js(b, sprintf("JSON.parse(document.querySelector('script[data-for=\"lienzo-I-3\"]').textContent).csv['%s-%s']",
                     nuevo, nuevo))
if (is.null(antes) || identical(antes, despues)) {
  fallar("I-3: el selector de censo no cambio el dibujo")
} else if (is.null(csv) || !startsWith(grep("^#", strsplit(csv, "\n")[[1]], value = TRUE, invert = TRUE)[2],
                                       paste0(nuevo, ";"))) {
  fallar("I-3: el CSV del censo ", nuevo, " no corresponde")
} else ok("I-3: censo ", nuevo, " y su CSV")
b$close()

# La piramide de I.2: un censo son dos series de barras; "Superpuestos" son
# dos contornos por censo. La escala no se mueve entre una vista y la otra.
b <- abrir("poblacion.html#cuadro-I-2")
Sys.sleep(1)
tipos <- function() js(b, "JSON.stringify(echarts.getInstanceByDom(document.getElementById('lienzo-I-2')).getOption().series.map(function(s){return s.type}))")
eje   <- function() opcion(b, "lienzo-I-2", "xAxis[0].max")
uno <- jsonlite::fromJSON(tipos()); tope_uno <- eje()
js(b, "var d=document.getElementById('pob_piramide-anio'); d.value='todos'; d.dispatchEvent(new Event('change',{bubbles:true})); 1")
Sys.sleep(0.8)
todos <- jsonlite::fromJSON(tipos()); tope_todos <- eje()
if (!identical(uno, c("bar", "bar"))) {
  fallar("I-2: un censo deberia dibujar dos barras; dibujo ", paste(uno, collapse = ","))
} else if (length(todos) != 8 || !all(todos == "line")) {
  fallar("I-2: Superpuestos deberia dibujar 8 contornos; dibujo ", paste(todos, collapse = ","))
} else if (!identical(tope_uno, tope_todos)) {
  fallar("I-2: la escala cambio entre un censo (", tope_uno, ") y Superpuestos (", tope_todos, ")")
} else ok("I-2: un censo, Superpuestos y la misma escala")
b$close()

# Las fichas.
b <- abrir("metodologia.html")
js(b, "var c=document.getElementById('met-busqueda'); c.value='mortalidad'; c.dispatchEvent(new Event('input',{bubbles:true})); 1")
Sys.sleep(0.8)
cuenta <- js(b, "document.getElementById('met-cuenta').textContent")
if (!grepl("^\\d+ de \\d+ asientos$", cuenta)) {
  fallar("Busqueda 'mortalidad': ", cuenta)
} else ok("Busqueda 'mortalidad': ", cuenta)
b$close()

b <- abrir("metodologia.html?pieza=215")
Sys.sleep(0.8)
cuenta  <- js(b, "document.getElementById('met-cuenta').textContent")
abierta <- !js(b, "document.querySelector('[data-value=ind_215] .accordion-button').classList.contains('collapsed')")
if (!startsWith(cuenta, "1 de") || !abierta) {
  fallar("?pieza=215: ", cuenta, ", abierta = ", abierta)
} else ok("?pieza=215 deja la ficha sola y abierta")
b$close()


# ── 4. El menu de telefono ───────────────────────────────────────────────────
# En <=768px la franja de pestanas cede su lugar al menu "Indice" (menu_movil()).
# Tiene que traer las ocho secciones y todos los cuadros que publican los
# capitulos, abrir con el capitulo actual desplegado, llevar al cuadro en la
# misma pagina, y la barra tiene que seguir arriba al desplazarse.
cli::cli_h2("Menu de telefono")
visible <- function(b, sel)
  js(b, sprintf("(function(){var e=document.querySelector('%s'); return !!e && e.getClientRects().length > 0})()", sel))

b <- abrir("economia.html", 1360)
if (visible(b, ".menu-movil") || !visible(b, ".navbar-nav")) {
  fallar("@1360: el menu de telefono no deberia verse, la franja si")
} else ok("@1360: franja de pestanas, sin menu de telefono")
b$close()

cuadros_publicados <- sum(purrr::map_int(
  c("poblacion.html", "economia.html", "pobreza.html", "bienestar.html", "cohesion.html"),
  \(p) stringr::str_count(paste(readLines(file.path(SITIO, p), warn = FALSE), collapse = "\n"),
                          '<span class="pieza-numero">')))

b <- abrir("economia.html", 390)
franja <- visible(b, ".navbar-nav")
js(b, "document.querySelector('.menu-movil-boton').click(); 1"); Sys.sleep(0.4)
estado <- js(b, paste0(
  "JSON.stringify({abierto: document.querySelector('.menu-movil').open,",
  " panel: document.querySelector('.menu-movil-panel').getClientRects().length > 0,",
  " secciones: document.querySelectorAll('.menu-movil .menu-seccion').length,",
  " cuadros: document.querySelectorAll('.menu-movil .indice-item').length,",
  " actual: (document.querySelector('.menu-capitulo[open] [aria-current]') || {}).textContent || '',",
  " desborde: document.documentElement.scrollWidth > window.innerWidth})"))
estado <- jsonlite::fromJSON(estado)
if (isTRUE(franja)) {
  fallar("@390: la franja de pestanas sigue visible")
} else if (!isTRUE(estado$abierto) || !isTRUE(estado$panel)) {
  fallar("@390: el boton Indice no abrio el menu")
} else if (estado$secciones != 8) {
  fallar("@390: el menu trae ", estado$secciones, " secciones, no 8")
} else if (estado$cuadros != cuadros_publicados) {
  fallar("@390: el menu trae ", estado$cuadros, " cuadros; los capitulos publican ", cuadros_publicados)
} else if (!grepl("Econom", estado$actual)) {
  fallar("@390: el capitulo abierto no es el actual (", estado$actual, ")")
} else if (isTRUE(estado$desborde)) {
  fallar("@390: desborde horizontal con el menu abierto")
} else ok("@390: menu con 8 secciones y ", estado$cuadros, " cuadros, capitulo actual abierto")

# Un cuadro de la misma pagina: cierra el menu y despliega su entrada.
js(b, "document.querySelector('.menu-movil a[data-ancla=\"cuadro-II-3\"]').click(); 1")
Sys.sleep(1.2)
cerrado <- !js(b, "document.querySelector('.menu-movil').open")
desplegado <- !js(b, "document.querySelector('[data-value=\"cuadro-II-3\"] .accordion-button').classList.contains('collapsed')")
if (!cerrado || !desplegado) {
  fallar("@390: el enlace a II.3 no cerro el menu o no desplego el cuadro")
} else ok("@390: II.3 desde el menu, en la misma pagina")

js(b, "window.scrollTo(0, 2000); 1"); Sys.sleep(0.4)
tope <- js(b, "Math.round(document.querySelector('.navbar').getBoundingClientRect().top)")
if (!identical(as.numeric(tope), 0)) {
  fallar("@390: la barra no queda fija al desplazarse (top = ", tope, ")")
} else ok("@390: la barra queda fija al desplazarse")
exc <- excepciones(b)
if (length(exc)) fallar("Menu de telefono: ", paste(exc, collapse = " | "))
b$close()


# ── 5. La entrada ────────────────────────────────────────────────────────────
# index.html no lleva chasis ni colofon: se prueba aparte. "Entrar" estira la
# banda y recien despues navega, de ahi la espera.
cli::cli_h2("La entrada")
html <- paste(readLines(file.path(SITIO, "index.html"), warn = FALSE), collapse = "\n")
refs <- stringr::str_match_all(html, '(?:href|src)="([^"#?]+)')[[1]][, 2]
refs <- unique(refs[!grepl("^(https?:|mailto:|data:|//)", refs)])
rotos <- refs[!file.exists(file.path(SITIO, refs))]
if (length(rotos)) fallar("index.html: enlaces rotos ", paste(rotos, collapse = ", ")) else
  ok("index.html: ", length(refs), " enlaces internos")
for (ancho in c(1360, 390)) {
  b <- abrir("index.html", ancho)
  desborde <- js(b, "document.documentElement.scrollWidth > window.innerWidth")
  if (isTRUE(desborde)) fallar("index.html @", ancho, ": desborde horizontal")
  js(b, "document.querySelector('.entrada-prompt').click(); 1")
  Sys.sleep(2)
  destino <- js(b, "location.pathname.split('/').pop()")
  if (!identical(destino, "inicio.html"))
    fallar("index.html @", ancho, ": Entrar llevo a ", destino, ", no a inicio.html")
  exc <- excepciones(b)
  if (length(exc)) fallar("index.html @", ancho, ": ", paste(exc, collapse = " | "))
  if (!isTRUE(desborde) && identical(destino, "inicio.html") && !length(exc))
    ok("index.html @", ancho, "px: Entrar lleva a inicio.html")
  b$close()
}


# ── Resultado ────────────────────────────────────────────────────────────────
cli::cli_rule()
if (length(fallas)) {
  cli::cli_alert_danger("{length(fallas)} falla{?s}")
  quit(status = 1)
}
cli::cli_alert_success("Todo en orden")

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
#      despliega su entrada; la busqueda y ?pieza= filtran las fichas.
#   4. El menu de telefono: a 390 px reemplaza la franja, trae las 8 secciones
#      y todos los cuadros, lleva al cuadro, y la barra queda fija.
#
#   Termina con status 1 si algo falla, para poder usarlo antes de publicar.
#
# DEPENDENCIA DE TALLER: chromote y un Chrome instalado. No viaja al Action.
# ═════════════════════════════════════════════════════════════════════════════

suppressPackageStartupMessages(library(chromote))

SITIO <- normalizePath("_site", mustWork = TRUE)
PAGINAS <- c("index.html", "poblacion.html", "economia.html", "pobreza.html",
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
  primera <- strsplit(csv, "\n")[[1]][2]
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
} else if (is.null(csv) || !startsWith(strsplit(csv, "\n")[[1]][2], paste0(nuevo, ";"))) {
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


# ── Resultado ────────────────────────────────────────────────────────────────
cli::cli_rule()
if (length(fallas)) {
  cli::cli_alert_danger("{length(fallas)} falla{?s}")
  quit(status = 1)
}
cli::cli_alert_success("Todo en orden")

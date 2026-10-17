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
#      recortan sus dos cuadros y el CSV que se descarga; un ancla de cuadro
#      despliega su entrada; la busqueda y ?pieza= filtran las fichas.
#
#   Termina con status 1 si algo falla, para poder usarlo antes de publicar.
#
# DEPENDENCIA DE TALLER: chromote y un Chrome instalado. No viaja al Action.
# ═════════════════════════════════════════════════════════════════════════════

suppressPackageStartupMessages(library(chromote))

SITIO <- normalizePath("_site", mustWork = TRUE)
PAGINAS <- c("index.html", "poblacion.html", "economia.html", "pobreza.html",
             "bienestar.html", "cohesion.html", "metodologia.html", "fuentes.html")

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
  if (length(rotos)) {
    fallar(p, ": enlaces rotos ", paste(rotos, collapse = ", "))
  } else ok(p, ": ", length(refs), " enlaces internos")
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


# ── Resultado ────────────────────────────────────────────────────────────────
cli::cli_rule()
if (length(fallas)) {
  cli::cli_alert_danger("{length(fallas)} falla{?s}")
  quit(status = 1)
}
cli::cli_alert_success("Todo en orden")

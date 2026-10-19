# ═════════════════════════════════════════════════════════════════════════════
# R/40_pag_aparato.R — Las paginas del pie: Creditos y Contacto
#
# PAGINAS: creditos.html · contacto.html
#
# FUERA DE LA BARRA
#   No son secciones del catalogo: no tienen numeral ni entran a .CAPITULOS.
#   Se llega a ellas solo desde el colofon (ver .colofon() en R/50_sitio.R), y
#   pagina() las arma con la barra entera como enlaces, sin pestana activa.
#
# DONDE SE EDITAN LOS DATOS
#   .CONTACTO y .EQUIPO, aqui abajo. Es el unico lugar donde viven el correo y
#   los nombres. Mientras quede un "PENDIENTE", escribir_sitio() lo avisa.
#
# TEXTO CON TILDES
#   Son paginas nuevas, sin la herencia del encoding de Shiny: van con tildes
#   de punta a punta, como los rotulos de la barra.
# ═════════════════════════════════════════════════════════════════════════════

.CONTACTO <- list(
  correo    = "PENDIENTE",
  direccion = "PENDIENTE",
  telefono  = NULL           # opcional: NULL no publica la linea
)

# Una entrada por persona, en el orden en que se publica.
.EQUIPO <- list(
  list(nombre = "PENDIENTE", rol = "Dirección")
)

.PAGINAS_PIE <- list(
  list(archivo = "creditos.html", nombre = "Créditos", dibujo = \() pag_creditos()),
  list(archivo = "contacto.html", nombre = "Contacto", dibujo = \() pag_contacto())
)

#' Los campos de .CONTACTO y .EQUIPO que siguen sin completar
pendientes_pie <- function() {
  campos <- c(
    purrr::imap_chr(purrr::compact(.CONTACTO), \(v, k) paste0(".CONTACTO$", k, " = ", v)),
    purrr::imap_chr(.EQUIPO, \(p, i) paste0(".EQUIPO[[", i, "]]: ", p$nombre, " (", p$rol, ")")))
  campos[grepl("PENDIENTE", campos)]
}


# ── Creditos ─────────────────────────────────────────────────────────────────

# Las versiones se leen al construir: el credito no puede quedar describiendo
# una version que ya no es la que dibuja el sitio. La de ECharts sale del mismo
# yaml que lee .ruta_echarts() para copiar el archivo.
.software <- function() {
  dep <- yaml::read_yaml(system.file("htmlwidgets", "echarts4r.yaml", package = "echarts4r"))
  v <- \(pkg) as.character(utils::packageVersion(pkg))
  list(
    list("R", paste(R.version$major, R.version$minor, sep = "."),
         "Lenguaje en que se construye el sitio", "GPL-2 | GPL-3"),
    list("ECharts", dep$dependencies[[1]]$version, "Biblioteca de gráficos", "Apache-2.0"),
    list("echarts4r", v("echarts4r"), "ECharts desde R", "Apache-2.0"),
    list("bslib", v("bslib"), "Tema y componentes Bootstrap", "MIT"),
    list("htmltools", v("htmltools"), "Escritura del HTML", "GPL-2 | GPL-3"),
    list("Asap", NULL, "Tipografía de texto y cifras", "SIL OFL 1.1"),
    list("JetBrains Mono", NULL, "Tipografía de identificadores y medidas", "SIL OFL 1.1")
  )
}

.fila_credito <- function(nombre, detalle, extra = NULL) {
  div(class = "credito-fila",
      span(class = "credito-nombre", nombre),
      span(class = "credito-detalle", detalle),
      if (!is.null(extra)) span(class = "credito-extra", extra))
}

pag_creditos <- function() {
  pliego(
    tags$section(
      h2(class = "bloque-titulo", "Créditos"),
      p(class = "bloque-glosa prosa",
        "Datos Magallanes es una plataforma de la Unidad de Estudios Regionales",
        "de la Universidad de Magallanes.")
    ),
    tags$section(
      h3(class = "credito-seccion", "Equipo"),
      div(class = "creditos-lista",
          purrr::map(.EQUIPO, \(p) .fila_credito(p$nombre, p$rol)))
    ),
    tags$section(
      h3(class = "credito-seccion", "Software y tipografías"),
      p(class = "bloque-glosa prosa",
        "El sitio se escribe en R y se publica como páginas estáticas. Estas son",
        "las piezas de software libre con que se construye, en la versión que",
        "dibujó esta edición."),
      div(class = "creditos-lista",
          purrr::map(.software(), \(s) .fila_credito(
            # El nombre en Asap, la version en mono: es un identificador.
            tagList(s[[1]], if (!is.null(s[[2]])) span(class = "credito-version", s[[2]])),
            s[[3]], s[[4]]))),
      p(class = "bloque-glosa prosa credito-licencia",
        # El enlace cierra la frase: un punto en otra cadena quedaria separado
        # por el espacio que htmltools pone entre hijos.
        "Cada cifra conserva la cita de su fuente original. Los contenidos de la",
        "plataforma se publican bajo licencia",
        tags$a(href = "https://creativecommons.org/licenses/by/4.0/deed.es",
               "Creative Commons Atribución 4.0 (CC BY 4.0)"))
    )
  )
}


# ── Contacto ─────────────────────────────────────────────────────────────────

pag_contacto <- function() {
  correo <- .CONTACTO$correo
  pliego(
    tags$section(
      h2(class = "bloque-titulo", "Contacto"),
      p(class = "bloque-glosa prosa",
        "Escríbanos por consultas sobre los datos, para avisar de un error o para",
        "preguntar cómo citar o usar las cifras de la plataforma.")
    ),
    div(class = "creditos-lista",
        .fila_credito("Correo",
          # Sin direccion todavia, no se publica un mailto roto.
          if (identical(correo, "PENDIENTE")) correo
          else tags$a(href = paste0("mailto:", correo), correo)),
        .fila_credito("Dirección", .CONTACTO$direccion),
        if (!is.null(.CONTACTO$telefono)) .fila_credito("Teléfono", .CONTACTO$telefono),
        .fila_credito("Institución",
                      "Unidad de Estudios Regionales · Universidad de Magallanes"))
  )
}

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

# Una entrada por persona, en el orden en que se publica. Nombres y cargos como
# los publica la pagina "Quienes Somos" del sitio de la UER
# (09_Apps_Web/web_uer_complemento/equipo.qmd, 31-03-2026): si el equipo
# cambia alla, se actualiza aqui.
.EQUIPO <- list(
  list(nombre = "Felipe Lagos Rojas",      rol = "Jefe UER"),
  list(nombre = "Isabel Bustamante",       rol = "Investigadora"),
  list(nombre = "Paulina Cabezas Agüero",  rol = "Investigadora"),
  list(nombre = "Nicollet Gomez Rojas",    rol = "Investigadora"),
  list(nombre = "Marcelo Miño Ortiz",      rol = "Investigador"),
  list(nombre = "Valentina Pérez Nanjari", rol = "Encargada de Comunicaciones"),
  list(nombre = "Fabiola Millán",          rol = "Encargada de Administración"),
  list(nombre = "Scarlette Celis",         rol = "Profesional de Administración"),
  list(nombre = "Ma. Antonieta Pavez",     rol = "Profesional de Administración")
)

# ── Declaracion de uso de inteligencia artificial ───────────────────────────
# Lo que se usaron, para que y lo que NO se hizo con IA. La declaracion se
# limita a lo que consta: los modelos y el periodo salen de las lineas
# Co-Authored-By del historial de este repositorio y del dashboard que lo
# precede (10_Datos_Magallanes_dash, desde su primer commit del 05-03-2026).
# Al usar un modelo nuevo, o la IA en una tarea nueva, se actualiza aqui y en
# README.md ("Uso de inteligencia artificial"). Sigue la posicion de COPE: la
# IA no es autora, su uso se declara con la herramienta y el para que, y la
# responsabilidad es de quienes publican.
.USO_IA <- list(
  herramienta = "Claude Code, asistente de programación de Anthropic",
  modelos     = c("Claude Opus 4.6", "Claude Sonnet 4.6", "Claude Opus 5",
                  "Claude Sonnet 5", "Claude Opus 5.5"),
  periodo     = "2026-03 a 2026-10",
  con_ia = c(
    "Programación y diseño del sitio: código en R, JavaScript y CSS, diseño de la interfaz, pruebas automáticas y documentación técnica.",
    "Procesamiento de datos: limpieza, recorte regional y cálculo de los archivos de datos a partir de las fuentes oficiales."
  ),
  sin_ia = c(
    "La redacción de las fichas metodológicas y de los textos de la plataforma.",
    "Las series de prototipo que se publican en esta edición."
  )
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

# La declaracion de .USO_IA en la pagina: que herramienta, para que, que no, y
# quien responde. Las referencias van al pie, como en un articulo.
.seccion_uso_ia <- function() {
  ia <- .USO_IA
  lista <- \(x) tags$ul(class = "uso-ia-lista", purrr::map(x, tags$li))
  modelos <- paste0(paste(utils::head(ia$modelos, -1), collapse = ", "), " y ",
                    utils::tail(ia$modelos, 1))
  tags$section(
    h3(class = "credito-seccion", "Uso de inteligencia artificial"),
    p(class = "bloque-glosa prosa",
      "En el desarrollo de esta plataforma se usaron herramientas de inteligencia",
      "artificial generativa. Se declaran aquí con la herramienta, el período y",
      "las tareas en que intervinieron, para que el lector pueda evaluar el",
      "trabajo con esa información."),
    div(class = "creditos-lista",
        .fila_credito("Herramienta",
                      paste0(ia$herramienta, ", con los modelos ", modelos, "."),
                      ia$periodo),
        .fila_credito("Con asistencia de IA", lista(ia$con_ia)),
        .fila_credito("Sin IA", lista(ia$sin_ia)),
        .fila_credito("Al consultar el sitio",
                      paste("Ninguna. El sitio es estático: ninguna cifra se genera",
                            "ni se transforma en el navegador.")),
        .fila_credito("Supervisión y responsabilidad",
                      paste("El equipo de la UER revisó cada cambio antes de",
                            "publicarlo y es responsable del contenido de la",
                            "plataforma. La IA no figura como autora.")),
        .fila_credito("Trazabilidad",
                      paste("El historial de versiones del código registra cada",
                            "cambio hecho con asistencia de IA y el modelo usado."))),
    p(class = "bloque-glosa prosa uso-ia-referencias",
      "Referencias: Anthropic (2026). ", tags$em("Claude Code"), " [Software]. ",
      tags$a(href = "https://claude.com/claude-code", "claude.com/claude-code", .noWS = "after"),
      ". ",
      "COPE Council (2023). ", tags$em("Authorship and AI tools"),
      " [Declaración de posición, 13 de febrero de 2023]. ",
      tags$a(href = "https://publicationethics.org/guidance/cope-position/authorship-and-ai-tools",
             "publicationethics.org", .noWS = "after"), ".")
  )
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
    .seccion_uso_ia(),
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

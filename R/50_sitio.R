# ═════════════════════════════════════════════════════════════════════════════
# R/50_sitio.R — El chasis y la escritura del sitio
#
# QUE HACE
#   Arma cada pagina —barra de marca, menu de indices, la seccion, colofon— y
#   escribe el sitio completo en un directorio: paginas, recursos de www/,
#   ECharts y los CSV que se descargan. Lo llama construir.R.
#
# UNA PAGINA POR SECCION
#   En el dashboard Shiny las ocho secciones eran pestanas de una sola pagina.
#   Aqui cada una es SU pagina, con su URL (economia.html, y la pieza en
#   economia.html#cuadro-II-1): se enlaza, se guarda en marcadores y se cita
#   por su direccion, y abrir un capitulo no descarga los otros.
#
# EL CHASIS NO SE MUEVE
#   La barra de marca y la navegacion son identicas en las ocho paginas, y
#   deliberadamente sobrias: papel blanco y filete. La identidad fuerte vive en
#   las fotos banadas de las portadillas y en el portal.
# ═════════════════════════════════════════════════════════════════════════════

# ── Las paginas del sitio ────────────────────────────────────────────────────
# Se derivan de .CAPITULOS y de las dos salas de aparato (R/40_pag_presentacion.R),
# que son el registro unico de secciones: el rotulo de la barra, el archivo y el
# numeral salen de ahi. Lo unico que se declara aqui es que funcion dibuja cada
# una, en el orden de la barra.
.PAGINAS <- c(
  list(list(archivo = "index.html", nav = "Presentación", nombre = "Datos Magallanes",
            num = NULL, dibujo = \() pag_presentacion())),
  purrr::map2(
    c(.CAPITULOS, list(.SALA_METODOLOGIA, .SALA_FUENTES)),
    list(pag_poblacion, pag_economia, pag_pobreza, pag_bienestar, pag_cohesion,
         pag_metodologia, pag_fuentes),
    \(c, f) list(archivo = c$archivo, nav = c$nav, nombre = c$nombre,
                 num = c$num, dibujo = f))
)

# URL de un recurso con la fecha de su archivo: al editarlo cambia la URL y el
# navegador no puede servir la copia vieja de su cache.
.con_version <- function(url, archivo = url)
  paste0(url, "?v=", as.integer(file.mtime(archivo)))


# ── Barra de marca ───────────────────────────────────────────────────────────
# Tres piezas, en el orden que las distingue: la marca de LA PLATAFORMA a la
# izquierda, su nombre al centro y el sello de LA INSTITUCION a la derecha. La
# marca lleva a la portada.
.barra_marca <- function() {
  div(
    class = "barra-marca",
    tags$a(
      class = "marca", href = "index.html", style = "text-decoration:none",
      # La pestana de edicion: la del teal vertical de la portada del Boletin
      # ("N.2 / MARZO 2026"), aqui con la version y el mes de la edicion. Sale
      # de .EDICION: un solo cambio.
      div(class = "marca-edicion-pestana",
          span(class = "pestana-version", .EDICION$version),
          span(class = "pestana-fecha", .EDICION$mes)),
      # El emblema SIN el lettering que trae el archivo de portada: a 34px esas
      # tres lineas de texto son un borron y repetirian el nombre de al lado.
      tags$img(src = "marca-emblema.png", class = "marca-plataforma", alt = "",
               width = "50", height = "34"),
      div(class = "marca-regla"),
      div(class = "marca-lockup",
          div(class = "marca-titulo", "Datos Magallanes"),
          div(class = "marca-edicion",
              "Plataforma de informacion sobre bienestar y desarrollo"))
    ),
    tags$img(src = "logo_uer_color.png", class = "marca-institucion",
             alt = "Unidad de Estudios Regionales, Universidad de Magallanes")
  )
}

# ── Cabecera ─────────────────────────────────────────────────────────────────
.cabecera <- function(titulo) {
  tags$head(
    tags$title(titulo),
    # La fuente va ANTES de styles.css: declara los @font-face de Asap, que el
    # tema (tema_umag) solo nombra. Es nuestra copia, no una peticion a Google.
    tags$link(rel = "stylesheet", href = "fonts/asap.css"),
    tags$link(rel = "stylesheet", href = "fonts/mono.css"),
    tags$link(rel = "stylesheet", href = .con_version("styles.css", "www/styles.css")),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    # Un solo tema, claro: que el navegador no aplique su esquema oscuro a los
    # controles nativos.
    tags$meta(name = "color-scheme", content = "light"),

    # ── Identidad fuera de la pagina ────────────────────────────────────────
    tags$link(rel = "icon", type = "image/png", sizes = "32x32", href = "favicon-32.png"),
    tags$link(rel = "icon", type = "image/png", sizes = "16x16", href = "favicon-16.png"),
    tags$link(rel = "apple-touch-icon", sizes = "180x180", href = "apple-touch-icon.png"),
    tags$meta(name = "theme-color", content = "#ffffff"),
    # La tarjeta que se ve al pegar el enlace en un correo o un chat. El
    # emblema de portada viaja solo, con su nombre incrustado.
    tags$meta(property = "og:type",        content = "website"),
    tags$meta(property = "og:locale",      content = "es_CL"),
    tags$meta(property = "og:site_name",   content = "Datos Magallanes"),
    tags$meta(property = "og:title",       content = titulo),
    tags$meta(property = "og:description", content = .DESCRIPCION_SOCIAL),
    tags$meta(property = "og:image",       content = "og-image.png"),
    tags$meta(property = "og:image:width",  content = "1200"),
    tags$meta(property = "og:image:height", content = "630"),
    tags$meta(property = "og:image:alt",   content = .DESCRIPCION_SOCIAL),
    tags$meta(name = "twitter:card",        content = "summary_large_image"),
    tags$meta(name = "twitter:title",       content = titulo),
    tags$meta(name = "twitter:description", content = .DESCRIPCION_SOCIAL),
    tags$meta(name = "twitter:image",       content = "og-image.png"),
    tags$meta(name = "description",         content = .DESCRIPCION_SOCIAL),
    # Antes de que se dibuje nada, y en este orden: el formateador de cifras
    # (DM.n) que invoca cada rotulo y tooltip, y el tema "catalogo" que
    # e_lamina() le pide a cada grafico.
    script_formato(),
    script_tema_echarts(),
    # Diferidos: el primer grafico se dibuja recien cuando el lector abre una
    # entrada, y para entonces los tres ya cargaron.
    tags$script(src = "lib/echarts/echarts.min.js", defer = NA),
    tags$script(src = .con_version("portal.js", "www/portal.js"), defer = NA),
    tags$script(src = .con_version("js/sitio.js"), defer = NA)
  )
}

# ── Colofon ──────────────────────────────────────────────────────────────────
# Chasis fijo al pie de las ocho paginas. Lo abre el perfil del Paine de borde a
# borde y debajo va la firma: sello UER, institucion, el lugar desde donde se
# publica en coordenadas, y la ficha de edicion (de .EDICION).
.colofon <- function() {
  div(
    class = "colofon",
    div(class = "horizonte", `aria-hidden` = "true"),
    div(
      class = "colofon-interior",
      tags$img(src = "logo_uer_color.png", class = "colofon-logo",
               alt = "Unidad de Estudios Regionales, Universidad de Magallanes"),
      div(class = "colofon-texto",
          div(class = "colofon-institucion",
              "Unidad de Estudios Regionales · Universidad de Magallanes"),
          div(class = "colofon-lugar", "Punta Arenas · 53°09′50″S 70°55′02″W")),
      div(class = "colofon-meta",
          span(class = "colofon-edicion", paste0("Edicion ", .EDICION$version)),
          paste0(" · Beta de datos · Actualizado el ", .EDICION$actualizado,
                 " · © ", .EDICION$anio, " · CC BY 4.0"))
    )
  )
}


# ── Una pagina ───────────────────────────────────────────────────────────────
#' El chasis de page_navbar() con un solo panel: el de la seccion de la pagina
#'
#' Las demas entradas de la barra son enlaces a su propia pagina, con el mismo
#' marcado .nav-link que estiliza styles.css: la barra se ve y se recorre igual
#' que en el dashboard, pero cambiar de seccion es navegar.
pagina <- function(actual) {
  entradas <- purrr::map(.PAGINAS, function(p) {
    if (identical(p$archivo, actual$archivo))
      nav_panel(p$nav, div(class = "contenedor", p$dibujo()))
    else
      nav_item(tags$a(class = "nav-link", href = p$archivo, p$nav))
  })

  titulo <- if (identical(actual$archivo, "index.html")) "Datos Magallanes"
            else paste(actual$nombre, "· Datos Magallanes")

  do.call(page_navbar, c(
    list(
      id = "main_nav",
      theme = tema_umag(),
      fillable = FALSE,          # la pagina se desplaza; no se ajusta al viewport
      window_title = titulo,
      title  = .barra_marca(),
      # El indice de cada capitulo, colgado de su pestana. Se emite oculto y
      # js/sitio.js lo posiciona al abrirlo. Sale de LAM: una pieza nueva entra
      # al menu por el solo hecho de tener su grafico.R.
      header = tagList(.cabecera(titulo), menu_indices(.CAPITULOS)),
      footer = .colofon()
    ),
    entradas
  ))
}

#' La pestana de la pagina actual, con el marcado de las demas
#'
#' Fuera de una sesion Shiny, page_navbar() emite la pestana de su nav_panel con
#' marcado de Bootstrap 3 (<li class="active"><a data-toggle="tab">), sin la
#' clase .nav-link que styles.css estiliza; en el dashboard la completaba el
#' binding de Shiny al cargar. Aqui se reescribe al guardar: pasa a ser un
#' enlace a su propia pagina, marcado como la actual. Si bslib cambia ese
#' marcado, la construccion se detiene en vez de publicar una barra rota.
.pestana_activa <- function(archivo, href) {
  txt <- paste(readLines(archivo, encoding = "UTF-8"), collapse = "\n")
  patron <- '<li class="active">(\\s*)<a href="#tab-[^"]+" data-toggle="tab" data-bs-toggle="tab"'
  if (!grepl(patron, txt))
    cli::cli_abort("No encontre la pestana activa en {.path {archivo}}: cambio el marcado de bslib.")
  txt <- sub(patron, paste0('<li class="nav-item">\\1<a class="nav-link active" ',
                            'aria-current="page" href="', href, '"'), txt)
  writeLines(txt, archivo, useBytes = TRUE)
}


# ── El sitio ─────────────────────────────────────────────────────────────────
#' Escribir el sitio completo en `destino`
#'
#' @param destino Directorio de salida. Se vacia antes de escribir.
escribir_sitio <- function(destino) {
  if (dir.exists(destino)) unlink(destino, recursive = TRUE)
  dir.create(destino)

  # Recursos: fuentes, fotos de portadilla, logos, styles.css, portal.js, y el
  # JS del sitio.
  invisible(file.copy(list.files("www", full.names = TRUE), destino, recursive = TRUE))
  dir.create(file.path(destino, "js"))
  invisible(file.copy("js/sitio.js", file.path(destino, "js")))

  # ECharts, la misma version que trae echarts4r. Se copia el archivo y no la
  # dependencia del htmlwidget: aqui no hay htmlwidget, hay un lienzo que
  # js/sitio.js inicializa cuando se abre su entrada.
  dir.create(file.path(destino, "lib", "echarts"), recursive = TRUE)
  invisible(file.copy(.ruta_echarts(),
                      file.path(destino, "lib", "echarts", "echarts.min.js")))

  # Los CSV de los botones de descarga: uno por pieza con datos, y los dos
  # registros del capitulo VII.
  datos <- file.path(destino, "datos")
  dir.create(datos)
  purrr::iwalk(IND, \(df, carpeta) escribir_csv(df, file.path(datos, paste0(carpeta, ".csv"))))
  escribir_csv(d_fuentes, file.path(datos, "fuentes.csv"))
  escribir_csv(d_red, file.path(datos, "red_capitulo_fuente.csv"))
  cli::cli_alert_success("CSV: {length(IND) + 2}")

  # Las paginas. Las dependencias (Bootstrap compilado con tema_umag(), jQuery,
  # el JS de los componentes de bslib) quedan en lib/, compartidas.
  for (p in .PAGINAS) {
    archivo <- file.path(destino, p$archivo)
    htmltools::save_html(pagina(p), archivo, libdir = "lib", lang = "es")
    .pestana_activa(archivo, p$archivo)
    cli::cli_alert_success(p$archivo)
  }

  .podar_lib(destino)
}

#' La copia de ECharts que trae echarts4r, leida de su dependencia
.ruta_echarts <- function() {
  dep <- yaml::read_yaml(system.file("htmlwidgets", "echarts4r.yaml", package = "echarts4r"))
  system.file(dep$dependencies[[1]]$src, "echarts.min.js", package = "echarts4r",
              mustWork = TRUE)
}

#' Dejar en lib/ solo lo que alguna pagina pide
#'
#' save_html() copia cada dependencia con su directorio entero: fuentes Sass,
#' mapas, variantes sin minificar. Son unos 10 MB que ningun navegador pide. Se
#' conserva lo que las paginas referencian y lo que esas hojas de estilo
#' referencian a su vez con url(); el resto se borra.
.podar_lib <- function(destino) {
  lib  <- file.path(destino, "lib")
  html <- purrr::map(list.files(destino, "\\.html$", full.names = TRUE), readLines) |>
    unlist() |> paste(collapse = "\n")
  usados <- unique(stringr::str_match_all(html, '(?:src|href)="(lib/[^"?#]+)')[[1]][, 2])
  usados <- normalizePath(file.path(destino, usados))
  for (css in usados[grepl("\\.css$", usados)]) {
    refs <- stringr::str_match_all(paste(readLines(css, warn = FALSE), collapse = "\n"),
                                   "url\\(['\"]?([^'\")?#]+)")[[1]][, 2]
    refs <- refs[!grepl("^(data:|https?:)", refs)]
    usados <- c(usados, normalizePath(file.path(dirname(css), refs), mustWork = FALSE))
  }
  todos  <- normalizePath(list.files(lib, recursive = TRUE, full.names = TRUE))
  sobran <- setdiff(todos, usados)
  unlink(sobran)
  cli::cli_alert_info("lib/: {length(todos) - length(sobran)} archivos usados, {length(sobran)} podados")
}

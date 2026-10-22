# ═════════════════════════════════════════════════════════════════════════════
# R/30_ui_components.R — Componentes de El Catalogo Razonado
#
# Piezas de interfaz reutilizables. Funciones puras que devuelven tags HTML: no
# leen datos ni reaccionan a inputs. La apariencia se resuelve por clase CSS
# (www/styles.css); aqui se fija la ESTRUCTURA del marcado.
#
# Complementan al mobiliario de nivel de pagina de R/10_utils.R (cubierta,
# portadilla, inventario). Estas son de nivel de contenido.
#
# EL NUMERO DE ACCESO
#   Es la identidad de cada pieza y aparece en todos los componentes de este
#   archivo. Un indicador se cita por su numero, se busca por su numero y se
#   ancla por su numero. No es decoracion ni un rotulo sobre un titulo.
# ═════════════════════════════════════════════════════════════════════════════

# ── Cuadro: la lamina numerada ───────────────────────────────────────────────
# Sobrevive del mundo anterior por decision del usuario. Todo grafico y toda
# tabla viven dentro de un cuadro numerado con su fuente al pie. Un cuadro sin
# numero y sin fuente no se publica.
#
# La direccion del cuadro (II.3) es su cita: encoda el capitulo, de modo que una
# cifra arrancada de la pagina sigue sabiendo de donde salio.
#
# DOS FORMAS DE LLAMARLO
#   cuadro("II.3", "Titulo", grafico, fuente = "...")   la de siempre
#   cuadro(lam, grafico)                                con una lamina del registro
#
# En la segunda, `numero` es la lamina (LAM[["carpeta"]][["II.3"]]) y el numero,
# el titulo, la fuente y la nota salen de ella: el titulo y la fuente los trae
# ya resueltos contra la ficha metodologica, de modo que el cuadro nombra y cita
# la pieza igual que el asiento del capitulo VII. Un argumento explicito sigue
# ganando, para los casos en que el capitulo necesite matizar la nota al pie.
#
# CUIDADO CON EL SEGUNDO ARGUMENTO POSICIONAL
#   `cuadro(lam, grafico)` pasa el grafico en la posicion del formal `titulo`,
#   no en `...`. Si no se recupera, se pierde y el cuadro se publica con su
#   cabecera y su pie pero con el cuerpo vacio. De ahi el rescate explicito de
#   abajo: con una lamina, lo que llegue por `titulo` es contenido.
#
#' @param numero    Direccion del cuadro (ej. "II.3"), o una lamina del registro.
#' @param titulo    Titulo del cuadro. Con una lamina, es contenido: el titulo
#'                  lo manda la ficha.
#' @param ...       Contenido publicado: el grafico o la tabla.
#' @param controles Controles opcionales, alineados a la derecha de la cabecera.
#' @param fuente    Texto de la fuente. Obligatorio en la practica.
#' @param nota      Advertencia metodologica opcional, al pie tras la fuente.
#' @param descarga  Boton de descarga opcional (boton_descarga()), al final de
#'                  los controles. Separado de `controles` porque lo agrega el
#'                  modulo aunque el cuadro no tenga ningun otro control propio.
#' @param ancla     FALSE suprime el `id` del cuadro. pieza_cuadro() lo suprime
#'                  porque el ancla de cita la lleva su entrada plegada, que es
#'                  la que muestra direccion y nombre.
#' @param unidad     Unidad de medida, bajo el titulo y entre parentesis.
#' @param definicion Que mide la pieza. Va al pie, antes de la fuente.
#' @param pieza      Numero de acceso (110). Si se entrega, el pie publica el
#'                   enlace al asiento completo del capitulo VI.
#' @param cabecera  Cuanto de la cabecera se dibuja. Existe porque el cuadro ya
#'                  no siempre se publica suelto: dentro de una entrada plegada,
#'                  quien la encabeza ya dijo de que pieza se trata, y repetirlo
#'                  es ruido.
#'                  - "completa" (por defecto): numero, titulo, unidad y controles.
#'                  - "ninguna": sin cabecera. Es el caso de la entrada de
#'                    capitulo, que ya muestra direccion, nombre y unidad. Los
#'                    controles, si los hay, van en una franja sobre el cuerpo —
#'                    nunca bajo el grafico, que es donde no se buscan.
cuadro <- function(numero, titulo = NULL, ..., controles = NULL, fuente = NULL,
                    nota = NULL, descarga = NULL, ancla = TRUE, unidad = NULL,
                    definicion = NULL, pieza = NULL,
                    cabecera = c("completa", "ninguna")) {
  cabecera <- match.arg(cabecera)

  contenido <- list(...)

  # Se reconoce una lamina por su campo `numero`, no por is.list() a secas: un
  # tag de Shiny tambien es una lista.
  if (is.list(numero) && !is.null(numero$numero)) {
    lam <- numero
    # El grafico viaja en la posicion de `titulo`; se devuelve al cuerpo antes
    # de que el titulo de la ficha lo pise.
    if (!is.null(titulo)) contenido <- c(list(titulo), contenido)
    titulo <- lam$titulo
    fuente <- if (is.null(fuente)) lam$fuente else fuente
    nota   <- if (is.null(nota))   lam$nota   else nota
    unidad <- if (is.null(unidad)) lam$unidad else unidad
    definicion <- if (is.null(definicion)) lam$definicion else definicion
    # El numero de acceso sale del nombre de la carpeta, que por la regla de
    # identidad del catalogo SIEMPRE lo lleva de prefijo.
    if (is.null(pieza) && !is.null(lam$carpeta)) pieza <- sub("_.*", "", lam$carpeta)
    numero <- lam$numero
  }

  ilustrativo <- isTRUE(.PROTOTIPO) && !is.null(pieza)

  # La descarga NO se mezcla con los controles. Un slider de anos cambia lo que
  # el grafico muestra y por eso vive sobre el: es parte de la consulta. El CSV
  # no cambia nada — es lo que uno se lleva despues de mirar — y su lugar esta
  # al pie, junto a la fuente que habra que citar y al enlace a la ficha.

  div(
    class = "cuadro",
    # El ancla del cuadro es su direccion de cita: el cuadro II.3 vive en
    # #cuadro-II-3. Asi un enlace a una pieza es la misma cadena que se escribe
    # al citarla en un informe, y el indice del menu no necesita otra tabla de
    # correspondencias. El punto se cambia por guion porque en un selector CSS
    # un punto abre una clase.
    id = if (isTRUE(ancla)) ancla_cuadro(numero),
    if (cabecera != "ninguna")
      div(
        class = "cuadro-cabecera",
        div(class = "cuadro-identidad",
            span(class = "cuadro-numero", numero),
            if (cabecera == "completa")
              div(class = "cuadro-lockup",
                  # Con cabecera propia el cuadro va suelto en la pagina (el
                  # VII.1): su titulo es un encabezado bajo el h1 del capitulo.
                  h2(class = "cuadro-titulo", titulo),
                  rotulo_unidad(unidad))),
        if (!is.null(controles)) div(class = "cuadro-controles", controles)
      )
    # Sin cabecera los controles no desaparecen: se recogen en una franja sobre
    # el cuerpo, que es donde el lector los busca.
    else if (!is.null(controles))
      div(class = "cuadro-controles cuadro-controles-solos", controles),
    div(class = "cuadro-cuerpo", contenido),
    # El aparato del cuadro, en el orden en que se necesita: QUE mide, DE DONDE
    # sale, y la advertencia si la hay. La definicion va primera porque sin ella
    # la cifra no se interpreta; la fuente, porque sin ella no se cita.
    if (!is.null(definicion) || !is.null(fuente) || !is.null(nota) ||
        !is.null(pieza) || !is.null(descarga))
      div(
        class = "cuadro-pie",
        # La marca de prototipo va pegada al grafico, antes que todo: es lo que
        # entra en una captura de pantalla, y el lector que llego por el ancla
        # nunca vio la del inventario. Solo en los cuadros de un indicador: el
        # VII.1 cuenta fichas del catalogo, que no son de prototipo.
        if (ilustrativo)
          div(class = "cuadro-aviso", marca_estado("ilustrativo", .AVISO_PROTOTIPO)),
        if (!is.null(definicion))
          div(span(class = "llamada", "Definicion"), definicion),
        if (!is.null(fuente))
          div(span(class = "llamada", "Fuente"), fuente),
        if (!is.null(nota))
          div(span(class = "llamada", "Nota"), nota),
        # Lo que el lector hace DESPUES de leer el cuadro: ir a la ficha
        # completa o llevarse los datos. La ficha no se duplica aqui, se
        # enlaza: calculo, desagregaciones, disponibilidad y comparabilidad
        # viven en el asiento del capitulo VI.
        if (!is.null(pieza) || !is.null(descarga))
          div(
            class = "cuadro-acciones",
            # Un href real: la ficha se abre aunque el JS no haya cargado.
            # js/sitio.js la deja sola en la busqueda y la despliega.
            if (!is.null(pieza))
              tags$a(class = "enlace-ficha",
                     href = paste0("metodologia.html?pieza=", pieza),
                     `data-pieza` = pieza, "Ver ficha tecnica detallada")
            else span(),
            descarga
          )
      )
  )
}

# ── El ancla de un cuadro ────────────────────────────────────────────────────
#' Direccion de cita convertida en ancla HTML
#'
#' "II.3" -> "cuadro-II-3". Lo usan cuadro() al publicar y el indice del menu al
#' enlazar; ninguno de los dos inventa la cadena por su cuenta.
ancla_cuadro <- function(numero) paste0("cuadro-", gsub(".", "-", numero, fixed = TRUE))


# ── La unidad, bajo el nombre de la pieza ────────────────────────────────────
#' Rotulo de unidad de medida, entre parentesis
#'
#' Va bajo el titulo porque sin ella el grafico no se puede leer: "7,9" no dice
#' nada hasta saber que son nacidos vivos por mil habitantes. Es un requisito
#' del propio sistema —"acompanar toda cifra de su unidad, su periodo y su
#' fuente"— que hasta ahora solo cumplia la columna del inventario.
#'
#' NO VA EN ITALICA, aunque sea la convencion para este rotulo. Los tres
#' @font-face de www/fonts/asap.css son `font-style: normal`: pedir italica la
#' sintetizaria el navegador inclinando la recta, que es el mismo defecto de las
#' negritas falsas que el proyecto ya corrigio al dejar font_google(). Lo
#' distintivo lo dan el cuerpo menor, la tinta terciaria y los parentesis.
#'
#' @param unidad Texto de la unidad, o NULL/NA si la ficha no la trae.
rotulo_unidad <- function(unidad) {
  if (is.null(unidad) || length(unidad) != 1 || is.na(unidad) ||
      !nzchar(trimws(unidad))) return(NULL)
  u <- trimws(unidad)
  # "Porcentaje (%)" ya trae su parentesis: envolverla daria "(Porcentaje (%))".
  # Se aplana el de adentro a coma, que es como se lee en voz alta.
  u <- sub("\\s*\\(([^()]*)\\)\\s*$", ", \\1", u)
  span(class = "rotulo-unidad", paste0("(", u, ")"))
}


# ── El indice de un capitulo: las piezas que publica, por numero ─────────────
# Alimenta el desplegable de la barra de navegacion. Se deriva de LAM y de las
# fichas, no de una lista escrita a mano: un indicador nuevo aparece en el menu
# por el solo hecho de tener su grafico.R, igual que aparece en su capitulo.
#
# El capitulo de una lamina se lee de su propio numero de cuadro: "IV.2" es del
# capitulo IV. Esa es la razon de ser de la direccion de cita — encoda donde
# vive la pieza— asi que aqui se aprovecha en vez de mantener otro registro.
#
#' @param romano Numeral del capitulo ("I", "II", ...).
#' @return Lista de piezas, ordenadas por numero de cuadro.
indice_de_capitulo <- function(romano) {
  filas <- list()
  for (carpeta in names(LAM)) {
    for (lam in LAM[[carpeta]]) {
      partes <- strsplit(lam$numero, ".", fixed = TRUE)[[1]]
      if (partes[1] != romano) next
      filas[[length(filas) + 1]] <- list(
        numero = lam$numero,
        id     = sub("_.*", "", carpeta),
        nombre = lam$titulo,
        # Numerico y no alfabetico: de otro modo II.10 se ordenaria antes que
        # II.2, que es el clasico error de ordenar numeros como texto.
        orden  = suppressWarnings(as.numeric(partes[2]))
      )
    }
  }
  if (!length(filas)) return(list())
  filas[order(purrr::map_dbl(filas, "orden"))]
}

#' Los desplegables de la barra de navegacion, uno por capitulo
#'
#' Se emiten ocultos y js/sitio.js los posiciona bajo su pestana al abrirlos.
#' Cada entrada es un enlace real a la pagina del capitulo y al ancla del
#' cuadro (economia.html#cuadro-II-1): funciona sin JS, se puede copiar y citar.
#'
#' @param capitulos Lista con `num` (romano), `nav` (rotulo de la pestana) y
#'   `archivo` (la pagina del capitulo).
menu_indices <- function(capitulos) {
  paneles <- lapply(capitulos, function(c) {
    piezas <- indice_de_capitulo(c$num)
    if (!length(piezas)) return(NULL)
    div(
      class = "indice", `data-seccion` = c$nav, role = "menu",
      `aria-label` = paste("Indicadores del capitulo", c$nombre),
      lapply(piezas, \(p) .item_indice(c, p, role = "menuitem", tabindex = "-1"))
    )
  })
  div(class = "indices", purrr::compact(paneles))
}

# Una entrada de indice: direccion de cuadro, numero de acceso y nombre, como
# enlace real al ancla del cuadro. La comparten el desplegable de escritorio y
# el menu de telefono.
.item_indice <- function(capitulo, pieza, ...) {
  ancla <- ancla_cuadro(pieza$numero)
  tags$a(
    class = "indice-item", ...,
    href = paste0(capitulo$archivo, "#", ancla),
    `data-seccion` = capitulo$nav, `data-ancla` = ancla,
    span(class = "indice-cuadro", pieza$numero),
    span(class = "indice-id", pieza$id),
    span(class = "indice-nombre", pieza$nombre)
  )
}

#' El menu de telefono: todas las secciones y los cuadros de cada capitulo
#'
#' En <=768 px la franja de pestanas se oculta y su lugar lo toma este menu,
#' colgado de un boton "Indice" en la barra de marca. Es `<details>` nativo:
#' abre, cierra y navega sin JS; js/sitio.js solo agrega el cierre con Escape o
#' al tocar fuera y el bloqueo del fondo. Se deriva de .PAGINAS y de LAM, como
#' menu_indices(): una pieza nueva entra al menu por tener su grafico.R.
#'
#' @param actual Archivo de la pagina actual. El capitulo actual viene abierto y
#'   su entrada lleva aria-current; en las paginas del pie no hay ninguna.
menu_movil <- function(actual) {
  entradas <- lapply(.PAGINAS, function(p) {
    es_actual <- identical(p$archivo, actual)
    rotulo <- tagList(
      span(class = "menu-num", p$num %||% ""),
      span(class = "menu-nombre", p$nav)
    )
    piezas <- if (is.null(p$num)) list() else indice_de_capitulo(p$num)
    if (!length(piezas))
      return(tags$a(class = "menu-seccion", href = p$archivo,
                    `aria-current` = if (es_actual) "page", rotulo))
    tags$details(
      class = "menu-capitulo", open = if (es_actual) NA,
      tags$summary(class = "menu-seccion",
                   `aria-current` = if (es_actual) "page", rotulo),
      tags$a(class = "menu-inicio", href = p$archivo, "Inicio del capitulo"),
      lapply(piezas, \(x) .item_indice(p, x))
    )
  })
  tags$details(
    class = "menu-movil",
    tags$summary(class = "menu-movil-boton",
                 `aria-label` = "Indice del sitio",
                 span(class = "menu-movil-icono", `aria-hidden` = "true"),
                 span(class = "menu-movil-rotulo", "Indice")),
    tags$nav(class = "menu-movil-panel", `aria-label` = "Secciones y cuadros del sitio",
             entradas)
  )
}


# ── El capitulo plegado: una pieza a la vez ──────────────────────────────────
# El capitulo dejo de ser un muro de graficos. El inventario sigue arriba
# mostrando TODAS las piezas con su cifra vigente —la cantidad sigue siendo el
# argumento— y debajo cada cuadro se pliega bajo su direccion de cita, de modo
# que el lector que viene por una consulta puntual abre la suya y no recorre
# ocho graficos que no pidio.
#
# NO LLEVA FICHA. El asiento del capitulo VI es el que reune cuadro y registro;
# aqui va solo la lamina. Esa es la linea que separa las dos secciones y evita
# que el capitulo y Metodologia terminen siendo lo mismo.

#' Una pieza del capitulo, plegada bajo su direccion de cita
#'
#' @param clave  Valor del panel. Es el ancla del primer cuadro, para que el
#'               indice del menu pueda abrirlo ademas de desplazarse hasta el.
#' @param numero Direccion de cita que encabeza la entrada ("I.2").
#' @param nombre Nombre de la pieza.
#' @param unidad Unidad de medida. Va bajo el nombre, entre parentesis: la
#'               entrada plegada es lo unico que se lee del capitulo sin abrir
#'               nada, y ahi la unidad convierte una lista de nombres en una
#'               lista de mediciones.
#' @param ...    El cuadro o los cuadros.
entrada_pieza <- function(clave, numero, nombre, unidad = NULL, ...) {
  cabecera_h3(bslib::accordion_panel(
    value = clave,
    title = div(
      class = "pieza-cabeza",
      span(class = "pieza-numero", numero),
      div(class = "pieza-lockup",
          span(class = "pieza-nombre", nombre),
          rotulo_unidad(unidad))
    ),
    ...
  ))
}

#' La cabecera de una entrada plegada, como encabezado h3
#'
#' bslib la emite como <div class="accordion-header">: quien recorre la pagina
#' por encabezados (lector de pantalla, tecla H) no encontraba ningun cuadro.
#' Como h3 cada pieza es un encabezado bajo el h2 de su lista, y el boton que
#' abre la entrada sigue dentro, como pide el patron de acordeon de la WAI.
cabecera_h3 <- function(panel) {
  htmltools::tagQuery(panel)$find(".accordion-header")$each(\(x, i) x$name <- "h3")$allTags()
}

#' El cuerpo del capitulo: sus piezas plegadas
#'
#' `multiple = TRUE` a proposito: dos piezas abiertas a la vez es como se
#' comparan dos series que no comparten cuadro.
piezas_capitulo <- function(id, ...) {
  tagList(
    # El h2 de la lista: en pantalla la lista se presenta sola, pero en el
    # esquema de encabezados las piezas (h3) necesitan de quien colgar.
    h2(class = "visually-hidden", "Cuadros del capitulo"),
    do.call(bslib::accordion,
            c(list(...), list(id = id, open = FALSE, multiple = TRUE,
                              class = "piezas-acc")))
  )
}

#' Una pieza del capitulo: la entrada plegada con su cuadro dentro
#'
#' El armado que los cinco capitulos de datos repiten por cada lamina. El cuadro
#' va sin cabecera (la entrada ya dice numero, nombre y unidad), con el
#' conmutador del cero donde la lamina lo admite y la descarga al pie.
#'
#' El grafico es un lienzo con todos sus dibujos ya hechos (ver lienzo()). Los
#' ids salen del numero de cuadro —lienzo-II-1, cero-II-1— y no de un namespace:
#' el numero ya es unico en todo el catalogo.
#'
#' @param lam       La lamina del registro LAM.
#' @param datos     Lo que dibuja. Por defecto, los datos de su propia carpeta.
#' @param controles Controles propios del capitulo (el rango de anos de II.1),
#'                  que van antes del conmutador del cero.
#' @param nota      Nota al pie que matiza la de la lamina (ver cuadro()).
#' @param rango     Un rango_anios() del capitulo, si la pieza lo sigue.
pieza_cuadro <- function(lam, datos = IND[[lam$carpeta]], controles = NULL,
                         nota = NULL, rango = NULL) {
  sufijo  <- gsub(".", "-", lam$numero, fixed = TRUE)
  id_cero <- if (isTRUE(lam$admite_cero)) paste0("cero-", sufijo)
  # El conmutador del cero, solo donde tiene sentido: las laminas de barras no
  # lo llevan (ver lam$admite_cero en R/20_graficos.R). Arranca en el estado
  # que la lamina declara (lam$cero_inicial), no marcado siempre.
  if (!is.null(id_cero))
    controles <- tagList(controles,
                         control_check(id_cero, "Eje desde cero", lam$cero_inicial))

  id_lienzo <- paste0("lienzo-", sufijo)
  ancla <- ancla_cuadro(lam$numero)
  entrada <- entrada_pieza(
    clave  = ancla,
    numero = lam$numero,
    nombre = lam$titulo,
    unidad = lam$unidad,
    # Sin controles queda NULL, no una lista vacia: cuadro() dibujaria una
    # franja de controles en blanco.
    cuadro(lam,
           controles = controles,
           nota      = nota,
           descarga  = boton_descarga(lam$carpeta, if (!is.null(rango)) id_lienzo),
           cabecera  = "ninguna",
           ancla     = FALSE,
           lienzo(id_lienzo, lam, datos, rango, id_cero))
  )
  # El ancla de cita va en la entrada y no en el cuadro: el cuadro va sin
  # cabecera, y quien llega por economia.html#cuadro-II-1 tiene que aterrizar
  # sobre la direccion y el nombre que va a citar, no sobre un grafico mudo.
  # Tambien sin JS: el salto nativo del navegador cae en la misma cabecera.
  htmltools::tagAppendAttributes(entrada, id = ancla)
}

#' El lienzo de una lamina y todos sus dibujos
#'
#' Un div vacio del alto de la lamina y, a su lado, un <script type=
#' "application/json"> con cada dibujo que el lector puede pedir, hecho por
#' dibujar(): uno por rango de anos (o uno solo, "todo") y, dentro, uno por
#' estado del conmutador ("si"/"no") o el unico que admite ("fijo", las barras).
#' js/sitio.js lo inicializa cuando se abre su entrada y solo ELIGE entre ellos.
#'
#' POR QUE TODO SE DIBUJA AQUI. El eje lo decide .anclar_cero() (R/20_graficos.R)
#' y reescribirlo en JS daria dos definiciones del mismo eje. Cuesta poco
#' mientras los rangos sean cortos: con n anos hay n(n+1)/2 rangos (21 para el
#' PIB). Si una serie con selector llegara a 25-30 anos, convendria recortar en
#' el navegador y dejar el eje del rango completo.
lienzo <- function(id, lam, datos, rango = NULL, id_cero = NULL) {
  rangos <- if (is.null(rango)) list(todo = NULL) else rango$rangos
  recorte <- function(r) if (is.null(r)) datos else
    dplyr::filter(datos, anio >= r[1], anio <= r[2])

  # Una lamina que declara el argumento `todo` recibe ademas los datos
  # completos, para fijar con ellos lo que no debe moverse entre cortes (la
  # escala de la piramide de I.2). Sigue siendo pura: `todo` tiene por defecto
  # el propio `df`, y desde la consola se dibuja igual.
  extra <- if ("todo" %in% names(formals(lam$dibujo))) list(todo = datos)
  dibujos <- purrr::map(rangos, function(r) {
    d <- recorte(r)
    dib <- function(...) opciones_grafico(do.call(dibujar, c(list(lam, d), extra, list(...))))
    if (isTRUE(lam$admite_cero)) list(si = dib(cero = TRUE), no = dib(cero = FALSE))
    else list(fijo = dib())
  })
  # Con rango, el CSV es el del rango que el cuadro muestra, como en la app.
  csv <- if (!is.null(rango)) purrr::map(rangos, \(r) texto_csv(recorte(r), aviso_csv()))

  .lienzo_html(id, lam$altura, paste("Cuadro", lam$numero, "-", lam$titulo),
               list(dibujos = dibujos, csv = csv),
               cero = id_cero, rango = rango$id)
}

#' Un lienzo con un solo dibujo, para laminas que no estan en LAM
#'
#' El sankey del capitulo VII dibuja el catalogo entero y no cuelga de ninguna
#' ficha, asi que se arma en su pagina (ver R/40_pag_fuentes.R).
#'
#' @param e Objeto echarts4r ya terminado (con e_lamina()).
lienzo_fijo <- function(id, e, altura, etiqueta) {
  .lienzo_html(id, altura, etiqueta,
               list(dibujos = list(todo = list(fijo = opciones_grafico(e)))))
}

.lienzo_html <- function(id, altura, etiqueta, carga, cero = NULL, rango = NULL) {
  tagList(
    div(class = "lamina-lienzo", id = id,
        style = paste0("width:100%;height:", altura, ";"),
        `data-cero` = cero, `data-rango` = rango,
        role = "img", `aria-label` = etiqueta),
    tags$script(type = "application/json", `data-for` = id, HTML(a_json(carga)))
  )
}

#' Un rango de anos compartido por dos cuadros
#'
#' En Economia y en Pobreza un solo par Desde/Hasta gobierna dos cuadros, para
#' que el nivel y su variacion (o las dos pobrezas) no queden mostrando periodos
#' distintos. Se declara una vez en el capitulo y se pasa a las dos piezas; la
#' primera lleva ademas los controles.
#'
#' @param id    Prefijo de los selectores: <id>-anio_desde y <id>-anio_hasta.
#' @param anios Los anos que ofrece el selector, del propio CSV.
#' @return Lista con `id`, `rangos` (todos los pares desde <= hasta, con clave
#'   "2018-2023") y `controles` (los dos selectores).
rango_anios <- function(id, anios) {
  anios <- sort(unique(anios))
  pares <- tidyr::expand_grid(desde = anios, hasta = anios) |>
    dplyr::filter(desde <= hasta)
  list(
    id = id,
    rangos = purrr::set_names(purrr::map2(pares$desde, pares$hasta, c),
                              paste(pares$desde, pares$hasta, sep = "-")),
    controles = tagList(
      control_select(paste0(id, "-anio_desde"), "Desde", anios, min(anios), "96px"),
      control_select(paste0(id, "-anio_hasta"), "Hasta", anios, max(anios), "96px"))
  )
}

#' Un ano suelto: el selector de censo
#'
#' La variante de un solo ano de rango_anios(): el lector elige UN ano y el
#' cuadro muestra solo ese corte (los censos de I.3). Reusa la maquinaria del
#' rango —cada ano es el rango "2017-2017", dibujado por lienzo() al construir—,
#' asi que js/sitio.js sigue eligiendo entre dibujos hechos, y el CSV que se
#' descarga es el del ano que el cuadro muestra.
#'
#' CON `todos`, el selector ofrece ademas una ultima opcion que deja pasar
#' todos los anos a la vez (la clave "todos-todos", que js/sitio.js arma igual
#' que las demas). Que hacer con varios anos lo decide la lamina: la piramide
#' de I.2 los superpone.
#'
#' @param id     Prefijo del selector: <id>-anio.
#' @param anios  Los anos que ofrece el selector, del propio CSV.
#' @param rotulo Rotulo del selector.
#' @param todos  Rotulo de la opcion con todos los anos, o NULL para no darla.
#' @return La misma forma que rango_anios(): `id`, `rangos` y `controles`.
corte_anio <- function(id, anios, rotulo = "Ano", todos = NULL) {
  anios <- sort(unique(anios))
  rangos <- purrr::set_names(purrr::map(anios, \(a) c(a, a)),
                             paste(anios, anios, sep = "-"))
  opciones <- purrr::set_names(anios, anios)
  if (!is.null(todos)) {
    rangos[["todos-todos"]] <- range(anios)
    opciones <- c(opciones, purrr::set_names("todos", todos))
  }
  list(
    id = id,
    rangos = rangos,
    controles = control_select(paste0(id, "-anio"), rotulo, opciones, max(anios),
                               if (is.null(todos)) "96px" else "150px")
  )
}


# ── Marca de estado: trama y corte, nunca solo color ─────────────────────────
# El estado del dato se distingue por FORMA ademas de por color, para que sea
# legible impreso en blanco y negro y para daltonismo. La trama la dibuja el CSS
# en ::before; no hay glifo ni emoji involucrado.
#
# tipo: "compilado" | "preliminar" | "interrumpida" | "nodisponible" | "ilustrativo"
#
#' @param tipo  Una de las cuatro claves de `etiquetas`.
#' @param texto Rotulo alternativo; por defecto, el estandar del tipo.
marca_estado <- function(tipo, texto = NULL) {
  etiquetas <- c(
    compilado    = "Con datos",
    preliminar   = "Dato preliminar",
    interrumpida = "Serie interrumpida",
    nodisponible = "Sin datos compilados",
    ilustrativo  = "Dato ilustrativo"
  )
  if (is.null(texto)) texto <- etiquetas[[tipo]]
  span(class = paste0("marca-estado es-", tipo), texto)
}

# ── Nota de aparato: advertencia metodologica dentro del cuerpo ─────────────
# Se distingue de la nota al pie del cuadro: esta va junto al dato porque el
# lector necesita leerla ANTES de interpretar lo que ve.
nota_aparato <- function(...) div(class = "nota-aparato", ...)

# ── Pliego: la columna de lectura ────────────────────────────────────────────
# Los dos campos violetas (cubierta y portadilla) van a sangre, de borde a borde
# de la ventana. Todo lo demas se compone dentro de este pliego, que es lo que
# fija el ancho de lectura. Envolver en vez de recortar con vw evita el
# desbordamiento horizontal que produce la barra de desplazamiento.
pliego <- function(...) div(class = "pliego", ...)

# ── Controles ────────────────────────────────────────────────────────────────
# El mismo marcado que dibujaban selectInput(selectize = FALSE), checkboxInput y
# textInput de Shiny, que es el que estiliza www/styles.css (.form-group,
# .checkbox, .form-control). Sin Shiny no hay binding que los inicialice: son
# controles nativos, y js/sitio.js escucha sus eventos.

#' Selector nativo
#'
#' @param opciones Valores del selector. Si el vector tiene nombres, el nombre
#'   es el rotulo que se lee y el valor es lo que viaja (corte_anio(todos=)).
control_select <- function(id, rotulo, opciones, elegido = NULL, ancho = "100%") {
  rotulos  <- names(opciones) %||% as.character(opciones)
  opciones <- as.character(opciones)
  div(class = "form-group shiny-input-container", style = paste0("width:", ancho, ";"),
      tags$label(class = "control-label", id = paste0(id, "-label"), `for` = id, rotulo),
      div(tags$select(class = "form-control", id = id,
                      purrr::map2(opciones, rotulos, \(o, r)
                        tags$option(value = o, selected = if (identical(o, as.character(elegido))) NA, r)))))
}

#' Casilla de verificacion
control_check <- function(id, rotulo, marcado = FALSE) {
  div(class = "form-group shiny-input-container", style = "width:auto;",
      div(class = "checkbox",
          tags$label(
            tags$input(id = id, type = "checkbox", checked = if (isTRUE(marcado)) NA),
            span(rotulo))))
}

#' Campo de texto
control_texto <- function(id, rotulo, ayuda = NULL) {
  div(class = "form-group shiny-input-container", style = "width:100%;",
      tags$label(class = "control-label", id = paste0(id, "-label"), `for` = id, rotulo),
      tags$input(id = id, type = "text", class = "form-control", value = "",
                 placeholder = ayuda, autocomplete = "off"))
}

# ── Boton de descarga: el CSV que dibuja el cuadro ───────────────────────────
# El enlace que dibujaba downloadButton() (clase btn-descarga, que es lo que
# styles.css estiliza), apuntando al archivo que construir.R escribe en datos/.
#
# Con `lienzo`, la pieza sigue un rango de anos: el archivo depende del rango
# vigente, y js/sitio.js lo arma al hacer clic con el CSV embebido en el lienzo.
#
#' @param carpeta Carpeta del indicador, o nombre base del archivo en datos/.
#' @param lienzo  Id del lienzo con rango, si lo hay.
boton_descarga <- function(carpeta, lienzo = NULL) {
  tags$a(class = "btn btn-default btn-descarga",
         href = if (is.null(lienzo)) paste0("datos/", carpeta, ".csv") else "#",
         download = paste0(carpeta, "_", format(Sys.Date(), "%Y%m%d"), ".csv"),
         `data-descarga-de` = lienzo,
         "CSV")
}

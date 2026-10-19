# ═════════════════════════════════════════════════════════════════════════════
# R/40_pag_presentacion.R — El portal
#
# PAGINA: inicio.html (la raiz, index.html, es la entrada: R/40_pag_entrada.R)
#
# QUE HACE
#   Es la entrada de la plataforma, y responde tres preguntas antes que
#   cualquier otra cosa: que problema resuelve esto, que hay adentro, y por que
#   lo construye una universidad publica desde la region. Cuatro piezas:
#
#     1. El umbral — la portada del Boletin N.2 en papel: la foto del indice del
#        Boletin a la izquierda, la frase de apertura con su palabra en banda
#        magenta, la linea de estado del catalogo, y el perfil del Paine al pie.
#     2. El indice — "In/di/ce" y las siete salas en filas de registro. La
#        portada NO publica piezas: publica entradas.
#     3. El pulso de la region — seis indicadores del catalogo en pequenos
#        multiplos, uno por dimension tematica. Resumen, no inventario.
#     4. El cimiento — soberania digital, trazabilidad y acceso, sobre las
#        curvas de nivel. El unico lugar donde la UER habla de la plataforma.
#
#   No tiene logica propia: las salas y los paneles del pulso son enlaces a la
#   pagina de su capitulo.
#
# NINGUNA CIFRA SE TRANSFORMA AQUI
#   El pulso dibuja el nivel que trae el CSV de cada fuente y anota su ultimo
#   valor. No hay delta calculado, ni indice base, ni re-referenciacion.
#
# DATOS QUE CONSUME
#   d_indicadores  las fichas del catalogo, con la columna derivada tiene_datos
#   IND / ficha_de() las seis series del pulso y sus fichas
#   d_fuentes      el recuento de registros oficiales y de organismos (R/00_data.R)
# ═════════════════════════════════════════════════════════════════════════════

# ── Los cinco capitulos tematicos ────────────────────────────────────────────
# Fuente unica de verdad de la navegacion: de aqui salen la barra, los menus de
# indice, las salas de la portada y los rotulos del capitulo VII (R/50_sitio.R),
# de modo que cambiar el nombre de una seccion es un solo cambio.
#   archivo  la pagina del capitulo
#   num      numeral romano del capitulo
#   nav      rotulo de la pestana en la barra, con tildes: el menu de indice
#            cuelga de la pestana que lleva este mismo texto
#   nombre   rotulo en la puerta (sin tildes, como el resto de la UI)
#   glosa    que contiene el capitulo, en una linea
#   seccion  valor del campo `seccion` en las ficha.yaml, para contar piezas
#   rango    rango de numeros de acceso del capitulo
.CAPITULOS <- list(
  list(archivo = "poblacion.html", num = "I", nav = "Población", nombre = "Poblacion",
       glosa = "Tamano, estructura por edad y sexo, migracion y envejecimiento",
       seccion = "Poblacion", rango = "100-199"),
  list(archivo = "economia.html", num = "II", nav = "Economía", nombre = "Economia",
       glosa = "Producto regional, mercado laboral y composicion sectorial",
       seccion = "Economia", rango = "200-299"),
  list(archivo = "pobreza.html", num = "III", nav = "Pobreza e Ingresos", nombre = "Pobreza e Ingresos",
       glosa = "Pobreza multidimensional y por ingresos, desigualdad y brechas",
       seccion = "Pobreza e Ingresos", rango = "300-399"),
  list(archivo = "bienestar.html", num = "IV", nav = "Bienestar", nombre = "Bienestar",
       glosa = "Salud, educacion y condiciones de habitabilidad",
       seccion = "Bienestar", rango = "400-499"),
  list(archivo = "cohesion.html", num = "V", nav = "Cohesión Social", nombre = "Cohesion Social",
       glosa = "Confianza institucional, participacion ciudadana y seguridad",
       seccion = "Cohesion Social", rango = "500-599")
)

# La sexta sala. No esta en .CAPITULOS porque no es una dimension tematica: no
# cuenta indicadores de una seccion sino el total de fichas del catalogo.
.SALA_METODOLOGIA <- list(archivo = "metodologia.html", num = "VI", nav = "Metodología",
                          nombre = "Metodologia",
                          glosa = "La ficha tecnica completa de cada indicador del catalogo")

# La septima. Tampoco es una dimension tematica: es el otro registro del
# catalogo —el asiento de cada fuente— y cuenta operaciones estadisticas, no
# indicadores.
.SALA_FUENTES <- list(archivo = "fuentes.html", num = "VII", nav = "Fuentes",
                      nombre = "Fuentes",
                      glosa = "De donde viene cada cifra: las operaciones estadisticas que alimentan el catalogo")


# ─────────────────────────────────────────────────────────────────────────────
# EL PULSO DE LA REGION
# ─────────────────────────────────────────────────────────────────────────────
# Seis indicadores del catalogo, uno por dimension tematica (la economia lleva dos:
# producto y desempleo son las dos cifras que la region cita mas). La eleccion
# es editorial y esta declarada aqui, no repartida por la vista.
#
# Solo se declara de DONDE sale el dato y COMO se escribe su cifra. El nombre,
# la unidad y la fuente los manda la ficha de la carpeta, igual que en todo
# cuadro del catalogo: la portada no puede nombrar una pieza distinto de como
# la nombra su asiento del capitulo VI.
#
#   carpeta  la carpeta del indicador; de ahi salen el dato Y la ficha
#   col      columna del CSV que lleva el valor
#   dec      decimales con que se escribe la cifra (formato chileno)
#   suf      lo que va pegado a la cifra; la unidad completa va bajo el nombre
#   archivo  pagina de destino al pulsar el panel
.PULSO <- list(
  list(carpeta = "101_poblacion_regional_segun_sexo", col = "total",           dec = 0, suf = "",  archivo = "poblacion.html"),
  list(carpeta = "215_pib_regional",            col = "pib",             dec = 0, suf = "",  archivo = "economia.html"),
  list(carpeta = "205_empleo",                  col = "desempleo",       dec = 1, suf = "%", archivo = "economia.html"),
  list(carpeta = "301_pobreza",                 col = "pobreza_ingreso", dec = 1, suf = "%", archivo = "pobreza.html"),
  list(carpeta = "404_anos_escolaridad",        col = "escolaridad",     dec = 1, suf = "",  archivo = "bienestar.html"),
  list(carpeta = "515_participacion_electoral", col = "electoral",       dec = 1, suf = "%", archivo = "cohesion.html")
)

# ── El trazo de una serie, en SVG plano ──────────────────────────────────────
# No es echarts: seis lienzos mas en la portada costarian seis instancias de
# ECharts por el gusto de dibujar una polilinea de doce puntos. Esto es SVG
# emitido por R, sin una sola linea de JavaScript, y se imprime.
#
# EL VIEWBOX SE ESTIRA Y EL TRAZO NO. `preserveAspectRatio = "none"` deja que el
# panel elija su ancho, y `vector-effect: non-scaling-stroke` (en styles.css)
# impide que ese estiramiento engorde la linea. Por eso el extremo de la serie
# se marca con una VERTICAL y no con un circulo: bajo escala horizontal no
# uniforme un circulo se deforma en elipse, una vertical sigue siendo vertical.
#
# El eje de valor se ajusta a la serie con un 8% de aire. Es un panel de
# resumen, no un cuadro: la cifra exacta va anotada al lado y el cuadro con su
# eje completo vive en el capitulo, a un clic.
#
#' @param valores Vector numerico de la serie, en orden cronologico.
#' @param retardo Milisegundos de espera antes de trazar. Escalona los paneles.
.trazo_serie <- function(valores, retardo = 0) {
  W <- 260; H <- 58; margen <- 5

  rango <- range(valores, na.rm = TRUE)
  aire  <- max(diff(rango) * 0.08, 1e-9)
  lo    <- rango[1] - aire; hi <- rango[2] + aire

  n  <- length(valores)
  xs <- if (n == 1) W / 2 else seq(0, W, length.out = n)
  ys <- H - margen - (valores - lo) / (hi - lo) * (H - 2 * margen)

  # La entrada la hace un recorte que descubre el SVG entero de izquierda a
  # derecha (ver .pulso-svg en styles.css); aqui solo se fija su retardo.
  tags$svg(
    class = "pulso-svg", viewBox = paste("0 0", W, H),
    style = sprintf("--retardo: %dms;", retardo),
    preserveAspectRatio = "none", `aria-hidden` = "true", focusable = "false",
    role = "presentation",
    # La linea de base: el filete capilar del sistema, tambien aqui.
    tags$line(class = "pulso-base", x1 = 0, y1 = H - 0.5, x2 = W, y2 = H - 0.5),
    tags$polyline(
      class = "pulso-trazo",
      points = paste(sprintf("%.2f,%.2f", xs, ys), collapse = " ")
    ),
    # El extremo de la serie, atado a la cifra que lo anota al lado.
    tags$line(class = "pulso-trazo pulso-remate",
              x1 = W, y1 = ys[n], x2 = W, y2 = H - 0.5)
  )
}


pag_presentacion <- function() {

  # ── Las cifras del sistema, leidas del disco ───────────────────────────────
  # Ninguna se escribe a mano: si manana entra una ficha o se compila un CSV, la
  # linea de estado del umbral cambia sola.
  total     <- nrow(d_indicadores)
  con_datos <- sum(d_indicadores$tiene_datos)
  # Las fuentes salen del registro que ya cargo R/00_data.R (d_fuentes), no de
  # una segunda lectura del YAML: esa lectura saltaba la lectura UTF-8
  # explicita y se caia entera ante una fuente sin `institucion`, que
  # d_fuentes publica como cadena vacia.
  n_fuentes    <- NROW(d_fuentes)
  n_organismos <- length(setdiff(unique(d_fuentes$institucion), ""))
  # La bajada nombra algunos organismos y cuenta el resto "en letras". Los dos
  # numeros salen del registro, y los nombrados se declaran aqui y no en la
  # prosa, para que "otros N" reste exactamente los que se nombran.
  .nombrados <- c("el INE", "el Banco Central", "MIDESO", "el SII")
  .n_otros   <- n_organismos - length(.nombrados)
  .en_letras <- function(n) {
    letras <- c("uno", "dos", "tres", "cuatro", "cinco", "seis", "siete",
                "ocho", "nueve", "diez", "once", "doce", "trece", "catorce",
                "quince", "dieciseis", "diecisiete", "dieciocho", "diecinueve",
                "veinte")
    if (n >= 1 && n <= length(letras)) letras[n] else as.character(n)
  }

  # ── Una sala del indice ────────────────────────────────────────────────────
  # El indice del Boletin puesto a trabajar: una fila de registro por sala, con
  # el numeral en mono magenta (la primera mitad de la direccion de cita de todo
  # cuadro del capitulo), el nombre, la glosa y la cuenta. Es un enlace a la
  # pagina del capitulo: se abre en otra pestana, se copia y se cita.
  sala <- function(num, archivo, nombre, glosa, cuenta, rango) {
    tags$a(
      class = "sala", href = archivo,
      span(class = "sala-num", num),
      span(class = "sala-cuerpo",
           span(class = "sala-nombre", nombre),
           span(class = "sala-glosa", glosa)),
      span(class = "sala-cuenta", cuenta),
      span(class = "sala-rango", rango),
      # El unico icono del sistema, dibujado a mano en el mismo trazo que los
      # filetes. No es un glifo tipografico prestado ni un emoji.
      tags$svg(class = "sala-flecha", width = "16", height = "16",
               viewBox = "0 0 16 16", fill = "none", `aria-hidden` = "true",
               tags$path(d = "M3 8h9M8.6 4.6 12 8l-3.4 3.4", stroke = "currentColor",
                         `stroke-width` = "1.5", `stroke-linecap` = "round",
                         `stroke-linejoin` = "round"))
    )
  }

  # Las cinco salas tematicas, con su cuenta leida del YAML: si se agregan
  # fichas, la cuenta se actualiza sola.
  salas <- lapply(.CAPITULOS, function(c) {
    n <- sum(d_indicadores$seccion == c$seccion)
    k <- sum(d_indicadores$seccion == c$seccion & d_indicadores$tiene_datos)
    sala(c$num, c$archivo, c$nombre, c$glosa,
         tagList(tags$b(k), paste0(" / ", n, " con datos")), c$rango)
  })
  salas[[length(salas) + 1]] <- sala(
    .SALA_METODOLOGIA$num, .SALA_METODOLOGIA$archivo, .SALA_METODOLOGIA$nombre,
    .SALA_METODOLOGIA$glosa, tagList(tags$b(total), " fichas"), "registro")
  # La sala de Fuentes cuenta lo que ese capitulo publica —fuentes, no piezas—
  # y su cuenta sale del mismo registro que la linea de estado del umbral.
  salas[[length(salas) + 1]] <- sala(
    .SALA_FUENTES$num, .SALA_FUENTES$archivo, .SALA_FUENTES$nombre,
    .SALA_FUENTES$glosa, tagList(tags$b(n_fuentes), " fuentes"),
    paste(n_organismos, "organismos"))

  # ── Los seis paneles del pulso ─────────────────────────────────────────────
  paneles <- lapply(seq_along(.PULSO), function(i) {
    p  <- .PULSO[[i]]
    df <- IND[[p$carpeta]]
    f  <- ficha_de(p$carpeta)

    df <- df[order(df$anio), ]
    v  <- df[[p$col]]
    ok <- is.finite(v)
    v  <- v[ok]; anios <- df$anio[ok]
    ultimo <- length(v)

    # Cada panel lleva al capitulo de su pieza: el panel es un resumen, y el
    # cuadro completo esta a un clic de distancia.
    tags$a(
      class = "pulso-pieza", href = p$archivo,
      div(class = "pulso-cabeza",
          span(class = "pulso-id", f$id),
          span(class = "pulso-nombre", f$nombre)),
      span(class = "pulso-unidad", f$unidad),
      div(
        class = "pulso-cuerpo",
        # 140 ms entre panel y panel: los seis trazos se leen como una sola
        # entrada escalonada y no como seis animaciones simultaneas.
        .trazo_serie(v, retardo = (i - 1) * 140),
        div(class = "pulso-cierre",
            span(class = "pulso-valor", paste0(fmt_n(v[ultimo], p$dec), p$suf)),
            span(class = "pulso-anio", anios[ultimo]))
      ),
      div(class = "pulso-pie",
          span(class = "pulso-rango", paste(anios[1], "—", anios[ultimo])),
          # El organismo, no la cita completa: la cita entera vive en el pie del
          # cuadro y en el asiento de la pieza.
          span(class = "pulso-fuente", sub("\\s*[—-]{1,2}\\s.*$", "", f$fuente)))
    )
  })

  tagList(
    # ── El umbral: la portada del Boletin, en papel ──────────────────────────
    # Va a sangre, fuera del pliego. A la izquierda la foto del indice del
    # Boletin, en color; a la derecha el texto, sobre las curvas de nivel. El
    # perfil del Paine cierra el bloque de borde a borde, cruzando la foto.
    div(
      class = "umbral",
      div(
        class = "umbral-foto",
        tags$img(src = "img/portal-indice.webp", width = "900", height = "1213",
                 alt = "Estepa magallanica con ovejas pastando y el casco de una estancia al fondo"),
        div(class = "credito", "Foto: Boletin de Estudios Regionales N.2, p. 2")
      ),
      div(
        class = "umbral-texto",
        h1(class = "umbral-titulo",
           # HTML y no tres hijos: htmltools separa los hijos con un salto de linea,
           # que se lee como un espacio antes de la coma.
           HTML(paste0("Los datos de Magallanes estan repartidos en ",
                       .en_letras(n_organismos), " organismos.",
                       " Aqui estan <span class=\"banda\">reunidos</span>,",
                       " documentados y citables."))),
        p(class = "umbral-bajada",
          tags$strong("Datos Magallanes"),
          " es el primer componente de la Plataforma de Inteligencia Territorial",
          " que la Unidad de Estudios Regionales construye para la Region de",
          " Magallanes y de la Antartica Chilena. Recorta a la region los",
          paste0(" indicadores que hoy publican ",
                 paste(.nombrados, collapse = ", "),
                 if (.n_otros >= 1) paste0(" y otros ", .en_letras(.n_otros), " organismos"),
                 ", y entrega cada uno con su"),
          " definicion, su calculo y su fuente declarados, listo para citar."),
        div(
          class = "umbral-estado",
          div(class = "estado-dato", span(class = "estado-cifra", total),
              span(class = "estado-rotulo", "indicadores documentados")),
          div(class = "estado-dato", span(class = "estado-cifra", con_datos),
              span(class = "estado-rotulo", "con datos compilados")),
          div(class = "estado-dato", span(class = "estado-cifra", n_fuentes),
              span(class = "estado-rotulo", "fuentes oficiales")),
          div(class = "estado-dato", span(class = "estado-cifra", n_organismos),
              span(class = "estado-rotulo", "organismos distintos"))
        ),
        # La advertencia de prototipo va en la primera pantalla: es lo primero
        # que debe saber quien entra mientras la beta siga con series de
        # prototipo, y no se retira mientras siga siendo cierta.
        div(class = "umbral-aviso",
            marca_estado("ilustrativo",
                         "Las series visibles son de prototipo, no cifras oficiales"))
      ),
      div(class = "horizonte", `aria-hidden` = "true")
    ),

    pliego(
      # ── El indice ───────────────────────────────────────────────────────────
      # El ÍN/DI/CE del Boletin: la palabra partida en tres, liviana y grande, y
      # al lado el registro de las siete salas. La portada no publica piezas:
      # publica entradas.
      tags$section(
        class = "indice-portal", `aria-labelledby` = "indice_titulo",
        h2(class = "indice-rotulo", id = "indice_titulo",
           span("In"), span("di"), span("ce")),
        div(class = "salas", salas)
      ),

      # ── El pulso de la region ───────────────────────────────────────────────
      tags$section(
        class = "pulso-bloque",
        h2(class = "bloque-titulo", "El ", tags$span(class = "banda", "pulso"),
           " de la region"),
        p(class = "bloque-glosa prosa",
          "Seis indicadores del catalogo, uno por dimension. Se publica el nivel que",
          "trae la fuente: ninguna cifra se transforma en esta pagina. El cuadro",
          "completo, con su eje y su nota metodologica, esta en su capitulo."),
        div(class = "pulso", paneles)
      )
    ),

    # ── El cimiento ────────────────────────────────────────────────────────────
    # Lo que la plataforma dice de si misma, y solo aqui: sobre las curvas de
    # nivel, con el emblema de la plataforma como sello de la seccion.
    tags$section(
      class = "cimiento",
      div(
        class = "cimiento-interior",
        div(
          class = "cimiento-cabeza",
          tags$img(src = "logo_portada_transparente.webp", class = "cimiento-emblema",
                   alt = "Plataforma de Informacion sobre Bienestar y Desarrollo en la Region de Magallanes",
                   width = "673", height = "615", loading = "lazy"),
          div(
            h2(class = "cimiento-titulo",
               "Por que una universidad publica construye esto desde la ",
               tags$span(class = "banda", "region")),
            p(class = "cimiento-entrada",
              "America Latina concentra fuera de su territorio buena parte de la",
              "infraestructura que procesa sus propios datos, y Magallanes repite",
              "esa condicion periferica a escala subnacional: la region produce el",
              "dato bruto y el valor se captura en otra parte. Reunir, documentar y",
              "publicar aqui la informacion regional es, antes que una mejora",
              "tecnica, una decision sobre quien controla el conocimiento del",
              "territorio.")
          )
        ),
        div(
          class = "compromisos",
          div(class = "compromiso",
              h3(class = "compromiso-titulo", "Estandarizacion y trazabilidad"),
              p(class = "compromiso-texto",
                "Cada indicador declara su definicion, su calculo, su unidad, su",
                "periodicidad y su fuente, y lleva un numero de acceso con el",
                "que se cita. Reducir la heterogeneidad de formatos es lo que",
                "permite leer en la misma pagina un dato del INE y uno del",
                "Banco Central sin traducirlos a mano.")),
          div(class = "compromiso",
              h3(class = "compromiso-titulo", "Accesibilidad y transparencia"),
              p(class = "compromiso-texto",
                "La informacion publica se publica abierta y dinamica:",
                "cualquiera lee la cifra, ve de donde viene y descarga el CSV",
                "que dibuja el cuadro. Sin registro previo, sin licencia de uso",
                "y sin intermediario.")),
          div(class = "compromiso",
              h3(class = "compromiso-titulo", "Soberania digital regional"),
              p(class = "compromiso-texto",
                "Codigo abierto, datos abiertos y estandares abiertos,",
                "mantenidos por un equipo que vive en la region. Por su escala,",
                "Magallanes permite ensayar gobernanza de datos de forma eficaz",
                "y controlada: la capacidad queda instalada aqui y lo aprendido",
                "es transferible a otros territorios."))
        ),
        # El argumento de dependencia tecnologica y soberania digital no es
        # nuestro: se cita, como se cita cualquier fuente en este catalogo.
        p(class = "cimiento-nota",
          "El argumento sobre dependencia tecnologica y soberania digital",
          "sigue a Filgueiras (2023) y a Arner, Castellano y Selga (2021); el",
          "diagnostico regional, a la minuta de gobernanza regional de datos",
          "de la UER y al diagnostico de la Estrategia Regional de Desarrollo",
          "2023-2030.")
      )
    )
  )
}

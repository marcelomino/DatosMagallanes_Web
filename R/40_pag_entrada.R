# ═════════════════════════════════════════════════════════════════════════════
# R/40_pag_entrada.R — La entrada
#
# PAGINA: index.html (la raiz del sitio)
#
# QUE HACE
#   La tapa del Boletin antes de abrirlo: papel, un terreno de curvas de nivel
#   que gira despacio a la derecha, el nombre de la plataforma, una frase y una
#   sola accion, escrita como una linea de comandos: "> entrar", con el cursor
#   magenta parpadeando. Pulsarla estira su banda hasta cubrir la pantalla; la
#   portada (inicio.html) aparece cuando la banda se retira hacia la derecha, y
#   el nombre viaja hasta su lugar en la barra de marca (www/transicion.css).
#
#   La entrada solo la ve quien llega desde fuera: la barra y el colofon de
#   todas las paginas apuntan a inicio.html, nunca aqui.
#
# SIN CHASIS
#   No lleva barra, navegacion ni colofon, ni Bootstrap, ni ECharts. Es un
#   documento propio que escribe escribir_sitio() con .documento_entrada()
#   (R/50_sitio.R). El prompt es un <a href> comun: sin JavaScript se entra
#   igual, solo que sin la banda.
#
# LA MONO DEL PROMPT
#   Es la unica mono de la pagina que no es un identificador ni una medida: la
#   pidio el usuario como referencia a lo tecnologico (19-10-2026). Es una
#   excepcion de esta pagina, no una licencia para el resto del sistema.
#
# DATOS QUE CONSUME
#   d_indicadores, d_fuentes  las cuentas de la linea de estado, leidas del disco
# ═════════════════════════════════════════════════════════════════════════════

# La pagina a la que lleva "Entrar": la portada del catalogo.
.DESTINO_ENTRADA <- "inicio.html"

pag_entrada <- function() {
  total     <- nrow(d_indicadores)
  con_datos <- sum(d_indicadores$tiene_datos)
  n_fuentes <- NROW(d_fuentes)

  tags$main(
    class = "entrada",
    # El campo: un terreno (img/topo-giro.svg) que gira sobre su cumbre, a la
    # derecha, a velocidad constante. La mascara no gira: las curvas pasan bajo
    # ella y se apagan antes de llegar al nombre.
    div(class = "entrada-campo", `aria-hidden` = "true",
        div(class = "entrada-curvas")),

    # La cabeza: la pestana de edicion baja del borde, como en la barra de
    # marca, y el sello de la institucion a la derecha.
    tags$header(
      class = "entrada-cabeza",
      div(class = "marca-edicion-pestana",
          span(class = "pestana-version", .EDICION$version),
          span(class = "pestana-fecha", .EDICION$mes)),
      tags$img(src = "logo_uer_color.png", class = "entrada-sello",
               alt = "Unidad de Estudios Regionales, Universidad de Magallanes",
               width = "200", height = "64")
    ),

    div(
      class = "entrada-cuerpo",
      # El nombre es el mismo elemento, para la transicion, que el de la barra
      # de marca de inicio.html: viaja hasta alla al entrar.
      h1(class = "entrada-titulo",
         span(class = "entrada-linea", "Datos"), " ",
         span(class = "entrada-linea", span(class = "banda", "Magallanes"))),
      p(class = "entrada-bajada",
        "Los indicadores de poblacion, economia, pobreza, bienestar y cohesion",
        "social de la Region de Magallanes y de la Antartica Chilena, reunidos",
        "en un solo lugar, con su definicion, su calculo y su fuente."),
      div(
        class = "entrada-accion",
        # "> entrar" y el cursor. El signo y el cursor son decorado: el lector
        # de pantalla oye "entrar", nada mas.
        tags$a(class = "entrada-prompt", href = .DESTINO_ENTRADA,
               span(class = "prompt-signo", `aria-hidden` = "true", ">"),
               span(class = "prompt-palabra", "entrar"),
               span(class = "prompt-cursor", `aria-hidden` = "true")),
        # La advertencia de prototipo va en la primera pantalla mientras siga
        # siendo cierta. La primera pantalla ahora es esta.
        marca_estado("ilustrativo",
                     "Las series visibles son de prototipo, no cifras oficiales")
      )
    ),

    tags$footer(
      class = "entrada-pie",
      p(class = "entrada-estado",
        span(tags$b(total), " indicadores documentados"),
        span(tags$b(con_datos), " con datos compilados"),
        span(tags$b(n_fuentes), " fuentes oficiales")),
      p(class = "entrada-lugar",
        span("Unidad de Estudios Regionales · Universidad de Magallanes"),
        span(class = "entrada-coordenadas", "Punta Arenas · 53°09′50″S 70°55′02″W"))
    ),
    div(class = "horizonte entrada-horizonte", `aria-hidden` = "true"),

    # El telon: la banda de "Magallanes" estirada a toda la pantalla. Lo mueve
    # www/entrada.js al pulsar "Entrar"; sin JS nunca aparece.
    div(class = "entrada-telon", `aria-hidden` = "true")
  )
}

# ═════════════════════════════════════════════════════════════════════════════
# _dev/motivos_paisaje.R  —  Curvas de nivel y perfil del Paine, en papel claro
#
# QUE HACE
#   Escribe los dos motivos de paisaje del sistema como SVG estaticos:
#     www/img/topo.svg        curvas de nivel procedurales (fondo del portal)
#     www/img/topo-giro.svg   un terreno cuadrado con su cumbre al centro: el
#                             que gira en la entrada (index.html)
#     www/img/horizonte.svg   perfil estilizado del macizo del Paine
#
#   Vienen del tema «austral» de la presentacion de brechas sociolaborales
#   (04_Comunicaciones/.../R/motivos_paisaje.R), donde se dibujaban en glaciar
#   sobre noche. Aqui van en el teal de PAL$curva sobre papel blanco, mas
#   tenues, porque en el catalogo son el terreno sobre el que se lee y no
#   pueden competir con una cifra.
#
# POR QUE SE CONGELAN
#   Son geometria fija (semilla fija): se revisan una vez y quedan. La app no
#   los calcula; solo los sirve. El unico que se mueve es topo-giro.svg, y lo
#   mueve CSS girandolo entero, sin tocar su geometria.
#
# USO
#   Rscript _dev/motivos_paisaje.R
# ═════════════════════════════════════════════════════════════════════════════
suppressPackageStartupMessages({ library(shiny); library(purrr); library(cli) })
source("R/10_utils.R")

TRAZO <- PAL$curva

# ── Curvas de nivel ──────────────────────────────────────────────────────────
# Un relieve de ondas suaves mas catorce cerros gaussianos. Cada quinta curva
# es maestra y va mas gruesa, como en una carta topografica del IGM.
set.seed(53)
W <- 1600; H <- 900; nx <- 200; ny <- 113
x <- seq(0, 1, length.out = nx); y <- seq(0, 1, length.out = ny)
g <- expand.grid(x = x, y = y)
z <- 0.6 * sin(2.1 * pi * g$x + 0.8) * cos(1.4 * pi * g$y) + 0.25 * sin(5 * pi * (g$x + g$y))
for (i in 1:14) {
  cx <- runif(1); cy <- runif(1); s <- runif(1, 0.05, 0.18); a <- runif(1, -1, 1.6)
  z <- z + a * exp(-((g$x - cx)^2 + ((g$y - cy) * 0.56)^2) / (2 * s^2))
}
m <- matrix(z, nx, ny)
niveles <- pretty(range(m), 34)
curvas <- contourLines(x, y, m, levels = niveles) |>
  map_chr(\(k) {
    px <- round(k$x * W, 1); py <- round((1 - k$y) * H, 1)
    maestra <- match(k$level, niveles) %% 5 == 0
    sprintf('<path d="M%s" class="%s"/>', paste(px, py, sep = ",", collapse = "L"),
            if (maestra) "m" else "c")
  })
writeLines(c(
  sprintf('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" preserveAspectRatio="xMidYMid slice">', W, H),
  sprintf('<style>path{fill:none;stroke:%s;stroke-linejoin:round;vector-effect:non-scaling-stroke}.c{stroke-width:.7;stroke-opacity:.45}.m{stroke-width:1.2;stroke-opacity:.8}</style>', TRAZO),
  curvas, "</svg>"), "www/img/topo.svg")
cli_alert_success("www/img/topo.svg ({length(curvas)} curvas)")

# ── El terreno que gira ──────────────────────────────────────────────────────
# Cuadrado, porque gira: un rectangulo mostraria sus esquinas a media vuelta. La
# cumbre va al centro, que es el eje del giro, rodeada de cerros menores que
# son los que se ven pasar. Lleva mas niveles que topo.svg porque se dibuja
# mas grande (unos 2000 px de lado) y las curvas no deben verse ralas.
set.seed(70)
L <- 2000; n <- 200
u <- seq(0, 1, length.out = n)
g <- expand.grid(x = u, y = u)
r <- sqrt((g$x - 0.5)^2 + (g$y - 0.5)^2)
z <- 1.5 * exp(-r^2 / (2 * 0.11^2)) +
     0.35 * sin(3.4 * pi * g$x + 0.6) * cos(2.8 * pi * g$y) +
     0.15 * sin(7 * pi * (g$x - g$y))
for (i in 1:22) {
  ang <- runif(1, 0, 2 * pi); dist <- runif(1, 0.12, 0.48)
  cx <- 0.5 + dist * cos(ang); cy <- 0.5 + dist * sin(ang)
  s <- runif(1, 0.03, 0.1); a <- runif(1, -0.7, 1.1)
  z <- z + a * exp(-((g$x - cx)^2 + (g$y - cy)^2) / (2 * s^2))
}
m <- matrix(z, n, n)
niveles <- pretty(range(m), 58)
curvas <- contourLines(u, u, m, levels = niveles) |>
  map_chr(\(k) {
    # A pixel entero: a este tamano el decimal no se ve y pesa un tercio del archivo.
    px <- round(k$x * L); py <- round((1 - k$y) * L)
    maestra <- match(k$level, niveles) %% 5 == 0
    sprintf('<path d="M%s" class="%s"/>', paste(px, py, sep = ",", collapse = "L"),
            if (maestra) "m" else "c")
  })
writeLines(c(
  sprintf('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d">', L, L),
  sprintf('<style>path{fill:none;stroke:%s;stroke-linejoin:round;vector-effect:non-scaling-stroke}.c{stroke-width:.7;stroke-opacity:.45}.m{stroke-width:1.2;stroke-opacity:.8}</style>', TRAZO),
  curvas, "</svg>"), "www/img/topo-giro.svg")
cli_alert_success("www/img/topo-giro.svg ({length(curvas)} curvas)")

# ── Perfil del Paine ─────────────────────────────────────────────────────────
# Estepa -> Paine Grande -> Cuernos -> Torres -> estepa. El trazo no se estira
# con el viewBox (non-scaling-stroke): el perfil cruza la pagina de borde a
# borde a cualquier ancho y la linea sigue midiendo lo mismo que un filete.
p <- matrix(c(0,132, 80,128, 160,130, 240,122, 300,124, 360,112, 420,116, 470,100, 520,96, 560,80,
              590,84, 620,60, 650,52, 675,30, 700,42, 720,36, 745,58, 770,50, 790,64, 815,40, 830,22,
              842,38, 856,26, 868,44, 890,62, 910,56, 930,70, 950,44, 962,12, 970,40, 978,20, 986,6,
              994,34, 1004,16, 1012,44, 1030,66, 1060,74, 1100,88, 1150,94, 1200,104, 1260,108,
              1320,116, 1400,120, 1480,126, 1600,130), ncol = 2, byrow = TRUE)
pts <- paste(p[, 1], p[, 2], sep = ",", collapse = " ")
writeLines(c(
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 140" preserveAspectRatio="none">',
  sprintf('<polygon points="%s 1600,140 0,140" fill="%s" fill-opacity=".05"/>', pts, TRAZO),
  sprintf('<polyline points="%s" fill="none" stroke="%s" stroke-width="1.25" stroke-linejoin="round" vector-effect="non-scaling-stroke"/>', pts, TRAZO),
  "</svg>"), "www/img/horizonte.svg")
cli_alert_success("www/img/horizonte.svg")

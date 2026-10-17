# ═════════════════════════════════════════════════════════════════════════════
# _dev/red_fuentes.R  —  Regenera indicadores/red.yaml
#
# QUE HACE
#   Lee las 69 indicadores/{id}_{slug}/ficha.yaml, arma el grafo del catalogo
#   —cada pieza tiene dos aristas: su fuente y su capitulo— y escribe en
#   indicadores/red.yaml dos cosas que el capitulo VII necesita y la app no
#   puede calcular en cada arranque:
#
#     1. Las medidas de estructura: intermediacion, cercania, puntos de
#        articulacion, aristas de corte, asortatividad y comunidades.
#     2. Las POSICIONES de los 90 nodos, calculadas con el algoritmo de
#        Fruchterman-Reingold.
#
# POR QUE LAS POSICIONES SE CALCULAN AQUI Y NO EN EL NAVEGADOR
#   ECharts sabe simular fuerzas en el cliente, pero esa simulacion produce una
#   disposicion distinta en cada carga y no se puede corregir: solo se pueden
#   mover parametros de repulsion y volver a mirar. Calculadas aqui con semilla
#   fija, la disposicion es siempre la misma, se revisa una vez y queda. El
#   cuadro VII.2 las usa con layout = "none".
#
# POR QUE SE CONGELA EN UN YAML Y NO SE CALCULA AL ARRANCAR LA APP
#   Estas medidas cambian cuando cambia el catalogo, no cuando alguien lo mira.
#   Recalcularlas en cada arranque seria repetir trabajo sin cambio posible, y
#   ademas obligaria al servidor de despliegue a cargar igraph. El YAML lleva
#   estampada la fecha y el numero de piezas con que se calculo; R/00_data.R avisa
#   al arrancar si el catalogo crecio despues, y el capitulo publica el aparato
#   marcado como desactualizado en vez de dar por buena una cifra vieja.
#
#   LO QUE SI SE DERIVA EN VIVO son los conteos (piezas por fuente, cuota,
#   concentracion): estan en R/00_data.R y se rehacen en cada arranque.
#
# REQUISITOS
#   igraph. Es dependencia de TALLER, no de la app: no se carga en app.R y no
#   viaja al despliegue.
#
# USO — desde la raiz del proyecto
#   Rscript _dev/red_fuentes.R
# ═════════════════════════════════════════════════════════════════════════════

suppressPackageStartupMessages({
  library(dplyr)
  library(purrr)
  library(stringr)
  library(igraph)
})

RUTA <- "indicadores"
SALIDA <- file.path(RUTA, "red.yaml")

# Semilla unica para las dos operaciones que no son deterministas: la deteccion
# de comunidades y la disposicion de fuerzas. Sin ella, cada corrida publicaria
# una particion y un dibujo distintos sin que el catalogo haya cambiado.
SEMILLA <- 7


# ── 1. Leer el catalogo ──────────────────────────────────────────────────────
# Mismo criterio de carpeta que R/00_data.R: solo {digitos}_{slug}. indicadores/
# _plantilla tambien trae ficha.yaml —con el id 999 y una fuente de ejemplo— y
# sin este filtro entraria al grafo como una pieza mas.
carpetas <- list.dirs(RUTA, full.names = FALSE, recursive = FALSE) |>
  keep(\(x) str_detect(x, "^\\d+_"))

leer <- function(ruta) yaml::yaml.load(
  paste(readLines(ruta, encoding = "UTF-8", warn = FALSE), collapse = "\n"))

fichas <- map_dfr(carpetas, \(carpeta) {
  f <- leer(file.path(RUTA, carpeta, "ficha.yaml"))
  tibble(
    id        = as.integer(f$id),
    nombre    = f$nombre,
    seccion   = f$seccion,
    fuente_id = f$fuente_id %||% NA_character_,
    datos     = file.exists(file.path(RUTA, carpeta, "datos.csv")))
})

fuentes <- leer(file.path(RUTA, "fuentes.yaml"))$fuentes |> map_chr("id")


# ── 2. Armar el grafo ────────────────────────────────────────────────────────
# Tripartito y sin pesos. Las dos aristas de cada pieza son las dos unicas
# relaciones que el catalogo declara, asi que el grafo no interpreta nada: es el
# catalogo leido de otra manera.
#
# Los nombres de nodo llevan prefijo para que una pieza y una fuente no puedan
# colisionar, y para poder separarlos despues sin una tabla aparte.
aristas <- bind_rows(
  fichas |> transmute(de = paste0("I:", id), a = paste0("D:", seccion)),
  fichas |> filter(!is.na(fuente_id)) |> transmute(de = paste0("I:", id),
                                                   a  = paste0("F:", fuente_id))
)

G <- graph_from_data_frame(aristas, directed = FALSE)

tipo_de <- \(n) case_when(str_starts(n, "I:") ~ "pieza",
                          str_starts(n, "F:") ~ "fuente",
                          TRUE                ~ "dimension")
V(G)$tipo <- tipo_de(V(G)$name)


# ── 3. Medidas de estructura ─────────────────────────────────────────────────
inter <- betweenness(G, normalized = TRUE)
cerca <- closeness(G, normalized = TRUE)
arts  <- names(articulation_points(G))

#' Cuantos nodos quedan separados del cuerpo principal al quitar un nodo
#'
#' Es la lectura util de un punto de articulacion: no basta saber que parte el
#' grafo, importa cuanto se lleva. Devuelve 0 si no lo parte.
desprende <- function(nodo) {
  H <- delete_vertices(G, nodo)
  tam <- sort(components(H)$csize, decreasing = TRUE)
  if (length(tam) > 1) sum(tam[-1]) else 0
}

medidas_de <- function(nodo) list(
  intermediacion = round(unname(inter[nodo]), 4),
  cercania       = round(unname(cerca[nodo]), 4),
  grado          = unname(degree(G, nodo)),
  articulacion   = nodo %in% arts,
  desprende      = if (nodo %in% arts) desprende(nodo) else 0
)

# ── 4. Proyeccion sobre las fuentes ──────────────────────────────────────────
# Dos fuentes se unen si alimentan un mismo capitulo. Es la vista en que se ve
# cuales sostienen la union entre capitulos, y su intermediacion NO coincide con
# la del grafo completo: ahi pesa cuantas piezas carga una fuente, aqui pesa a
# cuantos capitulos distintos toca.
pares <- fichas |>
  filter(!is.na(fuente_id)) |>
  distinct(seccion, fuente_id) |>
  group_by(seccion) |>
  filter(n() > 1) |>
  reframe(as.data.frame(t(combn(sort(fuente_id), 2)))) |>
  transmute(de = V1, a = V2)

P <- graph_from_data_frame(distinct(pares), directed = FALSE,
                           vertices = data.frame(name = fuentes))
inter_p <- betweenness(P, normalized = TRUE)


# ── 5. Comunidades ───────────────────────────────────────────────────────────
set.seed(SEMILLA)
com <- cluster_louvain(G)

grupos <- split(V(G)$name, membership(com)) |>
  (\(g) g[order(-lengths(g))])() |>
  map(\(nodos) {
    piezas <- fichas |> filter(paste0("I:", id) %in% nodos)
    list(
      n           = length(nodos),
      piezas      = as.list(sort(table(piezas$seccion), decreasing = TRUE)),
      fuentes     = sort(str_remove(nodos[str_starts(nodos, "F:")], "^F:")),
      dimensiones = sort(str_remove(nodos[str_starts(nodos, "D:")], "^D:"))
    )
  }) |>
  unname()


# ── 6. Disposicion: Fruchterman-Reingold ─────────────────────────────────────
# Las coordenadas se normalizan al rango 0-1. Asi el cuadro VII.2 las escala al
# ancho que tenga en pantalla sin saber nada de este archivo, y un cambio de
# tamano del grafico no exige recalcular nada.
set.seed(SEMILLA)
xy <- layout_with_fr(G, niter = 3000, grid = "nogrid")
normal <- \(v) round((v - min(v)) / (max(v) - min(v)), 4)

posiciones <- tibble(nodo = V(G)$name, tipo = V(G)$tipo,
                     x = normal(xy[, 1]), y = normal(xy[, 2])) |>
  pmap(\(nodo, tipo, x, y) list(id = str_remove(nodo, "^[IFD]:"),
                                tipo = tipo, x = x, y = y))


# ── 7. Escribir ──────────────────────────────────────────────────────────────
salida <- list(
  generado = list(
    fecha   = as.character(Sys.Date()),
    script  = "_dev/red_fuentes.R",
    piezas  = nrow(fichas),
    fuentes = n_distinct(fichas$fuente_id[!is.na(fichas$fuente_id)]),
    igraph  = as.character(packageVersion("igraph")),
    semilla = SEMILLA
  ),

  grafo = list(
    nodos          = gorder(G),
    aristas        = gsize(G),
    componentes    = components(G)$no,
    densidad       = round(edge_density(G), 4),
    diametro       = as.integer(diameter(G, unconnected = FALSE)),
    camino_medio   = round(mean_distance(G), 3),
    asortatividad  = round(assortativity_degree(G), 3),
    aristas_corte  = nrow(as.data.frame(as_edgelist(G)[bridges(G), , drop = FALSE])),
    articulaciones = length(arts)
  ),

  # Una entrada por fuente, con la clave de fuentes.yaml: asi R las une sin
  # ninguna tabla de equivalencias intermedia.
  fuentes = set_names(
    map(fuentes, \(f) c(medidas_de(paste0("F:", f)),
                        list(intermediacion_entre_fuentes = round(unname(inter_p[f]), 4)))),
    fuentes),

  dimensiones = set_names(
    map(sort(unique(fichas$seccion)), \(s) medidas_de(paste0("D:", s))),
    sort(unique(fichas$seccion))),

  # Por pieza solo se guarda lo que el dibujo y el asiento necesitan; el resto
  # (nombre, capitulo, si tiene datos) ya esta en su ficha y se lee en vivo.
  piezas = set_names(
    map(fichas$id, \(i) medidas_de(paste0("I:", i))[c("intermediacion", "articulacion")]),
    as.character(fichas$id)),

  # Las diez piezas de mayor intermediacion: las que son paso obligado entre dos
  # partes del catalogo pese a tener grado 2.
  piezas_frontera = fichas |>
    mutate(intermediacion = round(unname(inter[paste0("I:", id)]), 4)) |>
    arrange(desc(intermediacion)) |>
    head(10) |>
    pmap(\(id, nombre, seccion, fuente_id, datos, intermediacion)
         list(id = id, nombre = nombre, seccion = seccion,
              intermediacion = intermediacion)),

  comunidades = list(
    n            = length(grupos),
    modularidad  = round(modularity(com), 3),
    grupos       = grupos
  ),

  proyeccion_fuentes = list(
    nodos        = gorder(P),
    aristas      = gsize(P),
    densidad     = round(edge_density(P), 3),
    # El agrupamiento promedio cuenta como 0 —y no como indefinido— a la fuente
    # de grado 1: sin dos vecinos no puede cerrar ningun triangulo, y dejarla
    # fuera del promedio subiria la cifra (0,865 en vez de 0,811) haciendo
    # parecer mas trabada la red de lo que es. igraph la excluye por defecto con
    # type = "average", asi que el promedio se toma a mano.
    agrupamiento = local({
      loc <- transitivity(P, type = "local")
      round(mean(ifelse(is.nan(loc), 0, loc)), 3)
    }),
    componentes  = components(P)$no
  ),

  posiciones = posiciones
)

cabecera <- paste(
  "# ═══════════════════════════════════════════════════════════════════",
  "# ARCHIVO GENERADO — no editar a mano.",
  "#",
  "# Medidas de estructura del grafo del catalogo (intermediacion, puntos de",
  "# articulacion, comunidades) y posiciones de los 90 nodos. Las publica el",
  "# capitulo VII, Fuentes. Los conteos NO estan aqui: R/00_data.R los deriva de",
  "# las fichas en cada arranque.",
  "#",
  "# Regenerar:  Rscript _dev/red_fuentes.R",
  "# ═══════════════════════════════════════════════════════════════════",
  "", sep = "\n")

writeLines(paste0(cabecera, "\n", yaml::as.yaml(salida)), SALIDA)

cli::cli_alert_success(
  "indicadores/red.yaml — {salida$grafo$nodos} nodos, {salida$grafo$aristas} aristas, \\
   {salida$grafo$articulaciones} articulaciones, {salida$comunidades$n} comunidades \\
   (modularidad {salida$comunidades$modularidad})")

# Project Instructions

## Proyecto

Sitio web estatico de indicadores socioeconomicos de la Region de Magallanes (UER-UMAG).
Stack: R (bslib + htmltools + echarts4r) que **escribe** HTML; JS plano en el navegador.
Datos en CSV + YAML. No hay servidor: el resultado es `_site/`.

Es la continuacion del dashboard Shiny `10_Datos_Magallanes_dash`, **congelado el
17-10-2026** (commit b5a1843). El catalogo vive aqui; no se edita alla.

## Construir, probar y publicar

- Construir: `Rscript construir.R` → `_site/` (~3 s). Se abre con doble clic.
- Probar: `Rscript _dev/probar_sitio.R` (chromote): enlaces, las 39 laminas, errores
  de JS, desborde a 390 px, controles. Correrlo antes de cada push.
- Ver en local: `python3 -m http.server 8080 --directory _site`
- Publicar: `git push` a `master`. `.githooks/pre-push` corre `_dev/publicar.sh`:
  exige arbol limpio, construye, prueba y sube `_site/` a Netlify (`netlify-cli@27`).
  Si algo falla, el push se cancela; `git push --no-verify` sube sin publicar.
  Requiere `git config core.hooksPath .githooks` y `netlify login` + `link` en la
  maquina. `.github/workflows/publicar.yml` publica ademas en GitHub Pages, pero no
  corre mientras la cuenta tenga Actions bloqueadas por facturacion (17-10-2026).
  `_site/` y `.netlify/` no se versionan.

## Estructura

```
construir.R              Punto de entrada: source() de R/ en orden, escribir_sitio("_site")
R/00_data.R              Registros IND (datos) y FICHA (metadata); ficha_de(); valida la identidad
R/10_utils.R             PAL, tema, e_lamina(), formateadores, portadilla(), inventario(), CSV y JSON
R/20_graficos.R          Registro de laminas: barre indicadores/*/grafico.R y arma LAM; dibujar()
R/30_ui_components.R     cuadro(), pieza_cuadro(), lienzo(), rango_anios(), controles, marca_estado()
R/40_pag_*.R             Una funcion pag_*() por seccion (8)
R/40_pag_aparato.R       Paginas del pie (Creditos, Contacto); .EQUIPO y .CONTACTO se editan aqui
R/50_sitio.R             Chasis (barra, cabecera, colofon), pagina(), escribir_sitio()
js/sitio.js              Monta laminas, conmuta el cero, aplica rangos, filtra fichas, navega
www/                     styles.css, portal.js, fuentes, fotos de portadilla, logos
indicadores/{id}_{slug}/ficha.yaml   LA FUENTE DE VERDAD del indicador (define su id)
indicadores/{id}_{slug}/datos.csv    Los datos de ese indicador
indicadores/{id}_{slug}/grafico.R    Las laminas de ese indicador (echarts4r plano)
indicadores/fuentes.yaml             Registro de fuentes; las fichas apuntan con fuente_id
indicadores/indicadores.yaml         AGREGADO GENERADO de las 71 fichas. No editar.
indicadores/red.yaml                 GENERADO: medidas del grafo de fuentes
indicadores/_plantilla/              ficha.yaml y grafico.R comentados, para copiar
_dev/agregar_fichas.R    Regenera el agregado. Correr tras tocar una ficha.
_dev/red_fuentes.R       Regenera red.yaml (igraph). Correr tras agregar/quitar un indicador.
_dev/portadillas.R       Tine las fotos de portadilla (ImageMagick). Lee los originales del
                         Boletin en ../_Logos_Plantillas/ (fuera del repo).
_dev/motivos_paisaje.R   Escribe www/img/topo.svg y horizonte.svg desde PAL.
_dev/ver.R               Dibuja una lamina en la consola.
_dev/probar_sitio.R      Prueba del sitio construido en Chrome sin ventana.
_dev/publicar.sh         Construye, prueba y sube a Netlify. Lo llama el hook pre-push.
.githooks/pre-push       Cada push a master publica (activar: git config core.hooksPath .githooks)
```

## Paginas

| Seccion            | Archivo            | Funcion             |
|--------------------|--------------------|---------------------|
| Presentacion       | `index.html`       | `pag_presentacion()`|
| I Poblacion        | `poblacion.html`   | `pag_poblacion()`   |
| II Economia        | `economia.html`    | `pag_economia()`    |
| III Pobreza        | `pobreza.html`     | `pag_pobreza()`     |
| IV Bienestar       | `bienestar.html`   | `pag_bienestar()`   |
| V Cohesion         | `cohesion.html`    | `pag_cohesion()`    |
| VI Metodologia     | `metodologia.html` | `pag_metodologia()` |
| VII Fuentes        | `fuentes.html`     | `pag_fuentes()`     |
| Creditos (pie)     | `creditos.html`    | `pag_creditos()`    |
| Contacto (pie)     | `contacto.html`    | `pag_contacto()`    |

Las dos del pie no entran a la barra: se enlazan solo desde el colofon
(`.PAGINAS_PIE`, R/40_pag_aparato.R). La construccion avisa mientras `.EQUIPO` o
`.CONTACTO` tengan campos en "PENDIENTE".

`.CAPITULOS` (R/40_pag_presentacion.R) es el registro unico de secciones: de ahi salen
la barra, los menus de indice, las salas de la portada y los rotulos del cap. VII.
Direcciones citables: `economia.html#cuadro-II-1` (abre la pieza) y
`metodologia.html?pieza=215` (deja la ficha sola y abierta).

## Reglas del proyecto

- **No hacer commit ni push hasta que el usuario lo indique.** Los cambios quedan
  en el arbol de trabajo para su revision. Cada push a `master` publica el sitio.
- **Estilo R**: perspectiva tidyverse — pipes (`|>`), purrr, dplyr, stringr, readr, cli
- **Colores**: nunca hardcodear — siempre usar `PAL$*` (definido en `R/10_utils.R`)
- **Graficos echarts4r**: siempre aplicar `e_lamina()` (registra el tema unico UMAG)
- **Ninguna cifra se transforma en la interfaz.** Se publica el nivel que trae la
  fuente. La medida de variacion es la que la propia fuente publica en el CSV,
  formateada con `medida_publicada()`. Si el CSV no la trae, la celda queda vacia.
- **Ninguna cifra se calcula en el navegador.** Toda variante que el lector puede
  pedir (cada rango de anos, cada estado del "Eje desde cero") la dibuja `dibujar()`
  en R al construir, y `lienzo()` la embebe como JSON. `js/sitio.js` solo ELIGE entre
  dibujos hechos. `.anclar_cero()` es la unica definicion del eje: no se reescribe en
  JS. Con n anos un rango son n(n+1)/2 dibujos; si una serie con selector pasa de
  25-30 anos, revisar esta regla en vez de inflar la pagina.
- **Mundo visual: El Boletin de campo** (ver DESIGN.md). Papel blanco. Cada color
  tiene UN trabajo: magenta = banda y serie protagonista; magenta_prof = toda
  numeracion; azul = SOLO lo accionable; violeta = segunda serie; teal = SOLO la
  pestana de edicion.
- **JetBrains Mono solo en identificadores y medidas.** Nombres, prosa y cifras en Asap.
- **Cero sombras** salvo el anillo de foco, y **sin radios** (`--radio: 0`).
- **Portadillas con foto**: foto, bano y credito viven en `.PORTADILLAS`
  (R/10_utils.R). Ninguna foto sin credito publicado.
- **UNA CARPETA, UN INDICADOR, UNA FICHA, UN ID.** El id lo declara
  `indicadores/{id}_{slug}/ficha.yaml` y la carpeta debe llevarlo de prefijo.
  `R/00_data.R` **aborta la construccion** si no calzan, si dos carpetas declaran el
  mismo id, o si una carpeta no trae ficha: un desajuste de identidad no produce un
  error visible, produce una cifra correcta publicada con el nombre de otra pieza.
- **Numero de acceso**: el id del indicador es su identidad; se cita y se busca por el.
- **Numeracion de cuadros**: cada capitulo numera sus cuadros I.1, I.2... sin saltos,
  en el orden en que se publican; el id (101, 215) es orden interno. El inventario
  lleva una fila por cuadro, en ese mismo orden y con ese mismo numero:
  `fila_inventario(.I[["I.3"]], ...)` recibe la lamina, no un id. `probar_sitio.R`
  falla si inventario y cuadros no coinciden.
- **Datos**: `IND[["301_pobreza"]]`, `ficha_de("301_pobreza")`. Los `d_*` son alias
  legibles sobre `IND` (seccion 4 de R/00_data.R).
- **Trazabilidad**: `ind_id(df)`, `ind_carpeta(df)`, `ind_ficha(df)`.
- **Agregar un indicador**: crear `indicadores/{id}_{slug}/` con `ficha.yaml`,
  `datos.csv` y `grafico.R` (copiar `_plantilla/`), correr `Rscript _dev/agregar_fichas.R`
  y agregar su `pieza_cuadro()` en la pagina de su capitulo. Una carpeta con solo
  `ficha.yaml` es legitima: el catalogo la publica marcada como sin datos.
- **El estado no se declara**: tener datos se deriva de si la carpeta trae `datos.csv`.
- **Los graficos viven en la carpeta de su indicador**: `grafico.R` define `laminas`
  con el numero de cuadro y `dibujo(df)` en echarts4r plano; R/20_graficos.R los deja
  en `LAM[["{id}_{slug}"]][["II.3"]]`.
- **La lamina es una funcion pura.** Los controles se declaran en la pagina del
  capitulo (`rango_anios()`), que pasa los datos; toda lamina se dibuja desde la
  consola: `dibujar(LAM[["511_delitos_dmcs"]][["V.3"]], d_crimen)`.
  Si `dibujo` declara `function(df, todo = df)`, `lienzo()` le pasa ademas los datos
  completos para fijar lo que no debe moverse entre cortes (la escala de la piramide
  I.2). `corte_anio(todos = "Superpuestos")` agrega la opcion con todos los anos.
- **El titulo y la fuente del cuadro los manda la ficha.** No hay campo `ficha` en la
  lamina; R/20_graficos.R aborta si lo encuentra.
- **El capitulo VII publica el otro registro**: `indicadores/fuentes.yaml`. La fuente
  NO lista sus piezas: se derivan de las fichas (`d_fuentes`, `d_red`).
- **La lamina VII.1 se dibuja en su pagina** con `lienzo_fijo()`, no en `LAM`: dibuja
  el catalogo entero y no cuelga de ninguna ficha.
- **Las medidas de grafo no se calculan al construir**: las congela
  `Rscript _dev/red_fuentes.R` en `indicadores/red.yaml`. igraph es dependencia de
  taller y no viaja al Action.
- **Sin Shiny.** Los controles son marcado nativo (`control_select()`,
  `control_check()`, `control_texto()`) con las clases que estiliza styles.css.
- **Formato numerico**: chileno — `format(x, big.mark = ".", decimal.mark = ",")`
- **Idioma**: todo en espanol. Los textos de interfaz heredados van sin tildes (la
  restriccion venia del encoding de Shiny; en HTML estatico ya no aplica, pero no se
  mezclan estilos dentro de una pagina).

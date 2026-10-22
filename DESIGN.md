---
name: Datos Magallanes
description: El Boletin de campo. El catalogo de indicadores socioeconomicos de la Region de Magallanes (UER-UMAG) vestido como el Boletin de Estudios Regionales N.2 y leido como una hoja de campo patagonica
colors:
  papel: "#ffffff"
  lamina: "#ffffff"
  campo: "#f5f3f7"
  fila: "#efecf2"
  tinta: "#1D1320"
  tinta-2: "#5A4E60"
  tinta-3: "#6c6272"
  regla: "#dcd6e0"
  regla-fina: "#ece8ef"
  magenta: "#E82D88"
  magenta-prof: "#C2186B"
  azul: "#4A5CAB"
  violeta: "#593D80"
  teal: "#037686"
  curva: "#037686"
  bano-azul: "#0B1230"
  bano-violeta: "#1A0A2A"
  bano-rojo: "#1E0504"
  serie-3: "#8f8597"
  serie-4: "#3a2d42"
  conforme: "#1c6b52"
  atencion: "#a32a22"
typography:
  indice:
    fontFamily: "Asap, sans-serif"
    fontSize: "clamp(3.6rem, 7.4vw, 6rem)"
    fontWeight: 200
    lineHeight: 0.88
    letterSpacing: "0.01em"
  portadilla:
    fontFamily: "Asap, sans-serif"
    fontSize: "clamp(2.3rem, 4.8vw, 3.75rem)"
    fontWeight: 300
    lineHeight: 1.02
    letterSpacing: "0.01em"
  portal:
    fontFamily: "Asap, sans-serif"
    fontSize: "clamp(2.1rem, 3.8vw, 3.3rem)"
    fontWeight: 300
    lineHeight: 1.1
    letterSpacing: "0.005em"
  numeral:
    fontFamily: "JetBrains Mono, ui-monospace, monospace"
    fontSize: "clamp(2.25rem, 3.6vw, 3.25rem)"
    fontWeight: 200
    lineHeight: 1
    letterSpacing: "0.02em"
  titulo:
    fontFamily: "Asap, sans-serif"
    fontSize: "clamp(1.6rem, 2.5vw, 2.125rem)"
    fontWeight: 300
    lineHeight: 1.12
    letterSpacing: "0.01em"
  cifra:
    fontFamily: "Asap, sans-serif"
    fontSize: "1.625rem"
    fontWeight: 300
    lineHeight: 1.1
    letterSpacing: "-0.01em"
    fontFeature: "tnum"
  cobertura:
    fontFamily: "Asap, sans-serif"
    fontSize: "1.5rem"
    fontWeight: 400
    lineHeight: 1.5
  sala:
    fontFamily: "Asap, sans-serif"
    fontSize: "1.375rem"
    fontWeight: 400
    lineHeight: 1.2
    letterSpacing: "0.005em"
  mayor:
    fontFamily: "Asap, sans-serif"
    fontSize: "1.125rem"
    fontWeight: 400
    lineHeight: 1.62
  body:
    fontFamily: "Asap, sans-serif"
    fontSize: "0.9375rem"
    fontWeight: 400
    lineHeight: 1.55
    fontFeature: "tnum"
  nombre:
    fontFamily: "Asap, sans-serif"
    fontSize: "0.9375rem"
    fontWeight: 500
    lineHeight: 1.3
  dato:
    fontFamily: "Asap, sans-serif"
    fontSize: "0.8125rem"
    fontWeight: 400
    lineHeight: 1.55
    fontFeature: "tnum"
  menor:
    fontFamily: "Asap, sans-serif"
    fontSize: "0.75rem"
    fontWeight: 400
    lineHeight: 1.55
  rotulo:
    fontFamily: "Asap, sans-serif"
    fontSize: "0.6875rem"
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: "0.12em"
  identificador:
    fontFamily: "JetBrains Mono, ui-monospace, monospace"
    fontSize: "0.8125rem"
    fontWeight: 500
    lineHeight: 1.3
  medida:
    fontFamily: "JetBrains Mono, ui-monospace, monospace"
    fontSize: "0.75rem"
    fontWeight: 400
    lineHeight: 1.3
  credito:
    fontFamily: "Asap, sans-serif"
    fontSize: "0.75rem"
    fontWeight: 500
    letterSpacing: "0.1em"
rounded:
  radio: "0"
spacing:
  canal: "32px"
  canal-movil: "18px"
  pie-seccion: "72px"
  ancho: "1440px"
components:
  cuadro:
    backgroundColor: "{colors.lamina}"
    rounded: "{rounded.radio}"
  cuadro-cabecera:
    padding: "12px 16px"
  cuadro-pie:
    backgroundColor: "{colors.campo}"
    textColor: "{colors.tinta-3}"
    typography: "{typography.menor}"
    padding: "10px 16px 11px"
  cuadro-numero:
    textColor: "{colors.magenta-prof}"
    typography: "{typography.identificador}"
  banda:
    backgroundColor: "{colors.magenta}"
    textColor: "{colors.papel}"
    padding: "0 0.16em 0.05em"
  portadilla:
    backgroundColor: "{colors.bano-violeta}"
    textColor: "{colors.papel}"
    padding: "40px 32px 30px"
  portadilla-azul:
    backgroundColor: "{colors.bano-azul}"
  portadilla-rojo:
    backgroundColor: "{colors.bano-rojo}"
  pestana-edicion:
    backgroundColor: "{colors.teal}"
    textColor: "{colors.papel}"
    typography: "{typography.medida}"
    padding: "16px 10px 8px"
  nav-link:
    textColor: "{colors.tinta-2}"
    typography: "{typography.dato}"
    padding: "11px 0 9px"
  nav-link-active:
    textColor: "{colors.tinta}"
  btn-serie:
    backgroundColor: "{colors.lamina}"
    textColor: "{colors.tinta-2}"
    typography: "{typography.menor}"
    rounded: "{rounded.radio}"
    padding: "4px 11px"
  btn-serie-active:
    backgroundColor: "{colors.azul}"
    textColor: "{colors.papel}"
  btn-descarga:
    backgroundColor: "{colors.lamina}"
    textColor: "{colors.azul}"
    typography: "{typography.medida}"
    rounded: "{rounded.radio}"
    padding: "3px 10px"
  btn-descarga-hover:
    backgroundColor: "{colors.azul}"
    textColor: "{colors.papel}"
  campo-formulario:
    backgroundColor: "{colors.lamina}"
    textColor: "{colors.tinta}"
    typography: "{typography.dato}"
    rounded: "{rounded.radio}"
  inventario-fila:
    backgroundColor: "{colors.lamina}"
    padding: "14px"
  inventario-fila-hover:
    backgroundColor: "{colors.fila}"
  sala:
    textColor: "{colors.tinta}"
    typography: "{typography.sala}"
    padding: "17px 6px 16px"
  sala-hover:
    backgroundColor: "{colors.campo}"
    textColor: "{colors.azul}"
  cimiento:
    backgroundColor: "{colors.campo}"
    padding: "72px 32px 56px"
  marca-estado:
    backgroundColor: "{colors.lamina}"
    textColor: "{colors.tinta-2}"
    typography: "{typography.menor}"
    padding: "3px 9px 3px 7px"
---

# Design System: Datos Magallanes

## Overview

**Creative North Star: "El Boletin de campo"**

El catalogo se viste como el Boletin de Estudios Regionales N.2 (UER-UMAG, marzo 2026) y se lee como una hoja de campo patagonica. Del Boletin vienen el papel blanco, la tinta violeta-negra, Asap liviana con tracking positivo, la banda magenta de imprenta y una foto banada en un solo color por capitulo. De la hoja de campo vienen las curvas de nivel, el perfil del Paine de borde a borde, las coordenadas, el marco de instrumento en las esquinas del cuadro y la mono en todo lo que se cita o se mide. Cada capitulo abre como un articulo del Boletin (la portadilla) y cada cifra se lee como una lectura de instrumento, con su numero de acceso al lado.

La densidad es de impreso de consulta: registros con regla de apertura, filetes capilares entre filas, cifras tabulares alineadas por la coma, y aire generoso entre bloques (72px). El campo es acromatico; el color vive en la banda, en la numeracion y en las series, y cada color hace un solo trabajo. La profundidad no existe: todo es plano, sin sombras ni radios. El vocabulario del mobiliario se conserva del mundo anterior porque es la gramatica del catalogo: portadilla, cuadro, inventario, asiento, numero de acceso, indice, pulso, cimiento, colofon, banda.

Este mundo reemplaza por completo a "El Catalogo Razonado" (papel hueso, violeta solo en umbrales, radio 2px, campo noche en el chasis), retirado el 27-09-2026. Rechazos confirmados: la parrilla de tarjetas KPI y el tablero oscuro de "datos".

**Key Characteristics:**
- Papel blanco y tinta violeta-negra; un solo escalon tonal (campo) tenido de violeta.
- Un color, un trabajo: magenta banda y serie protagonista, magenta profundo numeracion, azul solo lo accionable, teal solo la pestana de edicion y el trazo del paisaje.
- Asap liviana (200-300 en display) con tracking positivo; JetBrains Mono solo para identificadores y medidas.
- Cero sombras salvo el anillo de foco, radio 0, filete de 1px y regla de apertura de 2px en tinta.
- Fotos del Boletin banadas en duotono (azul, violeta o rojo) bajo cada portadilla, con credito visible.
- Firma de movimiento: la banda magenta que se dibuja de izquierda a derecha.

## Colors

Campo acromatico en papel blanco y tinta violeta-negra; el color esta confinado a la banda, a la numeracion, a las series y a los filetes del paisaje.

### Primary
- **Magenta de imprenta** (magenta): el magenta del Boletin N.2. Dos trabajos que son el mismo gesto de imprenta: la banda (a lo sumo una palabra por titular; la cobertura de cada portadilla) y la serie protagonista de todo grafico, incluido el trazo del pulso y el primer color de `PAL$serie`. Blanco sobre magenta mide 4,1:1: solo texto grande, por eso la cobertura en banda va a 24px y no baja.
- **Magenta profundo** (magenta-prof): toda numeracion en texto chico. Numero de acceso (101, 215), direccion de cuadro (I.1, II.3), numeral de sala en el indice, id del asiento y del pulso. 5,8:1 sobre papel.

### Secondary
- **Azul de trabajo** (azul, Pantone 2728 C): SOLO lo accionable. Enlaces, pestana activa (filete inferior de 2px), anillo de foco, control activo (boton de serie activo, slider, casilla, descarga en hover), nombre de sala y de pieza en hover. Nunca pinta un dato: un dato en azul se leeria como enlace, por eso no entra en `PAL$serie`.
- **Violeta del manual** (violeta, Pantone 268 C): segunda serie de grafico, y extremo oscuro de `rampa_orden()` para categorias ordenadas (magenta claro, magenta, violeta oscurecido).

### Tertiary
- **Teal de edicion** (teal): la pestana vertical de edicion en la barra de marca (version y mes, blanco sobre teal 5,3:1), bajando desde el borde superior como en la portada del Boletin. Es su unico uso como superficie.
- **Trazo de paisaje** (curva): el mismo teal como trazo, nunca como texto. Curvas de nivel (`topo.svg`, trazo 0,7-1,2 con opacidad 0,45-0,8) tras el umbral y el cimiento, y el perfil del Paine (`horizonte.svg`, 1,25px) que cierra el umbral y abre el colofon. Ambos SVG los genera `_dev/motivos_paisaje.R` desde `PAL$curva`.
- **Banos de portadilla** (bano-azul, bano-violeta, bano-rojo): la sombra del duotono de cada foto de capitulo y el fondo bajo ella. Cada bano tiene sombra, medio y luz en `PAL$bano` (azul #2F5BC8/#DCE6FF, violeta #7B2FC4/#EBDDFF, rojo #B81E16/#F2907E), que `_dev/portadillas.R` usa para tenir las fotos. La asignacion por capitulo vive en `.PORTADILLAS` (I azul, II rojo, III violeta, IV azul, V violeta, VI rojo, VII azul).
- **Series de contexto** (serie-3, serie-4): tercera y cuarta serie, gris violaceo y tinta profunda. Orden fijo del ciclo: magenta, violeta, serie-3, serie-4.

### Neutral
- **Papel** (papel) y **Lamina** (lamina): fondo de pagina y superficie de trabajo, ambos blancos; la lamina es la misma hoja con otro nombre de rol.
- **Campo** (campo): el unico escalon tonal. Pie de cuadro, pieza desplegada, hover de sala y de pulso, barra de filtros, cimiento.
- **Fila** (fila): hover de fila sobre lamina (inventario, indice colgante).
- **Tinta** (tinta): texto principal, 17,6:1. Tambien la regla de apertura de 2px y las esquinas de instrumento.
- **Tinta 2** (tinta-2, 7,9:1) y **Tinta 3** (tinta-3, 6,0:1): texto secundario; rotulos, glosas, fuentes, ejes.
- **Regla** (regla) y **Regla fina** (regla-fina): los filetes, el unico recurso estructural del sistema.
- **Conforme** (conforme) y **Atencion** (atencion): reservados a significado. Atencion cubre la baja de una medida publicada y la advertencia metodologica (marca de prototipo); conforme, el alza.

### Named Rules
**The Un Color Un Trabajo Rule.** Cada color hace un solo trabajo y ningun otro: si un elemento nuevo necesita color, se le asigna el rol existente o queda en tinta. Magenta no enlaza, azul no pinta datos, teal no aparece fuera de la pestana y el paisaje.

**The Una Banda Por Titular Rule.** A lo sumo una palabra (o la cobertura) en banda por titular. Si un titulo tiene dos bandas, una sobra. La banda lleva texto blanco a 400 y corta limpia al pasar de linea (`box-decoration-break: clone`).

**The Colores Por Nombre Rule.** Nunca se hardcodea un color: en R va por `PAL$*`, en CSS por las variables de `:root`. Los `--bano-*` de styles.css repiten la sombra de `PAL$bano` y deben cambiar juntos.

## Typography

**Display Font:** Asap (variable, servida localmente; con -apple-system, Segoe UI, sans-serif)
**Body Font:** Asap
**Label/Mono Font:** JetBrains Mono (variable 100-800, servida localmente; con ui-monospace, SF Mono, Menlo)

**Character:** Asap liviana con tracking positivo, como los titulares del Boletin: grande, abierta y sin peso, la jerarquia sale del tamano y no del negro. La mono es la voz del instrumento: cita y mide, no titula, no enfatiza y no escribe prosa.

### Hierarchy
- **Indice** (200, clamp 3,6-6rem, 0,88): la palabra "In/di/ce" partida en tres lineas en el portal. Unico uso del 200 en Asap.
- **Portadilla** (300, clamp 2,3-3,75rem, 1,02): nombre de capitulo en blanco sobre la foto. En <=768px sube a `--t-portadilla-movil` (2,75rem) para seguir mandando sobre la cobertura de 24px.
- **Portal** (300, clamp 2,1-3,3rem, 1,1): la frase de apertura del umbral.
- **Numeral** (mono 200, clamp 2,25-3,25rem): el numeral romano de la portadilla sobre su filete blanco; primera mitad de la direccion de cita.
- **Titulo** (300, clamp 1,6-2,125rem, 1,12): titulo de bloque y del cimiento, con 72px de aire arriba.
- **Cifra** (300, 1,625rem, tracking -0,01em, tabular): el valor en el inventario, el pulso y la linea de estado. La cifra va en Asap, nunca en mono.
- **Cobertura** (400, 1,5rem): la linea de alcance en banda de la portadilla.
- **Sala** (400, 1,375rem) y **Mayor** (400, 1,125rem): nombre de sala en el indice; bajada del portal, titulo de compromiso, id del asiento.
- **Body** (400, 0,9375rem, 1,55, tabular): cuerpo; prosa a 68ch. En <=768px el cuerpo baja a 0,8125rem.
- **Nombre** (500, 0,9375rem): nombre de pieza, de cuadro, de asiento, de pulso.
- **Dato** (400, 0,8125rem): celdas, controles, pestanas de navegacion (500), glosas de sala.
- **Menor** (400, 0,75rem): pies, fuentes, glosas, unidad bajo el nombre.
- **Rotulo** (600, 0,6875rem, 0,12-0,14em, versalita): cabeceras de tabla, campos del asiento, llamadas del pie de cuadro (Definicion, Fuente, Nota), descriptor de la marca, caption del inventario.
- **Identificador / Medida** (mono 500 / 400, 0,8125 / 0,75rem): numero de acceso, direccion de cuadro, numeral de sala, periodo, rango de ids, coordenadas, edicion, boton CSV. Los ejes de grafico van en mono 10,5px desde `.tema_echarts`.
- **Credito** (0,75rem, versalita; ningun texto que se lea baja de 11px): credito fotografico vertical en Asap 500 (son palabras, no medidas) y mes de la pestana de edicion en mono.

### Named Rules
**The Rampa Cerrada Rule.** Todo tamano sale de las variables `--t-*` de `:root`. Un tamano nuevo se agrega a la rampa o no existe; incluido el titulo de portadilla en telefono (`--t-portadilla-movil`, 2,75rem).

**The La Mono No Es Disfraz Rule.** JetBrains Mono va solo en identificadores y medidas: ids, direcciones de cuadro, numerales, periodos, rangos, coordenadas, edicion y ejes. Nombres, prosa, rotulos y cifras van en Asap.

**The Liviana Con Aire Rule.** El display va en 200-300 con tracking positivo (0,005-0,02em); los nombres en 400-500. El negrita queda para enfasis minimo en la bajada y el estado activo de la pestana (600). Nada rotula un titulo.

## Layout

Pliego clampeado a 1440px (`--ancho`) con canal de 32px (18px en <=768px). Los campos a sangre (umbral, portadilla, cimiento, horizonte) anulan el canal de bslib y cada bloque de lectura se clampea a si mismo dentro de un pliego. Pie de seccion de 72px; el cimiento lo anula con margen negativo para tocar el horizonte del colofon.

- **Portal:** el umbral es una rejilla 5/7 (4/8 en <=1024px): foto del indice del Boletin a sangre a la izquierda, texto a la derecha sobre curvas de nivel enmascaradas bajo el titular. El horizonte cruza foto y texto de borde a borde al pie. En telefono se apila: foto como franja de 220px, y la marca de prototipo sube bajo el titular para caer en la primera pantalla. Debajo, el indice en 4/8 ("In/di/ce" a la izquierda, siete salas a la derecha), luego el pulso y el cimiento con tres compromisos.
- **Entrada (index.html):** la tapa antes de abrir el Boletin, sin chasis. Papel y una sola capa de curvas de nivel (`img/topo-giro.svg`, cuadrada, cumbre al centro) que gira sobre un eje a la derecha a velocidad constante, una vuelta cada 140 s, bajo una mascara fija que la apaga antes del nombre (en telefono baja al tramo entre el prompt y el pie). "Datos Magallanes" en Asap 200 a `--t-indice` con "Magallanes" en banda, una frase, y la accion escrita como linea de comandos: `> entrar` en mono azul con cursor de bloque magenta que parpadea; al pasar, la banda se dibuja sobre "entrar" como texto seleccionado en una terminal. Es la unica mono de la pagina que no es identificador ni medida: excepcion pedida por el usuario como referencia a lo tecnologico, no norma del sistema. La marca de prototipo va en la primera pantalla. Al pie la linea de estado, el lugar en coordenadas y el Paine de borde a borde. Su unico momento: al pulsar, la banda de "entrar" corre de borde a borde como franja y despues inunda la pantalla; en la portada se retira hacia la derecha mientras el nombre viaja a la barra de marca (`transicion.css`, View Transitions entre documentos; en Firefox, respaldo con `html.llega-banda`). Sin movimiento bajo `prefers-reduced-motion`.
- **Capitulo:** portadilla fotografica (min 280-400px), inventario, piezas plegadas (acordeon de cuadros), nota de aparato al pie.
- **Chasis identico** en las ocho secciones: barra de marca, navegacion (franja horizontal en escritorio, menu Indice en telefono), colofon con el Paine y las coordenadas de Punta Arenas.
- **Navegacion:** en escritorio las ocho pestanas estan siempre a la vista en la franja, cada capitulo con su indice de cuadros al pasar o enfocar la pestana. En <=768px la franja no cabia (mostraba tres y media y escondia el resto sin aviso): la reemplaza el boton **Indice** de la barra de marca, que despliega un panel a pantalla completa con las ocho secciones y, dentro de cada capitulo plegable, sus cuadros (el actual abierto, marcado con el filete azul). La barra de marca queda fija arriba. Es `<details>` nativo: funciona sin JS. Bajo 380px el boton queda solo con su icono.
- **Inventario en telefono:** cada fila se recompone como rejilla de tres columnas (numero, nombre, cifra), con unidad y periodo bajo la cifra y fuente y medida bajo el nombre. Ninguna cifra se publica sin su unidad y su periodo al lado.
- **Asiento en telefono:** la tabla campo/valor se apila como prosa de consulta.
- Breakpoints observados: 1024px y 768px.

### Named Rules
**The Cifra Con Unidad Rule.** En todo tamano, una cifra viaja con su unidad y su periodo en la misma fila visual. Una recomposicion responsiva que los separe es un defecto.

## Elevation & Depth

El sistema es plano. No hay sombras: el tema Bootstrap las desactiva por contrato, las tooltips de ECharts llevan `box-shadow:none`, y la jerarquia se construye con filetes y con el unico escalon tonal (campo). La unica "profundidad" es la de la foto banada de la portadilla, que es una imagen, no un relieve.

### Shadow Vocabulary
- **Anillo de foco** (`outline: 2px solid var(--azul); outline-offset: 2px`; blanco sobre la portadilla; en campos de formulario `box-shadow: 0 0 0 3px color-mix(in srgb, var(--azul) 18%, transparent)`): la unica sombra admitida, y solo como senal de foco.

### Named Rules
**The Cero Sombras Rule.** Cero sombras salvo el anillo de foco. Un borde, un campo o un filete de 2px resuelven cualquier jerarquia que una sombra pretenda.

## Shapes

Radio 0 en todo (`--radio: 0`): cuadros, botones, campos, handles del slider, barras de grafico, tooltips. El filete de 1px en regla o regla fina es el recurso estructural; el filete de 2px en tinta es solo regla de apertura de una tabla o lista (inventario, piezas plegadas, asientos, salas, pulso, compromisos, filtros, indice colgante). El cuadro lleva las dos esquinas del marco de instrumento: 12px en tinta a 1,5px arriba a la izquierda y abajo a la derecha. El chevron del acordeon se dibuja con dos bordes de 1,5px, no con un glifo. La portadilla lleva una reticula de instrumento cada 80px en blanco al 6%.

### Named Rules
**The Regla De Apertura Rule.** Toda tabla o lista de registro abre con un filete de 2px en tinta y separa sus filas con 1px; no lleva marco lateral.

## Components

### Buttons
Controles de impreso: planos, rectos, en filete.
- **Shape:** radio 0, filete de 1px en regla.
- **Boton de serie:** lamina, texto tinta-2 en Asap menor 500; hover sube el filete a tinta-3; activo en azul pleno con texto blanco 600; deshabilitado en regla fina.
- **Descarga CSV:** en mono menor, texto azul sobre lamina; hover invierte a azul pleno. (Sin glifo: el sitio no carga Font Awesome.)
- **Hover / Focus:** transiciones de 0,12s; foco en el anillo azul.

### Inputs / Fields
- **Style:** lamina, filete de regla, radio 0, Asap dato.
- **Focus:** filete azul y anillo azul al 18%.
- **Rotulos:** versalita tracked (rotulo) en tinta-3.
- **Slider:** linea de 2px en regla, barra y handle cuadrado en azul, etiquetas en mono.

### Navigation
- **Barra de marca:** papel, pestana teal de edicion (version en mono 600, mes en credito), emblema, nombre en Asap 500 y descriptor en versalita tracked; sello UER a la derecha.
- **Pestanas:** Asap dato 500 en tinta-2, sin fondo ni radio; activa en tinta 600 con filete inferior azul de 2px.
- **Indice colgante:** panel de lamina con regla de apertura que cuelga de cada pestana; filas direccion (mono magenta profundo), id (mono tinta-3), nombre; hover en fila y nombre en azul.

### Cuadro (signature)
La lamina numerada con marco de instrumento. Lamina con filete de 1px y esquinas de instrumento; cabecera con la direccion en mono magenta profundo y el titulo (que manda la ficha) en Asap nombre; controles a la derecha; cuerpo con el grafico; pie en campo con las llamadas Definicion, Fuente y Nota en versalita, el enlace a la ficha en azul subrayado y el boton CSV.

### Graficos
Todo grafico pasa por `e_lamina()`, que registra el tema unico `.tema_echarts`: fondo transparente, Asap 12px en texto y leyenda, ejes en JetBrains Mono 10,5px, lineas de division en regla fina, barras sin radio, lineas rectas de 2,2px, leyenda en rect de 12x2. Ciclo de series fijo: magenta, violeta, serie-3, serie-4 (`tintas_serie()`); una sola serie en `tinta_plana()` (magenta); categorias ordenadas en `rampa_orden()`. El area opcional es un degradado vertical muy claro de la propia serie. Las referencias (`e_datum()`) van en tinta terciaria discontinua, nunca en color de serie.

### Portadilla
Cada capitulo abre como un articulo del Boletin: foto a sangre al 92% sobre su bano, veladura inferior del bano, reticula de instrumento, numeral mono 200 sobre filete blanco, nombre en Asap 300, cobertura en banda magenta a 24px, rango de numeros de acceso en mono versalita, y credito vertical pegado al borde (horizontal arriba en telefono). Al entrar, la banda se dibuja de izquierda a derecha (0,9s, `cubic-bezier(0.65, 0, 0.35, 1)`, 0,3s de retardo); se redibuja cada vez que se abre el capitulo. El texto es blanco desde el primer cuadro, nada queda invisible mientras la banda crece.

### Inventario
Tabla de impreso con regla de apertura: numero de acceso en mono magenta profundo a la derecha, nombre en Asap 500 con glosa, cifra en Asap 300 1,625rem alineada a la derecha, unidad, periodo en mono, medida publicada por la fuente (alza en conforme, baja en atencion; vacia si el CSV no la trae) y sigla de fuente alineada a la izquierda. Sobre la tabla, el caption en versalita y la marca de estado.

### Piezas plegadas y asientos
Acordeones de bslib leidos como lista de registro: regla de apertura, filete de 1px por item, direccion o id en mono magenta profundo, nombre en Asap 500 con unidad entre parentesis debajo, chevron dibujado. Desplegado o en hover, el boton pasa a campo. El asiento (capitulo VI) expone sus campos en tabla campo/valor con rotulos en versalita.

### Marca de estado
El estado del dato es una marca dibujada, nunca solo un color: cuadro de 10px con relleno pleno (compilado), rayado a 45 grados (preliminar), barra horizontal (interrumpida), diagonal (no disponible), y rayado inverso en atencion con texto atencion (ilustrativo o prototipo).

### Indice del portal
"In/di/ce" en Asap 200 partido en tres lineas y siete salas en lista de registro: numeral romano en mono magenta profundo, nombre de sala en Asap 400 con glosa, cuenta con cifra en mono, rango de ids en mono, flecha que se desplaza 4px y se tine de azul en hover.

### Pulso
Seis series del catalogo, una por dimension, dibujadas en su nivel publicado: id en mono magenta profundo, nombre, unidad, trazo magenta de 1,75px con `non-scaling-stroke`, remate vertical, cifra final en Asap 300, ano en mono, rango y fuente al pie. Al entrar en pantalla cada trazo se descubre de izquierda a derecha con un recorte (`clip-path: inset`, 1100ms, escalonado por panel), no con `stroke-dasharray`: con `non-scaling-stroke` en un viewBox estirado la longitud del guion se mide en pixeles de pantalla y los ultimos anos no se dibujaban.

### Cimiento y colofon
El cimiento es un campo sobre curvas de nivel al 32% con emblema, titulo en Asap 300 (una palabra en banda), entrada y tres compromisos con regla de apertura. El colofon abre con el horizonte del Paine y firma con sello, institucion, coordenadas en mono y edicion.

### Named Rules
**The Banda Que Se Dibuja Rule.** El unico movimiento de firma es la banda magenta trazada de izquierda a derecha: al entrar a cada portadilla y una vez en el titular del portal (donde la palabra arranca en magenta profundo y pasa a blanco cuando la banda la cubre). Con `prefers-reduced-motion` todo queda en su estado final: banda dibujada, trazos del pulso visibles, transiciones a 0,01ms.

**The Ninguna Cifra Se Transforma Rule.** La interfaz publica el nivel que trae la fuente. La medida de variacion es la que la fuente publica en el CSV, formateada con `medida_publicada()`; si no la trae, la celda queda vacia. No hay conmutador de referencia, indice base ni delta calculado.

## Do's and Don'ts

### Do:
- **Do** asignar cada color a su unico trabajo: magenta en banda y serie protagonista, magenta profundo en numeracion chica, azul solo en lo accionable, teal solo en la pestana de edicion y el trazo del paisaje.
- **Do** tomar todo color de `PAL$*` en R y de las variables de `:root` en CSS, y todo tamano de la rampa `--t-*`.
- **Do** pasar todo grafico por `e_lamina()` y respetar el orden de series magenta, violeta, serie-3, serie-4.
- **Do** poner en JetBrains Mono los ids, direcciones de cuadro, numerales, periodos, rangos, coordenadas, edicion y ejes, y todo lo demas en Asap.
- **Do** abrir toda tabla o lista de registro con el filete de 2px en tinta y separar filas con 1px.
- **Do** mantener la cobertura en banda a 24px o mas (blanco sobre magenta mide 4,1:1).
- **Do** publicar cada cifra con su unidad y su periodo al lado en todo tamano, en formato chileno (punto de miles, coma decimal) y con cifras tabulares.
- **Do** dar a cada portadilla una foto del Boletin banada en uno de los tres duotonos, registrada en `.PORTADILLAS` con su credito visible.
- **Do** escribir los textos de UI sin tildes.
- **Do** apagar todo movimiento bajo `prefers-reduced-motion`, dejando cada elemento en su estado final.

### Don't:
- **Don't** usar sombras (salvo el anillo de foco) ni radios distintos de 0.
- **Don't** pintar un dato en azul: se leeria como enlace.
- **Don't** poner mas de una palabra en banda por titular.
- **Don't** usar la mono para nombres, prosa, rotulos o cifras.
- **Don't** usar el teal fuera de la pestana de edicion y el trazo del paisaje.
- **Don't** calcular en la interfaz un delta, un indice base o una cifra re-referida.
- **Don't** construir parrillas de tarjetas KPI ni tableros oscuros de "datos".
- **Don't** usar glifos de icono (Font Awesome); los chevrones y marcas se dibujan con filetes.
- **Don't** revelar trazos SVG con `stroke-dasharray` cuando llevan `non-scaling-stroke`; usar recorte.
- **Don't** hardcodear un hex en un modulo, un `grafico.R` o una regla CSS.

## Unresolved

- **La rejilla de seis paneles del pulso.** El pulso se arrastra del mundo anterior como rejilla de 3x2 paneles con filete de 1px (2 columnas en <=1024px, 1 en telefono). La revision de cierre la marco como contradiccion de la THESIS ("refusa la parrilla de tarjetas KPI"). Queda registrada tal como se construyo, pero no es norma del sistema: no se replica en otras superficies hasta que el usuario decida si se conserva, se recompone como lista de registro o sale.

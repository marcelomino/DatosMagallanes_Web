# Historial de cambios — Datos Magallanes · UER-UMAG

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).
Versionado siguiendo [Semantic Versioning](https://semver.org/lang/es/) (`MAJOR.MINOR.PATCH`).

> **Nota sobre el prefijo `0.x`:** Mientras la versión mayor sea `0`, el proyecto
> se encuentra en desarrollo activo. La versión `1.0.0` se declarará al alcanzar
> un estado estable de producción con datos oficiales verificados.

> **Revisión de septiembre de 2026.** Este archivo se había quedado en la versión
> `0.4.0` (marzo) mientras el repositorio acumulaba seis commits con cuatro
> cambios de fondo sin documentar: la migración a CSV por indicador, la
> reestructuración en carpetas, el rediseño completo de la interfaz y el traslado
> de los gráficos a la carpeta de su indicador. Las versiones `0.5.0` a `0.8.0`
> se reconstruyeron desde el historial de `git`. La hoja de ruta también se
> corrigió: sus denominaciones anunciaban un plan que el desarrollo no siguió.

---

## [0.13.0] — El catálogo como sitio web  ← versión actual
Fecha: 2026-10-17 · repositorio `DatosMagallanes_Web`

La plataforma deja de ser una aplicación Shiny y pasa a ser un sitio estático:
`Rscript construir.R` escribe `_site/` y GitHub Pages lo publica en cada push a
`master`. El dashboard `10_Datos_Magallanes_dash` queda congelado en el commit
`b5a1843`; el catálogo (fichas, CSV, `grafico.R`) vive desde ahora en este
repositorio. Ninguna cifra, ficha ni lámina cambia.

### Cambiado
- **Una página por sección**, con dirección propia: `index.html`, `poblacion.html`
  … `fuentes.html`. Cada cuadro se cita y se enlaza (`economia.html#cuadro-II-1`
  abre su pieza) y cada ficha también (`metodologia.html?pieza=215`).
- **Los módulos pasan a ser páginas** (`R/40_pag_*.R`): el cuerpo de cada
  `mod_*_ui()` sin namespace y sin servidor. El chasis de `ui.R` pasa a
  `R/50_sitio.R`.
- **Cada lámina se dibuja al construir.** `pieza_cuadro()` publica un lienzo con
  todos sus dibujos ya hechos por `dibujar()` —cada rango de años de
  II.1/II.2 y III.1/III.2, y cada estado del «Eje desde cero»— y `js/sitio.js`
  solo elige cuál mostrar. `.anclar_cero()` sigue siendo la única definición del
  eje. Las láminas se inicializan al abrir su entrada, como antes.
- **Las descargas son archivos**: `datos/{carpeta}.csv`, en el mismo formato
  (`;`, coma decimal, BOM UTF-8). Las de cuadros con rango se arman con el CSV del
  rango vigente, embebido al construir.
- **Las salas y el pulso de la portada** son enlaces a su capítulo (eran
  `<button>` que llamaban a Shiny).
- **El filtro de Metodología oculta asientos** en vez de reconstruir el
  acordeón: refinar la búsqueda ya no cierra lo que el lector tenía abierto.

### Retirado
- Shiny: `app.R`, `ui.R`, `server.R`, `montar_cuadro()`, `descarga_csv()`
  (downloadHandler), `slider_anios()`, `boton_serie()`, `grupo_series()` y el
  mensaje `marcarSerie`. Los controles son marcado nativo (`control_select()`,
  `control_check()`, `control_texto()`).
- El despliegue en shinyapps.io (`rsconnect/`).

### Agregado
- `construir.R`, `R/50_sitio.R`, `js/sitio.js` y `.github/workflows/publicar.yml`.
- `_dev/probar_sitio.R`: recorre el sitio en Chrome sin ventana (enlaces, las 36
  láminas, errores de JS, desborde a 390 px, controles).
- `lienzo()`, `lienzo_fijo()`, `rango_anios()`, `escribir_csv()`, `texto_csv()`,
  `opciones_grafico()`, `a_json()`.

### Corregido
- `indicadores/red.yaml` se restauró desde `b5a1843`: en el árbol de trabajo del
  dashboard estaba borrado sin confirmar.

---

## [0.12.0] — El Boletín de campo
Fecha: 2026-09-27 · commit `ff1046b`

Rediseño del mundo visual completo. La plataforma deja «El Catálogo Razonado»
(papel hueso, campo noche, Asap sola) y adopta el estilo del *Boletín de
Estudios Regionales N.º 2*, cruzado con el registro técnico-patagónico del tema
«austral» de la presentación de brechas sociolaborales. Modo claro.
Ninguna cifra, ficha ni navegación cambia; cambia cómo se ven.

### Cambiado
- **Paleta** (`PAL` en `R/10_utils.R` y `:root` en `www/styles.css`): papel
  blanco y tinta violeta-negra; magenta de imprenta `#E82D88` para la banda y la
  serie protagonista; magenta profundo para toda numeración; el azul queda solo
  para lo accionable; teal solo en la pestaña de edición. La secuencia de series
  del tema de gráfico es magenta, violeta, gris de contexto y tinta.
- **Portadillas** con foto del Boletín a sangre, bañada en duotono azul, violeta
  o rojo, con crédito visible (`.PORTADILLAS`), numeral en mono sobre filete
  blanco y la cobertura en banda magenta que se dibuja al entrar.
- **Portal**: la foto del índice del Boletín a la izquierda, el titular con
  «reunidos» en banda, curvas de nivel y el perfil del Paine; las seis puertas
  pasan a un índice «In/di/ce» de siete filas.
- **Tipografía**: Asap liviana con tracking positivo; JetBrains Mono (servida
  en `www/fonts/mono.css`) solo para identificadores y medidas: número de
  acceso, dirección de cuadro, periodos, rangos, coordenadas, ejes.
- Sin radios (`--radio: 0`); tablas y listas con regla de apertura de 2px; el
  cuadro lleva esquinas de instrumento.
- `rampa_azul()` pasa a llamarse `rampa_orden()` (del magenta claro al violeta).
  Las cinco láminas de barras planas pintan con `PAL$magenta`.

### Corregido
- Las cifras del inventario quedaban alineadas a la izquierda, lejos de su
  cabecera VALOR: una regla de celda con más especificidad pisaba `.inv-valor`.
- Los trazos del pulso se cortaban al 75%: `stroke-dasharray` se mide en
  pixeles con `non-scaling-stroke`. La entrada es ahora un recorte.
- «(Porcentaje (%))»: `rotulo_unidad()` aplana el paréntesis interior.
- En teléfono, cada fila del inventario conserva su unidad y su periodo, y la
  advertencia de prototipo sube a la primera pantalla.

### Agregado
- `_dev/portadillas.R` (tiñe las fotos, ImageMagick) y
  `_dev/motivos_paisaje.R` (curvas de nivel y perfil del Paine desde `PAL`).
- `DESIGN.md` reescrito desde el mundo construido.

---

## [0.11.0] — Descarga de CSV
Fecha: 2026-09-17 · commit `d30e1ec`

Cada cuadro y cada ficha del catálogo publican ahora un botón de descarga: el
mismo data.frame que dibuja el gráfico, o que documenta la ficha, sale en CSV
tal cual se está mostrando en pantalla.

### Agregado
- `boton_descarga(ns, clave)` (`R/30_ui_components.R`) y su contraparte de
  servidor `descarga_csv(datos, prefijo)` (`R/10_utils.R`): un `downloadHandler`
  mínimo, listo para colgar de cualquier output. `datos` admite una función
  sin argumentos para los cuadros con recorte reactivo, de modo que el CSV
  entregado sea siempre el que el cuadro está mostrando, no la serie completa
- Parámetro `descarga` en `cuadro()`, que agrega el botón a `cuadro-controles`
  sin desplazar los controles propios del cuadro (selectores de rango, etc.)
- Botón de descarga en los 35 cuadros de los capítulos Población, Economía,
  Pobreza e Ingresos, Bienestar y Cohesión Social
- Botón de descarga al pie de cada asiento del capítulo Metodología, para las
  37 piezas con `datos.csv` compilado. Vive dentro del cuerpo del acordeón y
  no en su cabecera: la cabecera entera es el botón que abre y cierra el
  panel, y un enlace anidado ahí quedaría inalcanzable al foco y dispararía
  el toggle al hacer click
- `.btn-descarga` en `www/styles.css`, mismo molde que `.btn-serie`: sin
  sombra, radio único, tinta azul solo en hover

### Notas
- Verificado en un Chrome headless real, no solo por lectura de código: el
  CSV de un cuadro con recorte reactivo (PIB, pobreza) cambia junto con el
  selector de años, y la ficha 104 descarga exactamente su `datos.csv`

---

## [0.10.0] — Ingesta desde Drive
Fecha: 2026-09-17 · commit `d30e1ec`

Catálogo compilado: 23 → 37 de 69 indicadores. Los 14 nuevos ya venían
documentados con `ficha.yaml` pero sin `datos.csv`; los datos y las fichas
técnicas estaban recopilados en la carpeta compartida de Drive
`[Datos Magallanes] Recopilación Datos/Datos página/` (INE, Banco Central, SII,
CASEN-MDSF, DEIS, SIES-MINEDUC, CEAD), pendientes de volcarse al repositorio.

Compilar los 14 no bastó para verlos: cada capítulo (`R/40_mod_*.R`) arma su
grilla de cuadros a mano, número por número, y no hay renderizado automático
de todo lo que cargue `LAM`. Un indicador con `datos.csv` y `grafico.R` queda
compilado en el catálogo (capítulo VI, `indicadores.yaml`) pero invisible en su
capítulo temático hasta que el módulo lo referencia explícitamente. Se
descubrió al terminar la primera mitad de este trabajo, cuando el gráfico no
aparecía pese a que la validación decía todo correcto.

### Agregado
- **14 indicadores compilados**, con su `datos.csv` y `grafico.R`, y cableados
  en el módulo de su capítulo:
  - Población: 104 natalidad (I.6), 105 mortalidad general (I.7), 106
    fecundidad (I.8), 108 densidad poblacional (I.9)
  - Economía: 203 número de empresas (II.4), 208 informalidad laboral (II.5)
  - Pobreza e Ingresos: 307 hacinamiento habitacional (III.4), 308 déficit
    habitacional cuantitativo (III.5)
  - Bienestar: 403 asistencia escolar (IV.4), 404 años de escolaridad (IV.5),
    405 matrícula en educación superior (IV.6), 406 titulados en educación
    superior (IV.7)
  - Cohesión Social: 512 homicidios (V.4), 513 mortalidad por suicidios (V.5)
- 14 alias `d_*` nuevos en la sección 4 de `R/00_data.R`, uno por indicador
- Tres fuentes nuevas en `indicadores/fuentes.yaml`: `obs_homicidios`
  (Observatorio de Homicidios), `minvu_ceut` (MINVU — Centro de Estudios de
  Ciudad y Territorio) y `ine_medioambiente` (INE — Informe Anual de Medio
  Ambiente)
- 14 filas nuevas en el inventario de sus respectivos capítulos, y 5 bloques
  de cuadros nuevos en la grilla visual (dos en Población, dos en Bienestar,
  uno en Economía, Pobreza y Cohesión cada uno)

### Cambiado
- **Cuatro `fuente_id` corregidos** en fichas que ya existían documentadas,
  detectados al cotejar la ficha con la ficha técnica real de la fuente:
  - 512 homicidios: apuntaba a `ine_vitales` (INE/DEIS); la fuente real es el
    Observatorio de Homicidios de la Subsecretaría de Prevención del Delito
  - 208 informalidad laboral: apuntaba a `ine_ene`; la fuente específica real
    es la Encuesta CASEN, no la ENE
  - 308 déficit habitacional: apuntaba a `censo`; la fuente real es MINVU. Su
    `nombre`/`definicion` además decían "cualitativo" cuando la base es de
    déficit **cuantitativo**
  - 108 densidad poblacional: apuntaba a `ine_medioambiente` tras un primer
    error de esta misma ronda que lo dejó en `ine_vitales`
- Versión de la edición: `v0.9.0` → `v0.10.0` (`R/10_utils.R`, `.EDICION`)

### Notas
- **Único cálculo hecho sobre un dato**, excepción a la regla de "ninguna
  cifra se transforma en la interfaz": 308 déficit habitacional. La base MINVU
  no traía el porcentaje ya publicado, solo hogares totales y hogares en
  déficit por corte CASEN; se calculó `% = déficit / total hogares × 100` para
  Magallanes en los 13 cortes 1996–2024. Documentado en la ficha. Pendiente de
  confirmar si existe la cifra ya calculada en otra fuente de MINVU
- Quedan pendientes para una próxima ronda: refrescar 9 series ya compiladas
  (101/102, 201, 202, 216, 301, 302, 306, 401, 511) con datos más nuevos que
  también trae la carpeta de Drive; decidir qué hacer con "Migración interna"
  (sin id en el catálogo de 69 fichas); y ~30 indicadores documentados que
  siguen sin datos disponibles en Drive
- `103_tasa_crecimiento` y `110_indice_masculinidad` siguen compilados sin
  `grafico.R` — preexistente a esta ronda, no se tocó

---

## [0.9.0] — La ficha manda
Fecha: 2026-09-17 · commit `05a43a2`

Cada indicador declara su identidad en su propia carpeta. Antes convivían
**cuatro identificadores** para la misma pieza —el nombre de la carpeta, el id
que se extraía de su prefijo con una expresión regular, el campo `ficha` que
cada `grafico.R` declaraba a mano, y el número de cuadro— y **tres registros de
estado** que se contradecían entre sí.

No era un problema cosmético. Un desajuste de identidad no produce un error
visible: produce una cifra correcta publicada con el nombre de otra pieza, y el
catálogo llevaba meses haciéndolo. La carpeta `304_quintiles/` contenía ingreso
autónomo per cápita, que es la ficha **305**. Su lámina declaraba `ficha = 305`
para dibujar bien el cuadro III.3, pero la columna `tiene_datos` se calculaba
con el id de la carpeta. Resultado publicado en Metodología y en la portada: la
ficha **304** —razón de ingresos 20/20— figuraba como compilada sin tener un
solo dato, y la **305** como pendiente mientras se dibujaba a la vista de todos.

La regla ahora es una y no admite excepciones: **una carpeta, un indicador, una
ficha, un id**.

### Agregado
- **`indicadores/{id}_{slug}/ficha.yaml`**, la fuente de verdad de cada
  indicador: define su id y de ella salen el asiento del capítulo VI, el título
  de cada cuadro y la fuente al pie. 69 fichas, una por carpeta
- **46 carpetas nuevas** para las fichas que aún no tienen datos. Una carpeta
  con solo su `ficha.yaml` es válida y el catálogo la publica marcada como
  documentada: la unidad del catálogo es la carpeta, con datos o sin ellos
- **Validación que aborta, no que avisa** (`R/00_data.R`, sección 6). La app se
  detiene al arrancar si el id de una ficha no coincide con el prefijo de su
  carpeta, si dos carpetas declaran el mismo id, o si una carpeta de indicador
  no trae ficha. Detenerse es deliberado: los dos accidentes que motivaron esto
  —el 101 repetido y el 304/305— no dieron error ninguna de las dos veces
- `ficha_de(carpeta)`, que resuelve carpeta → ficha. Unifica tres lookups que
  estaban escritos por separado en `R/00_data.R`, `R/20_graficos.R` y `_dev/ver.R`,
  los tres por id y los tres expuestos al mismo desajuste
- `fuente_id` en cada ficha, que apunta al registro de fuentes. Las 69 lo traen
- Cuatro fuentes que faltaban en `indicadores/fuentes.yaml`: MINEDUC SIGE,
  MINEDUC SIES, la ENUT del INE y la Encuesta Regional UER. De 9 a 13
- Tres bloques opcionales de aparato interno en la ficha —`procesamiento`,
  `notas_calidad` e `historial`—, que no se publican
- `_dev/agregar_fichas.R`, que regenera el agregado. Idempotente
- `indicadores/_plantilla/ficha.yaml`, plantilla comentada

### Cambiado
- **`indicadores/indicadores.yaml` pasa a ser un agregado GENERADO.** La app ya
  no lo lee: se conserva versionado como vista única del catálogo, para leerlo
  de corrido y para que el diff de `git` siga siendo legible. Lleva cabecera de
  archivo generado y se regenera con `Rscript _dev/agregar_fichas.R`
- **`304_quintiles/` se renombra a `305_ingreso_autonomo/`**, y la ficha 304
  recibe su propia carpeta. Las dos quedan por fin correctamente marcadas
- `tiene_datos` se deriva **por carpeta** y ya no por id, que es lo que
  invertía el estado de 304 y 305
- La portadilla de Metodología lee la cuenta del registro. Decía «65 asientos»
  mientras el acordeón que tenía debajo renderizaba 69
- `ind_ficha(df)` resuelve por carpeta: no hay búsqueda que pueda dar con la
  ficha de otro indicador
- `/validate` valida cada `ficha.yaml` por separado —campos, id contra carpeta,
  ids únicos, sección reconocida, `fuente_id` registrado— y comprueba que el
  agregado esté al día generándolo en un temporal, sin escribir en el repositorio

### Eliminado
- **El campo `ficha` de las 21 láminas.** Era el parche de un problema de
  identidad, no una función: mientras existió, una lámina podía colgar de un
  indicador distinto al de su carpeta sin que nada más en el sistema se
  enterara. `R/20_graficos.R` ahora aborta si encuentra uno residual
- **Los 23 `metadata.md`.** No los leía ningún archivo R, 16 de los 23 eran la
  plantilla de relleno sin editar, y 15 citaban `_fuentes/fuentes.yaml#casen`,
  un directorio que no existe. Lo que sí aportaban —historial de separaciones,
  advertencias `PENDIENTE DE VALIDACION`, notas de interpretación— se absorbió
  en los bloques internos de la ficha, donde es legible por máquina
- **El marcador `Estado: Documentado` de la prosa de los comentarios** (42
  fichas). Era el tercer registro del mismo hecho y discrepaba con los otros dos
  en cinco fichas. Deliberadamente **no** se agregó un campo `estado:` a la
  ficha: habría sido un cuarto. El estado se deriva de la presencia de
  `datos.csv` y no puede quedar desactualizado
- Los arrays `indicadores: [...]` de `fuentes.yaml`. Declaraban el vínculo al
  revés, cubrían 40 de 69 fichas y nada los validaba

### Notas
- **Nada de lo que se publica cambió**, salvo lo que estaba mal. Se compararon
  `d_indicadores` y los `$x$opts` de las 21 láminas antes y después: las 21
  idénticas, y en las fichas solo las diferencias esperadas —las columnas nuevas
  `fuente_id` y `carpeta`, el marcador retirado, y `tiene_datos` invertido
  exactamente en 304 y 305
- La migración corrió con `_dev/migrar_fichas.R`, que reparsea las 69 fichas que
  escribe y aborta si algún campo no coincide con el original. Queda archivado
  como registro; el que se reejecuta es `_dev/agregar_fichas.R`
- Los 33 slugs de las carpetas nuevas se decidieron a mano y están fijados en el
  script de migración. La heurística se quedaba con las tres primeras palabras
  del nombre, que no siempre son las que nombran la pieza
- Pendiente, detectado y no abordado: `103_tasa_crecimiento/datos.csv` publica
  una columna `total` que duplica el dato de la ficha 101. Es el mismo patrón ya
  resuelto en 201/215, 205/216, 301/302 y 401/415

---

## [0.8.1] — Peso y arranque
Fecha: 2026-09-16 · commit `effbc97`

Revisión de rendimiento guiada por medición. El arranque de R nunca fue el
problema —las librerías, los datos y las 21 láminas suman menos de medio
segundo— pero la primera carga arrastraba casi 1,1 MB de imágenes y el tema
salía a Internet a buscar la tipografía.

### Cambiado
- **La tipografía la servimos nosotros.** `tema_umag()` solo nombra la familia;
  los `@font-face` viven en `www/fonts/asap.css`, con los tres subsets de Asap
  en `www/fonts/`. Antes `bslib::font_google("Asap")` salía a
  `fonts.googleapis.com` al arrancar: con el caché de `sass` vacío eso costaba
  entre 850 y 1510 ms, y **si Google no respondía el tema no compilaba y la app
  no arrancaba**. Ahora el arranque en frío son 338 ms sin una sola petición
- **Las negritas son reales por primera vez.** `font_google("Asap")` pedía la
  familia a secas y Google devolvía sólo la instancia del peso 400, así que los
  cuatro pesos del diseño —700 en 22 reglas de `styles.css`, más 600, 500 y
  400— los sintetizaba el navegador engordando el trazo. El archivo variable
  cubre el rango `100 900` y los dibuja como los dibujó el tipógrafo
- El emblema de portada pasa a WebP: 548 KB → 145 KB con diferencia invisible
  (RMSE 0,006) y la transparencia intacta. En PNG no había margen: tiene más de
  33.000 colores, ningún `gzip` lo comprime y cuantizarlo degrada el degradado
- `www/logo_uer_color.png` reoptimizado: 38,5 → 19,4 KB, idéntico pixel a pixel

### Eliminado
- `library(plotly)` y `library(DT)` de `app.R`. No se usaban en ninguna parte
  —ni un `plot_ly`, ni un `renderDT`, ni una `datatable`— y como `rsconnect`
  arma el bundle leyendo los `library()`, con ellos se van 14 paquetes que nada
  más necesitaba: ggplot2, data.table, openssl, curl, httr, crosstalk y otros.
  **49 MB que el servidor ya no instala**
- `www/logo_portada.png` (445 KB): el mismo emblema con fondo blanco, sin uso
- `www/logo_portada_transparente.png`: reemplazado por el `.webp`

### Notas
- `www/` baja de 1,07 MB a 336 KB, de los que 92 KB son las tres variantes de la
  fuente. Un lector en español descarga unos 209 KB donde antes bajaba 600
- Se midió y se descartó: precalcular las láminas al arrancar (las 21 cuestan
  44 ms), quitar `ecStat`/`dataTool` (5 KB gzip juntos) y compilar un ECharts
  propio (sólo se usan `e_line` y `e_bar`, pero el completo gzipea a 354 KB, así
  que el ahorro no paga mantener el artefacto)

---

## [0.8.0] — Láminas por indicador
Fecha: 2026-09-16 · commit `449dd97`

Los 16 gráficos vivían dentro de los cinco módulos de sección, de modo que cada
indicador nuevo engordaba un módulo. La ingesta de datos ya era granular —una
carpeta por indicador— y el código de sus gráficos no seguía esa regla.

### Agregado
- `R/20_graficos.R`: barre `indicadores/*/grafico.R` y arma `LAM`, el registro de
  láminas. Es a los gráficos lo que `R/00_data.R` es a los datos, con el mismo
  patrón de barrido y carga única al arrancar
- Un `grafico.R` por carpeta de indicador (21 láminas en 19 archivos), en
  echarts4r plano: el mismo código que estaba en los módulos, movido sin traducir
- `dibujar(lam, df)` como única vía de dibujo desde los módulos
- `indicadores/_plantilla/grafico.R`: plantilla comentada para una lámina nueva
- Firma alternativa `cuadro(lam, contenido)` en `R/30_ui_components.R`: el número, el
  título, la fuente y la nota salen de la lámina
- Cuatro fichas nuevas, para datos que se publicaban sin ella (ver más abajo):
  **113** Población total por comuna, **215** Producto interno bruto regional,
  **216** Tasa de ocupación, **415** Tasa de mortalidad infantil
- Criterios de forma y color documentados en `DESIGN.md` como sección propia

### Cambiado
- **El título y la fuente de cada cuadro los manda la ficha metodológica**, no el
  módulo: la lámina declara de qué pieza cuelga y el cuadro deriva de ahí su
  identidad, para nombrar y citar la pieza igual que el asiento del capítulo VII
- Los cinco módulos de sección bajan de ~840 a ~500 líneas y dejan de crecer con
  el catálogo; quedan en composición del capítulo e interacción, no en gráficos
- Agregar un indicador pasa a ser crear una carpeta con `datos.csv`, `grafico.R`
  y su ficha en el YAML. **Ningún módulo se toca**
- El registro pasa de **65 a 69 piezas** y los cuadros publicados de 16 a 21
- `indicadores/113_poblacion_comunas/` (antes `101_poblacion_comunas`): compartía
  el id 101 con la población total, de modo que dos cuadros distintos colgaban de
  una misma ficha
- `indicadores/201_variacion_pib/` (antes `201_pib_regional`): la ficha 201
  describe la variación anual, no el nivel, que pasa a la pieza 215
- `R/00_data.R`: alias nuevos `d_pobreza_multi`, `d_mortalidad`, `d_ocupacion`,
  `d_variacion_pib`; `d_pib` pasa a leer la carpeta 215
- Capítulo II de tres cuadros a cinco; capítulo III y IV de tres a cuatro
- `.claude/skills/validate/validate.R`: su lista de archivos, escrita a mano, no
  incluía `R/20_graficos.R` y hacía fallar la validación con un error críptico

### Corregido
- **Seis cuadros publicaban datos fuera del catálogo o citando la ficha
  equivocada.** Los módulos lo tapaban escribiendo el título a mano; derivarlo de
  la ficha lo dejó a la vista:
  - El CSV de **301** traía las dos series de pobreza que las fichas numeran por
    separado. Dividido: la pieza **302** deja de figurar como «sin datos»
  - El CSV de **401** traía la mortalidad infantil, que no tenía ficha
  - El CSV de **201** traía el nivel del PIB y su variación, que son dos medidas
  - El CSV de **205** traía ocupación y desempleo; la ficha 205 es solo desempleo
  - La carpeta **304** contiene el dato que describe la ficha **305**; su lámina
    lo declara explícitamente y la discrepancia queda pendiente en el origen
- El cuerpo del cuadro llegaba vacío cuando se llamaba `cuadro(lam, grafico)`: el
  gráfico se enlazaba al formal `titulo` en vez de caer en `...`
- Las láminas no encontraban los formateadores al renderizar: se evaluaban en un
  entorno colgado de `globalenv()`, pero `shiny::runApp()` evalúa `app.R` en un
  entorno propio

### Eliminado
- Los cinco botones de serie (`btn_ambas`, `btn_ocup`, `btn_desemp`,
  `btn_esperanza`, `btn_mortalidad`): eran conmutadores entre indicadores que
  ahora son cuadros propios

### Decisión descartada
- **Declarar las láminas en un `grafico.yaml` con vocabulario propio**
  (`forma: barra`, `color: rampa`). Habría creado una sintaxis paralela a una que
  ya existe, exigiría una guía para leerse y le pondría un peaje de aprendizaje a
  quien ya sabe R. El problema era dónde vive el código, no en qué lenguaje está
  escrito
- **Convertir las láminas interactivas en módulos Shiny anidados.** La eficiencia
  no distinguía entre las alternativas y la claridad favorecía no mezclar dibujo
  con reactividad: la lámina es una función pura y los controles se quedan en el
  módulo del capítulo

### Verificación
- Paridad exacta de las opciones de ECharts contra `ef189cf` en las 15 láminas
  que no cambiaron de contenido, comparadas con `identical()` sobre `$x$opts` y
  `$x$theme`. Las otras 6 cambiaron por la división de cuadros, no por el refactor
- Las 21 láminas renderizan en un entorno como el de `runApp()`; los 21 cuadros
  contienen su `echarts4rOutput`; `/validate` en PASS

### Pendiente declarado
- Las fichas 113, 215, 216 y 415 se redactaron a partir de sus fichas hermanas.
  Sus campos `calculo`, `disponibilidad` y `desagregaciones` están marcados como
  PENDIENTE DE VALIDACIÓN en el `metadata.md` de cada carpeta
- `tiene_datos` se calcula desde el id de la carpeta, así que marca la ficha 304
  con datos y la 305 sin ellos, que es al revés

---

## [0.7.0] — El Catálogo Razonado
Fecha: 2026-09-07 · commits `9306b61`, `ef189cf`

Rediseño completo de la interfaz bajo una metáfora editorial: el dashboard pasa a
leerse como un catálogo razonado, con cubierta, portadillas de capítulo,
inventarios y cuadros numerados que se citan por su dirección.

### Agregado
- `DESIGN.md` y `PRODUCT.md` con las decisiones de diseño del proyecto
- Mobiliario editorial en `R/10_utils.R`: `cubierta()`, `portadilla()`,
  `inventario()`, `fila_inventario()`, `medida_publicada()`, `eje_holgado()`
- Componentes en `R/30_ui_components.R`: `cuadro()` (la lámina numerada),
  `marca_estado()`, `nota_aparato()`, `pliego()`, `grupo_series()`, `boton_serie()`
- Tema único `catalogo` para echarts4r, registrado por JavaScript y aplicado por
  `e_lamina()` en todo gráfico
- Formateadores JS de cifra chilena: `eje_cifra()`, `rotulo_cifra()`,
  `tip_item()`, `tip_eje()`
- Marca de estado del dato distinguida por trama dibujada, no solo por color, para
  ser legible impresa en blanco y negro y con daltonismo

### Cambiado
- `www/styles.css` reescrito por completo (1.242 líneas modificadas)
- Paleta reducida: el violeta institucional queda confinado a la cubierta y las
  seis portadillas; el azul es la única tinta de trabajo del cuerpo
- Cero sombras salvo el anillo de foco, y un solo radio (`--radio: 2px`)
- `.rsconnectignore` renombrado a `.rscignore`

### Eliminado
- **Ninguna cifra se transforma en la interfaz**: se retiró el conmutador de
  referencia y el índice base. La medida de variación es la que publica la propia
  fuente en el CSV; si no la trae, la celda queda vacía
- Las tarjetas KPI, reemplazadas por el inventario de capítulo

---

## [0.6.0] — El registro de indicadores
Fecha: 2026-07-28 a 2026-08-29 · commits `662b86f`, `54c0871`, `e6c31c0`

### Agregado
- **Fichas metodológicas de 10 a 65 indicadores** en `indicadores.yaml`, con
  rangos por dimensión: Población 100-199, Economía 200-299, Pobreza 300-399,
  Bienestar 400-499, Cohesión Social 500-599
- Estructura de carpeta por indicador: `indicadores/{id}_{slug}/` con `datos.csv`
  y `metadata.md` (fuente primaria, procesamiento, notas de calidad, historial)
- Registro `IND` en `R/00_data.R`, indexado por carpeta, construido barriendo el
  directorio: agregar un indicador deja de exigir tocar código
- Estampado de procedencia como atributos del data.frame, recuperables con
  `ind_id()`, `ind_carpeta()` e `ind_ficha()`; sobreviven a `filter`/`mutate`
- Validación cruzada disco ↔ YAML al arrancar, no fatal: avisa de carpetas sin
  datos y de carpetas sin ficha
- `_docs/` con la documentación consolidada del proyecto

### Cambiado
- Datos migrados de cinco archivos Excel a un CSV por indicador
- `indicadores.yaml` y `fuentes.yaml` movidos a `indicadores/`
- La clave única pasa a ser la **carpeta**, no el id, porque el id se repetía en
  las desagregaciones

### Eliminado
- Los cinco archivos Excel de `data/` y la dependencia `readxl`
- `setup_proyecto.r`, script histórico ya sin uso

---

## [0.5.0] — Consolidación documental
Fecha: 2026-07-23 · commits `472996b`, `8df0552`

### Agregado
- Documentación del proyecto e informes de hitos
- Artefactos HTML generados al `.gitignore`

### Corregido
- Tildes en la navegación, por compatibilidad de codificación en Shiny
- Línea duplicada de licencia en la portada
- Encabezado de `app.R` con el nombre y la descripción del proyecto

---

## [0.4.0] — Beta de Datos
Fecha: 2026-03-05

### Agregado
- Cinco archivos Excel organizados por dimensión temática en `data/`
- Función interna `.xl(archivo, hoja)` en `data.R` como atajo de lectura
- Convención de tipos automática basada en formato de celda Excel
- Dependencia `readxl` agregada a `app.R`

### Cambiado
- `R/00_data.R` reescrito: 17 bloques `tibble::tribble()` reemplazados por 17
  llamadas `.xl()` (de ~160 a 55 líneas)
- `d_pob_total` migrado desde `poblacion_historica.csv` a hoja `pob_total`

### Eliminado
- Todos los bloques `tibble::tribble()` de `data.R`
- Dependencia `readr` del núcleo de la app

---

## [0.3.0] — Estructura de Datos
Fecha: 2026-03-05

### Agregado
- `data/poblacion_historica.csv`: serie censal real de la región (1907–2024)
- `data/indicadores.yaml`: fichas técnicas de los 11 indicadores de entonces
- Carga de `d_indicadores` con `yaml::yaml.load()` y UTF-8 explícito

### Corregido
- **Error crítico**: `d_pob_total` era la cadena `"data/poblacion_historica.csv"`
  en vez de un data frame
- `decimal.mark` faltante en tres llamadas a `format()`
- `yaml::read_yaml()` no aplica UTF-8 por defecto; resuelto con
  `readLines(encoding = "UTF-8")` + `yaml::yaml.load()`

---

## [0.2.0] — Diseño Institucional, Calidad Visual y Responsividad
Fecha: 2026-03-04

### Agregado
- Identidad visual UMAG: paleta institucional en `PAL`
- Navbar de dos filas con CSS Grid
- Pestaña Presentación y rediseño de Metodología con acordeón `bslib`
- Pirámide poblacional y gráfico de envejecimiento con eje Y secundario
- KPIs dinámicos calculados en tiempo de carga
- Responsividad móvil: media queries para ≤ 768 px y ≤ 480 px

### Cambiado
- Layout migrado a `bslib::page_navbar` con tema personalizado
- Gráficos `echarts4r` adaptados a la paleta UMAG

---

## [0.1.0] — Prototipo Inicial
Fecha: 2026-03-03

- Cinco módulos temáticos con datos de demostración
- Tarjetas KPI y gráficos `echarts4r` (barras, líneas, torta, treemap)
- Repositorio `git` inicializado

---

## Hoja de ruta

Las denominaciones de `0.5.0` a `0.8.0` se corrigieron en septiembre de 2026 para
reflejar lo que efectivamente se construyó. El plan original anunciaba
«Integración datos», «Implementación Indicadores», «Validación» y
«Documentación»; el desarrollo priorizó la arquitectura de datos y el rediseño
editorial, y la validación con usuarios y la documentación de uso siguen
pendientes.

| Versión | Denominación | Estado | Objetivo principal |
|---|---|---|---|
| 0.1.0 | Prototipo Inicial | ✅ Completado | Estructura y módulos base |
| 0.2.0 | Diseño Institucional y Responsividad | ✅ Completado | Identidad UMAG, UX, móvil |
| 0.3.0 | Estructura de Datos | ✅ Completado | Primer dato real + YAML |
| 0.4.0 | Beta de Datos | ✅ Completado | Arquitectura Excel editable |
| 0.5.0 | Consolidación documental | ✅ Completado | Informes de hito y limpieza |
| 0.6.0 | El registro de indicadores | ✅ Completado | CSV por indicador, 65 fichas |
| 0.7.0 | El Catálogo Razonado | ✅ Completado | Rediseño editorial de la interfaz |
| 0.8.0 | Láminas por indicador | ✅ Completado | El gráfico vive con sus datos |
| 0.9.0 | La ficha manda | ✅ Completado | Una carpeta, un indicador, una ficha, un id |
| 0.10.0 | Ingesta desde Drive | ✅ Completado | 14 indicadores compilados (23 → 37 de 69) |
| 0.11.0 | Descarga de CSV | ✅ Completado | Cada cuadro y cada ficha entregan su CSV |
| 0.12.0 | El Boletín de campo | ✅ Completado | Rediseño visual en la familia del Boletín N.º 2 |
| 0.13.0 | Datos oficiales | 🔲 Pendiente | Compilar las 32 piezas documentadas y validar las de prototipo |
| 0.14.0 | Validación | 🔲 Pendiente | Revisión con usuarios, ajustes UX |
| 0.15.0 | Documentación de uso | 🔲 Pendiente | README y manual de usuario |
| 1.0.0 | Versión operativa | 🔲 Pendiente | Despliegue institucional estable |

### Estado del catálogo al cierre de 0.9.0

| | Piezas |
|---|---|
| Fichas documentadas | 69 |
| Con datos compilados | 23 |
| Publicadas como cuadro | 21 |
| Solo ficha, sin datos | 46 |

Los totales no se movieron respecto de `0.8.0`: `0.9.0` no agregó ni quitó
piezas, ordenó su identidad. Lo que sí cambió es **cuáles** figuran compiladas —
la 304 y la 305 estaban invertidas— y que las 46 sin datos pasaron de ser
entradas de un YAML monolítico a tener cada una su carpeta.

Las dos piezas con datos que no se publican como cuadro son la **103** (tasa de
crecimiento, que alimenta la medida del inventario del capítulo I) y la **110**
(índice de masculinidad, que ningún capítulo grafica todavía).

Todas las series compiladas son **datos de prototipo**, marcados como tales en la
interfaz y pendientes de validación con la fuente primaria.

> Desde `0.9.0` hay un solo criterio de estado: un indicador está compilado si su
> carpeta trae `datos.csv`, que es lo que registra la columna derivada
> `d_indicadores$tiene_datos` y lo que informa `/validate`. Hasta `0.8.1` el
> recuento «Activo / Documentado» del validador respondía a otro: buscaba la
> palabra «documentado» en el comentario de la ficha, y discrepaba en cinco
> piezas.

### Para insertar en Word
Copiar el bloque siguiente, pegarlo en Word y luego: **Insertar → Tabla →
Convertir texto en tabla** → Separador: **Tabulaciones**.

```
Versión	Denominación	Estado	Objetivo principal
0.1.0	Prototipo Inicial	Completado	Estructura y módulos base
0.2.0	Diseño Institucional y Responsividad	Completado	Identidad UMAG, UX, móvil
0.3.0	Estructura de Datos	Completado	Primer dato real + YAML
0.4.0	Beta de Datos	Completado	Arquitectura Excel editable
0.5.0	Consolidación documental	Completado	Informes de hito y limpieza
0.6.0	El registro de indicadores	Completado	CSV por indicador, 65 fichas
0.7.0	El Catálogo Razonado	Completado	Rediseño editorial de la interfaz
0.8.0	Láminas por indicador	Completado	El gráfico vive con sus datos
0.9.0	La ficha manda	Completado	Una carpeta, un indicador, una ficha, un id
0.10.0	Datos oficiales	Pendiente	Compilar las 46 piezas documentadas
0.11.0	Validación	Pendiente	Revisión con usuarios, ajustes UX
0.12.0	Documentación de uso	Pendiente	README y manual de usuario
1.0.0	Versión operativa	Pendiente	Despliegue institucional estable
```

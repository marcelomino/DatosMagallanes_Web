# Datos Magallanes

Plataforma de información sobre bienestar y desarrollo en la Región de Magallanes y
de la Antártica Chilena. Unidad de Estudios Regionales (UER), Universidad de
Magallanes.

**Sitio:** https://datos-magallanes.netlify.app

69 indicadores de población, economía, pobreza, bienestar y cohesión social, cada
uno con su ficha técnica (definición, cálculo, fuente, desagregaciones) y su número
de acceso para citarlo. Parte de las series publicadas son **de prototipo, no cifras
oficiales**, y el sitio lo declara en cada capítulo.

## Cómo funciona

Es un sitio estático **generado con R**. `construir.R` lee el catálogo
(`indicadores/`), dibuja cada lámina con echarts4r y escribe páginas HTML en
`_site/`. No hay servidor: las páginas se abren con doble clic o se sirven desde
cualquier hosting.

Toda variante que el lector puede pedir (rango de años, «Eje desde cero») se dibuja
en R al construir; el navegador solo elige cuál mostrar. Ninguna cifra se calcula
en el navegador.

## Uso

```sh
Rscript construir.R                                  # escribe _site/ (~3 s)
Rscript _dev/probar_sitio.R                          # prueba el sitio en Chrome sin ventana
python3 -m http.server 8080 --directory _site        # verlo en http://127.0.0.1:8080
```

Paquetes de R (CRAN): bslib, htmltools, echarts4r, dplyr, purrr, stringr, tidyr,
yaml, jsonlite, glue, cli, sass, htmlwidgets. Para el taller (`_dev/`): chromote
(prueba), igraph (`red_fuentes.R`) e ImageMagick (`portadillas.R`).

**Publicar:** `git push` a `master`. El hook `.githooks/pre-push` corre
`_dev/publicar.sh`, que construye, prueba y sube `_site/` a Netlify; si la
construcción o la prueba fallan, el push se cancela. Preparación, una vez por
máquina:

```sh
git config core.hooksPath .githooks
npx netlify-cli login
npx netlify-cli link --id <id del sitio>
```

Además, el Action `.github/workflows/publicar.yml` despliega en GitHub Pages en
cada push. Hoy no corre porque la cuenta de GitHub tiene Actions bloqueadas por
facturación.

## Agregar o corregir un indicador

1. Crear `indicadores/{id}_{slug}/` con `ficha.yaml`, `datos.csv` y `grafico.R`
   (copiar `indicadores/_plantilla/`). El id de la ficha debe ser el prefijo de la
   carpeta; si no calza, la construcción se detiene.
2. `Rscript _dev/agregar_fichas.R` (regenera `indicadores/indicadores.yaml`).
3. Si cambia el número de piezas: `Rscript _dev/red_fuentes.R`.
4. Agregar su `pieza_cuadro()` en la página de su capítulo (`R/40_pag_*.R`).
5. `Rscript construir.R && Rscript _dev/probar_sitio.R`, y push.

Las reglas completas del catálogo están en [AGENTS.md](AGENTS.md); el sistema
visual, en [DESIGN.md](DESIGN.md).

## Procedencia

Hasta octubre de 2026 la plataforma era un dashboard Shiny
(`10_Datos_Magallanes_dash`, desplegado en shinyapps.io). Se congeló en el commit
`b5a1843` y su catálogo, su código de láminas y sus componentes se trasladaron
aquí. El historial está en [CHANGELOG.md](CHANGELOG.md).

## Licencia

Código: MIT. Datos y contenidos: CC BY 4.0, con atribución a UER-UMAG. Las
fotografías de portadilla provienen del *Boletín de Estudios Regionales N.º 2* y
llevan su crédito publicado.

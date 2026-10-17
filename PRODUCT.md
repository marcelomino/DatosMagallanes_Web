# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

**Primarios (confirmados por el usuario):**

- **Política pública regional** — autoridades, GORE, SEREMIs y equipos técnicos que necesitan cifras regionales para diagnósticos, planes, cuentas públicas y decisiones de inversión. Consultan buscando un dato concreto y defendible, a menudo bajo presión de tiempo, y necesitan poder citar la fuente.
- **Investigación y academia** — investigadores de la UMAG y de otras instituciones, tesistas y estudiantes que buscan series de datos y metodología citable para trabajos, informes y publicaciones. Su exigencia es de trazabilidad: definición, fuente, cálculo y comparabilidad de la serie.

El equipo UER-UMAG mantiene la plataforma y es también usuario operativo, pero no es la audiencia para la que se diseña.

**Audiencia secundaria, acotada a la portada:** prensa y ciudadanía general. La portada y las cifras destacadas deben ser comprensibles sin formación técnica —lenguaje llano, la cifra acompañada de qué significa— mientras que los cuadros de cada capítulo y la sección de metodología siguen calibrados para los dos perfiles primarios. Donde el conflicto sea real, el capítulo se resuelve a favor del público técnico y la portada a favor del general.

## Product Purpose

Datos Magallanes centraliza los indicadores demográficos, económicos y sociales de la Región de Magallanes y de la Antártica Chilena, hoy dispersos en múltiples fuentes nacionales, y los presenta ya filtrados a la región, documentados y comparables en el tiempo.

El éxito se mide por la capacidad de un usuario de encontrar el indicador que necesita, entender exactamente qué mide y de dónde viene, y usarlo en un documento propio sin tener que reconstruir el dato desde la fuente original.

## Positioning

Lo que un portal nacional no puede replicar sin dejar de ser nacional:

1. **Todo Magallanes en un solo lugar** — integra en un panel indicadores que hoy exigen recorrer INE, MIDESO, Banco Central, SERVEL, MINSAL, MINEDUC y SII por separado, ya recortados a la escala regional y comunal.
2. **Trazabilidad metodológica** — cada indicador lleva ficha técnica con definición, unidad, cálculo, fuente, desagregaciones, disponibilidad y notas: el dato es auditable y citable, no solo visible.
3. **Series históricas comparables** — reconstruye y armoniza series largas (censos desde 1907, rondas CASEN) que las fuentes originales publican de forma discontinua o con criterios cambiantes.

La plataforma **no** se posiciona como espacio de interpretación editorial de la UER: entrega el dato documentado, no la lectura política del dato.

## Operating Context

- Uso de escritorio en oficinas públicas y universitarias es el escenario dominante; la consulta móvil ocurre pero no es el caso principal.
- El resultado del uso suele salir de la plataforma hacia otro documento: un informe, una presentación, una minuta o una tesis. La cifra y su fuente deben poder trasladarse.
- Publicación y actualización a cargo de la UER-UMAG. El ciclo de datos depende de la periodicidad de las fuentes oficiales: bienal (CASEN), decenal (Censo), anual (Cuentas Nacionales, Estadísticas Vitales), trimestral (ENE).
- Las fuentes oficiales están registradas en `indicadores/fuentes.yaml` (13 fuentes: CASEN, Censo, Proyecciones INE, Estadísticas Vitales, ENE, Banco Central, SII, y las restantes ahí documentadas).

## Capabilities and Constraints

**Estructura del producto** — ocho secciones, una página cada una: Presentación, Población, Economía, Pobreza e Ingresos, Bienestar, Cohesión Social, Metodología y Fuentes. La sección Metodología expone las fichas técnicas con filtro por dimensión y búsqueda por indicador.

**Restricciones durables confirmadas:**

- **Stack fijo (desde el 17-10-2026):** sitio estático generado con R (bslib + htmltools + echarts4r); datos en CSV + YAML. `Rscript construir.R` escribe `_site/` y GitHub Pages lo publica en cada push a `master`. Reemplaza al dashboard Shiny (shinyapps.io), que queda congelado: la plataforma es solo diseminación y ninguna interacción necesita un servidor.
- **Identidad visual UMAG obligatoria:** paleta institucional (azul Pantone 2728C `#4A5CAB`, morado Pantone 268C `#593D80`), tipografía Asap, logos UER/UMAG. Los colores se consumen siempre desde `PAL` en `R/10_utils.R`, nunca hardcodeados.
- **Familia editorial del Boletín de Estudios Regionales N.º 2 (confirmado por el usuario, 27-09-2026):** la plataforma adopta el magenta de imprenta del Boletín (`#E82D88`), sus fotos bañadas por capítulo con crédito visible, y el registro técnico-patagónico de la presentación de brechas sociolaborales (curvas de nivel, horizonte del Paine, coordenadas). Modo claro. JetBrains Mono se admite como segunda familia solo para identificadores y medidas.

**Restricciones técnicas heredadas del stack:**

- Todo el estilo pasa por el tema `bslib` (`tema_umag()`) y `www/styles.css`; no hay build de front-end, HMR ni bundler.
- Los textos de UI heredados del dashboard van sin tildes (la restricción venía de Shiny).
- Formato numérico chileno: punto para miles, coma para decimales.

**Terminología:** el proyecto habla de *dimensiones* (las 5 áreas temáticas), *indicadores* (unidad numerada con ficha propia, IDs por rango: Población 100-199, Economía 200-299, Pobreza 300-399, Bienestar 400-499, Cohesión 500-599) y *fichas metodológicas* (la entrada YAML de cada indicador).

**Estado declarado del producto:** versión v0.5.0 "Beta de Datos". Se declarará 1.0.0 al alcanzar datos oficiales verificados en producción.

**Sin decidir:** no se ha establecido un estándar de accesibilidad exigible ni una política de descarga/exportación de datos por parte del usuario final.

## Brand Commitments

- Nombre: **Datos Magallanes**. Subtítulo institucional en uso: "Plataforma de informacion sobre bienestar y desarrollo en la Region de Magallanes".
- Titularidad: Unidad de Estudios Regionales (UER), Universidad de Magallanes, Punta Arenas. Vinculada a la Vicerrectoría de Vinculación con el Medio.
- Assets existentes en `www/`: `logo_portada_transparente.webp` (emblema de portada),
  `logo_uer_color.png` (sello en la barra de marca y el colofon), `logo_uer_blanco.png`
  (version para fondos oscuros, sin uso desde el rediseño claro), `img/` con las fotos
  del Boletín N.º 2 bañadas por capítulo (ver `.PORTADILLAS` y `_dev/portadillas.R`), y `fonts/` con Asap variable y JetBrains Mono variable (solo identificadores y medidas) servidas
  por nosotros.
- Idioma: español en todo el producto y el código.
- Licencia dual declarada: código MIT, datos y contenidos CC BY 4.0 con atribución a UER-UMAG.

## Evidence on Hand

**Real y disponible:**

- 69 fichas metodológicas, una por carpeta en `indicadores/{id}_{slug}/ficha.yaml`. `indicadores/indicadores.yaml` es la vista agregada, generada desde ellas.
- 23 indicadores con datos cargados en `indicadores/{id}_{slug}/datos.csv`. Los `metadata.md` se absorbieron en la ficha de cada carpeta.
- Registro de 13 fuentes oficiales en `indicadores/fuentes.yaml`, con URL institucional. Cada ficha apunta a la suya con `fuente_id`.
- Serie censal de población regional 1907–2024 (INE).
- `CHANGELOG.md`. La documentación interna (`_docs/`: plan de indicadores, informe de implementación, referencias de fuentes, documento ejecutivo) quedó en el dashboard congelado y no se publica en este repositorio público.

**Ausencias que el trabajo futuro no debe rellenar inventando:**

- Cerca de 46 indicadores tienen ficha pero **no** tienen datos compilados; están en estado "Documentado". Los datos los provee el usuario, no se estiman ni se completan.
- Parte de los datos actualmente visibles son de prototipo. El pie de portada lo declara ("Datos de ejemplo ilustrativos"); no presentar cifras de prototipo como oficiales ni retirar esa advertencia mientras siga siendo cierta.
- No existen testimonios, casos de uso documentados, métricas de audiencia, convenios ni respaldos institucionales publicables. No fabricarlos.

## Product Principles

1. **La región es el recorte, no un filtro.** Todo lo que se muestra ya está resuelto a escala Magallanes o comunal; el usuario no debería tener que recortar nada.
2. **Ningún dato sin procedencia.** Cifra, fuente, cálculo y período viajan juntos en la interfaz; un número que no se puede rastrear no se publica.
3. **La comparabilidad se declara, no se asume.** Los quiebres de serie, cambios metodológicos y años faltantes se hacen visibles en lugar de suavizarse.
4. **El dato debe poder salir de aquí.** La plataforma es un paso intermedio hacia un informe ajeno: leer, entender y citar debe ser trivial.
5. **Rigor antes que cobertura.** Es preferible un indicador menos que un indicador sin ficha, sin fuente o con datos de relleno.

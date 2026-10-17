#!/usr/bin/env bash
# ═════════════════════════════════════════════════════════════════════════════
# _dev/publicar.sh — Construir, probar y publicar el sitio en Netlify
#
#   _dev/publicar.sh            publica lo que esta en el ultimo commit
#
# Lo corre tambien el hook .githooks/pre-push en cada push a master, asi que en
# la practica basta con `git push`.
#
# QUE HACE, EN ORDEN (si un paso falla, no sigue)
#   1. Exige que no haya cambios sin confirmar: lo que se publica tiene que ser
#      exactamente lo que queda en el repositorio.
#   2. Rscript construir.R          escribe _site/
#   3. Rscript _dev/probar_sitio.R  enlaces, laminas, errores de JS, controles
#   4. netlify deploy --prod        sube _site/ al sitio enlazado
#
# PREPARACION, UNA VEZ POR MAQUINA
#   R con los paquetes de construir.R, chromote y Chrome (para la prueba), Node,
#   y la sesion de Netlify:
#     npx netlify-cli login
#     npx netlify-cli link --id <id del sitio>   (el id esta en .netlify/state.json
#                                                 de la maquina que lo creo, o en
#                                                 Netlify > Site configuration)
#
# POR QUE NETLIFY Y NO SOLO EL ACTION
#   El Action de GitHub (.github/workflows/publicar.yml) publica en GitHub Pages,
#   pero mientras la cuenta de GitHub tenga Actions bloqueadas no corre. Este
#   script no depende de GitHub: construye aqui y sube directo a Netlify.
# ═════════════════════════════════════════════════════════════════════════════
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# netlify-cli fijado en su version mayor: una version nueva no cambia el
# comportamiento sin que nadie lo decida.
NETLIFY="npx --yes netlify-cli@27"

paso() { printf '\n\033[1m── %s\033[0m\n' "$1"; }
fallo() { printf '\n\033[31m✖ %s\033[0m\n' "$1" >&2; exit 1; }

paso "1/4 Arbol de trabajo"
if ! git diff --quiet HEAD -- || [ -n "$(git ls-files --others --exclude-standard)" ]; then
  git status --short
  fallo "Hay cambios sin confirmar: se publicaria algo que no esta en el repositorio. Haz commit (o stash) y vuelve a intentar."
fi
[ -f .netlify/state.json ] || fallo "Este directorio no esta enlazado a un sitio de Netlify. Corre: npx netlify-cli link --id <id del sitio>"
echo "Limpio. Se publica $(git rev-parse --short HEAD)."

paso "2/4 Construir"
Rscript construir.R

paso "3/4 Probar"
Rscript _dev/probar_sitio.R || fallo "La prueba fallo: no se publica."

paso "4/4 Publicar en Netlify"
$NETLIFY deploy --prod --dir=_site \
  --message "$(git log -1 --format='%h %s')"

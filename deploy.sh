#!/usr/bin/env bash
set -e

# 1) Guarda tu trabajo en master (cambia a "main" si tu rama principal es main)
git add .
git commit -m "chore: actualiza contenidos" || true   # no falla si no hay cambios
git push origin master

# 2) Publica a GitHub Pages (gh-pages)
mkdocs gh-deploy --clean

echo
echo "✅ Listo. Revisa: https://pedrosegarra.github.io/DAW/ (haz Ctrl+Shift+R para refrescar sin caché)"

#!/usr/bin/env bash
# Manual flow: create the repo via the GitHub web UI first
# (https://github.com/new — give it the same name, NO README/gitignore),
# then run this from the project folder.

set -euo pipefail

REPO_URL=${1:?"Usage: $0 git@github.com:USERNAME/BrightonRestaurantsMap.git"}

[ -d .git ] && rm -rf .git
command -v quarto >/dev/null && quarto render

git init -b main
git add -A
git commit -m "Initial BRAVO 2026 map"
git remote add origin "$REPO_URL"
git push -u origin main

echo
echo "Now: GitHub → Settings → Pages → Source: 'Deploy from a branch' → main · /docs"

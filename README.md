---
title: "Brighton Restaurant Awards (BRAVO) 2026 — Interactive Map"
description: "Interactive map of all BRAVO Award Category winners and rankings, 2026"
site: index.html   # path under the Pages root — use this when there's no working index.html
image: https://github.com/adamdennett/BrightonRestaurantsMap/blob/main/images/bravo2026.png            # relative path in the repo, or a full URL
---

# Brighton Restaurant Awards (BRAVO) 2026 — Interactive Map

Interactive Leaflet map of every BRAVO 2026 winner across all 18 categories,
with category-icon markers, Spectral-coloured rank circles, and dropdown filters
for category, rank range, and venue.

Live site: <https://YOUR-GITHUB-USERNAME.github.io/BrightonRestaurantsMap/>

## Files

- `02_map.qmd` — the Quarto document. Renders straight from the CSVs to `docs/index.html`.
- `bravo_2026_winners.csv` — long-form, one row per venue × category × rank (360 rows).
- `bravo_2026_venues.csv` — one row per unique venue (192 after dedupe). 172 already geocoded via venue-page postcodes + ONSPD lookup.
- `01_geocode.R` — optional: rebuilds geocodes via ONSPD (and `tidygeocoder` fallback if you uncomment it).
- `_quarto.yml` — project config; outputs to `docs/`.
- `docs/` — what GitHub Pages serves.

The `ONSPD_FEB_2024_UK.zip` and `onspd_csv/` are gitignored (the zip is ~230 MB and not needed at runtime — only by `01_geocode.R`).

## Render locally

```bash
quarto render            # writes docs/index.html
```

(Or just `quarto render 02_map.qmd` — the YAML does the rest.)

## Publish to GitHub Pages

One-off setup (run from this folder):

```bash
git init
git add .
git commit -m "Initial BRAVO 2026 map"
git branch -M main
git remote add origin git@github.com:YOUR-USERNAME/BrightonRestaurantsMap.git
git push -u origin main
```

Then on GitHub: **Settings → Pages → Build and deployment**

- **Source**: Deploy from a branch
- **Branch**: `main` · **Folder**: `/docs`
- Save. The site appears at `https://YOUR-USERNAME.github.io/BrightonRestaurantsMap/` after a minute or two.

## Update workflow

```bash
quarto render            # regenerate docs/index.html
git add docs/
git commit -m "Update map"
git push
```

GitHub Pages picks up the new build automatically.

## Categories captured

Best Brighton Restaurant, Best Sussex Restaurant, Best Brunch, Plant Champions, Best Cocktails, Best Brighton Pub, Family Friendly, Best Team, Best Sussex Pub, Best Cafe, Best Lunch, Best Sunday Roast, Best Wine List, Best International Cuisine, Sustainability Champions, Best Value, Best Takeaway, Sweets and Treats.

## Source

All data scraped from <https://restaurantsbrighton.co.uk/> on 2026-05-07.

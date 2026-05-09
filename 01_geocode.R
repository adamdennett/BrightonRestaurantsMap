# 01_geocode.R
# Refine BRAVO venue geocoding using ONS Postcode Directory (ONSPD)
# and fall back to Nominatim via tidygeocoder for venues we still lack coords for.

library(readr)
library(dplyr)
library(stringr)

venues <- read_csv("bravo_2026_venues.csv", show_col_types = FALSE)
message("Venues loaded: ", nrow(venues))
message("Already geocoded: ", sum(!is.na(venues$lat) & venues$lat != ""))

# ----- Load ONSPD postcode lookup (BN/TN/RH/PO areas) -----
# Unzip the ONSPD bundle once. Adjust paths if needed.
onspd_zip <- "ONSPD_FEB_2024_UK.zip"
onspd_dir <- "onspd_csv"
if (!dir.exists(onspd_dir)) {
  dir.create(onspd_dir)
  for (area in c("BN", "TN", "RH", "PO")) {
    f <- sprintf("Data/multi_csv/ONSPD_FEB_2024_UK_%s.csv", area)
    unzip(onspd_zip, files = f, exdir = onspd_dir, junkpaths = TRUE)
  }
}

onspd_files <- list.files(onspd_dir, pattern = "^ONSPD_.*\\.csv$", full.names = TRUE)
onspd <- onspd_files |>
  lapply(function(p) read_csv(p, col_types = cols(pcds = "c", lat = "d", long = "d", .default = "c"))) |>
  bind_rows() |>
  filter(lat != 99.999999) |>     # 99.999999 is the ONSPD "unknown" marker
  select(postcode = pcds, lat_pc = lat, lon_pc = long)

message("ONSPD postcode rows loaded: ", nrow(onspd))

# ----- Refine geocodes using ONSPD where we already have postcode -----
venues <- venues |>
  mutate(postcode = str_trim(postcode)) |>
  left_join(onspd, by = "postcode") |>
  mutate(
    lat = ifelse(!is.na(lat_pc) & is.finite(lat_pc), as.character(lat_pc), as.character(lat)),
    lon = ifelse(!is.na(lon_pc) & is.finite(lon_pc), as.character(lon_pc), as.character(lon)),
    geocode_source = ifelse(!is.na(lat_pc), "ONSPD (postcode lookup)", geocode_source)
  ) |>
  select(-lat_pc, -lon_pc)

# ----- Optional: fall back to Nominatim for venues without coords -----
# Uncomment to run. Respects 1 req/sec.
# library(tidygeocoder)
# missing <- venues |> filter(is.na(lat) | lat == "")
# message("Geocoding ", nrow(missing), " missing venues via Nominatim …")
# bbox_uk <- function(query) {
#   # Bias to Sussex / Brighton & Hove
#   paste0(query, ", Brighton, UK")
# }
# nm <- missing |>
#   mutate(query = bbox_uk(name)) |>
#   geocode(address = query, method = "osm", limit = 1, full_results = TRUE) |>
#   select(name, lat_nm = lat, lon_nm = long, addr_nm = address)
# venues <- venues |>
#   left_join(nm, by = "name") |>
#   mutate(
#     lat = ifelse((is.na(lat) | lat == "") & !is.na(lat_nm), as.character(lat_nm), lat),
#     lon = ifelse((is.na(lon) | lon == "") & !is.na(lon_nm), as.character(lon_nm), lon),
#     geocode_source = ifelse((is.na(geocode_source) | geocode_source == "") & !is.na(lat_nm),
#                              "Nominatim (tidygeocoder)", geocode_source)
#   ) |>
#   select(-lat_nm, -lon_nm, -addr_nm)

# ----- Save outputs -----
venues_out <- venues |>
  mutate(
    lat = as.numeric(lat),
    lon = as.numeric(lon)
  )

write_csv(venues_out, "bravo_2026_venues_geocoded.csv")
saveRDS(venues_out, "bravo_2026_venues_geocoded.rds")

# Long-form winners with coords joined
winners <- read_csv("bravo_2026_winners.csv", show_col_types = FALSE) |>
  left_join(
    venues_out |> select(venue_idx, postcode, lat, lon, geocode_source),
    by = "venue_idx"
  )

write_csv(winners, "bravo_2026_winners_geocoded.csv")
saveRDS(winners, "bravo_2026_winners_geocoded.rds")

message("\nGeocoding summary:")
message("  Geocoded: ", sum(!is.na(venues_out$lat)), "/", nrow(venues_out))
message("  Missing : ", sum(is.na(venues_out$lat)))

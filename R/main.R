# library(forestables)
library(readr)
library(sf)
source("R/plot_tree_data.R")
load("data-raw/ifn4_cat.Rdata")
ifn3_cat <- rbind(readRDS("data-raw/ifn3_08.rds"),
                  readRDS("data-raw/ifn3_17.rds"),
                  readRDS("data-raw/ifn3_25.rds"),
                  readRDS("data-raw/ifn3_43.rds"))

plots_ph <- readr::read_csv("data-raw/pinhal_objectiu.csv") |> 
  dplyr::rename(id_unique_code = id_unique_) |> 
  sf::st_as_sf(coords = c("coordx", "coordy"), crs = 23031)  # Asegúrate de que ya esté en ED50 (EPSG:23031)


# Leer el shapefile (suponiendo que es un shapefile de líneas, puntos, etc.)
municipis <- sf::st_read("data-raw/PoliticalBoundaries/Products/Catalunya/divisions-administratives-v2r1-municipis-5000-20230928.shp")

# Ver el CRS del shapefile

municipis_transformed <- sf::st_transform(municipis, crs = 23031)
 
plots_ph <- sf::st_join(plots_ph, municipis_transformed |> 
                        dplyr::select(NOMMUNI,NOMCOMAR), join = st_intersects)

# Extraer las coordenadas en ED50 (EPSG:23031) y guardarlas
plots_ph <- plots_ph |>
  dplyr::mutate(
    coordx_ed50 = sf::st_coordinates(plots_ph)[,1],  # Extrae la coordenada X (longitud en ED50)
    coordy_ed50 = sf::st_coordinates(plots_ph)[,2]   # Extrae la coordenada Y (latitud en ED50)
  )

# Transformar a WGS84 (EPSG:4326)
plots_ph_wgs <- sf::st_transform(plots_ph, crs = "EPSG:4326")

# Extraer las coordenadas en WGS84 (EPSG:4326)
plots_ph_wgs <- plots_ph_wgs |>
  dplyr::mutate(
    lon_wgs84 = sf::st_coordinates(plots_ph_wgs)[,1],  # Extrae la longitud en WGS84
    lat_wgs84 = sf::st_coordinates(plots_ph_wgs)[,2]   # Extrae la latitud en WGS84
  )


# save(plots_ph_wgs, file = "data-raw/plots_ph_wgs.RData")

regDataIFN4_Catalunya <- readr::read_delim(
  "data-raw/IFN4/regDataIFN4_Catalunya.csv", 
  delim = "\t", escape_double = FALSE, 
  trim_ws = TRUE) 

IDs <- plots_ph$id_unique_code

for(id in IDs[1])  {
  output_dir <- file.path("forms", id)
  if(!dir.exists(output_dir)) dir.create(output_dir)
  rmarkdown::render(input = "Rmd/_child_map.Rmd",output_file = file.path("..", output_dir, "plot_location.html"))
  # Convierte el HTML generado a PDF
  pagedown::chrome_print(paste0("forms/", id, "/plot_location.html"))
}

for(id in IDs)  {
  output_dir <- file.path("forms", id)
  if(!dir.exists(output_dir)) dir.create(output_dir)
  rmarkdown::render(input = "Rmd/tree_table.Rmd",output_file = file.path("..", output_dir, "tree_table.html"))
  # Convierte el HTML generado a PDF
  pagedown::chrome_print(paste0("forms/", id, "/tree_table.html"))
}

for(id in IDs[1:3])  {
  output_dir <- file.path("forms", id)
  if(!dir.exists(output_dir)) dir.create(output_dir)
  rmarkdown::render(input = "Rmd/regen_table.Rmd",output_file = file.path("..", output_dir, "regen_table.html"))
  # Convierte el HTML generado a PDF
  pagedown::chrome_print(paste0("forms/", id, "/regen_table.html"))
}


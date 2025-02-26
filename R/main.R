library(forestables)
library(readr)

source("R/plot_tree_data.R")
load("data-raw/ifn4_cat.Rdata")
ifn3_cat <- rbind(readRDS("data-raw/ifn3_08.rds"),
                  readRDS("data-raw/ifn3_17.rds"),
                  readRDS("data-raw/ifn3_25.rds"),
                  readRDS("data-raw/ifn3_43.rds"))

plots_ph <- readr::read_csv("data-raw/pinhal_objectiu.csv") |> 
  dplyr::rename(id_unique_code = id_unique_) |> 
  sf::st_as_sf(
    crs ="23031" 
  )


plots_ph <- readr::read_csv("data-raw/pinhal_objectiu.csv") |> 
  dplyr::rename(id_unique_code = id_unique_) |> 
  sf::st_as_sf(coords = c("coordx", "coordy"), crs = 23031)  # Asegúrate de que ya esté en ED50 (EPSG:23031)

# Transformar a WGS84 (EPSG:4326)
plots_ph_wgs <- sf::st_transform(plots_ph, crs = "EPSG:4326")

# Extraer las coordenadas como columnas separadas en el data frame original
plots_ph_wgs <- plots_ph_wgs |> 
  dplyr::mutate(
    lon = sf::st_coordinates(plots_ph_wgs)[,1],  # Extrae la longitud
    lat = sf::st_coordinates(plots_ph_wgs)[,2]   # Extrae la latitud
  )

# save(plots_ph_wgs, file = "data-raw/plots_ph_wgs.RData")


IDs <- plots_ph$id_unique_code

for(id in IDs)  {
  output_dir <- file.path("forms", id)
  if(!dir.exists(output_dir)) dir.create(output_dir)
  rmarkdown::render(input = "Rmd/_child_map.Rmd",output_file = file.path("..", output_dir, "plot_location.html"))
  # Convierte el HTML generado a PDF
  pagedown::chrome_print(paste0("forms/", id, "/plot_location.html"))
}




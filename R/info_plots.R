library(dplyr)
library(readxl)
load("data-raw/ifn4_cat.Rdata")

ifn3_cat <- rbind(readRDS("data-raw/ifn3_08.rds"),
                  readRDS("data-raw/ifn3_17.rds"),
                  readRDS("data-raw/ifn3_25.rds"),
                  readRDS("data-raw/ifn3_43.rds"))


parceles_camp <- readr::read_delim(
  "data-raw/coords_obj_control_pinhal.csv", 
  delim = ";", escape_double = FALSE,
  trim_ws = TRUE) 
# parceles_camp <- parceles_camp[-c(38, 40,42), ]


  
  plots_ph<-plots_cat |> 
    dplyr::filter(id_unique_code %in% parceles_camp$id_unique_code ) |> 
    dplyr::select(id_unique_code, coordx, coordy) |> 
    sf::st_as_sf(coords = c("coordx", "coordy"), crs = 25831  ) |> # Asegúrate de que ya esté en ED50 (EPSG:23031)
  dplyr::mutate(
    Provincia = stringr::str_extract(id_unique_code, "^[^_]{2}"), # Primeros 2 caracteres antes de "_"
    Estadillo = stringr::str_extract(id_unique_code, "_\\d{4}_") |> 
      stringr::str_replace_all("_", ""), # 4 dígitos entre "_"
    IDCLASE  = stringr::str_extract(id_unique_code, "_[^_]+$") |> 
      stringr::str_replace_all("_", "") # Últimos caracteres después de "_"
  )


# Leer el shapefile (suponiendo que es un shapefile de líneas, puntos, etc.)
municipis <- sf::st_read("data-raw/divisions-administratives/divisions-administratives-v2r1-municipis-5000-20230928.shp")
municipis_transformed <- sf::st_transform(municipis, crs = 25831  )


plots_ph <- sf::st_join(plots_ph, municipis_transformed |> 
                          dplyr::select(NOMMUNI,NOMCOMAR), join = sf::st_intersects)

ENP<- sf::st_read("data-raw/enp-shp/Enp2023_P.shp") |> 
  dplyr::filter(NUT2== "51")
ENP <- sf::st_transform(ENP, crs = 25831)


  
# plots_ph<- sf::st_join( plots_ph,ENP |> 
#                 dplyr::select(SITE_NAME,ODESIGNATE), join = sf::st_intersects) 
# 

# Extraer las coordenadas en ED50 (EPSG:23031) y guardarlas
plots_ph <- plots_ph |>
  dplyr::mutate(
    coordx_etrs89 = sf::st_coordinates(plots_ph)[,1],  # Extrae la coordenada X (longitud en etrs89 )
    coordy_etrs89 = sf::st_coordinates(plots_ph)[,2]   # Extrae la coordenada Y (latitud en etrs89 )
  )


#TOPO

altitud<-terra::rast("data-raw/Catalunya_elevation_30m.tif")
aspect<- terra::rast("data-raw/Catalunya_aspect_30m.tif")
slope<- terra::rast("data-raw/Catalunya_slope_30m.tif")


crs_raster <- terra::crs(altitud)   # Obtener CRS del raster
crs_puntos <- sf::st_crs(plots_ph)  # Obtener CRS de los puntos

# Comparar CRS
if (crs_raster != crs_puntos) {
  print("Los CRS son diferentes. Transformando los puntos al CRS del raster...")
  puntos <- sf::st_transform(plots_ph, crs_raster)  
} else {
  print("Los CRS son iguales. No es necesario transformar.")
}
puntos_vect <- as(plots_ph$geometry, "SpatVector")

# Extraer los valores del raster en las ubicaciones de los puntos

valores_altitud <- raster::extract(altitud, puntos_vect)
valores_aspect <- raster::extract(aspect, puntos_vect)
valores_slope <- raster::extract(slope, puntos_vect)

plots_ph$altitud <- valores_altitud[, 2]

plots_ph$aspect <- valores_aspect[, 2]
 plots_ph$slope<-valores_slope[, 2]

 
 # Transformar a WGS84 (EPSG:4326)
 plots_ph_wgs <- sf::st_transform(plots_ph, crs = "EPSG:4326")
 
# Extraer las coordenadas en WGS84 (EPSG:4326)
plots_ph_wgs <- plots_ph_wgs |>
  dplyr::mutate(
    lon_wgs84 = sf::st_coordinates(plots_ph_wgs)[,1],  # Extrae la longitud en WGS84
    lat_wgs84 = sf::st_coordinates(plots_ph_wgs)[,2]   # Extrae la latitud en WGS84
  )





treeDataIFN4_Catalunya <- readr::read_delim("data-raw/treeDataIFN4_Catalunya.csv", 
                                            delim = "\t", escape_double = FALSE, 
                                            trim_ws = TRUE)
shrubDataIFN4_Catalunya <- readr::read_delim("data-raw/shrubDataIFN4_Catalunya.csv", 
                                             delim = "\t", escape_double = FALSE, 
                                             trim_ws = TRUE)
plotDataIFN4_Catalunya <- readr::read_delim("data-raw/plotDataIFN4_Catalunya.csv", 
                                            delim = "\t", escape_double = FALSE, 
                                            trim_ws = TRUE)
regDataIFN4_Catalunya <- readr::read_delim("data-raw/regDataIFN4_Catalunya.csv", 
                                           delim = "\t", escape_double = FALSE, 
                                           trim_ws = TRUE)


plots_ph_wgs_All <- plots_ph_wgs |> 
  tibble::tibble() |> 
  dplyr::left_join(plotDataIFN4_Catalunya |> 
                     dplyr::select(
                       IDCLASE,Provincia,Estadillo,
                       Rocosid, FccArb,Orienta1, MaxPend1,
                       Localiza, Acceso,Levanta, Obser
                     ), by = c("Provincia", "Estadillo", "IDCLASE")) |> 
  dplyr::mutate(Orienta1 = Orienta1 * 9 / 10,
                Localiza = dplyr::case_when(
                  Localiza == 1 ~ "Facil",
                  Localiza == 2 ~ "Medio",
                  Localiza == 3 ~ "Dificil"
                ),
                Acceso = dplyr::case_when(
                  Acceso == 1 ~ "Facil",
                  Acceso == 2 ~ "Medio",
                  Acceso == 3 ~ "Dificil"
                ),
                Levanta = dplyr::case_when(
                  Levanta == 1 ~ "Facil",
                  Levanta == 2 ~ "Medio",
                  Levanta == 3 ~ "Dificil"
                )
  ) |> 
  # Unir regDataIFN4_Catalunya y agrupar en un sub-data frame
  dplyr::left_join(regDataIFN4_Catalunya |> 
                     dplyr::select(Provincia, IDCLASE, Estadillo, Especie, CatDes, Densidad, NumPies, Hm), 
                   by = c("Provincia", "Estadillo", "IDCLASE")) |>
  tidyr::nest(reg_data = c(Especie, CatDes, Densidad, NumPies, Hm)) |>  # Agrupar en reg_data
  
  # Unir shrubDataIFN4_Catalunya y agrupar en un sub-data frame
  dplyr::left_join(shrubDataIFN4_Catalunya |> 
                     dplyr::select(IDCLASE, Provincia, Estadillo, Especie, Fcc, Hm, Agente), 
                   by = c("Provincia", "Estadillo", "IDCLASE")) |>
  tidyr::nest(shrub_data = c(Especie, Fcc, Hm, Agente)) |>  # Agrupar en shrub_data
  
  # Unir treeDataIFN4_Catalunya y agrupar en un sub-data frame
  dplyr::left_join(treeDataIFN4_Catalunya |> 
                     dplyr::select(IDCLASE, Provincia, Estadillo, Especie, 
                                   OrdenIf3, OrdenIf4, Dn1, Dn2, Ht, Agente), 
                   by = c("Provincia", "Estadillo", "IDCLASE")) |>
  tidyr::nest(tree_data = c(Especie, OrdenIf3, OrdenIf4, Dn1, Dn2, Ht, Agente)) 


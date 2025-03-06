
library(jsonlite)
library(sf)
library(ggplot2)
library(leaflet)
json_data <- jsonlite::fromJSON("data-raw/arboles_ifn3.json")
 json_data <- jsonlite::fromJSON("data-raw/parcelas_ifn3.json")


# Extraer la tabla de features
features <- json_data$features

# Extraer propiedades (datos de los árboles)
trees_data <- features$properties
plot_data <- features$properties
# Extraer coordenadas (algunas pueden ser NA)
coordinates <- do.call(rbind, features$geometry$coordinates)
colnames(coordinates) <- c("longitude", "latitude")

# Unir los datos
trees_sf <- cbind(trees_data, coordinates) %>%
  dplyr::filter(!is.na(latitude)) %>%  # Eliminar puntos sin coordenadas
  sf::st_as_sf(coords = c("longitude", "latitude"), crs = 4326)  # Convertir a objeto espacial
ggplot() +
  geom_sf(data = trees_sf, aes(color = scientificName), size = 3) +
  theme_minimal() +
  labs(title = "Distribución de árboles",
       subtitle = "Datos del IFN3 en Barcelona",
       color = "Especie")


# Crear el mapa
map <- leaflet::leaflet(trees_sf) |> 
  addTiles() %>%  # Mapa base por defecto
  addWMSTiles(
    baseUrl = "https://geoserveis.icgc.cat/servei/catalunya/orto-territorial/wms",
    layers = "ortofoto_color_2000-2003",
    options = WMSTileOptions(format = "image/jpeg", transparent = TRUE),
    attribution = "Institut Cartogràfic i Geològic de Catalunya"
  ) %>%
  leaflet::addCircleMarkers(
    radius = 5,
    color = "red",
    popup = ~paste("Especie:", scientificName,
                   "<br>Altura (m):", heightM,
                   "<br>Diámetro (mm):", dbh1mm)
  )

# Mostrar el mapa
map

# Instalar y cargar librerías necesarias
# install.packages("rgee")  # Si no lo tienes instalado
# install.packages("sf")
# install.packages("ggplot2")
# install.packages("tmap")

library(rgee)
library(sf)
library(ggplot2)
library(tmap)

# Iniciar Google Earth Engine
ee_Initialize()
# Instalar y cargar librerías necesarias
install.packages("rgee")  # Si no lo tienes instalado
install.packages("sf")
install.packages("ggplot2")
install.packages("tmap")

library(rgee)
library(sf)
library(ggplot2)
library(tmap)

# Iniciar Google Earth Engine
ee_Initialize()

# 1️⃣ Definir coordenadas UTM en ETRS89 UTM 31N (EPSG:25831)
utm_x <- 423919  # Coordenada X (Easting)
utm_y <- 4609805 # Coordenada Y (Northing)

# 2️⃣ Transformar a WGS84 (EPSG:4326)
utm_point <- st_sfc(st_point(c(utm_x, utm_y)), crs = 25831)
wgs84_point <- st_transform(utm_point, 4326)
lon <- st_coordinates(wgs84_point)[1]
lat <- st_coordinates(wgs84_point)[2]

# Mostrar resultado
print(paste("Longitud:", lon, "Latitud:", lat))

# 3️⃣ Crear punto en GEE y generar buffer de 100 metros
point <- ee$Geometry$Point(lon, lat)
aoi <- point$buffer(100)  # 100 metros de radio

# 4️⃣ Cargar el dataset de Landsat EVI
evi_dataset <- ee$ImageCollection("LANDSAT/COMPOSITES/C02/T1_L2_ANNUAL_EVI")

# 5️⃣ Seleccionar la imagen más reciente
evi_image <- evi_dataset$filterBounds(aoi)$sort("system:time_start", FALSE)$first()

# 6️⃣ Recortar la imagen a la AOI
evi_clip <- evi_image$clip(aoi)

# 7️⃣ Convertir la imagen a un objeto R para visualizar
evi_raster <- ee_as_raster(evi_clip, region = aoi)

# 8️⃣ Visualizar con ggplot2
ggplot() +
  geom_raster(data = as.data.frame(evi_raster, xy = TRUE), aes(x = x, y = y, fill = layer)) +
  scale_fill_viridis_c() +
  labs(title = "EVI Landsat en 100m alrededor del punto") +
  theme_minimal()

# 9️⃣ Alternativamente, visualizar con tmap (interactivo)
tm_shape(evi_raster) +
  tm_raster(style = "cont", palette = "-RdYlGn") +
  tm_layout(title = "Índice EVI en 100m alrededor del punto")

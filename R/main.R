library(forestables)
library(readr)
source("R/plot_tree_data.R")
load("data-raw/ifn4_cat.Rdata")
qmd_files <- list.files("qmd", pattern = "\\.qmd$", full.names = TRUE)

ids<- readr::read_csv("data-raw/pinhal_objectiu.csv") |> 
  dplyr::rename(
    id_unique_code = id_unique_
  )


ifn3_cat <- rbind(readRDS("data-raw/ifn3_08.rds"),
                  readRDS("data-raw/ifn3_17.rds"),
                  readRDS("data-raw/ifn3_25.rds"),
                  readRDS("data-raw/ifn3_43.rds"))


IDs <- ids$id_unique_code

for (id in IDs) {
  
  in_ifn3 <- id %in% ifn3_cat$id_unique_code
  in_ifn4 <- id %in% plots_cat$id_unique_code
  
  # Mensajes de advertencia según la condición
  if (!in_ifn3 && !in_ifn4) {
    warning(paste("ID", id, "no encontrado en IFN3 ni en IFN4"))
    next  # Saltar la iteración
  } else if (!in_ifn3) {
    warning(paste("ID", id, "no encontrado en IFN3"))
  } else if (!in_ifn4) {
    warning(paste("ID", id, "no encontrado en IFN4"))
  }
  
  # Crear directorio para el id dentro de 'forms' si no existe
  output_dir <- paste0("D:/IMPROMED_field_forms/", id)
  if (!dir.exists(output_dir)) dir.create(output_dir)
  
  # Iterar sobre cada archivo .qmd
  for (qmd_file in qmd_files) {
    # Crear un nombre de archivo específico para el HTML de cada id y cada .qmd
    file_name <- "plot_location.html"
    
    # Cambiar el directorio de trabajo al directorio de salida
    new_wd <- setwd(output_dir)
    on.exit(setwd("D:/IMPROMED_field_forms"))  # Restaurar el directorio de trabajo original al final
    
    # Renderizar el archivo .qmd a HTML
    quarto::quarto_render(
      input = file.path("D:/IMPROMED_field_forms/", qmd_file),  # Ruta completa del archivo .qmd
      output_format = "html",  # Formato de salida
      output_file = file_name,  # Nombre del archivo de salida
      quarto_args = paste0("--output-dir D:/IMPROMED_field_forms/forms/", id, "/", file_name),
      execute_params = list(id = id, plots_cat = plots_cat, ifn3_cat = ifn3_cat),
      debug = TRUE
    )
  }
}

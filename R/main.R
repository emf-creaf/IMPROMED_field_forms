# library(forestables)
library(readr)
library(sf)
library(dplyr)
source("R/plot_tree_data.R")
source("R/info_plots.R")
load("data-raw/ifn4_cat.Rdata")

ifn3_cat <- rbind(readRDS("data-raw/ifn3_08.rds"),
                  readRDS("data-raw/ifn3_17.rds"),
                  readRDS("data-raw/ifn3_25.rds"),
                  readRDS("data-raw/ifn3_43.rds"))


parceles_camp <- readr::read_delim(
  "data-raw/coords_obj_control_pinhal.csv", 
  delim = ";", escape_double = FALSE,
  trim_ws = TRUE) 

parceles_camp <- parceles_camp[-c(38, 40,42), ]
IDs <- parceles_camp$id_unique_code

IDs <- grep("^08", IDs, value = TRUE)


for(id in IDs)  {
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

for(id in IDs)  {
  output_dir <- file.path("forms", id)
  if(!dir.exists(output_dir)) dir.create(output_dir)
  rmarkdown::render(input = "Rmd/regen_shrub_ifn4.Rmd",output_file = file.path("..", output_dir, "regen_shrub_ifn4.html"))
  # Convierte el HTML generado a PDF
  pagedown::chrome_print(paste0("forms/", id, "/regen_shrub_ifn4.html"))
}


  output_dir <- file.path("forms")
  if(!dir.exists(output_dir)) dir.create(output_dir)
  rmarkdown::render(input = "Rmd/regen_table.Rmd",output_file = file.path("..", output_dir, "regen_table.html"))
  # Convierte el HTML generado a PDF
  pagedown::chrome_print(paste0("forms/regen_table.html"))



  output_dir <- file.path("forms")
  if(!dir.exists(output_dir)) dir.create(output_dir)
  rmarkdown::render(input = "Rmd/tree_general.Rmd",output_file = file.path("..", output_dir, "tree_general.html"))
  # Convierte el HTML generado a PDF
  pagedown::chrome_print(paste0("forms/tree_general.html"))

  output_dir <- file.path("forms")
  if(!dir.exists(output_dir)) dir.create(output_dir)
  rmarkdown::render(input = "Rmd/shrub_table.Rmd",output_file = file.path("..", output_dir, "shrub_table.html"))
  # Convierte el HTML generado a PDF
  pagedown::chrome_print(paste0("forms/shrub_table.html"))
  
  
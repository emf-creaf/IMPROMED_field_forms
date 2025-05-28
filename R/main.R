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


# 
# parceles_camp <-readr::read_delim(
#   "data-raw/coords_control_objetivo_osona_prades.csv", 
#   delim = ";", escape_double = FALSE, trim_ws = TRUE)|> 
#   dplyr::rename(
#     id_unique_code = id_unique_
#   )

parcelas_pinus_sylvestris <- read_delim(
  "data-raw/parcelas_pinus_sylvestris.csv", 
  delim = ";", escape_double = FALSE, trim_ws = TRUE) |> 
    dplyr::rename(
      id_unique_code = id_unique_
    )


IDs<- c( "25_1094_NN_A1_A1",
         "25_1096_NN_A1_A1",
         "25_1062_NN_A1_A1",
         "25_4199_xx_NN_A1",
         "25_1072_NN_A1_A1",
         "25_1076_xx_A4_A1",
         "25_1077_NN_A1_A1",
         "25_1066_NN_A1_A1",
         "25_1572_xx_A4_A1",
         "25_1577_xx_A4_A1",
         "25_1114_NN_A1_A1",
         "25_1127_NN_A1_A1",
         "25_0960_NN_A1_A1",
         "25_0950_NN_A1_A1",
         "25_0936_NN_A1_A1",
         "25_0929_NN_A1_A1",
         "25_0916_xx_A4_A1",
         "25_4184_xx_NN_A1",
         "25_0898_NN_A1_A1"
         )

# ids_25 <- parcelas_pinus_sylvestris$id_unique_code[grepl("^25", parcelas_pinus_sylvestris$id_unique_code)]
# 
# # Excluir los que ya están en la lista 'IDs'
# ids_25_filtrados <- ids_25[!ids_25 %in% IDs]

 codigos_en_df <- IDs[IDs %in% plots_cat$id_unique_code]
 
 # Códigos que NO están en la columna
 codigos_no_en_df <- IDs[!IDs %in% plots_cat$id_unique_code]

for(id in codigos_en_df)  {
  output_dir <- file.path("forms", id)
  if(!dir.exists(output_dir)) dir.create(output_dir)
  rmarkdown::render(input = "Rmd/_child_map.Rmd",output_file = file.path("..", output_dir, "plot_location.html"))
  # Convierte el HTML generado a PDF
  pagedown::chrome_print(paste0("forms/", id, "/plot_location.html"))
}

for(id in codigos_en_df)  {
  output_dir <- file.path("forms", id)
  if(!dir.exists(output_dir)) dir.create(output_dir)
  rmarkdown::render(input = "Rmd/tree_table.Rmd",output_file = file.path("..", output_dir, "tree_table.html"))
  # Convierte el HTML generado a PDF
  pagedown::chrome_print(paste0("forms/", id, "/tree_table.html"))
}

for(id in codigos_en_df)  {
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
  
  
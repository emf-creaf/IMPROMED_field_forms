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

# parcelas_pinus_sylvestris <- read_delim(
#   "data-raw/parcelas_pinus_sylvestris.csv", 
#   delim = ";", escape_double = FALSE, trim_ws = TRUE) |> 
#     dplyr::rename(
#       id_unique_code = id_unique_
#     )

# 
# llista_pinus_nigra<- read_excel("llista_pinus_nigra_deboscat_TableToExcel.xlsx")
# 
# IDs<- llista_pinus_nigra$id_unique_code

control_pinus_nigra <- read_excel("preseleccio_buffer_pinnig_control_TableToExcel.xlsx")

IDs<- control_pinus_nigra$id_unique_code

# 
# 
# IDs<- c(   "08_2616_NN_A1_A1", "08_2717_NN_A1_A1", "08_2737_NN_A1_A1" ,"08_2798_NN_A1_A1" ,"08_3005_NN_A1_A1",
#            "08_3332_NN_A1_A1", "08_3457_NN_A1_A1", "17_1635_NN_A1_A1" ,"17_1652_NN_A1_A1" ,"25_3212_NN_A1_A1",
#            "43_0521_NN_A1_A1", "43_0982_NN_A1_A1", "43_1108_NN_A1_A1" ,"43_2028_xx_NN_A1" ,"43_2064_xx_NN_A1",
#            "08_1292_xx_A4_A1", "08_1355_NN_A1_A1", "08_1879_NN_A1_A1", "17_0557_NN_A1_A1" ,"17_0920_NN_A1_A1",
#           "17_1843_NN_A1_A1", "25_0960_NN_A1_A1" ,"25_1066_NN_A1_A1", "25_1072_NN_A1_A1" ,"25_1862_NN_A1_A1",
#          "25_2427_NN_A1_A1", "25_4349_NN_A1_A1", "43_0594_xx_A4_A1", "43_0610_NN_A1_A1" ,"43_0697_NN_A1_A1"
#          )

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
  
  
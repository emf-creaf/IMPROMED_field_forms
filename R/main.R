library(forestables)

source("R/plot_tree_data.R")
load("data-raw/ifn4_cat.Rdata")
ifn3_cat <- rbind(readRDS("data-raw/ifn3_08.rds"),
                  readRDS("data-raw/ifn3_17.rds"),
                  readRDS("data-raw/ifn3_25.rds"),
                  readRDS("data-raw/ifn3_43.rds"))

IDs <- plots_cat$id_unique_code[c(1000, 2000, 2100, 2020)]

for(id in IDs)  {
  output_dir <- file.path("forms", id)
  if(!dir.exists(output_dir)) dir.create(output_dir)
  rmarkdown::render(input = "Rmd/_child_map.Rmd",output_file = file.path("..", output_dir, "plot_location.pdf"))
}


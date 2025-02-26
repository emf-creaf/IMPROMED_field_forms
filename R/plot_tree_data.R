library(ggplot2)
library(ggforce)
plot_tree_data <- function(treeData4, treeData3 = NULL, ingrowth = TRUE, tree_labels = TRUE) {
  lty <- "dotted"
  g <- ggplot()+
    geom_vline(xintercept = 0, col = "darkgray")+
    geom_hline(yintercept = 0, col = "darkgray")+
    geom_circle(aes(x0 = 0, y0=0, r=5), linetype = lty)+
    geom_circle(aes(x0 = 0, y0=0, r=10), linetype = lty)+
    geom_circle(aes(x0 = 0, y0=0, r=15), linetype = lty)+
    geom_circle(aes(x0 = 0, y0=0, r=25), linetype = lty)+
    coord_fixed(ratio = 1)+
    scale_y_continuous(limits = c(-25, 25))+
    scale_x_continuous(limits = c(-25, 25))+
    ylab("y (m)")+ xlab("x (m)")
  if(nrow(treeData4) > 0) {
    td <- treeData4 |>
      dplyr::select(sp_name, dbh, distance, azimuth, tree_ifn3, tree_ifn4) |>
      dplyr::mutate(status = dplyr::case_match(
        as.character(tree_ifn4),
        c("0") ~ "Cut",
        c("888") ~ "Dead",
        c("999")~ "Error",
        .default = "Alive",
      ))
    td_cut <- td |>
      dplyr::filter(status=="Cut")
    
    if(nrow(td_cut)>0 && !is.null(treeData3)) {
      td_cut <- td_cut |>
        dplyr::select(-distance, -azimuth, -dbh, -sp_name) |>
        dplyr::left_join(treeData3[,c("tree_ifn3", "distance", "azimuth", "dbh", "sp_name")], by=c("tree_ifn3"="tree_ifn3"))
      td <- td |>
        dplyr::filter(status != "Cut") 
      td <- dplyr::bind_rows(td, td_cut) 
    }
    td <- td |>
      dplyr::filter(!is.na(dbh),
                    !is.na(sp_name),
                    !is.na(distance),
                    !is.na(azimuth)) |>
      dplyr::mutate(azimuth_rad = azimuth*pi/180,
                    x = sin(azimuth_rad)*distance,
                    y = cos(azimuth_rad)*distance)
    if(!ingrowth)  {
      td <- td |>
        dplyr::filter(tree_ifn3!=0)
    } 
    if(nrow(td)>0) {
      g <- g +
        geom_point(aes(x = x, y = y, size = dbh, col = sp_name, fill = sp_name, shape = status), 
                   alpha = 0.8,
                   stroke = 1.0, 
                   data = td)
      if(tree_labels) {
        g <- g +
          geom_text(aes(x = x, y = y, label = tree_ifn4), size = 2, data = td)
      }
      g <- g +
        scale_size_binned("DBH (cm)", limits = c(7.5, NA)) + 
        scale_color_discrete("Species")+
        scale_fill_discrete("Species")+
        scale_shape_manual("Status", values = c("Alive" = 16, "Dead" = 8, "Cut" = 1,"Error" = 0.5))+
        guides(size = guide_bins(direction = "horizontal"))
    }
  }
  g <- g +
    theme_classic()
  return(g)
}
library(tidyplots)
penguins |>
  tidyplot(x = species) |>
  add_count_bar() |>
  adjust_x_axis_title("Especies") |>
  adjust_y_axis_title("Frecuencia")
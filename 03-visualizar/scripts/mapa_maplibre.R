ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  facet_wrap(vars(cyl, drv), labeller = "label_both")

library(mapgl)
manzanas_ind <- read_rds('data/clean/manzanas_independencia.rds') |>
  select(comuna, manzent, n_per, n_inmigrantes, pct_inm_num)

maplibre_view(manzanas_ind, column = "pct_inm_num") |>
    add_fill_layer(
      id = "migrantes_ind",
      source = manzanas_ind,
      fill_opacity = 0.7,
      fill_color = interpolate(
        column = "pct_inm_num",
        values = c(0, 90),
        stops = c("lightblue", "darkblue"),
        na_color = "lightgrey"
        ),
      )|>
    add_legend("Porcentaje Población Migrante Independencia",
               values = c(0,90),
               colors = c("lightblue", "darkblue"))


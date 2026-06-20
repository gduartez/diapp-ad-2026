# Horario de Consulta 1 ---------------------------------------------------

library(tidyverse)
library(readr)
homicidios_rm_sf <- read_rds('data/clean/homicidios_rm_sf.rds')

class(homicidios_rm_sf)
homicidios_rm_sf
str(homicidios_rm_sf)

ggplot(homicidios_rm_sf) +
  geom_sf()


# Pregunta 3 --------------------------------------------------------------

ggplot(homicidios_anual, aes(x = anio, y = homicidios)) +
  geom_text(
    aes(label = homicidios),
    vjust = -0.4,
    size = 4,
    fontface = "bold"
  ) +
  geom_col(fill = '#173277', width = 0.7) +
  scale_y_continuous(
    limits = c(-500, 1500),
    breaks = seq(-1000, 1500, 500),
    expand = expansion(mult = c(0.8, 0.9))
  ) +
  labs(x = "Año", y = "Frecuencia") +
  scale_x_continuous(breaks = seq(2018, 2025, 1)) +
  theme_clean(base_size = 14)

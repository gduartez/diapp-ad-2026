library(gapminder)
library(tidyverse)
library(dplyr)
library(ggthemes)

gap_2007 <- gapminder |> filter(year == 2007)

# 1. 💻 Histograma -----------------------------------------------------------
library(gapminder)
library(ggplot2)
library(dplyr)

gap_2007 <- gapminder |> filter(year == 2007)

ggplot(gap_2007, aes(x = lifeExp)) +
  geom_histogram(fill = "blue3", color = "black", bins = 10) +
  labs(x = "Esperanza de vida", y = "Frecuencia") +
  theme_minimal()

# 2. 💻 Objetos geométricos diferenciados por color --------------------------
library(gapminder)
library(ggplot2)
library(dplyr)

gapminder |>
  group_by(continent, year) |>
  summarise(lifeExp = mean(lifeExp), .groups = "drop") |>
  ggplot(aes(x = year, y = lifeExp, color = continent)) +
  geom_line(linewidth = 1.5) +
  geom_point(size = 2, alpha = 0.9) +
  scale_y_continuous(limits = c(0, NA)) +
  labs(title = "Esperanza de vida por continente",
       x = "Año", y = "Esperanza de vida",
       color = "Continente") +
  theme_minimal(base_size = 14)

# Lineas en el tiempo -----------------------------------------------------
gapminder |>
  filter(country == "Chile") |>
  ggplot(aes(x = year, y = lifeExp)) +
  geom_line(linewidth = 1.5, color = "steelblue") +
  geom_point(size = 2, color = "black", alpha = 0.8) +
  scale_y_continuous(limits = c(0, 80), 
                     breaks = seq(0,80,10)) +
  labs(title = "Evolución de la esperanza de vida en Chile",
       subtitle = "1952–2007",
       x = "Año", y = "Esperanza de vida",
       caption = "Fuente: Gapminder") +
  theme_bw(base_size = 15)

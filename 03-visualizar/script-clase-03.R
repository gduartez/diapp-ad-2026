# 1. Librerías y Datos ---------------------------------------------------------------
library(tidyverse)
library(janitor)
library(readxl)
library(gapminder)
library(ggthemes)
library(scales)

theme_g1 <-   theme(
  # Sólo líneas horizontales
  panel.grid.major.x = element_blank(),
  panel.grid.minor.x = element_blank(),
  panel.grid.major.y = element_line(
    colour = "#D0D0D0",
    linewidth = 0.6
  ),
  panel.grid.minor.y = element_blank(),
  # Ejes
  axis.title = element_text(colour = "#173277"),
  axis.text = element_text(colour = "#173277"),
  # Sin borde
  panel.border = element_blank()
)


# Ejercicios Clase --------------------------------------------------------


# 1 -----------------------------------------------------------------------
library(gapminder)
library(ggplot2)
library(dplyr)

gap_2007 <- gapminder |> filter(year == 2007)

ggplot(gap_2007, aes(x = lifeExp)) +
  geom_histogram(fill = "blue4", color = "black", bins = 10) +
  labs(x = "Esperanza de vida", y = "Frecuencia") +
  theme_minimal()


# 2 -----------------------------------------------------------------------


# 3 -----------------------------------------------------------------------

library(gapminder)
library(ggplot2)
library(dplyr)

gap_2007 <- gapminder |> filter(year == 2007)

ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp,
                     color = continent)) +
  geom_point(alpha = 0.7, size = 2.5) +
  geom_smooth(se = FALSE, method = "lm") +
  labs(
    title = "Relación PIB y Esperanza de Vida por continente",
    x = "PIB per cápita (USD)",
    y = "Esperanza de vida (años)",
    color = "Continente"
  ) +
  theme_minimal(base_size = 14)

# Ejercicio Grupal --------------------------------------------------------
## 1 -----------------------------------------------------------------------
homicidos_wide <- read_excel('data/clean/homicidios_wide.xlsx') |> 
  mutate(tasa_hom_2024 = hom_2024/poblacion_censada*100000) |> 
  mutate(zona = case_when(
    codigo_region %in% c(15, 1, 2, 3, 4) ~ "Norte",
    codigo_region %in% c(5, 13, 6, 7, 16, 8) ~ "Centro",
    codigo_region %in% c(9, 14, 10) ~ "Sur",
    .default = "Austral",
  ))

homicidos_long <- read_excel('data/clean/homicidios_long.xlsx')

homicidos_anual <- homicidos_long |> 
  count(anio, name = "homicidios")

homicidos_wide_p <- homicidos_wide |> 
  filter(hom_2024 > 0)

## 2 -----------------------------------------------------------------------
# Linea
p2 <- ggplot(homicidos_anual, aes(x = anio, y = homicidios)) +
  geom_line(color = '#4393C3', linewidth = 2, alpha = .8) +
  geom_point(alpha = .7, size= 2) +
  scale_x_continuous(breaks = seq(2018,2025,1)) +
  scale_y_continuous(limits = c(0,1500)) +
  theme_clean(base_size = 14) 

p2

# 3 -----------------------------------------------------------------------
# Columnas
# Linea
p3 <- ggplot(homicidos_anual, aes(x = anio, y = homicidios)) +
  geom_col(fill = '#173277', width = 0.7) +
  geom_text(
    aes(label = comma(homicidos_anual$homicidios, big.mark = ".")),
    vjust = -0.4,
    size = 4,
    fontface = "bold"
  ) +
  scale_y_continuous(
    limits = c(0, 1500),
    breaks = seq(0, 1500, 500),
    expand = expansion(mult = c(0, 0.05))
  ) +
  labs(
    x = "Año",
    y = "Frecuencia"
  ) +
  scale_x_continuous(breaks = seq(2018,2025,1)) +
  theme_clean(base_size = 14)

p3

## 4 -----------------------------------------------------------------------
# Scatterplot
p4 <- ggplot(homicidos_wide_p, aes(x = tasa_pobreza, y = tasa_hom_2024)) +
  geom_point(aes(color = zona)) +
  labs(
    x = "Tasa de Pobreza",
    y = "Tasa de Homicidios 2024"
  ) +
  theme_clean(base_size = 14) 

p4

## 5 -----------------------------------------------------------------------
p5 <- p4 +
  geom_smooth()

p5

## 6 -----------------------------------------------------------------------
homicidos_wide_p_filter <- homicidos_wide_p |> 
  filter(poblacion_censada >10000)

p6 <- ggplot(homicidos_wide_p_filter, aes(x = tasa_pobreza, y = tasa_hom_2024)) +
  geom_point(aes(color = zona)) +
  labs(
    x = "Tasa de Pobreza",
    y = "Tasa de Homicidios 2024"
  ) +
  theme_clean(base_size = 14) +
  geom_smooth(method = lm)

p6

## 7 -----------------------------------------------------------------------
homicidios_rm_sf <- read_rds('data/clean/homicidios_rm_sf.rds')

ggplot(homicidios_rm_sf |> 
         filter(provincia == 'Santiago')) +
  geom_sf(aes(fill = tasa_hom_2024), color = 'grey100', linewidth = 0.05) +
  scale_fill_distiller(palette = "RdBu",
                       direction = -1,
                       labels = scales::label_number(accuracy = 1))+
  labs(
    title = "Tasa de Homicidios Comunal 2024",
    subtitle = "Región Metropolitana - Provincia de Santiago",
    caption = "Fuente: Centro para la Prevención de Homicidios y Delitos Violentos",
    fill = str_wrap("Tasa de Víctimas de Homicidio", 15)
  ) +
  annotation_scale() +
  annotation_north_arrow(location = "tl") +
  theme_minimal()

ggsave(
  "output/mapa_homicidios_rm.png",
  width = 10,
  height = 10,
  dpi = 300,
  bg = "white"
)


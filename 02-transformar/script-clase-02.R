# 1. Librerías y Datos ---------------------------------------------------------------
library(tidyverse)
library(janitor)
library(readxl)
library(gapminder)

poblacion_2024 <- read_excel(
  "data/D1_Poblacion-censada-por-sexo-y-edad-en-grupos-quinquenales.xlsx",
  sheet = "2",  #también puede ser sheet = 3, indicando que corresponde a la tercera hoja
  skip = 3, #para saltar las primeras 3 filas y leer desde la fila 4
  n_max = 347 #última fila correspondiente a Torres del Paine
) |> 
  clean_names()

# Para ejemplo de bind_rows
poblacion_2024 |> 
  count(region)


## Ejemplo filter + slice --------------------------------------------------
glimpse(gapminder)

distinct(gapminder, continent)
gapminder |>
  filter(continent == "Americas" & year == 2007) |>
  slice_max(lifeExp, n = 3) |>
  select(country, lifeExp, gdpPercap)


## Ejercicio Aplicado: Factores --------------------------------------------
library(gapminder)
library(dplyr)
library(forcats)

gapminder |>
  filter(year == 2007) |>
  mutate(
    nivel_vida = if_else(lifeExp >= 70, 1, 0),
    nivel_vida = factor(nivel_vida, levels = c(0, 1), labels = c("Baja", "Alta"))
  ) |>
  count(nivel_vida)


# Ejercicio Grupal --------------------------------------------------------


## 1 -----------------------------------------------------------------------


## 2 -----------------------------------------------------------------------


## 3 -----------------------------------------------------------------------


## 4 -----------------------------------------------------------------------



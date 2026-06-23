# 0. Librerías y Datos ---------------------------------------------------------------
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

## Ejemplo aplicado 1: filter + slice --------------------------------------------------
glimpse(gapminder)

distinct(gapminder, continent)
gapminder |>
  filter(continent == "Americas" & year == 2007) |>
  slice_max(lifeExp, n = 3) |>
  select(country, lifeExp, gdpPercap)

## Ejemplo aplicado 2: filter + slice --------------------------------------------------
gapminder |>
  filter(year == 2007) |>
  mutate(
    nivel_desarrollo = case_when(
      gdpPercap > 20000  ~ "Alto",
      gdpPercap > 5000  ~ "Medio",
      .default = "Bajo"
    )
  ) |>
  count(nivel_desarrollo)

## Ejemplo aplicado 3: Factores --------------------------------------------
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
# Ocupar bind_rows() para unir años y limpiar nombres de columnas
homicidios_2024 <- read_excel('data/clean/homicidios-2024.xlsx')
homicidios_2025 <- read_excel('data/clean/homicidios-2025.xlsx')

homicidios_24_25 <- bind_rows(homicidios_2024, homicidios_2025) |> 
  clean_names()

## 2 -----------------------------------------------------------------------
# Contar homicidios por año y comuna, añadiendo region.
# Ordenar por año más antiguo y en orden descendente de cantidad de homicidios
homicidios_count <- homicidios_24_25 |> 
  count(id_ano, nom_reg, comun_agr)

homicidios_count <-  homicidios_count |> 
  arrange(id_ano, desc(n))

## 3 -----------------------------------------------------------------------
# Pivotear wide para tener año 2024 y 2025
homicidios_wide <- homicidios_count |> 
  pivot_wider(names_from = "id_ano",
              values_from = "n")

## 4 -----------------------------------------------------------------------
# Crear variable de variacion entre años.
# Comprobar error si no se ocupa backticks o acentos graves.
# Ver opción de usar name_prefix en pivot_wider
homicidios_wide <- homicidios_wide |> 
  mutate(dif = 2025 - 2024)

# Opción 1
homicidios_wide |> 
  mutate(dif = `2025` - `2024`)

# Opción 2
homicidios_wide <- homicidios_count |> 
  pivot_wider(names_from = "id_ano",
              values_from = "n",
              names_prefix = "anio_") |> 
  mutate(dif = anio_2025 - anio_2024)

## 5 -----------------------------------------------------------------------
# Renombrar comuna, region y diferencia
homicidios <- homicidios_wide |> 
  rename(comuna = comun_agr, region = nom_reg, variacion = dif )

## 6 -----------------------------------------------------------------------
# Filtrar por region metropolitana
homicidios_rm <- homicidios |> 
  filter(region == "Metropolitana de Santiago")

## 7 -----------------------------------------------------------------------
# Cargar dataset de clase 1 y renombrar tasa de pobreza y dejar solo variables de
# codigo, comuna, provincia, tasa de pobreza y población
# Cruzar homicidios con datos de poblacion y pobreza
poblacion_pobreza <- read_excel('data/clean/pobreza_pob_censo_2024.xlsx') |> 
  rename(tasa_pobreza = porcentaje_de_personas_en_situacion_de_pobreza_de_ingresos_2024) |> 
  select(codigo, comuna, provincia, tasa_pobreza, poblacion_censada)

homicidios_rm <- homicidios_rm |> 
  left_join(poblacion_pobreza, join_by(comuna))

## 8 -----------------------------------------------------------------------
# Variaciones por provincia y promedio de tasa de pobreza
homicidios_rm |> 
  group_by(provincia) |> 
  summarise(variacion_total = sum(variacion, na.rm = T),
            pobreza_media = mean(tasa_pobreza)
            )

## 9 -----------------------------------------------------------------------
# Vemos que hay dos problemas con el cálculo anterior
# 1) los NA en verdad corresponden a 0, por lo que hay que corregir las variables
# 2) promediar porcentajes es un cálculo erróneo para el % de pobreza de 
# un conjunto agrupado (en este caso la tasa de pobreza de la provincia no es
# el promedio de pobreza de las comunas).

# Cargo dataset con poblacion y personas en sit. pobreza
poblacion_pobreza <- read_excel('data/clean/pobreza_pob_censo_2024.xlsx') |> 
  rename(tasa_pobreza = porcentaje_de_personas_en_situacion_de_pobreza_de_ingresos_2024,
         pob_proyectada = 4, #cuarta columna
         pob_pobreza = 5) |> #quinta columna
  select(codigo, comuna, provincia, tasa_pobreza, starts_with("pob")) |> 
  mutate(pob_pobreza = round(pob_pobreza)) #redondeamos para no tener decimales

homicidios_rm2 <- homicidios |> 
  filter(region == "Metropolitana de Santiago") |> 
  mutate(across(
    starts_with("anio"), \(x) replace_na(x, 0) # O ~ replace_na(.x, 0)
    ),
    variacion = anio_2025 - anio_2024)

homicidios_rm2 <- homicidios_rm2 |> 
  left_join(poblacion_pobreza, join_by(comuna))

homicidios_rm2 |> 
  group_by(provincia) |> 
  summarise(variacion_total = sum(variacion, na.rm = T),
            personas_proyectadas = sum(pob_proyectada),
            personas_pobreza = sum(pob_pobreza)
  ) |> 
  mutate(tasa_pobreza = personas_pobreza/personas_proyectadas)

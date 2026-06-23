# 0. Librerías ------------------------------------------------------------
library(tidyverse)   # incluye dplyr (left_join) y readr
library(readxl)      # para leer archivos .xlsx
library(janitor)     # para usar clean_names()
library(openxlsx)    # para guardar en formato excel
library(haven)       # para trabajar datos en formato .dta
library(arrow)       # para trabajar datos en formato parquet
library(sf)          # para trabajar datos espaciales

# Ejemplo aplicado 1 --------------------------------------------------------
df <- tibble(`Nombre Comuna`  = c("Santiago", "Cerrillos"),
             `Población 2017` = c(503147, 88056))
df |> clean_names() #aplico limpieza de nombres

# Ejercicio Guiado  --------------------------------------------------------
## 1 -----------------------------------------------------------------------
USArrests1 <- read_csv('data/USArrests1.csv')
USArrests2 <- read_csv2('data/USArrests2.csv')
USArrests3 <- read_dta('data/USArrests3.dta')
USArrests4 <- read_sav('data/USArrests4.sav')
USArrests5 <- read_delim('data/USArrests5.txt', delim = " ")
USArrests6 <- read_tsv('data/USArrests6.txt')
USArrests7 <- read_excel('data/USArrests7.xlsx')
USArrests8 <- read_rds('data/USArrests8.rds')

## 2 -----------------------------------------------------------------------
comunas_rm <- st_read('data/comunas_rm.shp')

ggplot(comunas_rm) +
  geom_sf()

## 3 -----------------------------------------------------------------------
homicidios_cead <- read_excel('data/homicidios_anuales_cead.xlsx')

## 4 -----------------------------------------------------------------------
homicidios_cead2 <- read_excel('data/homicidios_anuales_cead.xlsx',
                               range = 'A4:W426')

# Ejercicio Grupal --------------------------------------------------------
## 1 -----------------------------------------------------------------------
pobreza_2024 <- read_excel("data/SAE_ingresos_2024.xlsx")
glimpse(pobreza_2024)
view(pobreza_2024)

## 2 -----------------------------------------------------------------------
pobreza_2024 <- read_excel("data/SAE_ingresos_2024.xlsx",
                           range = "A3:J348")
glimpse(pobreza_2024)

## 3 -----------------------------------------------------------------------
pobreza_2024 <- pobreza_2024 |> 
  clean_names()
glimpse(pobreza_2024)

## 4 -----------------------------------------------------------------------
poblacion_2024 <- read_excel(
  "data/D1_Poblacion-censada-por-sexo-y-edad-en-grupos-quinquenales.xlsx",
  sheet = "2",  #también puede ser sheet = 3, indicando que corresponde a la tercera hoja
  skip = 3, #para saltar las primeras 3 filas y leer desde la fila 4
  n_max = 347 #última fila correspondiente a Torres del Paine
) |> 
  clean_names()

glimpse(poblacion_2024)

## 5 -----------------------------------------------------------------------
poblacion_pobreza_2024 <- left_join(pobreza_2024,
                                    poblacion_2024,
                                    join_by(codigo == codigo_comuna)
                                    )

glimpse(poblacion_pobreza_2024)

summary(poblacion_pobreza_2024$poblacion_censada)

## 6 -----------------------------------------------------------------------
poblacion_pobreza_2024_v2 <- left_join(pobreza_2024,
                                       poblacion_2024,
                                       join_by(nombre_comuna == comuna)
                                       )

glimpse(poblacion_pobreza_2024_v2)

summary(poblacion_pobreza_2024_v2$poblacion_censada)

## 7 -----------------------------------------------------------------------
write.xlsx(poblacion_pobreza_2024, 'data/clean/pobreza_pob_censo_2024.xlsx')
write_parquet(poblacion_pobreza_2024, 'data/clean/pobreza_pob_censo_2024.parquet')

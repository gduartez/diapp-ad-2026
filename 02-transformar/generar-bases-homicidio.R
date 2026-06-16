library(tidyverse)
library(janitor)
library(readxl)
library(gapminder)
library(openxlsx)

homicidios <- read_excel('data/01-victimas-homicidio-2018-2025.xlsx')

hom_2024 <- homicidios |> 
  filter(ID_ANO == 2024)

hom_2025 <- homicidios |> 
  filter(ID_ANO == 2025)

write.xlsx(hom_2024, 'data/clean/homicidios-2024.xlsx')
write.xlsx(hom_2025, 'data/clean/homicidios-2025.xlsx')

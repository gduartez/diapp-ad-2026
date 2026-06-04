library(arrow)
library(tidyverse)
library(openxlsx)

censo_pers <- read_parquet('../../_common/data/personas_censo2024.parquet')

glimpse(censo_pers)

censo_red <- censo_pers |> 
  select(region:comuna, sexo, edad, escolaridad)

censo_pers |> 
  filter(comuna == 13108) |> 
  write.xlsx('data/censo24-personas-independencia.xlsx')

independencia <- censo_red |> 
  filter(comuna == 13108)

independencia |> 
  filter(edad >= 0) |> 
  summarise(mean(edad))


library(tidyverse) # Manipulación y visualización de Datos
library(readxl) #Importar archivos excel
library(janitor) #Limpieza de datos
library(openxlsx) #Guardar archivos excel
library(scales) #Formatear visualización de texto

homicidios_wide <- read_excel('data/homicidios_wide_v2.xlsx')

ggplot(homicidios_wide,
       aes(x = tasa_pobreza,
           y = tasa_hom_2024)) +
  geom_point() +
  geom_smooth(se = FALSE,
              method = "lm",
              color = "darkred") +
  facet_wrap(vars(region),
             scales = "free") +
  labs(x = "Tasa de Pobreza", y = "Tasa de Homicidios 2024") +
  theme_bw(base_size = 12)

# Mapa Chile --------------------------------------------------------------
library(chilemapas)

# mapa de la región metropolitana
mapa_comunas <- mapa_comunas |> 
  # especificar la geometría
  st_set_geometry(mapa_comunas$geometry) |> 
  mutate(codigo_comuna = as.numeric(codigo_comuna))

homicidios_wide_cruce <- homicidios_wide |> 
  select(codigo_comuna, comuna, region, zona, tasa_pobreza, tasa_hom_2024)

homicidios_mapa <- mapa_comunas |> 
  left_join(homicidios_wide_cruce, join_by(codigo_comuna))

write_rds(homicidios_mapa, "data/homicidios_sf.rds")

homicidios_mapa |> 
  filter(region == "Antofagasta") |> 
  ggplot(aes(fill = tasa_hom_2024)) +
  geom_sf(col = "black", alpha = 0.8) +
  scale_fill_fermenter(palette = "Oranges", direction = 1) +
  geom_sf_label(aes(label = paste(comuna, round(tasa_hom_2024,1)))) +
  # geom_text(aes(label = comuna)) +
  theme_minimal()

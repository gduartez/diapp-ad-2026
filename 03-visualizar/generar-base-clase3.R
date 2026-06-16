library(tidyverse)
library(janitor)
library(readxl)
library(stringi)
library(stringr)
library(openxlsx)
library(sf)
library(arrow)
library(scales)
library(ggspatial)
library(viridis)
# library(fuzzyjoin)

# Limpio homicidios -------------------------------------------------------
homicidios <- read_excel('data/clean/01-victimas-homicidio-2018-2025.xlsx') |> 
  clean_names() |> 
  rename(comuna = comun_agr,
         region = nom_reg,
         edad = edad_recod,
         nacionalidad = nacion_recod,
         lugar_agr = lug_agr_recod,
         arma = arma_recod,
         contexto = contexto_recod,
         anio = id_ano,
         bloque_horario = hora_recod,
         mes = mes2
  )

homicidios_wide <- homicidios |> 
  count(anio, comuna) |> 
  pivot_wider(names_from = anio,
              values_from = n,
              names_prefix = "hom_") |> 
  mutate(across(where(is.numeric), ~ replace_na(.x, 0))) |> 
  mutate(hom_totales = rowSums(pick(starts_with("hom_"))))

# Base comunal ------------------------------------------------------------
pobreza <- read_excel('data/clean/pobreza_pob_censo_2024.xlsx') |> 
  clean_names() |> 
  rename(region = region_x, 
         codigo_comuna = codigo,
         tasa_pobreza = porcentaje_de_personas_en_situacion_de_pobreza_de_ingresos_2024) |> 
  select(codigo_region, region, provincia, codigo_comuna, comuna:mujeres, tasa_pobreza)

# Cruce -------------------------------------------------------------------
limpiar_comuna <- function(x) {
  x |> 
    str_to_lower() |>
    str_trim() |>
    str_replace_all("'", "") |>
    str_replace_all("-", " ") |>
    str_squish() |>
    stringi::stri_trans_general("Latin-ASCII")
}

pobreza_clean <- pobreza |> 
  mutate(comuna_join = limpiar_comuna(comuna))

homicidios_clean <- homicidios_wide |> 
  mutate(comuna_join = limpiar_comuna(comuna))

# Veo cuáles comunas no cruzan
homicidios_clean |> 
  anti_join(pobreza_clean, by = "comuna_join") |> 
  select(comuna)

# Vuelvo a limpiar
pobreza_clean <- pobreza |> 
  mutate(comuna_join = limpiar_comuna(comuna))

homicidios_clean <- homicidios_wide |> 
  mutate(comuna = comuna |> 
           replace_values("Paiguano" ~ "Paihuano",
                          "Treguaco" ~ "Trehuaco")
  ) |> 
  mutate(comuna_join = limpiar_comuna(comuna))

homicidios_comunales <- pobreza_clean |> 
  left_join(homicidios_clean |> 
              select(-comuna),
            join_by(comuna_join)
            ) 

summary(homicidios_comunales)

# Exporto -----------------------------------------------------------------
homicidios |> 
  write.xlsx('data/clean/homicidios_long.xlsx')

homicidios_comunales |> 
  write.xlsx('data/clean/homicidios_wide.xlsx')

# No funciona
# posibles_match <- pobreza_clean |> 
#   stringdist_left_join(
#     homicidios_clean,
#     by = "comuna_join",
#     method = "jw",
#     max_dist = 0.12,
#     distance_col = "distancia"
#   ) |> 
#   filter(!is.na(comuna.y)) |> 
#   arrange(distancia) |> 
#   select(
#     codigo_comuna,
#     region,
#     comuna_pobreza = comuna.x,
#     comuna_homicidios = comuna.y,
#     distancia
#   )


# Bases listas para usar --------------------------------------------------
homicidos_wide <- read_excel('data/clean/homicidios_wide.xlsx') |> 
  mutate(tasa_hom_2024 = hom_2024/poblacion_censada*100000) |> 
  mutate(zona = case_when(
    codigo_region %in% c(15, 1, 2, 3, 4) ~ "Norte",
    codigo_region %in% c(5, 13, 6, 7, 16, 8) ~ "Centro",
    codigo_region %in% c(9, 14, 10) ~ "Sur",
    .default = "Austral",
  ))

write.xlsx(homicidos_wide, 'data/clean/homicidios_wide_v2.xlsx')

homicidios_rm <- homicidos_wide |> 
  filter(codigo_region == 13)

comunas_rm <- st_read("data/clean/comunas_rm.shp") |> 
  select(1) |> 
  rename(codigo_comuna = 1) |> 
  mutate(codigo_comuna = as.numeric(codigo_comuna))

homicidios_rm_sf <- comunas_rm |> 
  left_join(homicidios_rm, join_by(codigo_comuna))

write_rds(homicidios_rm_sf, 'data/clean/homicidios_rm_sf.rds')

# Datos censo -------------------------------------------------------------
manzanas <- read_parquet(
  "data/clean/Cartografia_censo2024_Pais_Manzanas.parquet"
) |>
  clean_names() |>
  mutate(
    across(manzent, as.character),
    pct_inm = round(n_inmigrantes / n_per, 4),
    pct_inm_num = round(pct_inm * 100, 0),
    pct_inm_label = percent(pct_inm, accuracy = 0.1)
  ) |>
  mutate(
    pct_infante = round(n_edad_0_5 / n_per, 4),
    pct_infante_num = round(pct_infante * 100, 0),
    pct_infante2 = round(n_edad_6_13 / n_per, 4),
    pct_infante_num2 = round(pct_infante2 * 100, 0),
    pct_hacinados = round(n_viv_hacinadas / n_vp, 4),
    pct_hacinados_num = round(pct_hacinados * 100, 0),
  ) |> 
  st_as_sf(crs = 4326)

# Manzanas de la comuna de Independencia
manz_ind <- manzanas |>
  filter(cut == 13108)

write_rds(manz_ind, "data/clean/manzanas_independencia.rds")

manz_ind <- read_rds("data/clean/manzanas_independencia.rds")

ggplot(manz_ind) +
  geom_sf(aes(fill = pct_inm), color = 'grey100', linewidth = 0.05) +
  scale_fill_distiller(palette = "RdBu",
                       direction = -1,
                       labels = scales::label_percent(accuracy = 1))+
  labs(
    title = "Número de personas censadas por manzana",
    subtitle = "Comuna de Independencia",
    caption = "Fuente: Censo 2024",
    fill = str_wrap("Número de Personas", 15)
  ) +
  annotation_scale() +
  annotation_north_arrow(location = "tl") +
  theme_void()



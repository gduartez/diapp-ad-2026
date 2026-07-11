# install.packages("pak")
# pak::pak("bastianolea/territorial")
library(pacman)
library(territorial)
p_load(tidyverse, readxl, janitor, purrr, sf, openxlsx)

detach("package:easystats", unload = TRUE)

# 1. Limpieza ------------------------------------------------------------
## I. Homicidios -------------------------------------------------------
homicidios <- read_excel('data/raw/Base_de_Datos_VHC_2018_2025.xlsx') |>
  clean_names() |>
  rename(
    comuna = comun_agr,
    region = nom_reg,
    edad = edad_recod,
    nacionalidad = nacion_recod,
    lugar_agr = lug_agr_recod,
    arma = arma_recod,
    contexto = contexto_recod,
    anio = id_ano,
    bloque_horario = hora_recod,
    mes = mes2
  ) |>
  mutate(nombre_comuna = limpiar_comunas(comuna), .before = 1) |>
  mutate(codigo_comuna = as_codigo_comuna(nombre_comuna), .before = 1) |>
  select(-comuna)

homicidios_wide <- homicidios |>
  count(anio, codigo_comuna, nombre_comuna) |>
  pivot_wider(names_from = anio, values_from = n, names_prefix = "hom_") |>
  mutate(
    across(where(is.numeric), ~ coalesce(.x, 0)), #Reemplazo con 0 los NA
    hom_totales = rowSums(pick(starts_with("hom_"))) #Genero homicidios totales de la serie
  )

# ?rowSums

## II. Población --------------------------------------------------------------
poblacion_proy17 <- read_excel(
  'data/raw/estimaciones-y-proyecciones-2002-2035-comunas.xlsx'
) |>
  clean_names() |>
  pivot_longer(
    starts_with("poblacion"),
    names_to = "anio_str",
    values_to = "poblacion"
  ) |>
  mutate(anio = as.numeric(str_sub(anio_str, -4))) |>
  group_by(comuna, anio) |>
  summarise(poblacion_proyectada = sum(poblacion)) |>
  filter(between(anio, 2018, 2025)) |> #para restringir a la muestra de homicidios
  rename(codigo_comuna = comuna) |>
  ungroup()

poblacion_2024 <- read_excel(
  "data/raw/D1_Poblacion-censada-por-sexo-y-edad-en-grupos-quinquenales.xlsx",
  sheet = "2", #también puede ser sheet = 3, indicando que corresponde a la tercera hoja
  skip = 3, #para saltar las primeras 3 filas y leer desde la fila 4
  n_max = 347 #última fila correspondiente a Torres del Paine
) |>
  clean_names() |>
  mutate(anio = 2024)


### Tabla 2024 -------------------------------------------------------------
t1 <- poblacion_proy17 |>
  filter(anio == 2024) |>
  select(-anio)

t2 <- poblacion_2024 |>
  select(-comuna) |>
  select(codigo_comuna, codigo_region, region, poblacion_censada)

## III. Pobreza ---------------------------------------------------------
pobreza <- read_excel("data/raw/SAE_ingresos_2024.xlsx", range = "A3:J348") |>
  clean_names() |>
  rename(
    codigo_comuna = codigo,
    poblacion_proyectada_casen = numero_de_personas_segun_proyecciones_de_poblacion,
    poblacion_pobreza = numero_de_personas_en_situacion_de_pobreza_de_ingresos,
    tasa_pobreza = porcentaje_de_personas_en_situacion_de_pobreza_de_ingresos_2024,
    li = limite_inferior,
    ls = limite_superior,
    comuna_casen = presencia_de_la_comuna_en_la_muestra_casen
  ) |>
  select(-region, -nombre_comuna) |>
  mutate(anio = 2024)

### Tabla 2024 -------------------------------------------------------------
t3 <- pobreza |>
  select(1:4)

## IV. Superficie comunal ----------------------------------------------
# sup <- read_rds('../../../../_common/data/datos-comunales-sf.rds')

superficie <- st_read('../../../../_common/data/comunas/COMUNAS_v1.shp') |>
  st_transform(crs = 32719) |>
  clean_names() |>
  mutate(
    area = as.numeric(st_area(geometry) / 1000000),
    cut_com = as.numeric(cut_com)
  ) |>
  st_drop_geometry() |>
  rename(codigo_comuna = cut_com)

### Tabla 2024 -------------------------------------------------------------
t4 <- superficie |>
  select(codigo_comuna, superficie)

## V. Migrantes --------------------------------------------------------------
migrantes <- read_excel(
  "data/raw/D4_Inmigracion-Internacional.xlsx",
  sheet = "4",
  range = "A4:H5209"
) |>
  clean_names() |>
  select(last_col(3):last_col())

### Tabla 2024 -------------------------------------------------------------
t5 <- migrantes |>
  filter(pais_o_continente_de_nacimiento == "Total nacidos fuera del país") |>
  group_by(codigo_comuna) |>
  summarise(inmigrantes_2024 = sum(inmigrantes_internacionales, na.rm = T))

## VI. IGVUST (Urbana, rural y mixta) -----------------------------------------
igvust <- read_excel('data/raw/202605_igvust_comunal_cuartil.xlsx') |>
  clean_names() |>
  rename(
    codigo_comuna = cod_com,
    categoria_pndr = clasificacion
  )

### Tabla 2024 -------------------------------------------------------------
t6 <- igvust |>
  select(codigo_comuna, categoria_pndr)

## VII. Ingresos municipales ------------------------------------------------
# data_sinim <- read_rds('../../../../_common/data/datos-comunales-sf.rds') |>
#   st_drop_geometry() |>
#   filter(ano == 2024) |>
#   rename(
#     codigo_comuna = cut_com,
#   )

ingresos_municipales <- read_excel(
  'data/raw/ingreso_total_percibido_2024.xls'
) |>
  clean_names() |>
  rename(comuna = unidad_territorial) |>
  mutate(
    ingresos_totales = as.numeric(na_if(str_trim(x2024), "-")),
    comuna = str_trim(str_remove(comuna, "\\s*\\(.*"))
  ) |>
  select(c(-2, -x2024)) |>
  mutate(nombre_comuna = limpiar_comunas(comuna), .before = 1) |>
  mutate(codigo_comuna = as_codigo_comuna(nombre_comuna), .before = 1)

### Tabla 2024 -------------------------------------------------------------
# t7 <- data_sinim |>
#   select(codigo_comuna, i_total, camaras_seg, vehiculos_seg)

t7 <- ingresos_municipales |>
  select(-nombre_comuna, -comuna)

## VIII. Años de escolaridad promedio ----------------------------------------
escolaridad <- read_excel(
  'data/raw/P7_Educacion.xlsx',
  sheet = "4",
  range = "A4:I1045"
) |>
  clean_names() |>
  rename(
    esc_promedio = anos_de_escolaridad_promedio,
    esc_promedio_s18 = anos_de_escolaridad_promedio_para_la_poblacion_de_18_anos_o_mas
  ) |>
  filter(sexo == "Total Comuna")

### Tabla 2024 -------------------------------------------------------------
t8 <- escolaridad |>
  select(codigo_comuna, starts_with("esc"))

## IX. Casos policiales CEAD -------------------------------------------
secuestros <- read_excel('data/raw/secuestros-anual-comuna.xlsx') |>
  clean_names() |>
  select(-ano) |>
  filter(comuna != "Total") |>
  pivot_longer(!comuna, names_to = "anio", values_to = "secuestros") |>
  mutate(anio = as.integer(str_remove(anio, "x"))) |>
  mutate(nombre_comuna = limpiar_comunas(comuna), .before = 1) |>
  mutate(codigo_comuna = as_codigo_comuna(nombre_comuna), .before = 1) |>
  mutate(secuestros = as.numeric(na_if(str_trim(secuestros), "-"))) |>
  select(-comuna)

extorsiones <- read_excel('data/raw/extorsiones-anual-comuna.xlsx') |>
  clean_names() |>
  select(-ano) |>
  filter(comuna != "Total") |>
  pivot_longer(!comuna, names_to = "anio", values_to = "extorsiones") |>
  mutate(anio = as.integer(str_remove(anio, "x"))) |>
  mutate(nombre_comuna = limpiar_comunas(comuna), .before = 1) |>
  mutate(codigo_comuna = as_codigo_comuna(nombre_comuna), .before = 1) |>
  mutate(extorsiones = as.numeric(na_if(str_trim(extorsiones), "-"))) |>
  select(-comuna)

armas <- read_excel('data/raw/armas-anual-comuna.xlsx') |>
  clean_names() |>
  select(-ano) |>
  filter(comuna != "Total") |>
  pivot_longer(!comuna, names_to = "anio", values_to = "armas") |>
  mutate(anio = as.integer(str_remove(anio, "x"))) |>
  mutate(nombre_comuna = limpiar_comunas(comuna), .before = 1) |>
  mutate(codigo_comuna = as_codigo_comuna(nombre_comuna), .before = 1) |>
  mutate(armas = as.numeric(na_if(str_trim(armas), "-"))) |>
  select(-comuna)

drogas <- read_excel('data/raw/drogas-anual-comuna.xlsx') |>
  clean_names() |>
  select(-ano) |>
  filter(comuna != "Total") |>
  pivot_longer(!comuna, names_to = "anio", values_to = "drogas") |>
  mutate(anio = as.integer(str_remove(anio, "x"))) |>
  mutate(nombre_comuna = limpiar_comunas(comuna), .before = 1) |>
  mutate(codigo_comuna = as_codigo_comuna(nombre_comuna), .before = 1) |>
  mutate(drogas = as.numeric(na_if(str_trim(drogas), "-"))) |>
  select(-comuna)

delitos_personas <- read_excel('data/raw/dpersonas-anual-comuna.xlsx') |>
  clean_names() |>
  select(-ano) |>
  filter(comuna != "Total") |>
  pivot_longer(!comuna, names_to = "anio", values_to = "delitos_personas") |>
  mutate(anio = as.integer(str_remove(anio, "x"))) |>
  mutate(nombre_comuna = limpiar_comunas(comuna), .before = 1) |>
  mutate(codigo_comuna = as_codigo_comuna(nombre_comuna), .before = 1) |>
  mutate(
    delitos_personas = as.numeric(na_if(str_trim(delitos_personas), "-"))
  ) |>
  select(-comuna)

### Tabla 2024 -------------------------------------------------------------
t9 <- secuestros |>
  filter(anio == 2024) |>
  select(codigo_comuna, secuestros)

t10 <- extorsiones |>
  filter(anio == 2024) |>
  select(codigo_comuna, extorsiones)

t11 <- armas |>
  filter(anio == 2024) |>
  select(codigo_comuna, armas)

t12 <- drogas |>
  filter(anio == 2024) |>
  select(codigo_comuna, drogas)

t13 <- delitos_personas |>
  filter(anio == 2024) |>
  select(codigo_comuna, delitos_personas)

# Genero df con todas las variables explicativas de las 346 comunas del país ----
rm(regresores)

regresores <- list(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13) |>
  reduce(left_join, by = join_by(codigo_comuna))

glimpse(regresores)

regresores |>
  group_by(codigo_comuna) |>
  summarise(n = n()) |>
  filter(n > 1)

# Genero base final ------------------------------------------------------
df_tarea <- homicidios_wide |>
  left_join(regresores, join_by(codigo_comuna)) |>
  relocate(c(codigo_region, region), .after = nombre_comuna) |>
  mutate(
    tasa_homicidios24 = hom_2024 / poblacion_proyectada * 100000,
    tasa_secuestros24 = secuestros / poblacion_proyectada * 100000,
    tasa_extorsiones24 = extorsiones / poblacion_proyectada * 100000,
    tasa_armas24 = armas / poblacion_proyectada * 100000,
    tasa_drogas24 = drogas / poblacion_proyectada * 100000,
    tasa_dpersonas24 = delitos_personas / poblacion_proyectada * 100000,
    tasa_migrantes = inmigrantes_2024 / poblacion_censada,
    densidad_poblacional = poblacion_proyectada / superficie,
    ingreso_pp = ingresos_totales / poblacion_proyectada
  )

writeClipboard(paste(names(df_tarea), collapse = "\t"))

write.xlsx(df_tarea, "data/clean/homicidios_tarea2.xlsx")

library(tidyverse) # Manipulación y visualización de Datos
library(readxl) #Importar archivos excel
library(janitor) #Limpieza de datos
library(openxlsx) #Guardar archivos excel
library(scales) #Formatear visualización de texto

# Otra alternativa
# install.packages("pacman") #Quitar "#" al inicio para ejecutar
library(pacman)
p_load(tidyverse, readxl, janitor, openxlsx, scales)

# Pregunta 1 --------------------------------------------------------------
homicidios <- read_excel('data/Base_de_Datos_VHC_2018_2025.xlsx') |> 
  clean_names() 

glimpse(homicidios)

# Pregunta 2 --------------------------------------------------------------
homicidios <- homicidios |> 
  rename(
    nacionalidad = nacion_recod,
    lugar_agresion = lug_agr_recod,
    comuna = comun_agr, 
    region = nom_reg,
    anio = id_ano,
    hora = hora_recod
  )

# Pregunta 3 --------------------------------------------------------------
proyeccion_2024 <- read_excel(
  'data/estimaciones-y-proyecciones-de-población-1992-2070_base-2024_tabulados.xlsx',
  sheet = 3,
  skip = 6
) |> 
  slice(2)

# Pregunta 4 --------------------------------------------------------------
proyeccion_2024_long <- proyeccion_2024 |> 
  pivot_longer(!1, 
               names_to = "anio",
               values_to = "poblacion") |> 
  select(-1) |> 
  mutate(anio = as.numeric(anio))

# Pregunta 5 --------------------------------------------------------------
homicidios_anual <- homicidios |> 
  count(anio, name = "n_homicidios")

# Pregunta 6 --------------------------------------------------------------
homicidios_anual <- homicidios_anual |> 
  left_join(proyeccion_2024_long, join_by(anio)) |> 
  mutate(tasa = round(n_homicidios/poblacion *100000,1))

# Pregunta 7 --------------------------------------------------------------
p1 <- ggplot(homicidios_anual, aes(x = anio, y = tasa))+
  geom_line(color = "red3", linewidth = 2)

p1

# Pregunta 8 --------------------------------------------------------------
p1_v2 <- p1 +
  geom_point(size = 2.5)+
  scale_x_continuous(breaks = seq(2018,2025,1))+ 
  scale_y_continuous(limits = c(0,7))

p1_v2

# Pregunta 9 --------------------------------------------------------------
p1_v3 <- p1_v2 +
  geom_text(
    aes(label = tasa),
    vjust = -1,
    fontface = "bold"
  ) +
  labs(title = "Tasa cada 100 mil habitantes de víctimas de homicidios consumados",
       x = "Año",
       y = "Tasa",
       caption = "Fuente: Elaboración propia en base a datos del
       Centro para la Prevención de Homicidios y Delitos Violentos") +
  theme_classic()

p1_v3

# Pregunta 10 --------------------------------------------------------------
homicidios_mensual <- homicidios |> 
  group_by(anio, mes2) |> 
  summarise(n_homicidios = n())

homicidios_promedio <- homicidios_mensual |> 
  filter(anio != 2025) |> 
  group_by(mes2) |> 
  summarise(promedio_historico = round(mean(n_homicidios),0))

# Pregunta 11 -------------------------------------------------------------
base_p2 <- homicidios_mensual |> 
  filter(anio == 2025) |> 
  left_join(homicidios_promedio, join_by(mes2))

base_p2 <- base_p2 |> 
  mutate(
    mes = ymd(paste("2025", mes2, "01"))
  )

# Opción 2
base_p2 <- base_p2 |> 
  mutate(
    mes = make_date(
      month = mes2,
      year = 2025,
      day = 1
    ))

# Pregunta 11 -------------------------------------------------------------
azul <- "#173277"
verde <- "#46B9AE"

p2 <- ggplot(base_p2, aes(x = mes)) +
  geom_col(aes(y = n_homicidios), fill = azul) +
  geom_text(aes(y = n_homicidios/2, label = n_homicidios),
            vjust = 0,
            color = "white",
            fontface = "bold") +
  scale_x_date(date_breaks = "1 month", date_labels = "%b")

p2

# Pregunta 12 -------------------------------------------------------------
p2_v2 <- p2 + 
  geom_line(aes(y = promedio_historico), linewidth = 1.5, color = verde) +
  geom_point(aes(y = promedio_historico), size = 2, color = verde) +
  geom_text(aes(y = promedio_historico, label = promedio_historico),
            vjust = -.9,
            color = verde,
            fontface = "bold")

p2_v2

# Pregunta 13 -------------------------------------------------------------
p2_v3 <- p2_v2 +
  scale_y_continuous(breaks = seq(0,125,25),
                     limits = c(0,125))+
  labs(title = "N° de víctimas de homicidios consumados durante 2025 según mes y promedio mensual 2018-2024",
       x = "",
       y = "Frecuencia") +
  theme_minimal()

p2_v3

# Pregunta 14 -------------------------------------------------------------
homicidios_hora_2025 <- homicidios |> 
  filter(anio == 2025) |> 
  group_by(hora, dia) |> 
  summarise(cantidad = n()) |> 
  ungroup() |> 
  mutate(hora = factor(hora),
         dia = factor(dia)) 

levels_dia <- c(
  "Lunes",
  "Martes",
  "Miércoles",
  "Jueves",
  "Viernes",
  "Sábado",
  "Domingo"
)

homicidios_hora_2025 <- homicidios_hora_2025 |> 
  mutate(hora = fct_relevel(hora, rev),
         dia = fct_relevel(dia, levels_dia))

# Pregunta 15 -------------------------------------------------------------
p3 <- ggplot(
  homicidios_hora_2025,
  aes(y = hora, x = dia, fill = cantidad)
) +
  geom_tile(color = "white", linewidth = 1) +
  geom_text(aes(label = cantidad), fontface = "bold", size = 8) +
  scale_fill_distiller(palette = "Spectral") +
  # scale_fill_viridis_c(direction = -1) + #Para usar los colores del informe
  theme_minimal(base_size = 18) +
  labs(
    title = "Concentración Temporal",
    x = "",
    y = "",
    fill = "Frecuencia"
  )

p3

##########################################################
#Parte 2#
##########################################################

# Pregunta 16 -------------------------------------------------------------
homicidios_condenas <- homicidios |> 
  group_by(anio, condenas) |> 
  summarise(n_homicidios = n())

homicidios_condenas <- homicidios_condenas |> 
  group_by(anio) |> 
  mutate(pct = n_homicidios/sum(n_homicidios))

ggplot(homicidios_condenas, aes(x = anio, y = pct, color = condenas))+
  geom_line(linewidth = 1.5, alpha = .8) +
  geom_point(size = 2) +
  geom_text(
    aes(label = percent(pct, accuracy = 1)),
    vjust = -0.8,
    size  = 3,
    show.legend = F
  ) +
  scale_colour_viridis_d() +
  labs(
    x = "Año",
    y = "Porcentaje",
    color = "Condenas"
  ) +
  scale_y_continuous(labels = label_percent()) +
  theme_classic()

# Pregunta 17 ----------------------------------------------------------------------
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
  scale_x_continuous(labels = label_percent()) +
  labs(x = "Tasa de Pobreza", y = "Tasa de Homicidios 2024") +
  theme_bw(base_size = 12)

# Pregunta 18 -------------------------------------------------------------
ggplot(homicidios_wide, aes(
  x = tasa_pobreza,
  y = tasa_hom_2024,
  color = zona)
) +
  geom_point(alpha = .5) +
  geom_smooth(se = F, method = "lm") +
  scale_x_continuous(labels = label_percent()) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "Tasa de Pobreza",
       y = "Tasa de Homicidios 2024",
       color = "Zona Geográfica") +
  theme_bw(base_size = 14)

# Pregunta 19: BONUS ------------------------------------------------------
homicidios_mapa <- read_rds("data/homicidios_sf.rds")
library(sf)

homicidios_mapa |> 
  filter(region == "Antofagasta") |> 
  ggplot(aes(fill = tasa_hom_2024)) +
  geom_sf(col = "black", alpha = 0.8) +
  scale_fill_fermenter(palette = "Oranges", direction = 1) +
  geom_sf_label(aes(label = paste(comuna, round(tasa_hom_2024,1)))) +
  # geom_text(aes(label = comuna)) +
  theme_minimal()





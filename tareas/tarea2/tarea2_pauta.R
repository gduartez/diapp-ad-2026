library(pacman)
# easystats::install_suggested()
p_load(
  tidyverse,
  readxl,
  performance,
  parameters,
  sjPlot,
  ggeffects,
  estimatr,
  marginaleffects,
  broom,
  moderndive,
  modelsummary,
  wooldridge,
  infer
)

theme_set(theme_sjplot(base_size = 16))

#!Ojo si cargan easystats porque choca clean_names() de janitor con clean_names() de insights!

# Pregunta 1: Carga de datos ---------------------------------------------
homicidios1 <- read_excel('data/clean/homicidios_tarea2.xlsx')

glimpse(homicidios1)

homicidios1 |>
  group_by(region) |>
  slice_max(hom_totales, n = 1) |>
  select(nombre_comuna, hom_totales)

# Pregunta 2: Creación de variables ---------------------------------------------
homicidios2 <- homicidios1 |>
  mutate(
    urbana = if_else(categoria_pndr == "Urbana", 1, 0),
    pobreza_pct = tasa_pobreza * 100,
    migrantes_pct = tasa_migrantes * 100
  )

homicidios2 |>
  count(urbana)

homicidios2 <- homicidios2 |>
  mutate(urbana = factor(urbana, labels = c("Rural o Mixta", "Urbana")))

homicidios2 |>
  count(urbana)

# Pregunta 3: Scatterplot ---------------------------------------------
ggplot(
  homicidios2,
  aes(x = migrantes_pct, y = tasa_homicidios24, color = urbana)
) +
  geom_point(alpha = 0.8) +
  scale_color_sjplot() +
  labs(
    x = "Población Migrante (%)",
    y = "Tasa de homicidios cada 100.000 hab.",
    color = "Clasificación PNDR"
  )

# Pregunta 4: MRLS ---------------------------------------------
reg1 <- lm(tasa_homicidios24 ~ migrantes_pct, data = homicidios2)

model_parameters(reg1)

# Pregunta 5: MRLS Dummy ---------------------------------------------
reg2 <- lm(tasa_homicidios24 ~ urbana, data = homicidios2)

model_parameters(reg2)

# Pregunta 6: MRLM ---------------------------------------------
reg3 <- lm(
  tasa_homicidios24 ~ esc_promedio_s18 + urbana,
  data = homicidios2
)

model_parameters(reg3)

ggplot(
  homicidios2,
  aes(x = esc_promedio_s18, y = tasa_homicidios24, color = urbana)
) +
  geom_point(alpha = 0.4) +
  geom_parallel_slopes(se = FALSE) +
  labs(
    x = "Escolaridad promedio de la población mayor de edad",
    y = "Tasa de homidios cada 100.000 habitantes",
    color = "Clasificación PNDR"
  )

# Pregunta 7: MRLM Interacción ---------------------------------------------
reg4 <- lm(
  tasa_homicidios24 ~ pobreza_pct + migrantes_pct + urbana * esc_promedio_s18,
  data = homicidios2
)

model_parameters(reg4)
plot_model(reg4, type = "pred", terms = c("esc_promedio_s18", "urbana"))

# Pregunta 8: Términos cuadráticos ---------------------------------------------
reg5 <- lm(
  tasa_homicidios24 ~ pobreza_pct +
    migrantes_pct +
    urbana * esc_promedio_s18 +
    densidad_poblacional +
    I(densidad_poblacional^2),
  # ingreso_pp +
  # I(ingreso_pp^2), # densidad_poblacional + I(densidad_poblacional^2),
  data = homicidios2
)

model_parameters(reg5)

plot_model(reg5, type = "pred", terms = "densidad_poblacional [all]") +
  labs(
    title = "Tasa de homicidios predicha según densidad poblacional",
    x = "Densidad poblacional (hab/km2)",
    y = "Tasa de homidios cada 100.000 habitantes"
  )

modelsummary(
  list(reg4, reg5),
  stars = T
)

# reg5_2 <- lm(
#   tasa_homicidios24 ~ pobreza_pct +
#     esc_promedio_s18 +
#     urbana * migrantes_pct +
#     densidad_poblacional +
#     I(densidad_poblacional^2),
#   data = homicidios2
# )

# tab_model(reg5, reg5_2, p.style = "stars")
# model_parameters(reg5_2)
# modelsummary(
#   list(reg5, reg5_2),
#   stars = T
# )

# ggpredict(reg5_2, terms = "densidad_poblacional [all]") |>
#   plot()

# Pregunta 9: Modelo ampliado ---------------------------------------------
reg6 <- lm(
  tasa_homicidios24 ~
    pobreza_pct +
    migrantes_pct +
    esc_promedio_s18 +
    densidad_poblacional +
    I(densidad_poblacional^2) +
    tasa_drogas24,
  data = homicidios2
)
model_parameters(reg6)

tab_model(reg5, reg6, p.style = "numeric_stars")

# reg6 <- lm(
#   tasa_homicidios24 ~
#     migrantes_pct +
#     pobreza_pct +
#     urbana +
#     tasa_drogas24 +
#     # log(tasa_drogas24) +
#     # tasa_secuestros24 +
#     # tasa_extorsiones24 +
#     log(ingreso_pp) +
#     log(densidad_poblacional),
#   # I(densidad_poblacional^2),
#   data = homicidios2
# )

# model_parameters(reg6)

modelsummary::modelsummary(list(reg1, reg3, reg6), stars = T)

# Pregunta 10: Comparación de modelos ---------------------------------------------
compare_performance(reg1, reg2, reg3, reg4, reg5, reg6, rank = TRUE)

homicidos_f <- homicidios2 |>
  filter(!is.na(tasa_drogas24))

reg1_f <- lm(
  tasa_homicidios24 ~ migrantes_pct,
  data = homicidos_f
)

reg4_f <- lm(
  tasa_homicidios24 ~ pobreza_pct + migrantes_pct + urbana * esc_promedio_s18,
  data = homicidos_f
)

# reg5_f <- lm(
#   tasa_homicidios24 ~ pobreza_pct +
#     migrantes_pct +
#     urbana * esc_promedio_s18 +
#     densidad_poblacional +
#     I(densidad_poblacional^2),
#   data = homicidos_f
# )

# reg6_f <- lm(
#   tasa_homicidios24 ~
#     pobreza_pct +
#     migrantes_pct +
#     esc_promedio_s18 +
#     densidad_poblacional +
#     I(densidad_poblacional^2) +
#     tasa_drogas24,
#   data = homicidos_f
# )

anova(reg1_f, reg4_f, reg6)

# Pregunta 11: Diagnóstico y errores robustos ---------------------------------------------
check_model(reg6)
check_heteroscedasticity(reg6)
check_collinearity(reg6)

reg6_robust <- lm_robust(
  tasa_homicidios24 ~
    pobreza_pct +
    migrantes_pct +
    esc_promedio_s18 +
    densidad_poblacional +
    I(densidad_poblacional^2) +
    tasa_drogas24,
  data = homicidios2
)

tab_model(reg6, reg6_robust, p.style = "numeric_stars")

# Pregunta 12: Logit/probit ---------------------------------------------
check_model(reg6_robust)

# Pregunta 12: Logit/probit ---------------------------------------------
homicidios_logit <- homicidios2 |>
  mutate(
    homicidio24_bin = if_else(hom_2024 > 0, 1, 0)
  )

logit1 <- glm(
  homicidio24_bin ~
    pobreza_pct +
    migrantes_pct +
    esc_promedio_s18 +
    densidad_poblacional +
    I(densidad_poblacional^2) +
    tasa_drogas24,
  family = binomial(link = "logit"),
  data = homicidios_logit
)

avg_slopes(logit1)

?avg_slopes

# Pregunta 13: Reflexión econométrica y causalidad ---------------------------------------------

# ¿Por qué los resultados no permiten afirmar
# que un mayor porcentaje de población migrante cause una mayor
# #  tasa de homicidios?

# Bonus ------------------------------------------------------------------
homicidios_r2 <- homicidios2 |>
  select(tasa_homicidios24:last_col(), -tasa_migrantes)

reg_bonus <- lm(tasa_homicidios24 ~ ., data = homicidios_r2)

summary(reg_bonus)
check_model(reg_bonus)

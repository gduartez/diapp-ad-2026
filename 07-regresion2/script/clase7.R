# 0. Cargo paquetes y datos -----------------------------------------------
library(pacman)
easystats::install_suggested()
p_load(easystats, tidyverse, sjPlot,
       wooldridge, ggeffects, lmtest, estimatr,
       broom, moderndive, modelsummary)
theme_set(theme_sjplot())

data(wage1)

# Creo factor de female
salarios <- wage1 |> 
  mutate(female = factor(female,
                         labels = c("Hombre", "Mujer"))
         )

# Corroboro etiquetas
salarios |> count(female)
wage1 |> count(female)

# 1. Dummy S/interacción -------------------------------------------------------
m1 <- lm(wage ~ female, data = salarios)

## Resumo resultados -------------------------------------------------------
(tbl_m1 <- model_parameters(m1))
(tbl_m1_v2 <- get_regression_table(m1))
ggpredict(m1, terms = "female")

## Tablas Estilo Paper -----------------------------------------------------
# sjPlot
tab_model(m1,
          show.reflvl = T,
          show.intercept = T,
          p.style = "numeric_stars"
          # file = "output/tabla_m1.doc"
          )

# modelsummary
modelsummary(list("Regresión Simple con dummy" = m1),
              stars = T,
              gof_map = c("nobs", "r.squared", "adj.r.squared" )
              )

## Gráficos ----------------------------------------------------------------
# Graficar valores para ambos grupos
plot_model(m1, type = "pred")

# Lo mismo
ggeffect(m1) |> 
  plot()

# Si quiero ver el parámetro estimado
plot_model(m1, show.values = T)

# 2. Múltiple más dummy ---------------------------------------------------
m2 <- lm(wage ~ female + educ, data = salarios)

parameters::model_parameters(m2)
get_regression_table(m2)

report(m2)

# Graficar modelo
plot_models(m2, m2_2)
plot_model(m2, type = "pred")

ggpredict(m2, terms = "female")
ggeffect(m2) |> 
  plot()

#Tabla
tab_model(m1, m2,
          show.reflvl = T,
          show.intercept = T,
          p.style = "numeric_stars"
          # file = "output/tabla_m1.doc"
)

modelsummary(list(
  "MRS con dummy" = m1,
  "MRM aditivo con dummy y educación (s/interacción)" = m2
  ),
  stars = T,
  estimate = "{estimate}{stars}<br>({std.error})",
  statistic = c(
               "IC 95%" = "[{conf.low}, {conf.high}]",
               "P" = "{p.value}"),
  shape = term ~ model + statistic,
  conf_level = 0.95,
  gof_map = c("nobs", "r.squared", "adj.r.squared")
)

plot_model(m2, type = "pred")
# 3. Dummy con interacción ------------------------------------------------
m3 <- lm(wage ~ female:educ, data = salarios)

parameters::model_parameters(m3)

plot_model(m3, type = "int")
plot_model(m3, type = "pred", terms = c("educ","female"))

salarios |>  
  ggplot(aes(x = educ, y = wage)) +
  geom_point(aes(col = female)) +
  theme_minimal() +
  theme(legend.position = "none") +
  geom_smooth(aes(col = female),
              method = "lm", se = T)

plot_model(m3, type = "pred", terms = c("female","educ [5, 10, 15]"))

# 4. Dummy con interacción y regresores aparte ----------------------------
m4 <- lm(wage ~ female*educ, data = salarios)

plot_model(m4, type = "pred", terms = c("educ","female"))

plot_model(m4, type = "int")

tab_model(m3, m4,
          show.reflvl = T,
          show.intercept = T,
          p.style = "numeric_stars"
          # file = "output/tabla_m1.doc"
)


report(m4)

modelsummary(list(
  "MRS con dummy" = m1,
  "MRM con dummy (s/interacción)" = m2,
  "MRM de pendientes por grupo con intercepto común" = m3,
  "MRM con interceptos y pendientes diferenciadas por sexo" = m4
),
stars = T,
estimate = "{estimate}{stars}<br>({std.error})",
statistic = c(
  "IC 95%" = "[{conf.low}, {conf.high}]",
  "P" = "{p.value}"),
shape = term ~ model + statistic,
conf_level = 0.95,
gof_map = c("nobs", "r.squared", "adj.r.squared")
)


# 5. Modelo más complejo --------------------------------------------------
m5 <- lm(wage ~ female*educ + exper, data = salarios)

tab_model(m4,m5,
          show.reflvl = T,
          show.intercept = T,
          p.style = "numeric_stars"
          # file = "output/tabla_m1.doc"
)

# 6. Términos cuadráticos ----------------------------------------------------
m6 <- lm(wage ~ female*educ + poly(exper, 2, raw = T), data = salarios)
m6 <- lm(wage ~ female*educ + exper + I(exper^2), data = salarios)

model_parameters(m6)

tab_model(m5,m6,
          show.reflvl = T,
          show.intercept = T,
          p.style = "numeric_stars"
          # file = "output/tabla_m1.doc"
)

modelsummary(list(
  "MRM con interceptos y pendientes diferenciadas por sexo" = m4,
  "MRM 4 + exper" = m5, 
  "MRM 4 con términos cuadráticos de exper" = m6
),
stars = T,
estimate = "{estimate}{stars}<br>({std.error})",
statistic = c(
  "IC 95%" = "[{conf.low}, {conf.high}]",
  "P" = "{p.value}"),
shape = term ~ model + statistic,
conf_level = 0.95,
gof_map = c("nobs", "r.squared", "adj.r.squared")
)

plot_model(
  m6,
  type = "pred",
  terms = c("exper [all]", "female")
) +
  labs(
    title = "Salario predicho según experiencia",
    x = "Años de experiencia",
    y = "Salario predicho por hora"
  )

b <- coef(m6)

efecto_exp <- tibble(
  exper = seq(
    min(salarios$exper, na.rm = TRUE),
    max(salarios$exper, na.rm = TRUE),
    length.out = 100
  ),
  efecto_marginal = b["exper"] + 2 * b["I(exper^2)"] * exper
)

ggplot(efecto_exp, aes(x = exper, y = efecto_marginal)) +
  geom_line(linewidth = 1) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = "Efecto marginal de la experiencia",
    subtitle = "Calculado como β_exper + 2β_exper² × experiencia",
    x = "Años de experiencia",
    y = "Efecto marginal sobre el salario por hora"
  ) +
  theme_minimal()

library(marginaleffects)

plot_slopes(
  m6,
  variables = "exper",
  condition = "exper"
)

# 7. Comparar modelos -----------------------------------------------------
compare_parameters(m5,m6)
compare_performance(m5,m6)

test_performance(m5,m6)
anova(m5,m6)

# 8. Validar supuestos ----------------------------------------------------

# A) chequeo general ------------------------------------------------------
check_model(m6)

# B) Chequeo normalidad ---------------------------------------------------
check_normality(m6)
shapiro.test(m1$residuals)

# C) Chequeo heterocedasticidad -------------------------------------------
check_heteroskedasticity(m6)
bptest(m6)

m6_r <- lm_robust(wage ~ female*educ + exper + I(exper^2), data = salarios)

tab_model(m6,m6_r)

test_performance(m4,m6_r)

parameters::compare_parameters(m2, m2_2)
performance::compare_performance(m2, m2_2, rank = TRUE)

anova(m6, m6_r)

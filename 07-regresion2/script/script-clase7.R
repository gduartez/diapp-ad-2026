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


# Ejercicio Aplicado 1 ----------------------------------------------------
modelo <- lm(wage ~ educ + exper + tenure + I(exper^2) + I(tenure^2), data = wage1)
tidy(modelo)

modelo <- lm(wage ~ educ + exper + tenure + I(exper^2) + I(tenure^2) , data = wage1)

me_exper <- plot_slopes(modelo, variables = "exper", condition = "exper") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Efecto marginal de la experiencia",
       x = "Años de experiencia", y = "Efecto de +1 año")

dplyr::mutate()
me_tenure <- plot_slopes(modelo, variables = "tenure", condition = "tenure") +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Efecto marginal de la antigüedad",
       x = "Años en la empresa (tenure)", y = "Efecto de +1 año")

me_exper | me_tenure   # patchwork: lado a lado

pred_exper  <- plot_model(modelo, type = "pred", terms = "exper [all]") +
  labs(title = "Salario predicho según experiencia",
       x = "Años de experiencia", y = "Salario por hora")

pred_tenure <- plot_model(modelo, type = "pred", terms = "tenure [all]") +
  labs(title = "Salario predicho según antigüedad",
       x = "Años en la empresa", y = "Salario por hora")

pred_exper | pred_tenure

# Ejercicio Aplicado 2 ----------------------------------------------------


# Ejercicios --------------------------------------------------------------
library(tidyverse)
library(easystats)
library(sjPlot)
library(ggeffects)
library(estimatr)
library(marginaleffects)
library(broom)
library(moderndive)
library(modelsummary)
library(wooldridge)

casas <- hprice1 |>
  mutate(colonial = factor(colonial, labels = c("No colonial", "Colonial")))

casas |> count(colonial)
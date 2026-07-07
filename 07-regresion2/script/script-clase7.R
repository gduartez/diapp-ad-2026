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


# Ejercicio Aplicado 2 ----------------------------------------------------

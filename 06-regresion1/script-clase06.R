library(wooldridge)
library(tidyverse)
library(broom)

modelo1 <- lm(wage ~ educ, data = wage1)
summary(modelo1)

tabla1_m1 <- tidy(modelo1)
tabla2_m2 <- glance(modelo1)

# Modelo 2
reg_mtcars <- lm(hp ~ mpg, data = mtcars)
names(reg_mtcars)

coef(reg_mtcars)
summary(reg_mtcars)


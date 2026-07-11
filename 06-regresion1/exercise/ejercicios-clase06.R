library(tidyverse)
library(broom)
library(moderndive)
library(wooldridge)

data(hprice1)


# Pregunta 1 --------------------------------------------------------------
casas <- hprice1 |>
  select(price, sqrft, bdrms, lotsize, lprice, lsqrft)

glimpse(casas)

# Pregunta 2 --------------------------------------------------------------
summary(casas)

ggplot(casas, aes(x = sqrft, y = price)) +
  geom_point(alpha = 0.6, color = "steelblue") +
  geom_smooth(method = "lm", se = F, color = "red3") +
  labs(x = "Superficie (pies cuadrados)",
       y = "Precio (miles de USD)") +
  theme_classic(base_size = 14)

# Pregunta 3 --------------------------------------------------------------
reg1 <- lm(price ~ sqrft, data = casas)
summary(reg1)

get_regression_table(reg1)

# Pregunta 4 --------------------------------------------------------------
glance(reg1) |>
  select(r.squared, nobs)

# Cálculo manual: var(y_gorro) / var(y)
var(fitted(reg1)) / var(casas$price) # STC = SEC + SRC. R2 = SEC/STC

# Pregunta 5 --------------------------------------------------------------
get_regression_table(reg1)

# Pregunta 6 --------------------------------------------------------------
reg2 <- lm(lprice ~ lsqrft, data = casas)
reg2 <- lm(log(price) ~ log(sqrft), data = casas)

tidy(reg2)
summary(reg2)

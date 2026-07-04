library(tidyverse)
library(gapminder)
library(gganimate)
library(scales)

# Datos: América 2007
sudamerica <- gapminder |>
  filter(year == 2007, continent == "Americas")

# Modelo OLS real
mod_ols <- lm(lifeExp ~ gdpPercap, data = sudamerica)
b0_ols <- coef(mod_ols)[1]
b1_ols <- coef(mod_ols)[2]
ssr_ols <- round(sum(residuals(mod_ols)^2), 1)

# Probar muchas pendientes (alrededor de la OLS)
pendientes <- seq(b1_ols * 4, b1_ols * -1, length.out = 41)

frames <- map_dfr(pendientes, function(b1) {
  # Intercepto pasa por el punto medio (x̄, ȳ)
  b0 <- mean(sudamerica$lifeExp) - b1 * mean(sudamerica$gdpPercap)
  sudamerica |>
    mutate(
      pendiente = b1,
      pred = b0 + b1 * gdpPercap,
      ssr  = sum((lifeExp - pred)^2)
    )
})

p <- ggplot(frames, aes(x = gdpPercap, y = lifeExp)) +
  # Recta OLS estática (siempre visible, en gris)
  geom_abline(intercept = b0_ols, slope = b1_ols,
              color = "grey70", linewidth = 1.2, linetype = "dashed") +
  # Recta que rota
  geom_abline(aes(intercept = mean(sudamerica$lifeExp) - pendiente * mean(sudamerica$gdpPercap),
                  slope = pendiente),
              color = "steelblue", linewidth = 1.5) +
  # Residuos
  geom_segment(aes(xend = gdpPercap, yend = pred), color = "red3",
               linewidth = 0.8, linetype = "dashed") +
  # Puntos observados y predichos
  geom_point(size = 3) +
  geom_point(aes(y = pred), shape = 1, size = 3, color = "grey40") +
  # Etiqueta con SSR dinámico vs OLS
  geom_label(
    aes(x = 3000, y = 100,
        label = paste0(
          "β1 (x1000) = ", sprintf("%.5f", pendiente*1000),
          "\nΣ residuos² = ", format(round(ssr), big.mark = "."),
          "\nΣ residuos² OLS = ", format(ssr_ols, big.mark = ".")
        )),
    size = 4, fontface = "bold", hjust = 0,
    fill = "white", label.size = 0.5
  ) +
  labs(x = "PIB per cápita (USD)",
       y = "Esperanza de vida (años)",
       title = "MCO (OLS) busca la pendiente que minimiza la suma de residuos al cuadrado",
       subtitle = "Recta gris punteada = MCO y Recta azul = Diferentes pendientes ") +
  scale_x_continuous(labels = scales::label_currency()) +
  theme_classic(base_size = 14) +
  theme(plot.title = element_text(face = "bold")) +
  transition_states(pendiente, transition_length = 1, state_length = 0.5) +
  ease_aes("cubic-in-out")

anim <- animate(p, nframes = 350, fps = 10, width = 750, height = 480,
                renderer = gifski_renderer())

anim_save("img/ols_animacion_gap.gif", animation = anim)

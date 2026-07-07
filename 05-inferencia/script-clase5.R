

# Pregunta aplicada 1 -----------------------------------------------------
library(infer)
library(dplyr)

# Muestra de ejemplo: 250 personas, variable "respuesta" (si/no)
muestra_ej <- tibble(
  respuesta = sample(c("si", "no"), 250, replace = TRUE, prob = c(0.4, 0.6))
)

muestra_ej |>
  specify(response = respuesta, success = "si") |>
  generate(reps = 500, type = "bootstrap") |>
  calculate(stat = "prop") |>
  visualise()

# Pregunta aplicada 2 -----------------------------------------------------

library(infer)
library(dplyr)

set.seed(123)

lanzamientos <- tibble(
  resultado = c(rep("cara", 60), rep("sello", 40))
)

p_hat <- lanzamientos |>
  specify(response = resultado, success = "cara") |>
  calculate(stat = "prop")

lanzamientos |>
  specify(response = resultado, success = "cara") |>
  hypothesise(null = "point", p = 0.5) |>
  generate(reps = 1000, type = "draw") |>
  calculate(stat = "prop") |>
  get_p_value(obs_stat = p_hat, direction = "both")


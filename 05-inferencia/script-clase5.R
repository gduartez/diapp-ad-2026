

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
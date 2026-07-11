# Cruce -------------------------------------------------------------------
limpiar_comuna <- function(x) {
  x |>
    str_to_lower() |>
    str_trim() |>
    str_replace_all("'", "") |>
    str_replace_all("-", " ") |>
    str_squish() |>
    stringi::stri_trans_general("Latin-ASCII")
}

pobreza_clean <- pobreza |>
  mutate(comuna_join = limpiar_comuna(comuna))

homicidios_clean <- homicidios_wide |>
  mutate(comuna_join = limpiar_comuna(comuna))

# Veo cuáles comunas no cruzan
homicidios_clean |>
  anti_join(pobreza_clean, by = "comuna_join") |>
  select(comuna)

# Vuelvo a limpiar
pobreza_clean <- pobreza |>
  mutate(comuna_join = limpiar_comuna(comuna))

homicidios_clean <- homicidios_wide |>
  mutate(
    comuna = comuna |>
      replace_values("Paiguano" ~ "Paihuano", "Treguaco" ~ "Trehuaco")
  ) |>
  mutate(comuna_join = limpiar_comuna(comuna))

homicidios_comunales <- pobreza_clean |>
  left_join(
    homicidios_clean |>
      select(-comuna),
    join_by(comuna_join)
  )

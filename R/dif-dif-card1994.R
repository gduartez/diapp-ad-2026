# 0. Librerías ------------------------------------------------------------
library(pacman)

p_load(tidyverse,
       janitor,
       wooldridge,
       haven,
       estimatr,
       scales,
       paletter
       )

data <- read_dta('../../../datasets/Card-Krueger-1994-data.dta') |> 
  mutate(date2 = lubridate::mdy(date2)) |> 
  # chain value label
  mutate(chain = case_when(chain == 1 ~ "bk",
                           chain == 2 ~ "kfc",
                           chain == 3 ~ "roys",
                           chain == 4 ~ "wendys")) |> 
  # state value label
  mutate(state = case_when(nj == 1 ~ "New Jersey",
                           nj == 0 ~ "Pennsylvania"), .after = nj) |> 
  # Region dummy
  mutate(region = case_when(south == 1 ~ "southj",
                            central == 1 ~ "centralj",
                            north == 1 ~ "northj",
                            shore == 1 ~ "shorej",
                            pa1 == 1 ~ "phillypa",
                            pa2 == 1 ~ "eastonpa"), .after = state) |> 
  # # meals value label
  # mutate(meals = case_when(meals1 == 0 ~ "none",
  #                          meals1 == 1 ~ "free meals",
  #                          meals1 == 2 ~ "reduced price meals",
  #                          meals1 == 3 ~ "both free and reduced price meals")) |> 
  # # meals value label
  # mutate(meals2 = case_when(meals2 == 0 ~ "none",
  #                           meals2 == 1 ~ "free meals",
  #                           meals2 == 2 ~ "reduced price meals",
  #                           meals2 == 3 ~ "both free and reduced price meals")) |> 
  # status2 value label
  mutate(status2 = case_when(status2 == 0 ~ "refused second interview",
                             status2 == 1 ~ "answered 2nd interview",
                             status2 == 2 ~ "closed for renovations",
                             status2 == 3 ~ "closed permanently",
                             status2 == 4 ~ "closed for highway construction",
                             status2 == 5 ~ "closed due to Mall fire")) |> 
  # mutate(comp_owned = if_else(comp_owned == 1, "yes", "no")) |> 
  mutate(bonus1 = if_else(bonus1 == 1, "yes", "no")) |> 
  mutate(interview2 = if_else(interview2 == 1, "phone", "personal")) |> 
  select(-nj, -(south:shore))

# Long data
# Structural variables
structure <- data %>%
  select(storeid, chain, comp_owned, state, region)

# Wave 1 variables
wave1 <- data %>%
  select(-ends_with("2"), - names(structure)) %>%
  rename_all(~str_remove(., "1"))  %>%
  mutate(observation = "February 1992", t = 0) %>%
  bind_cols(structure) 

# Wave 2 variables
wave2 <- data %>%
  select(ends_with("2")) |> 
  rename_all(~str_remove(., "2"))  |> 
  mutate(observation = "November 1992",
         t = 1) |> 
  bind_cols(structure) 

# Final dataset
df <- bind_rows(wave1, wave2) |> 
  relocate(storeid, chain, state,region, t, wage_start) |> 
  mutate(emptot = empft + nmgrs + 0.5 * emppt, .after = wage_start) |> 
  mutate(pct_fte = empft / emptot * 100, .after = wage_start) |> 
  mutate(d = if_else(state == "New Jersey", 1, 0), .after = t)
  
# data2 <- read_table2('../../../datasets/njmin/public.dat', col_names = F)

# Tabla 1 -----------------------------------------------------------------

data |> 
  count(nj)


# Tabla 2 -----------------------------------------------------------------


# Gráfico 1 ---------------------------------------------------------------
df_feb <- df |>
  mutate(
    # agrupo en saltos de 0.10 empezando en 4.25
    wage_group = round(floor((wage_start - 4.26) / 0.10) * 0.10 + 4.26,2),
    .after = wage_start
  ) |> 
  mutate(wage_range = cut(
    wage_start,
    breaks = seq(4.25, 5.55, 0.10),
    include.lowest = TRUE,
    right = F
  ), .after = wage_group)|> 
  drop_na(wage_start)

df_feb |> 
  count(t, state, wage_range) |>
  group_by(t, state) |>
  mutate(percent = n / sum(n)) |>
  ggplot(aes(x = wage_range, y = percent, fill = state)) +
  geom_col(position = "dodge", color = "black",) +
  scale_fill_manual(values = c("New Jersey" = "black", "Pennsylvania" = "white")) +
  labs(
    title = "Distribución de los salarios iniciales por Estado",
    x = "Wage Range",
    y = "Percent of Stores",
    fill = NULL
  ) +
  facet_wrap(vars(t),nrow = 2, scales = "free")+
  scale_y_continuous(labels = scales::percent_format(), breaks = pretty_breaks(10)) +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

df_feb_sum <- df_feb |>
  count(state, wage_group) |>
  group_by(state) |>
  mutate(pct =  n / sum(n))

df_feb_sum |>
  ggplot(aes(x = factor(wage_group),
             y = pct,
             fill = state)) +
  geom_col(position = "dodge", color = "black") +
  scale_fill_manual(values = c("New Jersey" = "black",
                               "Pennsylvania" = "white")) +
  labs(
    title = "February 1992",
    x = "Wage Range",
    y = "Percent of Stores",
    fill = NULL
  ) +
  scale_x_discrete(breaks = seq(4.25,5.55, by = .1)) +
  scale_y_continuous(labels = scales::percent_format()) +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

df |>
  filter(t == 0) |>
  ggplot(aes(x = wage_start, fill = state)) +
  geom_histogram(
    aes(y = after_stat(100 * count / sum(count))),  # porcentaje
    binwidth = 0.10,
    boundary = 4.25,        # para que los bins sean [4.25,4.35), [4.35,4.45) ...
    position = "dodge",
    color = "black"
  ) +
  scale_fill_manual(values = c("New Jersey" = "black",
                               "Pennsylvania" = "white")) +
  scale_x_continuous(breaks = seq(4.25, 5.55, by = 0.10)) +
  labs(
    title = "February 1992",
    x = "Wage Range",
    y = "Percent of Stores",
    fill = NULL
  ) +
  theme_minimal(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

df |> 
  filter(t == 0) |> 
  ggplot(aes(wage_start, fill = state, group = state)) + 
  geom_histogram(aes(y = after_stat(count / sum(count))), position = "dodge", color = "black") +
  scale_fill_manual(values = c("New Jersey" = "black", "Pennsylvania" = "white")) +
  # scale_x_continuous(breaks = seq(4.25,5.55, by = .1)) +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_x_continuous(breaks = seq(4.25, 5.55, by = 0.10)) +
  scale_fill_paletteer_d("nationalparkcolors::Acadia") +
  labs(
    title = "February 1992",
    x = "Wage Range",
    y = "Percent of Stores"
  ) +
  theme_minimal()

# Opción Philipp Leppert
df |> 
  filter(t == 0) %>%
  ggplot(aes(wage_start, fill = state)) +
  geom_histogram(aes(y=c(..count..[..group..==1]/sum(..count..[..group..==1]),
                         ..count..[..group..==2]/sum(..count..[..group..==2]))*100),
                 alpha=0.8, position = "dodge", bins = 23) +
  
  labs(title = "February 1992", x = "Wage range", y = "Percent of stores", fill = "") +
  scale_fill_paletteer_d("nationalparkcolors::Acadia") +
  theme_minimal()

hist.nov <- card_krueger_1994_mod %>%
  filter(observation == "November 1992") %>%
  ggplot(aes(wage_st, fill = state)) +
  geom_histogram(aes(y=c(..count..[..group..==1]/sum(..count..[..group..==1]),
                         ..count..[..group..==2]/sum(..count..[..group..==2]))*100),
                 alpha = 0.5, position = "dodge", bins = 23) +
  labs(title = "November 1992", x="Wage range", y = "Percent of stores", fill="") +
  scale_fill_paletteer_d("nationalparkcolors::Acadia") +
  theme_minimal()


# Regresión ---------------------------------------------------------------

did_model <- lm(emptot ~ t + d + t:d, data = df)

did_model_r <- lm_robust(emptot ~ t + d + t:d, data = df)

summary(did_model)
summary(did_model_r)

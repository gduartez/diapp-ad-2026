penguins |>
  ggplot(aes(x = body_mass)) +
  geom_density(fill = "purple4", color = "black", alpha = .5) +
  labs(x = "Largo de la Aleta", y = "Frecuencia", title = "Histograma del Largo de la Aleta",
       subtitle = "344 Pingüinos del dataset penguins")

library(educationR)
library(wooldridge)

shapiro.test(attend$termGPA)

attend |>
  ggplot(aes(x = termGPA)) +
  geom_density(fill = "purple4", color = "black", alpha = .5) +
  labs(x = "Largo de la Aleta", y = "Frecuencia", title = "Histograma del Largo de la Aleta",
       subtitle = "344 Pingüinos del dataset penguins")

qqnorm(attend$termGPA)
qqline(attend$termGPA, col = "red")

library(openintro)

shapiro.test(bdims$hgt) 

bdims |>
  ggplot(aes(x = hgt)) +
  geom_density(fill = "purple4", color = "black", alpha = .5) +
  labs(x = "Largo de la Aleta", y = "Frecuencia", title = "Histograma del Largo de la Aleta",
       subtitle = "344 Pingüinos del dataset penguins")

mean(bdims$hgt)
sd(bdims$hgt)

library(corrplot)
m <- cor(USArrests)
corrplot(m,method = 'number',type="lower",tl.col="black",pch.col = "black",)

# 0. Datos y Librerías ----------------------------------------------------
library(tidyverse) #Correr install.packages("tidyverse") si no está instalado
library(wooldridge) #Correr install.packages("wooldridge") si no está instalado
library(corrplot) #Correr install.packages("corrplot") si no está instalado

# 1. Estructura del dataframe ---------------------------------------------
str(wage1)
str(wage1$wage)

glimpse(wage1)
glimpse(wage1$wage)

# 2. Seleccionar solo variables a utilizar --------------------------------
salarios <- wage1 |> 
  select(wage, educ, exper, female)

str(salarios)

# 3. Clasificación de Variables -------------------------------------------
#wage cuantitativa continua
#educ cuantitativa discreta
#exper cuantitativa continua
#female cualitativa nominal

# 4. Salario Promedio -----------------------------------------------------
mean(salarios$wage)

# 5. Mediana del salario --------------------------------------------------
median(salarios$wage)

# 6. Asimetría ------------------------------------------------------------
#Dado los resultados anteriores, esta distribución debiese tener la cola hacia la derecha
#(ver lámina "Distribuciones Asimétricas"). Para graficar hacemos geom_density()

salarios |> 
  ggplot(aes(x = wage)) +
  geom_density(fill = "lightpink3", color = "black", alpha = .5) +
  labs(x = "Salario promedio por hora", y = "Frecuencia", title = "Gráfico de densidad del salario promedio por hora",
       subtitle = "526 personas del dataset wage1")

# 7. Desviación estándar del salario --------------------------------------
sd(salarios$wage)

# Percentiles 10, 25, 50, 75 y 90 ---------------------------------------------
quantile(salarios$wage, probs = c(0.10, 0.25, 0.5, 0.75, 0.90), na.rm = TRUE)

# 8. Boxplot --------------------------------------------------------------
salarios$female <- factor(wage1$female, 
                          levels = c(0, 1), 
                          labels = c("Hombre", "Mujer"))

salarios |> 
  ggplot(aes(x = female, y = wage)) +
  geom_boxplot(fill = "blue4", alpha = .6)

# 9. Resumen --------------------------------------------------------------
summary(salarios)

# 10. Puntaje Z 15 -----------------------------------------------------------
media <- mean(salarios$wage)
desv <- sd(salarios$wage)

z <- (15-media)/desv

z

# 11. Correlación wage y exper | wage y educ --------------------------------------------
cor(salarios$wage, salarios$exper)
cor(salarios$wage, salarios$educ)

#Correlación débil para ambos pero hay mas relación lineal con educación

# 12. Corrplot ----------------------------------------------------------------
salarios_num <- salarios |> 
  select(wage, exper, educ)

m <- cor(salarios_num)

corrplot(m, method = 'number', type="lower")

# 13. Scatter plot ------------------------------------------------------------
salarios |> 
  ggplot(aes(x = exper, y = wage,
             color = female)) +
  geom_point() + 
  labs(title = "Relación entre salario promedio por hora y años de experiencia",
       x = "Años de experiencia",
       y = "Salario promedio por hora")

salarios |> 
  ggplot(aes(x = educ, y = wage,
             color = female)) +
  geom_point() + 
  labs(title = "Relación entre salario promedio por hora y años educación",
       x = "Años de educación",
       y = "Salario promedio por hora")

# 14. Scatterplot con recta ajustada ------------------------------------------
salarios |> 
  ggplot(aes(x = educ, y = wage,
             color = female)) +
  geom_point() + 
  geom_smooth(method = lm) +
  labs(title = "Relación entre salario promedio por hora y años de educación",
       x = "Años de educación",
       y = "Salario promedio por hora")


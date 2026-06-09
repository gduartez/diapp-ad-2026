# 13.8 --------------------------------------------------------------------
library(openintro)

## 1. Área bajo la curva --------------------------------------------------
### A) Z < -1.35  --------------------------------------------------------------------
round(pnorm(-1.35),3)

### B) Z > -1.48 --------------------------------------------------------------------
round(1 - pnorm(1.48),3)

### C) -0.4 < Z < 1.5 --------------------------------------------------------------------
round(pnorm(1.5) - pnorm(-0.4),3)

### D) |Z| > 2 --------------------------------------------------------------------
round(2*(1 - pnorm(2)),3)

## 3. GRE scores, Z scores -------------------------------------------------
### A) write the distributions ----------------------------------------------
# x_i = 160; y_i = 157
# X ~ N(151, 7) ; Y ~ N(153, 7.67)

### B) z-scores in verbal and quantitative reasoning ------------------------
x_i = 160
y_i = 157
mu_x = 151
s_x = 7
mu_y = 153
s_y = 7.67

z_x <- (x_i-mu_x)/s_x
round(z_x,2)
z_y <- (y_i-mu_y)/s_y
round(z_y,2)

### C) What do the Z scores tell you? ----------------------------------------------------------------------
# z_x dice que su resultado está 1,29 desviaciones estándar sobre la media en verbal reasoning
# z_y dice que su resultado está 0,52 desviaciones estándar sobre la media en quantitative reasoning

### D) Relative to others, which section did Sophia do better on? ----------------------------------------------------------------------
# En términos relativos, lo hizo mejor en verbal reasoning porque su puntaje se aleja positivamente
# más de la media que en quantitative (es decir, su z es superior).

### E) Find her percentile scores for each of the two exams ----------------------------------------------------------------------
round(pnorm(z_x),4) # Percentil 90
round(pnorm(z_y),4) # Percentil 70

### F) What % of the test takers did better than her on each test --------

1 - round(pnorm(z_x),4) # 10% lo hizo mejor
1 - round(pnorm(z_y),4) # 30% lo hizo mejor

# G) Por qué comparar puntajes raw sería un error -------------------------
# No podemos comparar las puntuaciones brutas, ya que están en escalas diferentes.
# Comparar sus puntuaciones percentiles es más apropiado para comparar su desempeño con el de los demás.

# H)  ---------------------------------------------------------------------

# La respuesta a la parte (b) no cambiaría, ya que las puntuaciones Z
# se pueden calcular para distribuciones que no son normales.
# Para c) solo se pide una interpretación de qué es un puntaje Z, 
# lo cual no depende de la distribución original de la variable, por lo que tampoco afecta.
# Sin embargo, no podríamos responder a las partes (d)-(f)
# puesto que no podemos usar la tabla de probabilidad normal para calcular
# probabilidades y percentiles sin un modelo normal.


## 5. GRE scores, cutoffs --------------------------------------------------

# a) percentil 80 quantitative reasoning ----------------------------------
qnorm(0.8, mean = 153, sd = 7.67)

# b) percentil 30 de verbal reasoning -------------------------------------
qnorm(0.3, mean = 151, sd = 7)



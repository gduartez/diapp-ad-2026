set.seed(123)
dado  <- 1:6
tiros <- sample(dado, size = 5000, replace = TRUE)
table(tiros)
sum(tiros)
# Proporción de cada resultado (frecuencia relativa)
prop.table(table(tiros))

sum(tiros > 4) / length(tiros)
(806+826)/5000


# Test --------------------------------------------------------------------

library(infer)

bdims |> 
  t_test(formula = hgt ~ sex)

t.test()
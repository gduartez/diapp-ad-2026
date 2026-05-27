# publicar.R - corre esto cada vez que quieras actualizar el sitio
system("quarto render")
system('git add .')
system('git commit -m "Actualización del sitio"')
system('git push origin main')
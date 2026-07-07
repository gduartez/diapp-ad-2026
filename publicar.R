# publicar.R - corre esto cada vez que quieras actualizar el sitio
system("quarto render")
system('git add .')
system('git commit -m "Clase 7"')
system('git push origin main')

Cartografia_censo2024_Pais_Manzanas.parquet

git filter-branch --tree-filter 'rm -f Cartografia_censo2024_Pais_Manzanas.parquet' HEAD

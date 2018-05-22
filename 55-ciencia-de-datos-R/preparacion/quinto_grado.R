#############################################
#### Este programa crea los archivos que ####
#### se usaron durante la presentacion   ####
#############################################
library(tibble) 
library(readr)

clase <- tribble(
  ~fecha,      ~nombre,     ~matematica, ~ingles, ~matricula, 
  "1/1/2015", "Díaz, Bruno", 90, 60, 100,
  "1/2/2015", "Díaz, Bruno", 85, 70, 100,
  "1/3/2015", "Díaz, Bruno", 70, 80, 100,
  "1/4/2015", "Díaz, Bruno", 75, 85, 100,
  "1/5/2015", "Díaz, Bruno", 70, 90, 100,
  "1/6/2015", "Díaz, Bruno", 66, 90, 100,
  "1/1/2015", "Fernández, Gudiel", 60, 80, 102,
  "1/2/2015", "Fernández, Gudiel", 70, 80, 102,
  "1/3/2015", "Fernández, Gudiel", 80, 90, 102,
  "1/4/2015", "Fernández, Gudiel", 85, 85, 102,
  "1/5/2015", "Fernández, Gudiel", 60, 90, 102,
  "1/6/2015", "Fernández, Gudiel", 80, 99, 102,
  "1/1/2015", "Sosa, Guillermo", 60, 60, 105,
  "1/2/2015", "Sosa, Guillermo", 76, 66, 105,
  "1/3/2015", "Sosa, Guillermo", 66, 62, 105,
  "1/4/2015", "Sosa, Guillermo", 74, 70, 105,
  "1/5/2015", "Sosa, Guillermo", 66, 63, 105,
  "1/6/2015", "Sosa, Guillermo", 60, 64, 105,
  "1/1/2015", "Aguirre, Benjamin", 50, 60, 99,
  "1/2/2015", "Aguirre, Benjamin", 55, 65, 99,
  "1/3/2015", "Aguirre, Benjamin", 60, 64, 99,
  "1/4/2015", "Aguirre, Benjamin", 55, 63, 99,
  "1/5/2015", "Aguirre, Benjamin", 50, 66, 99,
  "1/6/2015", "Aguirre, Benjamin", 62, 70, 99,
  "1/1/2015", "Medina, Paulina", 90, 80, 103,
  "1/2/2015", "Medina, Paulina", 95, 85, 103,
  "1/3/2015", "Medina, Paulina", 90, 84, 103,
  "1/4/2015", "Medina, Paulina", 95, 93, 103,
  "1/5/2015", "Medina, Paulina", 90, 86, 103,
  "1/6/2015", "Medina, Paulina", 92, 80, 103,
  "1/1/2015", "Torres, Gabriela", 92, 71, 109,
  "1/2/2015", "Torres, Gabriela", 81, 72, 109,
  "1/3/2015", "Torres, Gabriela", 82, 73, 109,
  "1/4/2015", "Torres, Gabriela", 74, 84, 109,
  "1/5/2015", "Torres, Gabriela", 86, 73, 109,
  "1/6/2015", "Torres, Gabriela", 82, 71, 109,
  "1/1/2015", "Flores, Patricia", 92, 91, 98,
  "1/2/2015", "Flores, Patricia", 91, 92, 98,
  "1/3/2015", "Flores, Patricia", 92, 93, 98,
  "1/4/2015", "Flores, Patricia", 94, 94, 98,
  "1/5/2015", "Flores, Patricia", 96, 93, 98,
  "1/6/2015", "Flores, Patricia", 82, 99, 98,
  "1/1/2015", "Aragón, Maria", 74, 81, 110,
  "1/2/2015", "Aragón, Maria", 85, 82, 110,
  "1/3/2015", "Aragón, Maria", 77, 83, 110,
  "1/4/2015", "Aragón, Maria", 83, 84, 110,
  "1/5/2015", "Aragón, Maria", 72, 83, 110,
  "1/6/2015", "Aragón, Maria", 81, 89, 110
)

# Cambia las calificaciones para que sean differentes a las de cuarto 
set.seed(100)
matematica <- sample(60:100, size = nrow(clase), replace = TRUE)
ingles <- sample(60:100, size = nrow(clase), replace = TRUE)
clase$matematica <- matematica
clase$ingles <- ingles
clase$matricula <- clase$matricula + 20

write_csv(clase, "./quinto_grado.csv")

rm(clase)
rm(matematica)
rm(ingles)


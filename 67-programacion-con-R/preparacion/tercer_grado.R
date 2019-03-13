#############################################
#### Este programa crea los archivos que ####
#### se usaron durante la presentacion   ####
#############################################
library(tibble) 
library(readr)

clase <- tribble(
  ~fecha,      ~nombre,     ~matematica, ~ingles, ~matricula, 
  "1/1/2015", "Dominguez, Tomas", 90, 60, 100,
  "1/2/2015", "Dominguez, Tomas", 85, 70, 100,
  "1/3/2015", "Dominguez, Tomas", 70, 80, 100,
  "1/4/2015", "Dominguez, Tomas", 75, 85, 100,
  "1/5/2015", "Dominguez, Tomas", 70, 90, 100,
  "1/6/2015", "Dominguez, Tomas", 66, 90, 100,
  "1/1/2015", "Paz, Edwin", 60, 80, 102,
  "1/2/2015", "Paz, Edwin", 70, 80, 102,
  "1/3/2015", "Paz, Edwin", 80, 90, 102,
  "1/4/2015", "Paz, Edwin", 85, 85, 102,
  "1/5/2015", "Paz, Edwin", 60, 90, 102,
  "1/6/2015", "Paz, Edwin", 80, 99, 102,
  "1/1/2015", "Vasquez, Samuel", 60, 60, 105,
  "1/2/2015", "Vasquez, Samuel", 76, 66, 105,
  "1/3/2015", "Vasquez, Samuel", 66, 62, 105,
  "1/4/2015", "Vasquez, Samuel", 74, 70, 105,
  "1/5/2015", "Vasquez, Samuel", 66, 63, 105,
  "1/6/2015", "Vasquez, Samuel", 60, 64, 105,
  "1/1/2015", "Fuentes, Fernando", 50, 60, 99,
  "1/2/2015", "Fuentes, Fernando", 55, 65, 99,
  "1/3/2015", "Fuentes, Fernando", 60, 64, 99,
  "1/4/2015", "Fuentes, Fernando", 55, 63, 99,
  "1/5/2015", "Fuentes, Fernando", 50, 66, 99,
  "1/6/2015", "Fuentes, Fernando", 62, 70, 99,
  "1/1/2015", "Ayala, Antonio", 90, 80, 103,
  "1/2/2015", "Ayala, Antonio", 95, 85, 103,
  "1/3/2015", "Ayala, Antonio", 90, 84, 103,
  "1/4/2015", "Ayala, Antonio", 95, 93, 103,
  "1/5/2015", "Ayala, Antonio", 90, 86, 103,
  "1/6/2015", "Ayala, Antonio", 92, 80, 103,
  "1/1/2015", "Juarez, Roberto", 92, 71, 109,
  "1/2/2015", "Juarez, Roberto", 81, 72, 109,
  "1/3/2015", "Juarez, Roberto", 82, 73, 109,
  "1/4/2015", "Juarez, Roberto", 74, 84, 109,
  "1/5/2015", "Juarez, Roberto", 86, 73, 109,
  "1/6/2015", "Juarez, Roberto", 82, 71, 109,
  "1/1/2015", "Cifuentes, Melisa", 92, 91, 98,
  "1/2/2015", "Cifuentes, Melisa", 91, 92, 98,
  "1/3/2015", "Cifuentes, Melisa", 92, 93, 98,
  "1/4/2015", "Cifuentes, Melisa", 94, 94, 98,
  "1/5/2015", "Cifuentes, Melisa", 96, 93, 98,
  "1/6/2015", "Cifuentes, Melisa", 82, 99, 98,
  "1/1/2015", "Ventura, Juan", 74, 81, 110,
  "1/2/2015", "Ventura, Juan", 85, 82, 110,
  "1/3/2015", "Ventura, Juan", 77, 83, 110,
  "1/4/2015", "Ventura, Juan", 83, 84, 110,
  "1/5/2015", "Ventura, Juan", 72, 83, 110,
  "1/6/2015", "Ventura, Juan", 81, 89, 110
)

# Cambia las calificaciones para que sean differentes a las de cuarto 
set.seed(999)
matematica <- sample(60:100, size = nrow(clase), replace = TRUE)
ingles <- sample(60:100, size = nrow(clase), replace = TRUE)
clase$matematica <- matematica
clase$ingles <- ingles
clase$matricula <- clase$matricula + 40

write_csv(clase, "./datos_tercer_grado.csv")

rm(clase)
rm(matematica)
rm(ingles)


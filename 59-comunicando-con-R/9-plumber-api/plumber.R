library(plumber)

# https://www.rplumber.io/

#* @get /millas
#* @param cilindros
#* @param clase

load("datos/millas.rda")
load("modelo.rds")

function(cilindros, clase) {
  cilindros <- as.integer(cilindros)
  predict(modelo, data.frame(clase = clase, cilindros = cilindros))
}

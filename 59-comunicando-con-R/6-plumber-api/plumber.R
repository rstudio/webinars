library(plumber)

#* @get /millas
#* @param cilindros
#* @param clase
function(cilindros, clase) {
  cilindros <- as.integer(cilindros)
  predict(modelo, data.frame(clase = clase, cilindros = cilindros))
}

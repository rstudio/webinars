# Packages ----
# For API
library(plumber)
library(rapidoc)
# For model predictions
library(parsnip)
library(ranger)

# Load model ----
model <- readr::read_rds("model.rds")

# Goal ----
# predict(model,
#         new_data = jsonlite::read_json("penguins.json",
#                                        simplifyVector = TRUE),
#         type = "prob")

#* @apiTitle Penguin Predictions

#* Determine if the API is running and listening as expected
#* @get /health-check
function() {
  list(status = "All Good",
       time = Sys.time())
}

#* Predict penguin species based on input data
#* @parser json
#* @serializer csv
#* @post /predict
function(req, res) {
  # req$body is the parsed input
  predict(model, new_data = as.data.frame(req$body), type = "prob")
}

# Update UI
#* @plumber
function(pr) {
  pr %>% 
    pr_set_api_spec(yaml::read_yaml("openapi.yaml")) %>%
    pr_set_docs(docs = "rapidoc")
}
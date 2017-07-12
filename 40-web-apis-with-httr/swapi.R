library(httr)
library(jsonlite)
library(magrittr)

# Goal: Get the data for the planet Alderaan
# verb (method) = GET
# URL (endpoint) = http://swapi.co/api/planets/
# parameter = search

alderaan <- GET("http://swapi.co/api/planets/?search=alderaan")
# Same call in a different format
alderaan <- GET("http://swapi.co/api/planets/", query = list(search = "alderaan"))

names(alderaan)
alderaan$status_code
alderaan$headers$`content-type`

# Get the content of the response
text_content <- content(alderaan, "text", encoding = "UTF-8")
text_content

# Parse with httr
parsed_content <- content(alderaan, "parsed")
names(parsed_content)
parsed_content$count
str(parsed_content$results)
parsed_content$results[[1]]$name
parsed_content$results[[1]]$terrain

# Parse with jsonlite
json_content <- text_content %>% fromJSON
json_content
planetary_data <- json_content$results
names(planetary_data)
planetary_data$name
planetary_data$terrain

# -------------------------------

# Helper function
json_parse <- function(req) {
  text <- content(req, "text", encoding = "UTF-8")
  if (identical(text, "")) warning("No output to parse.")
  fromJSON(text)
}

# List results
planets <- GET("http://swapi.co/api/planets") %>% stop_for_status()
json_planets <- json_parse(planets)

# The response includes metadata as well as results
names(json_planets)
json_planets$count
length(json_planets$results$name)
json_planets$`next`

swapi_planets <- json_planets$results
swapi_planets$name

# Get the next page of results based on the content of the `next` field
next_page <- GET(json_planets$`next`) %>% stop_for_status()

# Use a function to parse the results
parsed_next_page <- json_parse(next_page)
parsed_next_page$results$name

# If the API results come back paged like this, you can write a loop to follow the next URL 
# until the there are no more pages, and rbind all the data into a single dataframe.

# Grab data on all of the Star Wars planets
planets <- GET("http://swapi.co/api/planets") %>% 
  stop_for_status() %>% 
  json_parse
swapi_planets <- planets$results

next_page <- planets$`next`
while (!is.null(next_page)) {
  more_planets <- GET(next_page) %>% 
    stop_for_status() %>% 
    json_parse
  swapi_planets <- rbind(swapi_planets, more_planets$results)
  next_page <- more_planets$`next`
}

length(swapi_planets$name)
swapi_planets$name

# In real life, you'd also want to handle any errors, headers, proxy, rate limits, etc. as needed.
help(package = httr)

# Someone wrote a package for swapi:  https://github.com/Ironholds/rwars

library(httr)

url <- "http://www.omdbapi.com/?t=frozen&y=2013&plot=short&r=json"

frozen <- GET(url)
frozen

details <- content(frozen, "parse")

details$Year

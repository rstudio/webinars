# Import from JSON
library(jsonlite)
json <- fromJSON("data/Water_Right_Applications.json")
json[[1]][[1]]

# Import from XML
library(xml2)
xml <- read_xml("data/Water_Right_Applications.xml")
xml_children(xml_children(xml))

# Import from HTML
library(rvest)
html <- read_html("https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population")
table <- xml_find_one(html, "//table")
View(html_table(table))
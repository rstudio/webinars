# Load packages -----------------------------------------------------

library(tidyverse)
library(rvest)
library(stringr)
library(robotstxt)

# Step 0: Check bot permission --------------------------------------

paths_allowed("http://www.lq.com/en/findandbook/hotel-listings.html")

# Step 1: Create list of links to hotels ----------------------------

base_url <- "http://www.lq.com"

pages <- read_html(file.path(base_url,"en/findandbook/hotel-listings.html")) %>%
  html_nodes("#hotelListing .col-sm-12 a") %>%
  html_attr("href") %>%
  discard(is.na) %>%
  discard(~ str_detect(., "hotel-details\\.null\\.html")) %>%
  file.path(base_url, .)

# pages <- head(pages, 30) # use a subset for testing code

# Step 2 : Save hotels pages locally ---------------------------------

# Create a directory to store downloaded hotel pages
data_dir <- "data/"
dir.create(data_dir, showWarnings = FALSE)

# Create a progress bar
p <- progress_estimated(length(pages))

# Download each hotel page
walk(pages, function(url){
  download.file(url, destfile = file.path(data_dir,basename(url)), quiet = TRUE)
  p$tick()$print()
})

# Step 3: Process all hotel info into df ----------------------------

# Create a character vector of names of all files in directory
files <- dir(data_dir, full.names = TRUE)

# Function: get_hotel_details, to be applied to each hotel page
get_hotel_details <- function(file) {

  page <- read_html(file)
  
  # Grab the details of the hotel (name, address, phone, fax)
  # Stored in the p tag on the page
  details <- page %>% 
    html_nodes("p") %>% 
    html_text() %>%
    str_replace_all("\\s{2,}", "\n")    # turn 2+ white spaces into a new line
  
  # Grab the URL of the minimap element, stored in the .minimap tag on the page
  map_src <- page %>% html_nodes(".minimap") %>% html_attr("src")
  
  # Regex: Look for |, followed by numbers, dots, or dash separated by commas, ending with &
  # using grouping with () so that the result is in two pieces,
  # result is a matrix
  lat_long <- map_src %>% str_match("\\|([0-9.-]{3,}),([0-9.-]{3,})&") %>%
    .[,-1] %>%        # omit the first column of the matrix
    as.numeric()      # turn lat/lon to numeric
  
  data_frame(
    # Name is the element tagged with h1
    name = page %>% html_node("h1") %>% html_text(),
    
    # Find where "Phone:" starts, and remove what comes after it 
    address = str_replace(details, "(?s)Phone:.*","") %>% str_trim(),
    
    # Find strings that match "Phone: " followed by 6 or more numbers and dashes
    # Use grouping, and then remove the first column containing "Phone: "
    phone = details %>% str_match("Phone: ([0-9-]{6,})") %>% .[,-1],
    
    # Find strings that match "Fax: " followed by 6 or more numbers and dashes
    # Use grouping, and then remove the first column containing "Fax: "
    fax = details %>% str_match("Fax: ([0-9-]{6,})") %>% .[,-1],
    
    # Second element of lat_long
    long = lat_long[2],
    
    # First element of lat_long
    lat = lat_long[1]
  )
} 

# Apply the get_hotel_details function to each element of files
lq <- map_df(files, get_hotel_details)


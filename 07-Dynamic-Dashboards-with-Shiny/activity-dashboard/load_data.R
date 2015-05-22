library(pilr.api.r)
library(httr)
library(jsonlite)

## NOTE: You would need a valid access code to access the PiLR API.
## They can be placed in a file called keys.R. This file should define the
## loc_info and calorimeter_info variables like those below, except with valid
## keys.

if (file.exists("keys.R")) {
  source("keys.R")
} else {
  # Information for location data
  loc_info <- list(
    pt = "999",   # Participant ID
    server = "http://liitah.pilrhealth.com",
    project = "liitah_testing_2",
    access_code = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  )

  # For calorimeter data
  calorimeter_info <- list(
    pt = "999",   # Participant ID
    server = "http://beta.pilrhealth.com",
    project = "shiny_demo_project",
    access_code = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  )
}


fetch_location_data <- function() {
  # Dates for filtering
  filterStart <- '2015-04-10T14:00:01Z'
  filterEnd <- '2016-04-11T23:59:59Z'

  # Fetch data from PiLR for the participant
  log <- read_pilr(
    pilr_server = loc_info$server,
    project = loc_info$project,
    access_code = loc_info$access_code,
    data_set = "pilrhealth:mobile:app_log",
    schema = "1",
    query_params = list(participant = loc_info$pt)
  )

  filterStart    <- as.POSIXct(filterStart, format = "%Y-%m-%dT%H:%M:%SZ")
  filterEnd      <- as.POSIXct(filterEnd, format = "%Y-%m-%dT%H:%M:%SZ")
  log$local_time <- as.POSIXct(log$local_time, format = "%Y-%m-%dT%H:%M:%SZ")
  log <- log[log$local_time > filterStart & log$local_time < filterEnd, ]

  log
}

fetch_venues_data <- function() {
  # Fetch data from PiLR for the participant
  venues <- read_pilr(
    pilr_server = loc_info$server,
    project = loc_info$project,
    access_code = loc_info$access_code,
    data_set = "pilrhealth:liitah:personal_venue",
    schema = "1",
    query_params = list(participant = loc_info$pt)
  )

  venues$local_time <- as.POSIXct(venues$local_time, format = "%Y-%m-%dT%H:%M:%SZ")

  venues
}


fetch_calorimeter_data <- function() {
  # Fetch data from PiLR for the participant
  raw <- read_pilr(
    pilr_server = calorimeter_info$server,
    project = calorimeter_info$project,
    access_code = calorimeter_info$access_code,
    data_set = "pilrhealth:calrq:calrq_data",
    schema = "1",
    query_params = list(participant = calorimeter_info$pt)
  )

  # Truncate first few invalid data points
  raw <- tail(raw, -70)

  raw$local_time <- as.POSIXct(raw$local_time, format = "%Y-%m-%dT%H:%M:%SZ")

  raw
}


# Can save data with:
# log <- fetch_location_data()
# saveRDS(log, "log.rds")
# venues <- fetch_venues_data()
# saveRDS(venues, "venues.rds")


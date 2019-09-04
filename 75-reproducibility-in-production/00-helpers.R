# 00-helpers.R

# To save screen real estate, I'll use this 
# script to load packages and write functions.

library(stringr)
library(openfda)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(DT)

# helper functions to query the openFDA API
get_adverse <- function(gender, brand_name, age) {
  fda_query("/drug/event.json") %>%
    fda_filter("patient.drug.openfda.brand_name", brand_name) %>% 
    fda_filter("patient.patientsex", gender) %>% 
    fda_filter("patient.patientonsetage", age) %>% 
    fda_count("patient.reaction.reactionmeddrapt.exact") %>% 
    fda_limit(10) %>% 
    fda_exec()
}

create_age <- function(min, max){
  sprintf('[%d+TO+%d]', min, max)
}
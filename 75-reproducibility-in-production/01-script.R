# 01-script.R

# R code that queries the open FDA data base and 
# plots the adverse events associated with a drug
# Code by Sean Lopp, modified by Phil Bowsher and 
# Garrett Grolemund.

source("00-helpers.R")

# Get and clean adverse event data from the openfda API
drug <- "Prednisone"
age <- create_age(20,65)

jnk <- capture.output(male <- get_adverse("1", drug, age))
jnk <- capture.output(female <- get_adverse("2", drug, age))

if (!is.null(male)) male$gender <- 'male'
if (!is.null(female)) female$gender <- 'female'

adverse <- rbind(male, female)
events <- adverse %>% 
  group_by(term) %>% 
  summarise(count = sum(count))

events$term[which.max(events$count)]

# plot all events  
events %>% 
  ggplot() +
  geom_bar(aes(reorder(term,count), count), stat = 'identity') +
  coord_flip() +
  labs(
    title = drug,
    x = NULL,
    y = NULL
  ) +
  theme_minimal()

# plot by gender
ggplot(adverse) +
  geom_bar(aes(reorder(term,count), count, fill = gender), stat = 'identity') +
  facet_wrap(~gender)+
  coord_flip() +
  labs(
    title = drug,
    x = NULL,
    y = NULL
  ) +
  theme_minimal() + 
  guides(fill = FALSE) + 
  scale_fill_manual(values = c("#d54a30","#4c83b6"))

# Use DT, an htmlwidget, to create an interactive table
# DT::datatable(adverse, options = list(pageLength = 5))

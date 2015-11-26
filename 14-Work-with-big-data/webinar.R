library(dplyr)
library(ggplot2)

# Create connection to the database
air <- src_postgres(
  dbname = 'airontime', 
  host = 'sol-eng.cjku7otn8uia.us-west-2.redshift.amazonaws.com', 
  port = '5439', 
  user = 'redshift_user', 
  password = 'ABCd4321')


# List table names
src_tbls(air)


# Create a table reference with tbl
flights <- tbl(air, "flights")
carriers <- tbl(air, "carriers")


# Write your own SQL background
vignette("new-sql-backend", package = "dplyr")


# Manipulate the reference as if it were the actual table
clean <- flights %>%
  filter(!is.na(arrdelay), !is.na(depdelay)) %>%
  filter(depdelay > 15, depdelay < 240) %>%
  filter(year >= 2002 & year <= 2007) %>%
  select(year, arrdelay, depdelay, distance, uniquecarrier)


# To see the SQL that dplyr will run.
show_query(clean)


# Extract random 1% sample of training data
random <- clean %>%
  mutate(x = random()) %>%
  collapse() %>%
  filter(x <= 0.01) %>%
  select(-x) %>%
  collect()


# Fit a model to training data
random$gain <- random$depdelay - random$arrdelay

# build model
mod <- lm(gain ~ depdelay + distance + uniquecarrier, data = random)

# Make coefficients lookup table
coefs <- dummy.coef(mod)
coefs_table <- data.frame(
  uniquecarrier = names(coefs$uniquecarrier),
  carrier_score = coefs$uniquecarrier,
  int_score = coefs$`(Intercept)`,
  dist_score = coefs$distance,
  delay_score = coefs$depdelay,
  row.names = NULL, 
  stringsAsFactors = FALSE
)


# Score test data
score <- flights %>%
  filter(year == 2008) %>%
  filter(!is.na(arrdelay) & !is.na(depdelay) & !is.na(distance)) %>%
  filter(depdelay > 15 & depdelay < 240) %>%
  filter(arrdelay > -60 & arrdelay < 360) %>%
  select(arrdelay, depdelay, distance, uniquecarrier) %>%
  left_join(carriers, by = c('uniquecarrier' = 'code')) %>%
  left_join(coefs_table, copy = TRUE) %>%
  mutate(gain = depdelay - arrdelay) %>%
  mutate(pred = int_score + carrier_score + dist_score * distance + delay_score * depdelay) %>%
  group_by(description) %>%
  summarize(gain = mean(1.0 * gain), pred = mean(pred))
show_query(score)
scores <- collect(score)

# Visualize results
ggplot(scores, aes(gain, pred)) + 
  geom_point(alpha = 0.75, color = 'red', shape = 3) +
  geom_abline(intercept = 0, slope = 1, alpha = 0.15, color = 'blue') +
  geom_text(aes(label = substr(description, 1, 20)), size = 4, alpha = 0.75, vjust = -1) +
  labs(title='Average Gains Forecast', x = 'Actual', y = 'Predicted')


# Visualize big data
ggplot(random) +
  geom_point(aes(depdelay, gain)) +
  
  cldata <- collect(clean)
ggplot(cldata) +
  geom_bar(aes(x = uniquecarrier))

clsummary <- clean %>%
  group_by(uniquecarrier) %>%
  summarise(count = n()) %>% 
  collect()
ggplot(clsummary) +
  geom_bar(aes(x = uniquecarrier, y = count), stat = "identity")




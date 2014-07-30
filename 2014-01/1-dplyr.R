library(nycflights13)
library(dplyr)

# Single table verbs 
flights
filter(flights, dest == "IAH")
select(flights, starts_with("arr"))
arrange(flights, desc(arr_delay))
mutate(flights, speed = distance / air_time * 60)

by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))

# Multi-table verbs
semi_join(planes, flights)
anti_join(planes, flights)

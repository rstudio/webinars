# Load packages -----------------------------------------------------

library(tidyverse)

# Load data ---------------------------------------------------------

dn = read_csv("data-csv/dennys.csv")
lq = read_csv("data-csv/laquinta.csv")

# Harversine distance formula implementation ------------------------

haversine <- function(long1, lat1, long2, lat2, round=3)
{
  # convert to radians
  long1 = long1 * pi / 180
  lat1  = lat1  * pi / 180
  long2 = long2 * pi / 180
  lat2  = lat2  * pi / 180
  
  R = 6371 # Earth mean radius in km
  
  a = sin((lat2 - lat1)/2)^2 + cos(lat1) * cos(lat2) * sin((long2 - long1)/2)^2
  d = R * 2 * asin(sqrt(a))
  
  return( round(d,round) ) # distance in km
}

# Vectorized distance calculation implementation --------------------

dist <- matrix(NA, nrow(dn), nrow(lq))

for(i in 1:nrow(dn))
{
  dist[i,] = haversine(dn$Longitude[i], dn$Latitude[i],
                       lq$Longitude,    lq$Latitude)
}

# Data frames for pairs ---------------------------------------------

# Create data frame for Denny's-La Quinta pairs
dn_lq = cbind(dist = apply(dist, 1, min), 
              dn = dn, 
              lq = lq[apply(dist, 1, which.min), ])

# Create data frame for La Quinta-Denny's pairs
lq_dn = cbind(dist = apply(dist, 2, min), 
              lq = lq, 
              dn = dn[apply(dist, 2, which.min), ])

# View tables of pairs ----------------------------------------------

# Denny's-La Quinta table
dn_lq %>% 
  select(-contains("Zip"),-contains("Longitude"),-contains("Latitude")) %>% 
  arrange(dist) %>%
  head(n = 7)

# La Quinta-Denny's table
lq_dn %>% 
  select(-contains("Zip"),-contains("Longitude"),-contains("Latitude")) %>% 
  arrange(dist) %>%
  head(n = 5)

# Summary of Denny's-La Quinta and La Quinta-Denny's distances ------

rbind("DN-LQ" = summary(dn_lq$dist),
      "LQ-DN" = summary(lq_dn$dist))

# Plot of distance distributions ------------------------------------

dn_lq_cus = filter(dn_lq, !(dn.State %in% c("AK","HI")))
lq_dn_cus = filter(lq_dn, !(dn.State %in% c("AK","HI")))

d = rbind(data.frame(pair = "DN-LQ (CONUS)", dist = dn_lq_cus$dist),
          data.frame(pair = "LQ-DN (CONUS)", dist = lq_dn_cus$dist))

ggplot(d, aes(x = dist)) + 
  geom_density(aes(group = pair, color = pair, fill = pair), alpha = 0.3, na.rm=TRUE) + 
  xlab("Distance (km)") + 
  ylab("Density") +
  xlim(0,100)

ggplot(d, aes(x = dist, color = pair)) + 
  stat_ecdf() + 
  xlab("Distance (km)") + xlim(0,100) +
  ylab("ECDF") 

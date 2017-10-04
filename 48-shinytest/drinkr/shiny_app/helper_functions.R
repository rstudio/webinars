##### Calcululations of BAC #####
#################################

# Using units meter, kg, seconds and litre unless noted.
# Also using proportions (e.g. 0.25) rather than percentages (e.g. 25%)

# Calculates the “Widmark factor” r according to Seidl et al 2000
# The default values are the mean height and weight for the USA according
# to Wikipedia (avaraged over men and women).
calc_widmark_factor <- function(height, weight, sex) {
  r_female <- 0.31223 - 0.006446 * weight + 0.4466 * height
  r_male   <- 0.31608 - 0.004821 * weight + 0.4632 * height
  # Capping the r-values according to the limits found by Seidl et al
  r_female[r_female < 0.44] <- 0.44
  r_female[r_female > 0.8] <- 0.8
  r_male[r_male < 0.60] <- 0.60
  r_male[r_male > 0.87] <- 0.87
  
  if(sex == "female") {
    r_female
  } else if(sex == "male") {
    r_male
  } else { # take the mean if sex is unspecified
    (r_male + r_female) / 2
  }
}

cumalative_absorption <- function(drinks, absorption_halflife, start_time, end_time ) {
  absorption_minutes <- round( (end_time - start_time) /  60)
  # The points in time (in s) to calculate the absorbtion for.
  t_sec <- seq(from = start_time, length.out = absorption_minutes, by = 60)
  # A matrix to hold the amount of alcohol absorbed from each drink at different points in time
  absorption_mat <- matrix(0, nrow = max(nrow(drinks), 1), ncol = absorption_minutes)
  for(i in seq_len(nrow(drinks))) {
    #The absorption equation from p. 35 in Posey and Mozayani 2007
    absorption_mat[i,] <- drinks$alc_kg[i] * (1 - exp(-(t_sec - drinks$time[i]) * log(2) / absorption_halflife))
  }
  absorption_mat[absorption_mat < 0] <- 0 # We don't absorb a negative amount of alcohol...
  # Summing the columns to calculate the total amount of absorbed alcohol at each time point
  kg_absorbed <- colSums(absorption_mat)
  data.frame(kg_absorbed = kg_absorbed, time = t_sec)
}

calc_bac_ts <- function(drinks, height, weight, sex, absorption_halflife, beta, start_time, end_time) {
  drinks$alc_vol <- drinks$vol * drinks$alc_prop # in litres 
  drinks$alc_kg <- drinks$alc_vol * 0.789 # 0.789 is the weight of one liter of alcohol
  r <- calc_widmark_factor(height, weight, sex)
  
  # "Starting" a data.frame time series to hold information about different aspects of
  # the Blood Alcohol Concentration (bac)
  bac_ts <- cumalative_absorption(drinks, absorption_halflife, start_time, end_time)
  bac_ts$time <- as.POSIXct(bac_ts$time, origin="1970-01-01", tz = "UTC")
  
  bac_ts$bac_excluding_elimination <- bac_ts$kg_absorbed / (r * weight)
  bac_ts$eliminated <- rep(0, nrow(bac_ts))
  for(i in 2:nrow(bac_ts)) {
    current_bac <- bac_ts$bac_excluding_elimination[i] - bac_ts$eliminated[i - 1]
    bac_ts$eliminated[i] <- bac_ts$eliminated[i - 1] + 
      min(current_bac, beta * 60) # We can't eliminate more bac than we got...
  }
  
  bac_ts$bac <- bac_ts$bac_excluding_elimination - bac_ts$eliminated
  bac_ts$bac_perc <- bac_ts$bac * 100
  # Removing the end of the time series
  ts_end_i <- max(which(bac_ts$bac > 0), 5 * 60)
  bac_ts <- bac_ts[seq_len(ts_end_i),]
  bac_ts
}

##### Other support functions #####

plot_bac_ts <- function(bac_ts, drinks, time_now, drink_info) {
  drink_color <- drink_info$color
  names(drink_color) <- drink_info$drink
  
  layout(rbind(1,2), heights = c(0.9, 0.1))
  old_par <- par(mar=c(2.5, 4.1, 1, 1.5), lab=c(8, 8, 10))
  plot(bac_ts$time, bac_ts$bac_perc, col=rgb(0,0,0,0), ylim=c(0, max(bac_ts$bac_perc, 0.1)),
       bty="L", yaxs="i", xlab="",ylab="% Blood Alcohol Concentration")
  with(bac_ts[ bac_ts$time <= time_now,], lines(time, bac_perc, col="skyblue", lwd=4))
  with(bac_ts[ bac_ts$time > time_now,], lines(time, bac_perc, col="skyblue", lwd=4, lty=2))
  if(time_now >= min(bac_ts$time) & time_now <= max(bac_ts$time)) {
    curr_i <- which.min(abs(bac_ts$time - time_now))
    points(bac_ts$time[curr_i], bac_ts$bac_perc[curr_i], col="orange", pch=19, lwd=4)
    text(bac_ts$time[curr_i], bac_ts$bac_perc[curr_i], labels=paste(round(bac_ts$bac_perc[curr_i], 3), "%"), lwd=4, pos = 4)
  }
  par(old_par)
  
  old_par <- par(mar = c(0, 4.1, 0, 1.5), bty="n", xaxt="n", yaxt="n")
  if(nrow(drinks) > 0) {
    drink_y_pos <- -((seq_len(nrow(drinks)) - 1) %% 3)
    plot(drinks$time, drink_y_pos, pch=19, ylim=c(-2.5, 0.5), col=drink_color[ drinks$name], xlab="", ylab="", xlim=range(bac_ts$time))
    text(drinks$time, drink_y_pos, labels = drinks$name, col=drink_color[ drinks$name], pos = 4)
  } else {
    plot(0, 0, col=rgb(0, 0, 0, 0), xlab="", ylab="")
  }
  par(old_par)
}



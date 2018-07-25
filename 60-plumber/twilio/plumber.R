# NOTE: This code is not well-architected and shouldn't be viewed as a model
# for future APIs. It does work as an API that can respond to incoming Twilio
# input, and is also able to serve other endpoints that render some graphs or
# a leaflet heatmap, but it's not well tested nor would it be maintainable
# nor does it follow "best practices."

library(zipcode)
library(sp)
library(dichromat)
library(rgdal)
library(KernSmooth)
library(fields)
library(emoGG)
library(rlang)
library(dplyr)

library(leaflet)
data(zipcode)

library(ggplot2)
library(emo)


if (file.exists("allemo.rds")){
  allemo <- readRDS("allemo.rds")
  messages <- readRDS("messages.rds")
} else{
  allemo <- data.frame(sid=character(0), lat=numeric(0), 
                       long=numeric(0), emoji=character(0), stringsAsFactors = FALSE)
  messages <- data.frame(sid=character(0), time=numeric(0),
                         body=character(0), long=numeric(0),
                         lat = numeric(0), number=character(0), 
                         stringsAsFactors = FALSE)
}

#* @post /sms
#* @get /sms
function (req, SmsSid, From, Body, FromState, FromZip, res){
  res$setHeader("Content-Type", "application/xml")
  
  chars <- strsplit(Body, "")[[1]]
  
  # TODO: could also consider using the new emo::ji_rx function
  emojis <- chars[chars %in% emo::jis$emoji]
  
  if (!missing(FromZip)){
    loc <- subset(zipcode, zip==FromZip)
  } else {
    # Canadians...
    loc <- list(longitude = NA, latitude = NA)
  }
  
  subset(emo::jis, emoji %in% chars)
  
  toadd <- data.frame(sid=SmsSid, lat=loc$latitude,
                      long = loc$longitude, emoji=emojis)
  allemo <<- rbind(allemo, toadd)
  
  messages <<- rbind(messages, data.frame(sid=SmsSid, time=Sys.time(), 
                                          body=Body, 
                                          emojis = paste0(emojis, collapse=""), 
                                          long=loc$longitude,
                                          lat = loc$latitude, 
                                          number= From, stringsAsFactors = FALSE))
  
  saveRDS(allemo, "allemo.rds")
  saveRDS(messages, "messages.rds")
  
  res$body <- '<?xml version="1.0" encoding="UTF-8"?><Response><Message>Your emojis have been plumbed!</Message></Response>'
  
  res
}

#* @post /voice
function(req, res){
  print ("Call incoming!!")
  res$setHeader("Content-Type", "application/xml")
  res$body <- "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Say voice=\"alice\">Hello. Goodbye.</Say></Response>"
  res
}

one_per_user <- function(){
  allemo %>% 
    left_join(messages, by="sid") %>% 
    group_by(emoji, number, lat.x, long.x) %>% 
    summarize(time=max(time)) %>% 
    rename(lat = lat.x, long = long.x)
}


#* @get /barplot
#* @png
function(){
  
  showcount <- 15
  
  # Should be the same high-low ordering that ggplot2 has
  tbl <- sort(table(one_per_user()$emoji), decreasing = TRUE)
  cols <- names(tbl)
  
  cols <- cols[1:showcount]
  
  p <- ggplot(one_per_user() %>% filter(emoji %in% cols)) +
    geom_bar(aes(reorder(emoji, emoji, function(x)-length(x)))) +
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank())
  
  if (length(tbl) == 0){
    # Nothing to show!
    print(p + annotate("text", x=0, y=0, label="No input received yet."))
    return()
  }
  
  y_offset <- max(tbl) * -0.03
  
  for (i in 1:length(cols)){
    tryCatch({
      e <- tolower(as.character(filter(emo::jis, emoji == cols[i])["runes"]))  
      # When Jim Hester gives you some R magic, you use that shit.
      p <- eval_tidy(quo(p + emoGG::geom_emoji(aes(x = !!i, y = !!y_offset), emoji = !!e)))
    }, error = function(e){
      # cat("Unable to render emoji:", as.character(e))
      lbl <- "?"
      cat("Couldn't find: ", cols[i], "\n")
      
      # Easier to just compare to emoji, but RStudio struggles with emojis in its editor...
      if (as.character(emo::jis %>% filter(emoji == cols[i]) %>% select(name)) == "middle finger"){
        lbl <- "!!"
      }
      p <<- p + annotate("text", x=i, y=y_offset, label=lbl)
    })
  }
  
  print(p)
}

#* @get /table
function(res){
  # Bypass CORS
  res$setHeader("Access-Control-Allow-Origin", "*")
  
  tbl <- sort(table(one_per_user()$emoji), decreasing=TRUE)
  data.frame(emo=names(tbl), count=as.integer(tbl))
}


#* @get /heatmap/<em>
#* @serializer htmlwidget
function(em, res){
  em <- URLdecode(em)
  # Bypass CORS
  res$setHeader("Access-Control-Allow-Origin", "*")
  
  one_per_user() %>% 
    filter(emoji == em) %>% 
    as.data.frame() %>% 
    heatmap()
}

# Code from https://gis.stackexchange.com/questions/168886/r-how-to-build-heatmap-with-the-leaflet-package
heatmap <- function(dat){
  set.seed(1234)
  dat <- dat %>% filter(!is.na(lat), !is.na(long))
  
  # Add jitter to make the heatmap more interesting. Area codes are overly specific.
  # dat$long <- dat$long + rnorm(nrow(dat), 0, .3)
  # dat$lat <- dat$lat + rnorm(nrow(dat), 0, .3)
  
  xsize <- 100
  ysize <- 30
  bw <- 0.15
  
  alldat <- one_per_user() %>% 
    as.data.frame() %>% 
    filter(!is.na(lat), !is.na(long))
  
  range <- list(c(-125,-66), c(25,50))
  globalkde <- bkde2D(alldat[, c("long", "lat")],
                      bandwidth=c(bw, bw), range.x = range, gridsize = c(xsize,ysize))
  
  ## MAKE CONTOUR LINES
  ## Note, bandwidth choice is based on MASS::bandwidth.nrd()
  kde <- bkde2D(dat[, c("long", "lat")],
                bandwidth=c(bw, bw), range.x = range, gridsize = c(xsize,ysize))
  
  # Normalize
  norm <- kde$fhat - globalkde$fhat*2 #Amplify global to pull-down so only meaningful spots highlighted
  # Smooth out to account for the fact that we're slightly off in our normalization in places
  norm <- fields::image.smooth(norm, theta=1)$z
  norm[norm < 0] <- 0
  CL <- contourLines(kde$x1 , kde$x2 , norm)
  
  map <- NULL
  
  if (length(CL) == 0){
    # No contours
    map <- leaflet(dat)
  } else {
    ## EXTRACT CONTOUR LINE LEVELS
    LEVS <- as.factor(sapply(CL, `[[`, "level"))
    NLEV <- length(levels(LEVS))
    
    ## CONVERT CONTOUR LINES TO POLYGONS
    pgons <- lapply(1:length(CL), function(i)
      Polygons(list(Polygon(cbind(CL[[i]]$x, CL[[i]]$y))), ID=i))
    spgons = SpatialPolygons(pgons)
    
    map <- leaflet(spgons)
  }
  
  ## Leaflet map with polygons
  map %>% addTiles() %>% 
    addMarkers(~long, ~lat, data=dat) %>% 
    addPolygons(color = heat.colors(NLEV, NULL)[LEVS])
}

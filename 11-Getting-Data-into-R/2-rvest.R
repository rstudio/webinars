# Inspired by
# http://notesofdabbler.github.io/201408_hotelReview/scrapeTripAdvisor.html

library(rvest)

# Always start by opening in web browser and experimenting with
# selectorgadget: http://selectorgadget.cm

url <- "http://www.tripadvisor.com/Hotel_Review-g37209-d1762915-Reviews-JW_Marriott_Indianapolis-Indianapolis_Indiana.html"
httr::BROWSE(url)

reviews <- url %>%
  read_html() %>%
  html_nodes("#REVIEWS .innerBubble")

length(reviews)
xml_structure(reviews[[1]])

# Most important distinction to get the hang of is html_nodes() vs html_node().
# html_nodes() returns m nodes; html_node() always returns n nodes. This is
# important to make sure that the variables line up correctly.

id <- reviews %>%
  html_node(".quote a") %>%
  html_attr("id")

quote <- reviews %>%
  html_node(".quote span") %>%
  html_text()

rating <- reviews %>%
  html_node(".rating .rating_s_fill") %>%
  html_attr("alt") %>%
  gsub(" of 5 stars", "", .) %>%
  as.integer()

date <- reviews %>%
  html_node(".rating .ratingDate") %>%
  html_attr("title") %>%
  strptime("%b %d, %Y") %>%
  as.POSIXct()

review <- reviews %>%
  html_node(".entry .partial_entry") %>%
  html_text()

library(dplyr)
data_frame(id, quote, rating, date, review) %>% View()

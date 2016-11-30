orlando <- read_html("http://www.bestplaces.net/climate/city/florida/orlando") 

tables <- html_nodes(orlando, css = "table") 

html_table(tables, header = TRUE)[[2]]

library(rvest)

# 1. Download the HTML and turn it into an XML file with read_html()
frozen <- read_html("http://www.imdb.com/title/tt2294629/")

# 2. Extract specific nodes with html_nodes()
cast <- html_nodes(frozen, "span.itemprop")

# 3. Extract content from nodes with html_text(), html_name(), 
#    html_attrs(), html_children(), html_table()
html_text(cast)
cast
html_name(cast)
html_attrs(cast)
html_children(cast)


# selectorGadget
# The above code captures non-actor/actress values. The following
# CSS derived with selectorGadget works better.
cast2 <- html_nodes(frozen, "#titleCast span.itemprop")
html_text(cast2)

cast3 <- html_nodes(frozen, ".itemprop .itemprop")
html_text(cast3)

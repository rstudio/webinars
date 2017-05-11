## webinar live coding

library(readxl)

## access examples-- -----------------------------------------------

## list all examples
readxl_example()

## get path to a specific example
readxl_example("datasets.xlsx")
datasets <- readxl_example("datasets.xlsx")
read_excel(datasets)


## IDE support ------------------------------------------------------

## in Files pane
## navigate to folder holding xls/xlsx
## click on one!
## choose Import Dataset...

## demo with deaths.xlsx

## admire the
##   * File/Url field
##   * Data preview, complete with column types
##   * Import options
##     - skip = 4, n_max = 10
##     - range = A5:F15
##     - range = other!A5:F15
##   * Preview code, copy it to clipboard, execute it

## alternative workflow:
## copy this URL to the clipboard:
## https://github.com/tidyverse/readxl/blob/master/inst/extdata/deaths.xlsx?raw=true
## File > Import Dataset > paste the URL and Update
## Nice touch: code includes commands necessary to download


## Data rectangle ------------------------------------------------------

## using read_excel() "by hand"
read_excel(
  readxl_example("deaths.xlsx"),
  range = "arts!A5:F15"
)

read_excel(
  readxl_example("deaths.xlsx"),
  sheet = "other",
  range = cell_rows(5:15)
)

## The Sheet Geometry vignette has all the details:
## http://readxl.tidyverse.org/articles/sheet-geometry.html
browseURL("http://readxl.tidyverse.org/articles/sheet-geometry.html")


## Column typing -------------------------------------------------------

## mix specific types with guessing
read_excel(
  readxl_example("deaths.xlsx"),
  range = "arts!A5:C15",
  col_types = c("guess", "skip", "numeric")
)

## recycling happens
read_excel(
  readxl_example("datasets.xlsx"),
  col_types = "text"
)

## "list" col_type prevents all coercion
(df <- read_excel(
  readxl_example("clippy.xlsx"),
  col_types = c("text", "list")
))
tibble::deframe(df)

## The Cell and Column Types vignette has all the details:
## http://readxl.tidyverse.org/articles/cell-and-column-types.html
browseURL("http://readxl.tidyverse.org/articles/cell-and-column-types.html")


## Workflows -------------------------------------------------------

library(tidyverse)

## store a csv snapshot at the moment of import
iris_xl <- readxl_example("datasets.xlsx") %>%
  read_excel(sheet = "iris") %>%
  write_csv("iris-raw.csv")

iris_xl
dir(pattern = "iris")
read_csv("iris-raw.csv")

## load all the worksheets in a workbook at once!
path <- readxl_example("datasets.xlsx")
excel_sheets(path)
path %>%
  excel_sheets() %>%
  set_names() %>%
  map(read_excel, path = path)

## load all the worksheets in a workbook into one BIG BEAUTIFUL
## data frame!
path <- readxl_example("deaths.xlsx")
deaths <- path %>%
  excel_sheets() %>%
  set_names() %>%
  map_df(~ read_excel(path = path, sheet = .x, range = "A5:F15"), .id = "sheet")
deaths

## use a similar workflow to iterate over multiple files in folder

## The readxl Workflows article has all the details:
## http://readxl.tidyverse.org/articles/articles/readxl-workflows.html
browseURL("http://readxl.tidyverse.org/articles/articles/readxl-workflows.html")

## bye bye now :)


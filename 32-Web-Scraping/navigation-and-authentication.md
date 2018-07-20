Navigation and Authentication
================
Garrett Grolemund
November 30, 2016

Two important questions came up that I wasn't able to answer sufficiently during the webinar:

1. Navigation
=============

*Q: Can you use rvest to navigate across web pages?*
*A: Yes.*

To navigate the web with rvest, connect to a url with `html_session()` instead of `read_html()`:

``` r
library(rvest)
orlando <- html_session("http://www.bestplaces.net/climate/city/florida/orlando") 
```

`html_session()` creates a persistent web session that you can navigate in with the following rvest functions:

-   `jump_to()` - navigates to a url, either relative or absolute, e.g.

    ``` r
    orlando %>% 
      jump_to("http://www.bestplaces.net/city/florida/orlando") %>%
      session_history()
    ```

        ##   http://www.bestplaces.net/climate/city/florida/orlando
        ## - http://www.bestplaces.net/city/florida/orlando

-   `follow_link()` - follows a link on the current page that you describe with css, an xpath, or the link text itself, e.g.

    ``` r
    orlando %>% 
      follow_link("Place Overview") %>%
      session_history()
    ```

        ## Navigating to http://www.bestplaces.net/city/florida/orlando

        ##   http://www.bestplaces.net/climate/city/florida/orlando
        ## - http://www.bestplaces.net/city/florida/orlando

-   `back()` - which navigates backwards, e.g.

    ``` r
    (orlando <- orlando %>% follow_link("Cost of Living"))
    ```

        ## Navigating to http://www.bestplaces.net/cost-of-living/

        ## <session> http://www.bestplaces.net/cost-of-living/
        ##   Status: 200
        ##   Type:   text/html; charset=utf-8
        ##   Size:   59225

    ``` r
    (orlando <- orlando %>% back())
    ```

        ## <session> http://www.bestplaces.net/climate/city/florida/orlando
        ##   Status: 200
        ##   Type:   text/html; charset=utf-8
        ##   Size:   150771

You can also submit values to a form on the website with `submit_form()`, described below.

2. Authentication
=================

*Q: Can you use rvest to login to password protected websites, or pages that require authentication?*
*A: This depends on how the website handles authentication.*

If the website relies on form submission, such as a login page, you can submit credentials with the following method:

1.  Navigate to the page in a `html_session()`.
2.  Use `html_node()` to extract the form
3.  Add the login credentials to the form with `set_values()`
4.  Submit the form with `submit_form()`, e.g.

    ``` r
    gh <- html_session("https://github.com/login")
    login <- gh %>% 
      html_node("form") %>% 
      html_form() %>%
      set_values(login = "<USERNAME>", password = "<PASSWORD>") 
    github <- gh %>% 
      submit_form(login) %>%
      read_html()
    ```

`submit_form()` will return a parsed html response if the submission is successful and an error if it is not.

If the website relies on basic HTTP authentication, you can use the `GET()` and `authenticate()` functions from the httr package to access the html. Then parse the reply with [httr methods](https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html).

library(httr)

# OAuth 2 example, lifted from https://github.com/hadley/httr/blob/master/demo/oauth2-github.r

# 1. Find OAuth settings for github:
#    http://developer.github.com/v3/oauth/
oauth_endpoints("github")

# 2. To make your own application, register at at
#    https://github.com/settings/applications. Use any URL for the homepage URL
#    (http://github.com is fine) and  http://localhost:1410 as the callback url
#
#    IRL, you'd want to set the key and secret as environment variables to keep them out of the code.
ghapp <- oauth_app("github",
                   key = "56b637a5baffac62cad9",
                   secret = "8e107541ae1791259e9987d544ca568633da2ebf"
)
# 3. Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), ghapp, cache = TRUE)

# 4. Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/rate_limit", gtoken)
stop_for_status(req)
rate_limit <- content(req)
rate_limit$resources$core$limit

# See API documentation for all resources, examples

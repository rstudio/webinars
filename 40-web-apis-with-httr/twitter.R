library(httr)

# OAuth 1 example, mostly lifted from https://github.com/hadley/httr/blob/master/demo/oauth1-twitter.r

# 1. Find OAuth settings for twitter: https://dev.twitter.com/docs/auth/oauth
oauth_endpoints("twitter")
# use oauth_endpoint() if you are accessing an API not covered in the convenience method oauth_endpoints

# 2. Register an application at https://apps.twitter.com/
#    Make sure to set callback url to "http://127.0.0.1:1410/"
#
#    IRL, you'd want to set the key and secret as environment variables to keep them out of the code.
myapp <- oauth_app("twitter",
                   key = "TYrWFPkFAkn4G5BbkWINYw",
                   secret = "qjOkmKYU9kWfUFWmekJuu5tztE9aEfLbt26WlhZL8"
)

# 3. Get OAuth credentials
twitter_token <- oauth1.0_token(oauth_endpoints("twitter"), myapp, cache = TRUE)

# 4. Use API
req <- GET("https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=rstudiotips&count=10",
           config(token = twitter_token))
stop_for_status(req)
rstudio_tips <- content(req)
rstudio_tips[[1]]$text

# See API documentation for all resources, examples

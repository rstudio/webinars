This is an example of a Plumber API that can respond to Twilio text messages.

The API itself is in `plumber.R`; you should be able to deploy just that file as an API, configure Twilio to route incoming text messages to that endpoint, and then have a working implementation.

The other files in this directory (`index.html` and `emoji.js`) are a silly little web client that leverage the graphs/outputs produced by the plumber API. In order to connect the two, you'll need to modify the `base` variable in `emoji.js` to point to the URL where your plumber API is hosted.

Also, since the site makes remote requests and runs JavaScript, you can't just open `index.html` locally and have it work -- you have to serve it and access it on a local port. You can do that pretty easily by running `python -m SimpleHTTPServer 8000`, at which point opening up http://localhost:8000 should show you a silly little app that hits your endpoint to pull down graphs and leaflet.

All of the code involved here is not well-constructed. It was thrown together at the last minute for demo purposes. I share it here so that you can see a working example which might serve as a useful pointer for your work, but the code/architecture/patterns should not be understood here as best practices or even necessarily secure.

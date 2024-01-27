# test/test-api-app.R
library(httr)

test_that("GET /health-check : API is running", {
  # Send API request
  req <- httr::GET("http://backend:8080/health-check")
  
  # Check response
  expect_equal(req$status_code, 200)

  expect_equal(
    jsonlite::fromJSON(httr::content(req, as = 'text', encoding =  "UTF-8"))$message, 
    "R service running")
})
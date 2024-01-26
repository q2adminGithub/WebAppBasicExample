# test/test-api-app.R

test_that("GET /health-check : API is running", {
  # Send API request
  req <- httr::GET(paste0("http://127.0.0.1"), port = 8080, path = "/health-check")
  
  # Check response
  expect_equal(req$status_code, 200)
  
  expect_equal(
    jsonlite::fromJSON(httr::content(req, as = 'text', encoding =  "UTF-8"))$message, 
    "R Service is running...")
})
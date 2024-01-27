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

test_that("GET /square/42 gives 1764", {
  # Send API request
  req <- httr::GET("http://backend:8080/square/42")
  
  # Check response
  expect_equal(req$status_code, 200)

  expect_equal(
    jsonlite::fromJSON(httr::content(req, as = 'text', encoding =  "UTF-8"))$result, 
    1764)
})

test_that("GET /square/deletestates deletes all saved states", {
  # Send API request
  req <- httr::GET("http://backend:8080/square/deletestates")
  
  # Check response
  expect_equal(req$status_code, 200)

  expect_equal(
    jsonlite::fromJSON(httr::content(req, as = 'text', encoding =  "UTF-8"))$states, 
    "deleted all")

  req <- httr::GET("http://backend:8080/square/savedstates")

  expect_equal(req$status_code, 200)
  expect_equal(
    nrow(jsonlite::fromJSON(httr::content(req, as = 'text', encoding =  "UTF-8"))$states), 
    NULL)  
})

test_that("GET /square/42/TRUE writes the state 42 into database and retrieves the correct value", {
  # Send API request
  req <- httr::GET("http://backend:8080/square/42/TRUE")
  
  # Check response
  expect_equal(req$status_code, 200)
  expect_equal(
    jsonlite::fromJSON(httr::content(req, as = 'text', encoding =  "UTF-8"))$result, 
    1764)

  req <- httr::GET("http://backend:8080/square/savedstates")

  expect_equal(req$status_code, 200)
  states <- jsonlite::fromJSON(httr::content(req, as = 'text', encoding =  "UTF-8"))$states 
  expect_equal(
    nrow(states), 1) #length(states) returns 2 here

  stateid <- states[1]$stateid
  req <- httr::GET(paste0("http://backend:8080/square/savedstate/", stateid))

  expect_equal(req$status_code, 200)
  expect_equal(
    jsonlite::fromJSON(httr::content(req, as = 'text', encoding =  "UTF-8"))$state$input[1], 
    42)  
})

test_that("GET /square/savedstate/42/TRUE is run several times the number of elements in statesave table does not exceed 6", {
  # Send API request
  for (x in 1:20) {
    req <- httr::GET(paste0("http://backend:8080/square/",x,"/TRUE"))
  }
  req <- httr::GET("http://backend:8080/square/savedstates")

  expect_equal(req$status_code, 200)
  states <- jsonlite::fromJSON(httr::content(req, as = 'text', encoding =  "UTF-8"))$states 
  expect_equal(
    nrow(states), 6) #length(states) returns 2 here  
})

test_that("GET /square/savedstate/0 returns an empty dictionary", {
  
  req <- httr::GET("http://backend:8080/square/savedstate/0")

  expect_equal(req$status_code, 200)
  expect_equal(
    length(jsonlite::fromJSON(httr::content(req, as = 'text', encoding =  "UTF-8"))$state), 
    0)  
})
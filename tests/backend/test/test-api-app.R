# test/test-api-app.R
library(httr)
library(curl)

test_that("GET /health-check : API is running", {
  # Send API request
  req <- httr::GET("http://backend:8080/health-check")

  # Check response
  expect_equal(req$status_code, 200)

  expect_equal(
    jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))$message,
    "R service running"
  )
})

test_that("GET /square/42 gives 1764", {
  # Send API request
  req <- httr::GET("http://backend:8080/square/42")

  # Check response
  expect_equal(req$status_code, 200)

  expect_equal(
    jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))$result,
    1764
  )
})

test_that("GET /square/deletestates deletes all saved states", {
  # Send API request
  req <- httr::GET("http://backend:8080/square/deletestates")

  # Check response
  expect_equal(req$status_code, 200)

  expect_equal(
    jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))$states,
    "deleted all"
  )

  req <- httr::GET("http://backend:8080/square/savedstates")

  expect_equal(req$status_code, 200)
  expect_equal(
    nrow(jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))$states),
    NULL
  )
})

test_that("GET /square/42/TRUE writes the state 42 into database and retrieves the correct value", {
  # Send API request
  req <- httr::GET("http://backend:8080/square/42/TRUE")

  # Check response
  expect_equal(req$status_code, 200)
  expect_equal(
    jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))$result,
    1764
  )

  req <- httr::GET("http://backend:8080/square/savedstates")

  expect_equal(req$status_code, 200)
  states <- jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))$states
  expect_equal(
    nrow(states), 1
  ) # length(states) returns 2 here

  stateid <- states[1]$stateid
  req <- httr::GET(paste0("http://backend:8080/square/savedstate/", stateid))

  expect_equal(req$status_code, 200)
  expect_equal(
    jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))$state$input[1],
    42
  )
})

test_that("GET /square/savedstate/42/TRUE is run several times the number of elements in statesave table does not exceed 6", {
  # Send API request
  for (x in 1:20) {
    req <- httr::GET(paste0("http://backend:8080/square/", x, "/TRUE"))
  }
  req <- httr::GET("http://backend:8080/square/savedstates")

  expect_equal(req$status_code, 200)
  states <- jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))$states
  expect_equal(
    nrow(states), 6
  ) # length(states) returns 2 here
})

test_that("GET /square/savedstate/0 returns an empty dictionary", {
  req <- httr::GET("http://backend:8080/square/savedstate/0")

  expect_equal(req$status_code, 200)
  expect_equal(
    length(jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))$state),
    0
  )
})

test_that("GET /square/non-blocking does not block the API", {
  done_callback <- function(req) {
    expect_equal(req$status_code, 200)
  }

  pool <- curl::new_pool()
  curl::curl_fetch_multi("http://backend:8080/square/non-blocking", done = done_callback, pool = pool)
  curl::curl_fetch_multi("http://backend:8080/square/non-blocking", done = done_callback, pool = pool)
  curl::curl_fetch_multi("http://backend:8080/square/non-blocking", done = done_callback, pool = pool)

  output <- curl::multi_run(pool = pool)
  expect_equal(output$success, 3)
})

test_that("GET /square/blocking blocks the API", {
  done_callback <- function(req) {
    expect_equal(req$status_code, 200)
  }

  pool <- curl::new_pool()
  curl::curl_fetch_multi("http://backend:8080/square/blocking", done = done_callback, pool = pool)
  curl::curl_fetch_multi("http://backend:8080/square/blocking", done = done_callback, pool = pool)
  curl::curl_fetch_multi("http://backend:8080/square/blocking", done = done_callback, pool = pool)

  output <- curl::multi_run(pool = pool)
  expect_equal(output$success, 3)
})


test_that("hist-raw returns results before hist-raw-slow", {
  # Initialize an empty list to store response information
  response_info <- list()

  # Define callback function for successful requests
  success <- function(res) {
    res$time <- Sys.time()
    response_info <<- c(response_info, list(res))
    return(TRUE)
  }

  # Define callback function for failed requests
  failure <- function(msg) {
    cat("Request failed!", msg, "\n")
    return(FALSE)
  }

  # Call hist-raw-slow and hist-raw in parallel
  pool <- curl::new_pool()
  curl::curl_fetch_multi("http://backend:8080/square/hist-raw-slow?ndraws=1000&mean=0&sd=1", done = success, fail = failure, pool = pool)
  curl::curl_fetch_multi("http://backend:8080/square/hist-raw?ndraws=1000&mean=0&sd=1", done = success, fail = failure, pool = pool)
  output <- curl::multi_run(pool = pool)

  # Check whether the response of the second request arrived before the first request
  expect_true(
    response_info[[2]]$time > response_info[[1]]$time,
    "Second response should be received before the first response."
  )

  # Check if the URL of the first response matches the expected URL
  expect_true(
    response_info[[1]]$url == "http://backend:8080/square/hist-raw?ndraws=1000&mean=0&sd=1",
    "URL of the first response does not match the expected URL."
  )

  # Print the response information
  for (response in response_info) {
    cat("Response time:", response$time, "URL:", response$url, "\n")
  }
})

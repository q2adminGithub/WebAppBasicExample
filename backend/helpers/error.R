# helpers/error.R

# this code is included in app.R

# (derived) custom error definition with error message and error code
api_error <- function(message, status) {
  err <- base::structure(
    list(message = message, status = status),
    class = c("api_error", "error", "condition")
  )
  base::signalCondition(err)
}

# this function is called in the Plumber error hook
# checks whether error is of custom error type api_error or not (in that case 500-internal server error) and logs error message and status
error_handler <- function(req, res, err) {
  if (!inherits(err, "api_error")) {
    # for all other errors except api_error
    logger::log_error("500 {convert_empty(err$message)}")
    res$status <- 500
    res$body <- list(
      code = 500,
      message = "Internal server error"
    )
  } else {
    # for errors of type api_error
    logger::log_error("{err$status} {convert_empty(err$message)}")
    res$status <- err$status
    res$body <- list(
      code = err$status,
      message = err$message
    )
  }
}

# error call for bad_request error emitting a custom api_error
bad_request <- function(message = "Somethings wrong") {
  return(api_error(message = message, status = 400))
}

# error call for no_found error emitting a custom api_error
not_found <- function(message = "Resource not found") {
  return(api_error(message = message, status = 404))
}
# helpers/error.R

api_error <- function(message, status) {
  err <- base::structure(
    list(message = message, status = status),
    class = c("api_error", "error", "condition")
  )
  base::signalCondition(err)
}

error_handler <- function(req, res, err) {
  if (!inherits(err, "api_error")) {
    logger::log_error("500 {convert_empty(err$message)}") # nolint
    res$status <- 500
    body <- list(
      code = 500,
      message = "Internal server error"
    )
  } else {
    logger::log_error("{err$status} {convert_empty(err$message)}") # nolint
    res$status <- err$status
    body <- list(
      code = err$status,
      message = err$message
    )
  }
}

bad_request <- function(message = "Somethings wrong") {
  return(api_error(message = message, status = 400))
}

not_found <- function(message = "Resource not found") {
  return(api_error(message = message, status = 404))
}
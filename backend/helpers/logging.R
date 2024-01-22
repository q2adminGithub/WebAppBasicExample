# helpers/logging.R

library('logger')
library('tictoc')

# write logs to file
log_dir <- "logs"
if (!fs::dir_exists(log_dir)) fs::dir_create(log_dir)
logger::log_appender(
  logger::appender_tee(
    base::tempfile(
      pattern = paste0("plumber_",format(Sys.time(),'%Y%m%d_%H%M%S'),"_"),
      tmpdir = log_dir,
      fileext = ".log"
    )
  )
)

# transform empty value to -
convert_empty <- function(string = "") {
  if (is.null(string)) return("-")
  if (string == "") return("-")
  return(string)
}

pre_route_logging <- function(req) {
  tictoc::tic(msg = req$PATH_INFO)
}

post_route_logging <- function(req, res) {
  end <- tictoc::toc(quiet = TRUE) # nolint
  
  logger::log_info(sprintf('%s "%s" %s %s %s %s %s',
                   convert_empty(req$REMOTE_ADDR),
                   convert_empty(req$HTTP_USER_AGENT),
                   convert_empty(req$HTTP_HOST),
                   convert_empty(req$REQUEST_METHOD),
                   convert_empty(end$msg),
                   convert_empty(res$status),
                   round(end$toc - end$tic, digits = getOption("digits", 5))
  )) # nolint
}
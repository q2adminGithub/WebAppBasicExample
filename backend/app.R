library(pool)
library(plumber)
library(magrittr)
library(jsonlite)
library(future)
library(promises)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) {
    stop("must provide three arguments: database name, database user, password", call. = FALSE)
}

# Create pool connection
con <- pool::dbPool(
    drv = RPostgres::Postgres(),
    dbname = args[1],
    host = "postgres_db", # this needs to be the name of the postgres service (line 3 in docker-compose.yml)
    user = args[2],
    password = args[3],
    port = 5432
)

# load required helpers
source("./helpers/error.R")
source("./helpers/logging.R")
source("./helpers/validator.R")
source("./helpers/database.R")

WORKERS <- strtoi(Sys.getenv("WORKERS", 3))

future::plan(future::multisession(workers = WORKERS))

log_info(paste0("Plumber will use ", WORKERS, " workers"))

logger::log_info(paste0("plumber API started"))
logger::log_info(paste0("connected to database ", args[1]))
# App initialization and settings for warning, trailing slash
app <- plumber::pr()
# options(warn = -1)
plumber::options_plumber(trailingSlash = TRUE)

# use Plumber hooks for error handling etc.
app %>%
    plumber::pr_set_error(error_handler) %>%
    plumber::pr_hooks(list(preroute = pre_route_logging, postroute = post_route_logging))

# for development: headers to switch off CORS (for simple get requests, not sufficient for application/json post requests)
app %>%
    plumber::pr_filter("cors", function(req, res){
        res$setHeader("Access-Control-Allow-Origin", "*") 
        if (req$REQUEST_METHOD == "OPTIONS") { # for cors preflight check
            res$setHeader("Access-Control-Allow-Methods", "DELETE, POST, GET, OPTIONS")
            res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
            res$status <- 200
            return (list())
        }
        plumber::forward()
    })

# Simple route for root
app %>%
    plumber::pr_get("/", function(req, res) {
        return(list(result = "Welcome to R Services"))
    },
    serializer = plumber::serializer_unboxed_json()
    )

# mount routes
# get all files in subfolder routes
r_routes_file_names <- base::list.files(
    path = "./routes",
    full.names = TRUE,
    recursive = TRUE
)
# loop over all files in subfolder routes and mount them
for (file_name in r_routes_file_names) {
    route_name <- base::substring(file_name, 10, nchar(file_name) - 2)
    logger::log_info(paste0("mounting endpoints in: ", file_name))
    app %>% plumber::pr_mount(route_name, plumber::pr(file_name))
}

# run plumber
app %>%
    plumber::pr_run(host = "0.0.0.0", port = 8080)

# Close pool connection on exit
app$registerHooks(
    list(
        "exit" = function() {
            logger::log_info(paste0("shutting down ... closing pool"))
            pool::poolClose(pool)
        }
    )
)

library(pool)
library(plumber)
library(magrittr)
library(jsonlite)


# Create pool connection
con <- pool::dbPool(
    drv = RPostgres::Postgres(),
    dbname = "mydb_dev",
    host = "postgres_db", # this needs to be the name of the postgres service (line 3 in docker-compose.yml)
    user = "myuser",
    password = "mypassword",
    port = 5432)

# load required helpers
source("./helpers/error.R")
source("./helpers/logging.R")
source("./helpers/validator.R")
source("./helpers/database.R")

logger::log_info(paste0('plumber API started'))
# App initialization and settings for warning, trailing slash
app <- plumber::pr()
#options(warn = -1)
plumber::options_plumber(trailingSlash = TRUE)
# Plumber settings
app %>% 
    plumber::pr_set_error(error_handler) %>%
    plumber::pr_hooks(list(preroute = pre_route_logging, postroute = post_route_logging))

# for development: headers to switch off CORS (for simple get requests, not sufficient for application/json post requests)
app %>%
    plumber::pr_filter("cors", function(res){
        res$setHeader("Access-Control-Allow-Origin", "*") 
        res$setHeader("Access-Control-Allow-Methods", "DELETE, POST, GET, OPTIONS")
        res$setHeader("Access-Control-Allow-Headers", "Origin, Accept, Content-Type, Authorization, X-Requested-With")
        plumber::forward()
    })

# Simple Routes
app %>%
    plumber::pr_get("/", function(req, res){
    return(list(result = "Welcome to R Services")) }, 
    serializer = plumber::serializer_unboxed_json())

# mount routes
##get all router files
r_routes_file_names <- base::list.files(path = './routes',
                                       full.names=TRUE, 
                                       recursive=TRUE)
##loop over all routers and mount them
#logger::log_info(paste0('route_file_names ', r_routes_file_names))
for (file_name in r_routes_file_names) {
    route_name <- base::substring(file_name, 10, nchar(file_name) - 2)
    logger::log_info(paste0('mounting endpoints in: ', file_name))
    app %>% plumber::pr_mount(route_name, plumber::pr(file_name))
}
 
# run plumber
app %>%
  plumber::pr_run(host = '0.0.0.0', port = 8080)

# Close your pool connection on exit
app$registerHooks(
    list(
        "exit" = function() {
            logger::log_info(paste0('shutting down ... closing pool'))
            pool::poolClose(pool)
        }
    )
)
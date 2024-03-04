# helpers/database.R

# this code is included in app.R

# check whether database connection is established, throws if not.
dbIsConnected <- function(origin = ""){
    isDBconnected <- pool::dbIsValid(con)
    if(!isDBconnected) {
        logger::log_error("DB IS NOT CONNECTED!")
        logger::log_error(paste0("R MESSAGE: ",geterrmessage()))
        api_error(paste0("DB IS NOT CONNECTED! FROM ", origin), 400)
    }
}

# insert a new row into table statesave with ts_utc the (UTC) system datetime and statejson the input jsonString
# if the total number of rows in table statesave after insertion exceeds maxNbrSaved, delete the most out-of-date rows until there are maxNbrSaved rows left
# optional origin to log the referrer in case of an error
addToStatesave <- function(jsonString, origin = ""){
    maxNbrSaved <- 6 # number of slots in the database for user to save app-states
    dbIsConnected(origin)
    ts <- format(Sys.time(),'%Y-%m-%d %H:%M:%S')
    pool::dbExecute(con, paste0("INSERT INTO statesave (ts_utc, statejson) VALUES ('",ts,"','", jsonString, "')"))
    pool::dbExecute(con, paste0("DELETE FROM statesave WHERE stateid IN (SELECT stateid FROM statesave ORDER BY stateid DESC OFFSET ", maxNbrSaved, ")"))
}

# get the stateid and the timestamp for all saved states from table savestate
# optional origin to log the referrer in case of an error
# returns as dictionary {'states': [{'stateid':..., 'ts_utc':...}, {...}, ...]}
savedStates <- function(origin = ""){
    dbIsConnected(origin)
    df <- pool::dbGetQuery(con, "SELECT stateid, ts_utc FROM statesave")
    return(list(states=jsonlite::fromJSON(jsonlite::toJSON(df))))
}

# get the content of row with stateid=i as dictionary
# optional origin to log the referrer in case of an error
# returns as dictionary {'state'={'stateid': i, 'ts_utc':..., 'jsonstring':{...}}} if there is a row with stateid=i or {'state'={}} else
savedState <- function(i, origin = ""){
    dbIsConnected(origin)
    sql <- pool::sqlInterpolate(con, "SELECT * FROM statesave WHERE stateid = ?id", id=i) # sanitize string since i is direct user input 
    df <- pool::dbGetQuery(con, sql)
    res <- if (nrow(df) > 0) df[['statejson']][1] else '{}'
    return(list(state=jsonlite::fromJSON(res, simplifyVector = FALSE)))
}

# deletes the row with stateid=i
# optional origin to log the referrer in case of an error
# returns as dictionary {'state'='deleted'} in any case
deleteState <- function(i, origin = ""){
    dbIsConnected(origin)
    sql <- pool::sqlInterpolate(con, "DELETE FROM statesave WHERE stateid = ?id", id=i) # sanitize string since i is direct user input
    df <- pool::dbGetQuery(con, sql)
    return(list(state='deleted'))
}

# deletes all rows in table statesave
# optional origin to log the referrer in case of an error
# returns as dictionary {'states'='deleted all'}
deleteStates <- function(origin = ""){
    dbIsConnected(origin)
    df <- pool::dbGetQuery(con, "DELETE FROM statesave")
    return(list(states='deleted all'))
}

# get the JSON content in column datajson of row with name=dfname as list of dictionary per row
# optional origin to log the referrer in case of an error
# returns JSON content in column datajson if there is a row with name=dfname or [] else
getSelectedInputData <- function(dfname, origin = ""){
    dbIsConnected(origin)
    sql <- pool::sqlInterpolate(con, "SELECT * FROM inputdata WHERE name = ?n", n=dfname) # sanitize string since dfname is direct user input 
    df <- pool::dbGetQuery(con, sql)
    res <- if (nrow(df) > 0) df[['datajson']][1] else '[]'
    return(jsonlite::fromJSON(res, simplifyVector = FALSE))
}

# get the all input data of table inputdata as dictionary
# optional origin to log the referrer in case of an error
# returns dictionary with names as keys and list of dictionary per row as value 
getInputData <- function(origin = ""){
    dbIsConnected(origin)
    df <- pool::dbGetQuery(con, "SELECT name, datajson FROM inputdata")
    if (nrow(df) == 0){
        return(list())
    }
    ret <- list()
    for( i in rownames(df)){
        ret[[df[i, "name"]]] = jsonlite::fromJSON(df[i, "datajson"], simplifyVector = FALSE)
    }
    return(ret)
}
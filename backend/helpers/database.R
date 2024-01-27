dbIsConnected <- function(origin = ""){
    isDBconnected <- pool::dbIsValid(con)
    if(!isDBconnected) {
        logger::log_error("DB IS NOT CONNECTED!")
        logger::log_error(paste0("R MESSAGE: ",geterrmessage()))
        api_error(paste0("DB IS NOT CONNECTED! FROM ", origin), 400)
    }
}

addToStatesave <- function(jsonString, origin = ""){
    maxNbrSaved <- 6 # number of slots in the database for user to save app-states
    dbIsConnected(origin)
    ts <- format(Sys.time(),'%Y-%m-%d %H:%M:%S')
    pool::dbExecute(con, paste0("INSERT INTO statesave (ts_utc, statejson) VALUES ('",ts,"','", jsonString, "')"))

    pool::dbExecute(con, paste0("DELETE FROM statesave WHERE stateid IN (SELECT stateid FROM statesave ORDER BY stateid DESC OFFSET ", maxNbrSaved, ")"))

    #nRows <- nrow(pool::dbReadTable(con, 'statesave'))
    #if (nRows > maxNbrSaved){
    #    df <- pool::dbGetQuery(con, paste0("SELECT stateid from statesave order by stateid asc limit ", (nRows-maxNbrSaved)))
    #    pool::dbExecute(con, paste0("DELETE FROM statesave WHERE stateid IN (", paste0(df[['stateid']], collapse=','),")"))
    #    logger::log_info(paste0("deleting", paste0(df[['stateid']], collapse=',')))
    #}
}

savedStates <- function(origin = ""){
    dbIsConnected(origin)
    df <- pool::dbGetQuery(con, "SELECT stateid, ts_utc FROM statesave")
    #return(list(ts_utc=df[['ts_utc']], stateid=df[['stateid']]))
    return(list(states=jsonlite::fromJSON(jsonlite::toJSON(df))))
}

savedState <- function(i, origin = ""){
    dbIsConnected(origin)
    sql <- pool::sqlInterpolate(con, "SELECT * FROM statesave WHERE stateid = ?id", id=i) 
    df <- pool::dbGetQuery(con, sql)
    #write.csv(df, "/app/test.txt") #, row.names=FALSE)
    #logger::log_info(paste0('sql result ', nrow(df), " ", paste0(df[['statejson']], collapse=',')))
    res <- if (nrow(df) > 0) df[['statejson']][1] else '{}'
    #logger::log_info(paste0('savedstate jsonString', i, ' ', res))
    return(list(state=jsonlite::fromJSON(res, simplifyVector = FALSE)))
}

deleteState <- function(i, origin = ""){
    dbIsConnected(origin)
    sql <- pool::sqlInterpolate(con, "DELETE FROM statesave WHERE stateid = ?id", id=i) 
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
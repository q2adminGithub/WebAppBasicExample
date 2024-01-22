# routes/square.R

#* @apiTitle  Square of a number with typed dynamic routing with and without saving the input to database
#* @apiDescription An API that computes the square of a number
#* @get /<x:int>/<save:bool>
#* @serializer unboxedJSON
square_function_save <- function(x, save) {
  if (save == TRUE){
    addToStatesave(jsonlite::toJSON(list(input=x), auto_unbox = TRUE), "GET square/<x:int>/<save:bool>")
  }
  return(list(result=x^2))
}

#* @apiTitle  Square of a number with typed dynamic routing
#* @apiDescription An API that computes the square of a number
#* @get /<x:int>
#* @serializer unboxedJSON
square_function <- function(x) {
  return(square_function_save(x, FALSE))
}

#* @apiTitle  Square of a number with query text
#* @apiDescription An API that computes the square of a number
#* @param x
#* @param save
#* @get /
#* @serializer unboxedJSON
square_function_query <- function(x, save) {
  logger::log_info(paste0("query ", x, " ", typeof(x), " ", is.numeric(x), " ", is.finite(x), " ", nchar(x), " ", as.numeric(x), " ", save, " ", typeof(save)))
  #x <- checkNumber(x) #throws for some reason? is.numeric("9") gives FALSE?
  x <- checkNumeric(x)
  save <- checkBoolean(save)
  logger::log_info(paste0("query after check ", x, " ", typeof(x), " ", save, " ", typeof(save)))
  return(square_function_save(x, save))
}

#* @apiTitle  retrieve all saved stated timestamps and ids
#* @apiDescription gets the saved states from database 
#* @get /savedstates
#* @serializer json
saved_states <- function(x) {
  return(savedStates('GET /square/savedstates'))
}

#* @apiTitle retrieves a specific saved stated with id
#* @apiDescription gets the saved states from database 
#* @get /savedstate/<i:int>
#* @serializer json
saved_state <- function(i) {
  return(savedState(i, 'GET /square/savedstate/<i:int>'))
}

#* @apiTitle deletes a specific saved stated with id
#* @apiDescription deletes the saved states in database 
#* @get /deletestate/<i:int>
#* @serializer json
delete_state <- function(i) {
  return(deleteState(i, 'GET /square/deletestate/<i:int>'))
}

#* @apiTitle  error test
#* @apiDescription  error test
#* @get /error
#* @serializer unboxedJSON
square_function_error <- function() {
  log_error('test api_error')
  api_error('API Error', 400)
  return(list(status=400))
}
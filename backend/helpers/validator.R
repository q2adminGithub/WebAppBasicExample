# helpers/validator.R

# this code is included in app.R

# check existance of all attributes in data object
# send bad_request error if one of the attributes does
# not exist
checkRequired <- function(data, attributes = c()) {
  lapply(attributes, function(attribute) {
    if (!exists(attribute, data)) bad_request(paste0(attribute,
                                                     " is required"))
  })
}

# check if the value is a data (array of object in js)
# and the length is not 0 or empty. the function also
# returns the data.
checkData <- function(data, attributeName = "data") {
  if (!is.list(data) || length(data) == 0) bad_request(paste0(attributeName, 
                                                              " must be an array and not empty"))
  return(data)
}

# check if the value is an array, e.g [1,2,3,4,5], not [] and
# will return the array, throw error otherwise.
checkArray <- function(data, attributeName = "data") {
  if (!is.vector(data) || length(data) == 0) bad_request(paste0(attributeName,
                                                                " must be an array and not empty"))
  return(data)
}

# check  ifthe value is an array and give empty array
# if the value is not an array, invalid, or NULL
checkVector <- function(data = c()) {
  if (!is.vector(data) || is.list(data)) return(c())
  
  data <- data[!is.na(data)]
  
  if (length(data) == 1 && !nzchar(data[1])) return(c())
  
  return(data[nzchar(data)])
}

# check if the value is a string and is in formula format
# e.g y~x1+x2 etc, and return it as an R formula, throw error otherwise
checkFormula <- function(formula, attributeName = "formula") {
  return(tryCatch(as.formula(formula),
                  error = function(error) bad_request(paste0(attributeName, 
                                                             " is not valid, example: y~x1+x2..."))
  ))
}

# check if the value is a number or numeric, give back the value.
# throw error if the value is not a number
checkNumber <- function(value, attributeName = "number") {
  if (!is.numeric(value)) bad_request(paste0(attributeName, 
                                             " is not number"))
  return(value)
}

# check if the value is a number or numeric, give back the value.
checkNumeric <- function(value, attributeName = "numeric"){
  return(tryCatch(as.numeric(value),  #produces warning that NA is returned
                  warning = function(warning) bad_request(paste0(value, " cannot be converted to numeric"))  ))
}

# check if the value exist in the given array.
# example is 3 exist in [3,4,5,6]?
checkInArray <- function(value, array) {
  if (!(value %in% array)) bad_request(paste0(value, 
                                              " is not in: ", 
                                              paste0(array, collapse = ", ")))
  return(value)
}

# check if the value is a boolean, e.g FALSE, false,
# TRUE, true, 0, 1, etc. return back the boolean value
checkBoolean <- function(value) {
  if (!(tolower(value) %in% c("true", "false", 1, 0))) bad_request(paste0(value, 
                                                                          " is not valid boolean"))
  return(tolower(value) == "true" || tolower(value) == 1)
}

# set the maximum number of the given value.
# setMaxNumber(4, 3) -> 3
setMaxNumber <- function(value, max){
  if(value < max) return(value)
  return(max)
}
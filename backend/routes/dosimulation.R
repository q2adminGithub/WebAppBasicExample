# routes/dosimulation.R

#* @apiTitle  get all input data
#* @apiDescription get all input data
#* @get /allinputdata
#* @serializer unboxedJSON
get_all_inputdata <- function() {
  return(getInputData("GET dosimulation/allinputdata"))
}

#* @apiTitle  get input data for dfname
#* @apiDescription get input data for dfname
#* @get /inputdata/<dfname>
#* @serializer unboxedJSON
get_inputdata <- function(dfname) {
  return(getSelectedInputData(dfname, "GET dosimulation/inputdata/<dfname>"))
}

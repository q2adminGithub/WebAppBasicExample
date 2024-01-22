# routes/health-check.R

#* Check if the API is running
#* @serializer unboxedJSON
#* @get /
function(req, res) {
  return(list(message = "R service running"))
}

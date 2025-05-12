#' ruf

#' @name pause_exec
#' @export
pause_exec <- function(prompt, r="character") {
  
  # check if return type is missing
  if(is.na(r)) {
    r = "character" # set default return as character
  }
  
  # get user input
  user_resp = readline(prompt = paste0(prompt, ": "))
  
  # convert response
  if(r == "numeric") {
    final <- as.numeric(user_resp)
  } else {
    final <- user_resp
  }
  
  return(final)
}
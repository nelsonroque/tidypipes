#' ruf

#' @name rand_datetime
#' @param start_date class: numeric
#' @param end_date  class: numeric
#' @param size  class: numeric
#' @param rand_seed  class: numeric
#' @keywords data processing
#' @import tidyverse
#' @import lubridate
#' @examples
#' rand_datetime(start_date, end_date, size, rand_seed)
#' @export
rand_datetime <- function(start_date, end_date, size, tz = "America/New_York", rand_seed=999, verbose=T, return_vector=F) {
  set.seed(rand_seed)
  
  # construct date timestamps
  dateselect <- sample(seq(as.Date(start_date), as.Date(end_date), by="day"), size=size, replace=TRUE)
  hourselect <- sample(1:23,size,replace=TRUE)
  minselect <- sample(0:59,size,replace=TRUE)
  secselect <- sample(0:59,size,replace=TRUE)
  
  if(verbose) {
    print("Date Sample Vector: ")
    print(dateselect)
    print("------------------------")
    print("Hour Sample Vector: ")
    print(hourselect)
    print("------------------------")
    print("Minutes Sample Vector: ")
    print(minselect)
    print("------------------------")
    print("Seconds Sample Vector: ")
    print(secselect)
    print("------------------------")
  }
  
  if(return_vector) {
    fr <- lubridate::parse_date_time2(paste(dateselect, "T", hourselect,":",minselect,":",secselect, sep=""), orders="%Y-%m-%d %H:%M:$S ", tz=tz)
  } else {
    fr <- tibble::tibble(timestamp=lubridate::parse_date_time2(paste(dateselect, "T", hourselect,":",minselect,":",secselect, sep=""), orders="%Y-%m-%d %H:%M:$S ", tz=tz))
    
  }
  return(fr)
}
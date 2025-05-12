#' ruf

#' @name get_time_travel_vector
#' @param start_date class: POSIXlt
#' @param horizon_days class: numeric
#' @param horizon_direction class: string
#' @keywords to add date features to timestamp
#' @import anytime
#' @examples
#' get_time_travel_vector(start_date, horizon_days = 14, horizon_direction = "+")
#' @export
get_time_travel_vector <- function(start_date, horizon_days = 14, horizon_direction = "+") {
  start_date <- anytime::anydate(start_date)
  
  if(horizon_direction == "+") {
    new_start <- start_date + as.difftime(horizon_days, unit="days")
    date_vec <- seq(start_date, new_start, 1)
  } else {
    if(horizon_direction == "-") {
      new_start <- start_date - as.difftime(horizon_days, unit="days")
      date_vec <- seq(new_start, start_date, 1)
    }
  }

  return(date_vec)
}
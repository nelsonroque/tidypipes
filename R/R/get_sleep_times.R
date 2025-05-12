#' ruf

#' @name get_rand_sleep_times
#' @param min class: numeric
#' @param max class: numeric
#' @param by class: numeric
#' @import tidyverse
#' @examples
#' get_rand_sleep_times(min=0, max=10, by=0.1)
#' @export
get_rand_sleep_times <- function(min=0, max=10, by=0.1) {
  if(min < 0) {
    stop("`min` must be greater than or equal to 0")
  }
  sleep_times <- tibble::tibble(sleep_times = seq(min, max, by))
  return(sleep_times)
}
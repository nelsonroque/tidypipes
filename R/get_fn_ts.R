#' Get Filename Timestamp
#'
#' This function generates a timestamp suitable for use in filenames.
#' The timestamp is cleaned using the `janitor` package to ensure that it
#' is free from any unwanted characters.
#'
#' @param time A POSIXct object representing the time. Defaults to the current system time (`Sys.time()`).
#' @param tz Timezone string
#'
#' @return A character string representing the cleaned timestamp.
#' @export
#'
#' @examples
#' # Generate a cleaned timestamp for the current time
#' get_fn_ts()
#'
#' # Generate a cleaned timestamp for a specific time
#' get_fn_ts(as.POSIXct("2024-06-15 12:34:56"))
get_fn_ts <- function(time = Sys.time(), tz="UTC", format="%Y-%B-%d_%H-%M-%S") {
    withr::local_locale(c("LC_TIME" = "C"))
    format(time, format , tz = tz)
}

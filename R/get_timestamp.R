#' Generate a Timestamp for Filenames
#'
#' This function generates a timestamp suitable for use in filenames.
#' The timestamp is formatted and optionally cleaned to ensure compatibility.
#'
#' @param time A POSIXct object representing the time. Defaults to the current system time (`Sys.time()`).
#' @param tz A string specifying the timezone. Defaults to "UTC".
#' @param format A string specifying the timestamp format. Defaults to "%Y-%m-%d_%H-%M-%S".
#' @param clean Logical. If TRUE, removes unsafe filename characters (e.g., spaces, special symbols). Defaults to TRUE.
#'
#' @return A character string representing the formatted and cleaned timestamp.
#' @export
#'
#' @examples
#' # Default timestamp
#' get_timestamp()
#'
#' # Custom timestamp format
#' get_timestamp(format = "%Y-%m-%d_%H-%M-%S")
#'
#' # Timestamp for a specific time
#' get_timestamp(as.POSIXct("2024-06-15 12:34:56"))
get_timestamp <- function(time = Sys.time(),
                          tz = "UTC",
                          format = "%Y-%m-%d_%H-%M-%S",
                          clean = TRUE) {
  withr::local_locale(c("LC_TIME" = "C"))

  ts <- format(time, format, tz = tz)

  if (clean) {
    ts <- gsub("[^A-Za-z0-9_-]", "_", ts) # Replace unsafe characters with underscores
  }

  return(ts)
}

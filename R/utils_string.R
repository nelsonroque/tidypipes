#' @section utils_string
#'
#' @keywords internal


#' Extract File Extension
#'
#' Extracts the file extension from a file path string.
#'
#' @param file_path A character string representing a file path.
#'
#' @return A character string representing the file extension.
#' @export
extract_file_ext <- function(file_path) {
  file_info <- strsplit(file_path, "\\.")
  file_ext <- file_info[[1]][length(file_info[[1]])]
  # TODO CHECK AGAINST PARSEABLE EXTS for READ/WRITE
  return(file_ext)
}

#' Make Tidy DateTime Filename
#'
#' Generates a clean, underscore-separated filename from a POSIXct timestamp.
#'
#' @param datetime A POSIXct object. Defaults to current system time.
#'
#' @param timezone A string specifying timezone. Defaults to "UTC".
#' @param prefix A string prefix to prepend to the filename.
#' @param suffix A string suffix to append to the filename.
#'
#' @return A character string suitable for use as a filename.
#' @export
make_tidy_datetime_filename <- function(datetime = Sys.time(), timezone = "UTC", prefix = "", suffix = "") {
  dt <- as.POSIXlt(datetime, tz = timezone)
  dt_str <- format(dt, "%Y_%m_%dT%H_%M_%S")
  tidy_str <- gsub("[^A-Za-z0-9_]", "_", dt_str)
  paste0(prefix, tidy_str, suffix)
}

#' @section utils_io
#'
#' @keywords internal
#'




#' Read Data File by Extension
#'
#' Reads a data file based on its extension (csv, json, xlsx, rds, etc.).
#'
#' @param file_path Path to the file.
#'
#' @return A data frame or list.
#' @export
read_any <- function(file_path) {
  if (!file.exists(file_path)) stop("File not found: ", file_path)
  ext <- tolower(tools::file_ext(file_path))

  read_methods <- list(
    csv = ~ readr::read_csv(.x, show_col_types = FALSE),
    json = ~ jsonlite::fromJSON(.x),
    rds = ~ readRDS(.x),
    xlsx = ~ readxl::read_xlsx(.x),
    parquet = ~ arrow::read_parquet(.x),
    feather = ~ arrow::read_feather(.x)
  )

  if (!ext %in% names(read_methods)) stop("Unsupported file format: ", ext)
  read_methods[[ext]](file_path)
}


#' Read and Optionally Merge Files from a Directory
#'
#' Reads all supported files (e.g., CSV, JSON, Parquet) from a directory.
#'
#' @param dir_path Path to the directory.
#' @param pattern Regex pattern to filter files (default: all files).
#' @param recursive Logical. If TRUE, reads files recursively. Default is TRUE.
#' @param return_list Logical. If TRUE, returns a list. If FALSE, binds into one data frame. Default is TRUE.
#'
#' @return A list of data frames or a single merged data frame.
#' @export
read_dir_files <- function(dir_path, pattern = ".*", recursive = TRUE, return_list = TRUE) {
  files <- list.files(path = dir_path, pattern = pattern, full.names = TRUE, recursive = recursive)
  data_list <- lapply(files, read_any)

  if (return_list) {
    return(data_list)
  } else {
    dplyr::bind_rows(data_list, .id = "source_file")
  }
}

#' Write Data File by Extension
#'
#' Writes a data frame to a file based on the file extension.
#'
#' @param data A data frame or list.
#' @param file_path Destination path.
#'
#' @return None.
#' @export
write_any <- function(data, file_path) {
  if (!is.data.frame(data) && !is.list(data)) stop("Input must be data.frame or list.")
  ext <- tolower(tools::file_ext(file_path))

  write_methods <- list(
    csv = ~ readr::write_csv(data, .x),
    json = ~ write(jsonlite::toJSON(data, pretty = TRUE, auto_unbox = TRUE), .x),
    rds = ~ saveRDS(data, .x),
    xlsx = ~ writexl::write_xlsx(data, .x),
    parquet = ~ arrow::write_parquet(data, .x),
    feather = ~ arrow::write_feather(data, .x)
  )

  if (!ext %in% names(write_methods)) stop("Unsupported file format: ", ext)
  write_methods[[ext]](file_path)
}


#' Write a Data Frame to CSV with Optional Timestamp
#'
#' Writes a data frame to a CSV file, optionally appending a timestamp to the filename.
#'
#' @param df A data frame to write.
#' @param add_timestamp Logical. If TRUE, appends a timestamp to the filename. Default is TRUE.
#' @param timezone A character string specifying the timezone for the timestamp. Default is "UTC".
#'
#' @return None. Writes a file to disk.
#' @export
write_qcsv <- function(df, add_timestamp = TRUE, timezone = "UTC") {
  if (!is_dataframe_or_tibble(df)) {
    stop("Only data frames and tibbles can be written with write_qcsv().")
  }

  fname <- deparse(substitute(df))
  if (add_timestamp) {
    ts <- make_tidy_datetime_filename(timezone = timezone)
    fname <- paste0(fname, "_", ts)
  }
  readr::write_csv(df, paste0(fname, ".csv"))
}


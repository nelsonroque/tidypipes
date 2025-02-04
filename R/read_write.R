#' Read Data File Based on File Extension
#'
#' This function reads a data file based on its extension and returns a data frame or list.
#' It supports various formats including CSV, JSON, SAS, Parquet, Excel, Feather, and RDS.
#'
#' @param file_path A character string representing the path to the file to be read.
#'
#' @return A data frame or list containing the data from the file.
#' @export
#'
#' @examples
#' \dontrun{read_data_file("data.csv")}
#' \dontrun{read_data_file("data.json")}
read_data_file <- function(file_path) {
  # Validate file existence
  if (!file.exists(file_path)) {
    stop(paste0("File not found: ", file_path))
  }

  # Determine file extension
  file_ext <- tolower(tools::file_ext(file_path))

  # Define file reading methods
  read_methods <- list(
    csv = function(fp) readr::read_csv(fp, show_col_types = FALSE),
    json = function(fp) jsonlite::fromJSON(fp),
    sas7bdat = function(fp) haven::read_sas(fp),
    xpt = function(fp) haven::read_xpt(fp),
    parquet = function(fp) arrow::read_parquet(fp),
    xlsx = function(fp) readxl::read_xlsx(fp),
    feather = function(fp) arrow::read_feather(fp),
    rds = function(fp) readRDS(fp)
  )

  # Check if the format is supported and read the file
  if (file_ext %in% names(read_methods)) {
    return(read_methods[[file_ext]](file_path))
  } else {
    stop(paste0("Unsupported file format: ", file_ext))
  }
}

#' Write Data to a File Based on Extension
#'
#' This function writes a data frame to a file based on the specified extension.
#' It supports various formats including CSV, JSON, Parquet, Excel, Feather, and RDS.
#'
#' @param data A data frame or list to be written to a file.
#' @param file_path A character string representing the path to the file where the data should be written.
#'
#' @return NULL
#' @export
#'
#' @examples
#' \dontrun{write_data_file(mtcars, "data.csv")}
#' \dontrun{write_data_file(mtcars, "data.json")}
write_data_file <- function(data, file_path) {
  # Ensure the provided data is valid
  if (!is.data.frame(data) && !is.list(data)) {
    stop("The data must be a data frame or a list.")
  }

  # Determine file extension
  file_ext <- tolower(tools::file_ext(file_path))

  # Define file writing methods
  write_methods <- list(
    csv = function(fp, dt) readr::write_csv(dt, fp),
    json = function(fp, dt) write(jsonlite::toJSON(dt, pretty = TRUE, auto_unbox = TRUE), fp),
    parquet = function(fp, dt) arrow::write_parquet(dt, fp),
    xpt = function(fp, dt) haven::write_xpt(dt, fp),
    sav = function(fp, dt) haven::write_sav(dt, fp),
    xlsx = function(fp, dt) writexl::write_xlsx(dt, fp),
    feather = function(fp, dt) arrow::write_feather(dt, fp),
    rds = function(fp, dt) saveRDS(dt, fp)
  )

  # Check if the format is supported and write the file
  if (file_ext %in% names(write_methods)) {
    write_methods[[file_ext]](file_path, data)
    message("File successfully saved: ", file_path)
  } else {
    stop(paste0("Unsupported file format: ", file_ext))
  }
}

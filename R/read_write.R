#' Read Data File
#'
#' This function reads a data file based on its extension and returns a data frame or list.
#' It supports various file formats including CSV, JSON, SAS, Parquet, Excel, Feather, and RDS.
#'
#' @param file_path A character string representing the path to the file to be read.
#'
#' @return A data frame or list containing the data from the file.
#' @export
#'
#' @examples
#' # Read a CSV file
#' \dontrun{read_data_file("data.csv")}
#'
#' # Read a JSON file
#' \dontrun{read_data_file("data.json")}
#'
#' # Read a SAS file
#' \dontrun{read_data_file("data.sas7bdat")}
#'
#' # Read a Parquet file
#' \dontrun{read_data_file("data.parquet")}
#'
#' # Read an Excel file
#' \dontrun{read_data_file("data.xlsx")}
#'
#' # Read a Feather file
#' \dontrun{read_data_file("data.feather")}
#'
#' # Read an RDS file
#' \dontrun{read_data_file("data.rds")}
read_data_file <- function(file_path) {
  if (stringr::str_detect(file_path, "\\.csv$")) {
    readr::read_csv(file_path)
  } else if (stringr::str_detect(file_path, "\\.json$")) {
    jsonlite::fromJSON(file_path)
  } else if (stringr::str_detect(file_path, "\\.sas7bdat$")) {
    haven::read_sas(file_path)
  } else if (stringr::str_detect(file_path, "\\.xpt$")) {
    haven::read_xpt(file_path)
  } else if (stringr::str_detect(file_path, "\\.parquet$")) {
    arrow::read_parquet(file_path)
  } else if (stringr::str_detect(file_path, "\\.xlsx$")) {
    readxl::read_xlsx(file_path)
  } else if (stringr::str_detect(file_path, "\\.feather$")) {
    arrow::read_feather(file_path)
  } else if (stringr::str_detect(file_path, "\\.rds$")) {
    readRDS(file_path)
  } else {
    stop(paste0("File format not supported: ", file_path))
  }
}

#' Write Data File
#'
#' This function writes a data frame to a file based on the specified extension.
#' It supports various file formats including CSV, JSON, Parquet, Excel, Feather, and RDS.
#'
#' @param data A data frame or list to be written to a file.
#' @param file_path A character string representing the path to the file where the data should be written.
#'
#' @return NULL
#' @export
#'
#' @examples
#' # Write a data frame to a CSV file
#' \dontrun{write_data_file(mtcars, "data.csv")}
#'
#' # Write a data frame to a JSON file
#' \dontrun{write_data_file(mtcars, "data.json")}
#'
#' # Write a data frame to a Parquet file
#' \dontrun{write_data_file(mtcars, "data.parquet")}
#'
#' # Write a data frame to an Excel file
#' \dontrun{write_data_file(mtcars, "data.xlsx")}
#'
#' # Write a data frame to a Feather file
#' \dontrun{write_data_file(mtcars, "data.feather")}
#'
#' # Write a data frame to an RDS file
#' \dontrun{write_data_file(mtcars, "data.rds")}
write_data_file <- function(data, file_path) {
  if (stringr::str_detect(file_path, "\\.csv$")) {
    readr::write_csv(data, file_path)
  } else if (stringr::str_detect(file_path, "\\.json$")) {
    json_data <- jsonlite::toJSON(data, pretty = TRUE, auto_unbox = TRUE)
    write(json_data, file_path)
  } else if (stringr::str_detect(file_path, "\\.parquet$")) {
    arrow::write_parquet(data, file_path)
  }  else if (stringr::str_detect(file_path, "\\.xpt$")) {
    haven::write_xpt(data, file_path)
  }  else if (stringr::str_detect(file_path, "\\.sav$")) {
    haven::write_sav(data, file_path)
  } else if (stringr::str_detect(file_path, "\\.xlsx$")) {
    writexl::write_xlsx(data, file_path)
  } else if (stringr::str_detect(file_path, "\\.feather$")) {
    arrow::write_feather(data, file_path)
  } else if (stringr::str_detect(file_path, "\\.rds$")) {
    saveRDS(data, file_path)
  } else {
    stop("File format not supported")
  }
}

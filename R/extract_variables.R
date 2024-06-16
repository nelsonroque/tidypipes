#' Extract Column Names from an Excel File
#'
#' This function reads an Excel file using `tidypipes::read_data_file` and
#' extracts its column names, returning a tibble with the file name and column names.
#'
#' @param file A string representing the file path to the Excel file.
#' @return A tibble with two columns: `dataframe` (file name) and `column_name` (column names in the file).
#' @export
#' @importFrom tidypipes read_data_file
#' @importFrom tibble tibble
extract_variables_from_file <- function(file) {
  tryCatch(
    {
      df <- tidypipes::read_data_file(file)
      tibble(
        filename = file,
        column_name = colnames(df)
      )
    },
    error = function(e) {
      tibble(
        filename = file,
        column_name = NA
      )
    }
  )
}

#' Extract Column Names from a List of Excel Files
#'
#' This function applies `extract_variables_from_file` to each file in a list
#' and combines the results into a single tibble.
#'
#' @param files A list of strings, each representing the file path to an Excel file.
#' @return A tibble with two columns: `filename` (file name) and `column_name` (column names in the files).
#' @export
#' @importFrom purrr map_dfr
extract_variables_from_file_list <- function(files) {
  variables_tibble <- purrr::map_dfr(files, extract_variables_from_file)
  return(variables_tibble)
}

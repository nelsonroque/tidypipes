#' Get Dataset Statistics
#'
#' This function generates statistics for a given dataset, including the number of columns,
#' number of rows, number of missing values, column names, and an MD5 hash of the dataset.
#'
#' @param .data A data frame or tibble for which the statistics are to be computed.
#'
#' @return A tibble containing the dataset name, number of columns, number of rows,
#' number of missing values, column names, and an MD5 hash of the dataset.
#' @export
#'
#' @examples
#' # Create a sample dataset
#' dataset <- tibble::tibble(
#'   col1 = c(1, 2, NA, 4),
#'   col2 = letters[1:4],
#'   col3 = c(NA, NA, NA, NA)
#' )
#'
#' # Generate the dataset statistics
#' get_dataset_stats(dataset)
get_dataset_stats <- function(.data) {
  return(tibble::tibble(dataset = deparse(substitute(.data)),
                             n_cols = ncol(.data),
                             n_rows = nrow(.data),
                             n_na = sum(is.na(.data)),
                             col_names = paste0(names(.data), collapse=","),
                             md5 = digest::digest(.data, algo="md5")))
}

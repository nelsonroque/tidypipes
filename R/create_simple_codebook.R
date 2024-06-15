#' Get Column Names and Data Types
#'
#' This function generates a tibble with the column names and data types for all columns in a given dataset.
#'
#' @param dataset A data frame or tibble for which the column names and data types are to be extracted.
#'
#' @return A tibble containing the column names and their corresponding data types.
#' @export
#'
#' @examples
#' # Create a sample dataset
#' dataset <- tibble::tibble(
#'   col1 = 1:5,
#'   col2 = letters[1:5],
#'   col3 = as.factor(letters[1:5]),
#'   col4 = as.Date('2020-01-01') + 0:4
#' )
#'
#' # Generate the column names and data types report
#' create_simple_codebook(dataset)
create_simple_codebook <- function(dataset) {
  if (!is.data.frame(dataset) && !is_tibble(dataset)) {
    stop("The input must be a data frame or tibble.")
  }

  column_info <- tibble::tibble(
    variable = names(dataset),
    data_type = sapply(dataset, class),
    description = NA
  )

  return(column_info)
}

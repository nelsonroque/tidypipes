#' Transform Data Frame to Tibble in Long Format
#'
#' This function transforms a given data frame into a tibble in a long format,
#' converting all columns to character type, adding a rowname column, and then
#' pivoting the data into key-value pairs.
#'
#' @param .data A data frame to be transformed.
#'
#' @return A tibble in long format with key-value pairs.
#' @examples
#' df <- data.frame(A = 1:3, B = 4:6)
#' t_tibble(df)
#'
#' @importFrom dplyr mutate across select
#' @importFrom tibble rownames_to_column
#' @importFrom tidyr pivot_longer
t_tibble <- function(.data) {
  df = .data %>%
    dplyr::mutate(dplyr::across(everything(), as.character)) %>%
    tibble::rownames_to_column(var = "rowname") %>%
    tidyr::pivot_longer(-rowname, names_to = "key", values_to = "value") %>%
    dplyr::select(-rowname)
  return(df)
}

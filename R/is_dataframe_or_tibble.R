#' Check if an Object is a Data Frame or Tibble
#'
#' This function checks whether the given object is either a data frame
#' or a tibble, returning `TRUE` if it is and `FALSE` otherwise.
#'
#' @param data An object to be checked.
#' @return A logical value: `TRUE` if the object is a data frame or tibble, `FALSE` otherwise.
#' @export
#'
#' @examples
#' # Check if an object is a data frame or tibble
#' is_dataframe_or_tibble(mtcars)   # TRUE
#' is_dataframe_or_tibble(tibble::tibble(x = 1:5)) # TRUE
#' is_dataframe_or_tibble(list(a = 1, b = 2)) # FALSE
is_dataframe_or_tibble <- function(data) {
  return(is_tibble(data) || is.data.frame(data))
}

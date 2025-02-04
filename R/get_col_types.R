#' Get Column Types in a Data Frame
#'
#' This function returns a tibble with each variable's name and class.
#' @param data A data frame or tibble.
#' @return A tibble with two columns: `variable` (column name) and `class` (data type).
#' @export
#' @import tidyverse
get_col_types <- function(data) {
  # Validate input
  if (!is.data.frame(data)) {
    stop("Input must be a data frame or tibble.")
  }

  # Compute column types
  d <- data %>%
    summarise(across(everything(), ~ class(.))) %>%
    pivot_longer(cols = everything(), names_to = "variable", values_to = "class") %>%
    mutate(class = map_chr(class, paste, collapse = ", ")) # Handle multiple classes

  return(d)
}

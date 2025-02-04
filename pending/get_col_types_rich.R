#' Get Column Metadata in a Data Frame
#'
#' This function returns a tibble with column types and additional metadata.
#' @param data A data frame or tibble.
#' @return A tibble with metadata including variable name, type, missing values, uniqueness, and sample values.
#' @export
#' @import tidyverse
get_col_types <- function(data) {
  # Validate input
  if (!is.data.frame(data)) {
    stop("Input must be a data frame or tibble.")
  }

  # Compute metadata
  d <- data %>%
    summarise(across(everything(), list(
      class = ~ paste(class(.), collapse = ", "),
      na_count = ~ sum(is.na(.)),
      unique_count = ~ n_distinct(.),
      sample_values = ~ paste0(head(unique(.), 3), collapse = ", "),
      is_numeric = ~ is.numeric(.),
      min_value = ~ ifelse(is.numeric(.), min(., na.rm = TRUE), NA),
      max_value = ~ ifelse(is.numeric(.), max(., na.rm = TRUE), NA),
      mean_value = ~ ifelse(is.numeric(.), mean(., na.rm = TRUE), NA),
      sd_value = ~ ifelse(is.numeric(.), sd(., na.rm = TRUE), NA)
    ), .names = "{.col}_{.fn}")) %>%
    pivot_longer(cols = everything(), names_to = c("variable", "metric"), names_sep = "_") %>%
    pivot_wider(names_from = "metric", values_from = "value") %>%
    mutate(
      na_count = as.integer(na_count),
      unique_count = as.integer(unique_count),
      is_numeric = as.logical(is_numeric)
    )

  return(d)
}

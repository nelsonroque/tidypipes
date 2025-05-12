#' @section utils_math
#'
#' @keywords internal

#' Count Unique Elements in a Vector
#'
#' Returns the number of unique values in a vector.
#'
#' @param vec A vector.
#'
#' @return An integer representing the number of unique elements.
#' @export
count_unique <- function(vec) {
  length(unique(vec))
}



#' Compute Proportional Change
#'
#' Computes percentage or raw proportional change between two values.
#'
#' @param old A numeric value representing the baseline.
#' @param new A numeric value representing the new value.
#' @param round_digits Number of decimal places to round. Default is 2.
#' @param as_percent Logical. If TRUE, result is multiplied by 100. Default is TRUE.
#' @param return_string Logical. If TRUE, result is returned as a percentage string. Default is TRUE.
#'
#' @return A numeric or character value representing the change.
#' @export
compute_prop_change <- function(old, new, round_digits = 2, as_percent = TRUE, return_string = TRUE) {
  old <- as.numeric(old)
  new <- as.numeric(new)
  change <- (new - old) / old
  if (as_percent) {
    change <- round(change * 100, round_digits)
    if (return_string) change <- paste0(change, "%")
  }
  return(change)
}


#' Extract Trimmed Observations from Distribution
#'
#' Identifies and marks lower/upper distributional trims based on a proportion.
#'
#' @param vec A numeric vector.
#' @param trim_lower Logical. If TRUE, trims the lower portion. Default is NA.
#' @param trim_upper Logical. If TRUE, trims the upper portion. Default is NA.
#' @param proportion A numeric value (0–1) specifying proportion to trim. Required.
#'
#' @return A list with trimmed observations, marked indicators, and summary stats.
#' @export
extract_distribution_trims <- function(vec, trim_lower = NA, trim_upper = NA, proportion = NA) {
  if (!is.numeric(vec)) stop("`vec` must be numeric.")
  if (is.na(proportion)) stop("You must specify a `proportion` to trim.")

  df <- tibble::tibble(value = vec)
  n <- nrow(df)
  n_trim <- floor(n * proportion)

  get_bounds <- function(lower, upper) {
    c(
      lower = if (isTRUE(lower)) floor(n_trim / 2) else 0,
      upper = if (isTRUE(upper)) ceiling(n_trim / 2) else 0
    )
  }

  bounds <- get_bounds(trim_lower, trim_upper)

  df <- df %>%
    dplyr::mutate(rank = dplyr::row_number(dplyr::desc(value))) %>%
    dplyr::mutate(trimmed = rank <= bounds['upper'] | rank > (n - bounds['lower']))

  stats <- tibble::tibble(
    total = n,
    trimmed_upper = bounds['upper'],
    trimmed_lower = bounds['lower'],
    trimmed_total = sum(df$trimmed),
    remain_total = n - sum(df$trimmed)
  )

  list(trim_data = df, stats = stats)
}

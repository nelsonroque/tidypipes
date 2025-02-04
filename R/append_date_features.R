#' Append Date and Time Features to a Data Frame
#'
#' This function appends various date and time features to a data frame based on a specified
#' date-time variable. It also optionally adds rounded time values.
#'
#' @param .data A data frame containing the date-time variable.
#' @param dt_var A string specifying the name of the date-time variable column.
#' @param time_features Logical. If TRUE, appends additional time-based features. Default is TRUE.
#' @param time_features_rounded Logical. If TRUE, appends rounded timestamps. Default is TRUE.
#'
#' @return A data frame with appended date and time features.
#' @export
#'
#' @examples
#' df <- data.frame(time_stamp = c("2023-06-15 12:34:56", "2023-06-16 13:45:10"))
#' append_datetime_features(df, dt_var = "time_stamp")
#'
#' @importFrom dplyr mutate select
#' @importFrom lubridate ymd_hms ymd as_date month day year week wday yday hour minute round_date
append_datetime_features <- function(.data,
                                     dt_var,
                                     time_features = TRUE,
                                     time_features_rounded = TRUE) {

  if (!dt_var %in% names(.data)) {
    stop("The specified date-time variable does not exist in the data frame.")
  }

  # Helper function to convert date column
  parse_datetime <- function(x) {
    parsed_dt <- lubridate::ymd_hms(x, quiet = TRUE)
    if (all(is.na(parsed_dt))) parsed_dt <- lubridate::ymd(x, quiet = TRUE)
    return(parsed_dt)
  }

  # Convert date column
  .data <- .data %>%
    mutate(dt_datetime = parse_datetime(!!rlang::sym(dt_var)))

  if (all(is.na(.data$dt_datetime))) {
    stop("Failed to parse the date-time column. Ensure it is in a recognized format.")
  }

  # Append base date features
  .data <- .data %>%
    mutate(
      dt_date = as_date(dt_datetime),
      dt_month = month(dt_datetime),
      dt_day = day(dt_datetime),
      dt_yday = yday(dt_datetime),
      dt_year = year(dt_datetime),
      dt_week = week(dt_datetime),
      dt_weekday_val = wday(dt_datetime),
      dt_weekday_label = wday(dt_datetime, label = TRUE),
      dt_is_weekend = dt_weekday_label %in% c("Sat", "Sun")
    )

  # Append additional time features if requested
  if (time_features) {
    .data <- .data %>%
      mutate(
        dt_hms = format(dt_datetime, "%H:%M:%S"),
        dt_hour = hour(dt_datetime),
        dt_minute = minute(dt_datetime)
      )
  }

  # Append rounded date timestamps if requested
  if (time_features_rounded) {
    rounding_intervals <- c(5, 10, 15, 30, 60)

    for (interval in rounding_intervals) {
      round_col <- glue::glue("dt_datetimestamp_round_{interval}min")
      time_col <- glue::glue("dt_timestamponly_round_{interval}min")

      .data <- .data %>%
        mutate(
          !!round_col := round_date(dt_datetime, paste(interval, "minutes")),
          !!time_col := format(!!rlang::sym(round_col), "%H:%M:%S")
        )
    }
  }

  return(.data)
}

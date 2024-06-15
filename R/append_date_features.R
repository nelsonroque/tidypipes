#' Append Date Features to a Data Frame
#'
#' This function appends various date and time features to a data frame based on a specified time variable.
#' It can also append rounded date timestamps if requested.
#'
#' @param .data A data frame containing the time variable.
#' @param dt_var A string specifying the name of the time variable column in the data frame.
#' @param time_features A logical for time features
#' @param time_features_rounded A logical value indicating whether to append rounded date timestamps. Defaults to TRUE.
#'
#' @return A data frame with appended date and time features.
#' @export
#'
#' @examples
#' df <- data.frame(time_stamp = c("2023-06-15 12:34:56", "2023-06-16 13:45:10"))
#' append_datetime_features(df, dt_var = "time_stamp")
#'
#' @importFrom dplyr mutate select
#' @importFrom lubridate ymd_hms as_date month day year week hour minute wday yday round_date
append_datetime_features <- function(.data,
                                     dt_var = NA,
                                     time_features = TRUE,
                                     time_rounded_features = TRUE) {
  # Convert dt_var to appropriate date or date-time object
  # Convert dt_var to appropriate date or date-time object
  if (inherits(.data[[dt_var]], "POSIXct") || inherits(.data[[dt_var]], "POSIXt")) {
    data_dates <- .data %>%
      mutate(dt_datetime = !!rlang::sym(dt_var))
  } else {
    data_dates <- .data %>%
      mutate(dt_datetime = lubridate::ymd_hms(!!rlang::sym(dt_var), quiet = TRUE))

    # If conversion to ymd_hms fails, try converting to Date
    if (all(is.na(data_dates$dt_datetime))) {
      data_dates <- .data %>%
        mutate(dt_datetime = lubridate::ymd(!!rlang::sym(dt_var), quiet = TRUE))
    }
  }

  #' Append date features
  data_dates <- data_dates %>%
    #' Convert dt_var to date time object using ymd_hms
    mutate(
      dt_date = lubridate::as_date(dt_datetime),
      dt_month = lubridate::month(dt_datetime),
      dt_day = lubridate::day(dt_datetime),
      dt_yday = lubridate::yday(dt_datetime),
      dt_year = lubridate::year(dt_datetime),
      dt_week = lubridate::week(dt_datetime),
      dt_weekday_val = lubridate::wday(dt_datetime),
      dt_weekday_label = lubridate::wday(dt_datetime, label = TRUE)
    ) %>%
    mutate(dt_is_weekend = dt_weekday_label %in% c("Sat", "Sun"))

  if (time_features) {
    #' Append date features
    data_dates <- data_dates %>%
      #' Append date and time features
      mutate(
        dt_hms = format(dt_datetime, "%H:%M:%S"),
        dt_hour = lubridate::hour(dt_datetime),
        dt_minute = lubridate::minute(dt_datetime),
        dt_weekday_val = lubridate::wday(dt_datetime)
      )
  }

  #' Append rounded date timestamps if requested
  if (time_rounded_features) {
    data_dates <- data_dates %>%
      #' Append rounded date timestamps
      mutate(
        dt_datetimestamp_round_5min = lubridate::round_date(dt_datetime, "5 minutes"),
        dt_datetimestamp_round_10min = lubridate::round_date(dt_datetime, "10 minutes"),
        dt_datetimestamp_round_15min = lubridate::round_date(dt_datetime, "15 minutes"),
        dt_datetimestamp_round_30min = lubridate::round_date(dt_datetime, "30 minutes"),
        dt_datetimestamp_round_60min = lubridate::round_date(dt_datetime, "60 minutes")
      ) %>%
      #' Append rounded timestamps
      mutate(
        dt_timestamponly_round_5min = format(dt_datetimestamp_round_5min, "%H:%M:%S"),
        dt_timestamponly_round_10min = format(dt_datetimestamp_round_10min, "%H:%M:%S"),
        dt_timestamponly_round_15min = format(dt_datetimestamp_round_15min, "%H:%M:%S"),
        dt_timestamponly_round_30min = format(dt_datetimestamp_round_30min, "%H:%M:%S"),
        dt_timestamponly_round_60min = format(dt_datetimestamp_round_60min, "%H:%M:%S")
      )
  }
  return(data_dates)
}

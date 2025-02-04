#' Get a comprehensive data quality report for a given dataframe
#' @param df A dataframe
#' @return A list containing data quality insights
#' @export
#'
get_data_quality <- function(df) {
  library(dplyr)
  library(tidyr)
  library(purrr)

  # Get missingness for each column
  missingness <- colMeans(is.na(df))

  # Get completeness (opposite of missingness)
  completeness <- 1 - missingness

  # Get data types for each column
  data_types <- map_chr(df, ~ class(.)[1]) # Ensuring primary class

  # Get unique values for each column
  unique_values <- map_int(df, ~ length(unique(na.omit(.))))

  # Classify cardinality (unique values relative to nrows)
  cardinality <- case_when(
    unique_values / nrow(df) < 0.01 ~ "Low",
    unique_values / nrow(df) < 0.5  ~ "Medium",
    TRUE                             ~ "High"
  )

  # Get summary statistics for numeric columns
  numeric_cols <- df %>% select(where(is.numeric))
  # summary_stats <- if (ncol(numeric_cols) > 0) {
  #   numeric_cols %>%
  #     summarise(across(everything(), list(
  #       min = min,
  #       q1 = ~ quantile(., 0.25, na.rm = TRUE),
  #       median = median,
  #       mean = mean,
  #       q3 = ~ quantile(., 0.75, na.rm = TRUE),
  #       max = max,
  #       sd = sd
  #     ), na.rm = TRUE)) %>%
  #     pivot_longer(everything(), names_to = c("column", ".value"), names_sep = "_")
  # } else {
  #   tibble(column = character(0))
  # }

  # Detect outliers using IQR method
  outlier_count <- if (ncol(numeric_cols) > 0) {
    numeric_cols %>%
      summarise(across(everything(), ~ sum(. < quantile(., 0.25, na.rm = TRUE) - 1.5 * IQR(., na.rm = TRUE) |
                                             . > quantile(., 0.75, na.rm = TRUE) + 1.5 * IQR(., na.rm = TRUE), na.rm = TRUE))) %>%
      pivot_longer(everything(), names_to = "column", values_to = "outlier_count")
  } else {
    tibble(column = character(0))
  }

  # Get mode for each column
  mode_value <- map_chr(df, function(x) {
    ux <- na.omit(unique(x))
    ux[which.max(tabulate(match(x, ux)))]
  })

  # Get memory usage per column
  memory_usage <- map_dbl(df, ~ object.size(.) / 1024) # KB

  # Create shadow matrix for missing/empty values
  shadow_df <- df %>%
    mutate(across(everything(), as.character)) %>%
    mutate(across(everything(), ~ ifelse(is.na(.), "NA", .))) %>%
    mutate(across(everything(), ~ ifelse(. == "", "EMPTY", .)))

  # Combine into a comprehensive list
  data_quality_info <- list(
    shadow = shadow_df,
    missingness = missingness,
    completeness = completeness,
    data_types = data_types,
    unique_values = unique_values,
    cardinality = cardinality,
    #summary_stats = summary_stats,
    outlier_count = outlier_count,
    mode_value = mode_value,
    memory_usage_kb = memory_usage
  )

  return(data_quality_info)
}

#' Get a Comprehensive Dataset Quality Report
#'
#' This function generates a detailed quality report for a given dataset,
#' including dataset statistics, missing values, unique values, data types,
#' memory usage, cardinality, mode, outliers, and more.
#'
#' @param df A data frame or tibble to analyze.
#' @param output_dir The directory where the report should be saved. Defaults to NULL (no file export).
#' @param format The file format for export. Options: "csv" (default) or "txt".
#'
#' @return A list containing data quality insights and dataset statistics.
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
#' # Generate the dataset quality report
#' get_dataset_report(dataset)
#'
#' # Generate and save the report as a CSV file
#' \dontrun{get_dataset_report(dataset, output_dir = "reports", format = "csv")}
#'
get_dataset_report <- function(df, output_dir = NULL, format = "csv") {
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(digest)

  # Validate input
  if (!tidypipes::is_dataframe_or_tibble(df)) {
    stop("Input must be a data frame or tibble.")
  }

  # Get dataset statistics
  dataset_stats <- tibble::tibble(
    dataset = deparse(substitute(df)),
    n_cols = ncol(df),
    n_rows = nrow(df),
    n_na = sum(is.na(df)),
    col_names = paste0(names(df), collapse = ","),
    md5 = digest(df, algo = "md5")
  )

  # Get missingness and completeness
  missingness <- colMeans(is.na(df))
  completeness <- 1 - missingness

  # Get data types
  data_types <- map_chr(df, ~ class(.)[1])

  data_types_tbl <- df %>%
    summarise(across(everything(), ~ class(.))) %>%
    pivot_longer(cols = everything(), names_to = "variable", values_to = "class") %>%
    mutate(class = map_chr(class, paste, collapse = ", ")) # Handle multiple classes

  # Get unique values and cardinality
  unique_values <- map_int(df, ~ length(unique(na.omit(.))))
  cardinality <- case_when(
    unique_values / nrow(df) < 0.01 ~ "Low",
    unique_values / nrow(df) < 0.5  ~ "Medium",
    TRUE                             ~ "High"
  )

  # Get mode values
  mode_value <- map_chr(df, function(x) {
    ux <- na.omit(unique(x))
    ux[which.max(tabulate(match(x, ux)))]
  })

  # Get memory usage
  memory_usage <- map_dbl(df, ~ object.size(.) / 1024)  # KB

  # Get numeric columns and detect outliers using IQR
  numeric_cols <- df %>% select(where(is.numeric))
  outlier_count <- if (ncol(numeric_cols) > 0) {
    numeric_cols %>%
      summarise(across(everything(), ~ sum(. < quantile(., 0.25, na.rm = TRUE) - 1.5 * IQR(., na.rm = TRUE) |
                                             . > quantile(., 0.75, na.rm = TRUE) + 1.5 * IQR(., na.rm = TRUE), na.rm = TRUE))) %>%
      pivot_longer(everything(), names_to = "column", values_to = "outlier_count")
  } else {
    tibble(column = character(0))
  }

  # Create shadow matrix for missing values
  shadow_df <- df %>%
    mutate(across(everything(), as.character)) %>%
    mutate(across(everything(), ~ ifelse(is.na(.), "NA", .))) %>%
    mutate(across(everything(), ~ ifelse(. == "", "EMPTY", .)))

  # Combine into a comprehensive list
  dataset_report <- list(
    dataset_stats = dataset_stats,
    shadow = shadow_df,
    missingness = missingness,
    completeness = completeness,
    data_types = data_types,
    data_types_tbl = data_types_tbl,
    unique_values = unique_values,
    cardinality = cardinality,
    outlier_count = outlier_count,
    mode_value = mode_value,
    memory_usage_kb = memory_usage
  )

  # Export report if requested
  if (!is.null(output_dir)) {
    # Ensure directory exists
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE)
    }

    # Generate timestamped filename
    timestamp <- get_timestamp()
    filename <- file.path(output_dir, paste0("Dataset_Report_", timestamp, ".", format))

    # Export based on format
    if (format == "csv") {
      readr::write_csv(dataset_stats, filename)
    } else if (format == "txt") {
      writeLines(capture.output(print(dataset_report)), filename)
    } else {
      stop("Invalid format. Use 'csv' or 'txt'.")
    }

    message("Dataset report saved to: ", filename)
  }

  return(dataset_report)
}

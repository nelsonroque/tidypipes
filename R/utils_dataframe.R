#' @section utils_dataframe
#'
#' @keywords internal


#' Check if a Column Exists in a Data Frame
#'
#' Verifies whether a given column name exists in a data frame or tibble.
#'
#' @param df A data frame or tibble.
#' @param col_name A character string representing the column name to check.
#'
#' @return Logical. TRUE if the column exists, FALSE otherwise.
#' @export
check_col_exists <- function(df, col_name) {
  if (!is_dataframe_or_tibble(df)) {
    stop("`df` must be a data.frame or tibble.")
  }
  col_name %in% colnames(df)
}


#' Validate Data Attribute
#'
#' Checks if a given attribute exists and matches the expected value.
#'
#' @param data A data frame or object with attributes.
#' @param tag_name A character string representing the attribute name.
#' @param tag_value Expected value for the attribute. Default is TRUE.
#'
#' @return Logical TRUE if attribute matches expected value, FALSE otherwise.
#' @export
check_data_attr <- function(data, tag_name = "", tag_value = TRUE) {
  if (is.null(attr(data, tag_name))) return(FALSE)
  attr(data, tag_name) == tag_value
}


#' Compare Metadata Between Two Data Objects
#'
#' Compares key metadata attributes between two datasets.
#'
#' @param df1 First data object with attributes.
#' @param df2 Second data object with attributes.
#'
#' @return A tibble with comparison results or NA if attributes missing.
#' @export
compare_data_tags <- function(df1, df2) {
  if (!check_data_attr(df1, "ruf::dataset_stats") || !check_data_attr(df2, "ruf::dataset_stats")) {
    return(NA)
  }

  tibble::tibble(
    match_nrows = df1$n_rows == df2$n_rows,
    match_ncols = df1$n_cols == df2$n_cols,
    match_colnames = df1$col_names == df2$col_names,
    match_md5 = df1$md5 == df2$md5
  )
}



#' Stamp Processing Metadata
#'
#' Appends hash and timestamp metadata to a data frame.
#'
#' @param df A data frame or tibble.
#' @param hash_algo A string for the hash algorithm to use (default is "md5").
#'
#' @return A data frame with added `processing_hash` and `processing_timestamp` columns.
#' @export
stamp_processing_metadata <- function(df, hash_algo = "md5") {
  if (!is_dataframe_or_tibble(df)) stop("Input must be a data frame or tibble.")
  df %>%
    dplyr::mutate(
      processing_hash = digest::digest(df, algo = hash_algo),
      processing_timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )
}

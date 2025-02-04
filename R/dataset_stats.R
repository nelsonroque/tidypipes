#' tidypipes: dataset_stats

#' @name dataset_stats
#' @param .data class: dataframe
#' @import tidyverse
#' @export
dataset_stats <- function(.data) {
  if(ruf::is_data_frame_tibble(.data)) {
    df = .data
    datastats = tibble::tibble(dataset = deparse(substitute(df)),
                               n_cols = ncol(df),
                               n_rows = nrow(df),
                               n_na = sum(is.na(df)),
                               col_names = paste0(names(df), collapse=","),
                               md5 = digest::digest(df, algo="md5")) %>%
      ruf::add_data_tag(., tag_name = "ruf::dataset_stats", tag_value = T)
  } else {
    datastats = NA
  }
  return(datastats)
}

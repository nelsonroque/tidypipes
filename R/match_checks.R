#' ruf

#' @name match_checks
#' @param data1 class: dataframe
#' @param data2 class: dataframe
#' @import tidyverse
#' @export
match_checks <- function(data1, data2) {
  
  if(ruf::is_data_tag_valid(data1, tag_name = "ruf::dataset_stats", tag_value = T) & 
     ruf::is_data_tag_valid(data1, tag_name = "ruf::dataset_stats", tag_value = T)) {
    
    match_nrows <- data1$n_rows == data2$n_rows
    match_ncols <- data1$n_cols == data2$n_cols
    match_colnames <- data1$col_names == data2$col_names
    match_md5 <- data1$md5 == data2$md5 
    
    checks = tibble::tibble(nrows = match_nrows, 
                            ncols = match_ncols,
                            colnames = match_colnames,
                            md5 = match_md5)
  } else {
    checks = NA
  }
  
  return(checks)
}
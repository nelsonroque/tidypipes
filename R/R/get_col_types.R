#' ruf
#' @name get_col_types
#' @export
#' @import tidyverse
get_col_types <- function(data) {
  d <- data %>% 
    dplyr::summarise_all(class) %>% 
    tidyr::gather(variable, class)
  return(d)
}
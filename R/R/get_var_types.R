#' ruf

#' @name get_var_types
#' @param data class: dataframe
#' @import tidyverse
#' @examples
#' get_var_types(data)
#' @export
get_var_types <- function(data) {
  if(is.data.frame(data)) {
    vt <- lapply(data, class)
  } else {
    vt <- NA
  }
  return(vt)
}

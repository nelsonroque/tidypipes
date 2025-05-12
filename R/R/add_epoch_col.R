#' ruf

#' @name add_epoch_col
#' @param data class: dataframe
#' @param every_n_rows  class: numeric
#' @keywords data processing
#' @import tidyverse
#' @examples
#' add_epoch_col(df)
#' @export
add_epoch_col <- function(data, every_n_rows=10) {
  result <- data %>%
    mutate(epoch = c(0, rep(1:(nrow(df)-1)%/%every_n_rows)),
           epoch_size = every_n_rows)
  return(result)
}
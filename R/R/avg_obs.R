#' ruf

#' @name avg_obs
#' @param data class: dataframe
#' @param time_var class: string
#' @param time_format  class: string
#' @keywords to add date features to timestamp
#' @import tidyverse
#' @examples
#' avg_obs(data, id_var="id")
#' @export
avg_obs <- function(data, id_var="id") {
  obs <- data %>% 
    group_by(!!sym(id_var)) %>% 
    summarise(n = n()) %>% 
    summarise(m = mean(n,na.rm=T))
  return(obs)
}
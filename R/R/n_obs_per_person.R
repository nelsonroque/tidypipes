#' ruf

#' @name n_obs_per_person
#' @param data class: dataframe
#' @param id_var class: string
#' @param expected_obs  class: numeric
#' @keywords ecological momentary assessment data, intensive longitudinal data
#' @import tidyverse
#' @examples
#' n_obs_per_person(df)
#' @export
n_obs_per_person <- function(data = NULL, id_var = NULL, expected_obs = NULL) {
  
  # get count of rows per person
  result <- data %>%
    mutate(missing = rowSums(is.na(.))) %>%
    group_by(!!sym(id_var)) %>%
    summarise(t_i = n(),
              n_vars_missing = sum(missing))
  
  if(!is.null(expected_obs)) {
    result <- result %>%
      mutate(diff_records_from_expected = t_i - expected_obs)
  }
  
  return(result)
}
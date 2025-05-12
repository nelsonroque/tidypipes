#' ruf

#' @name generate_2condition_response_time_dataset
#' @param df class: dataframe
#' @param n class: numeric
#' @param n_sessions  class: numeric
#' @param rt_mean class: numeric
#' @param rt_sd class: numeric
#' @param cond_cats class: vector
#' @param rand_seed class: numeric
#' @import tidyverse
#' @examples
#' generate_2condition_response_time_dataset(n = 20, n_sessions = 2, rt_mean = 500, rt_sd = 25, cond_Cats = c("native","script"))
#' @export
generate_2condition_response_time_dataset <- function(n = 10, n_sessions = 1, rt_mean = 500, rt_sd = 200, cond_cats = c("native","script"), rand_seed = 999) {
  set.seed(rand_seed)
  
  cat("NOTE: assumes identical population distribution across conditions.")
  
  # create synthetic data
  cond1_df <- expand.grid(id=seq(1,n,1), sessions=c(1:n_sessions)) %>% mutate(cond_type=cond_cats[1])
  cond2_df <- expand.grid(id=seq(1,n,1), sessions=c(1:n_sessions)) %>% mutate(cond_type=cond_cats[2])
  all_df <- bind_rows(cond1_df, cond2_df)
  
  # add a response time column
  all_df <- all_df %>%
    mutate(response_time = rnorm(n=nrow(all_df), mean=rt_mean, sd=rt_sd))
  
  return(all_df)
}
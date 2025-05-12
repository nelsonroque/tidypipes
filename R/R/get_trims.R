#' ruf
#' @name get_trims
#' @export
#' @param .data class: data.frame
#' @param trim_lower class: boolean
#' @param trim_upper class: boolean
#' @param p class: numeric
#' @import dplyr
#' @examples
#' read_any ("C:/filepath.csv")
get_trims <- function(.data, trim_lower = NA, trim_upper = NA, p = NA) {

  # validate params ---------------------------------------------------------
  
  # validate function parameters
  if(!ruf::is_data_frame_tibble(.data)){
    idata = data.frame(value = .data)
  }

  if(is.na(trim_upper)){
    trim_upper = F
  } else {
    if(is.na(trim_lower)) {
      trim_lower = F
    }
  }
  
  if(is.na(p)){
   stop("[error: Missing percentage to trim.]")
  }
  

  # calculate params for trimming -------------------------------------------
  
  n_obs = nrow(idata) 
  n_obs_trim = n_obs * p
  
  if(trim_upper & trim_lower){
    n_obs_trim_lower = n_obs_trim / 2
    n_obs_trim_upper = n_obs_trim / 2
  } else if(trim_upper & !trim_lower) {
    n_obs_trim_lower = 0
    n_obs_trim_upper = n_obs_trim
  } else if(!trim_upper & trim_lower) {
    n_obs_trim_lower = n_obs_trim
    n_obs_trim_upper = 0
  } else {
    stop("[error: No specification of what part of the distribution to trim]")
  }

  # calculate number of observations remaining
  remain_obs = n_obs - (n_obs_trim_lower + n_obs_trim_upper)
  
  # trim upper and lower ----------------------------------------------------
  
  # approach: get buckets for the top and bottom of the distributions
  obs_trim_lower = idata %>% 
    arrange(value) %>%
    filter(between(row_number(), 1, n_obs_trim_lower))
  
  obs_trim_upper = idata %>% 
    arrange(desc(value)) %>%
    filter(between(row_number(), 1, n_obs_trim_upper))
  
  # approach: mark rows for trimming
  
  obs_trim_lower_mark = idata %>% 
    arrange(value) %>%
    mutate(trim_lower = ifelse(between(row_number(), 1, n_obs_trim_lower), T, F))
  
  obs_trim_upper_mark = idata %>% 
    arrange(desc(value)) %>%
    mutate(trim_upper = ifelse(between(row_number(), 1, n_obs_trim_upper), T, F))
  
  obs_trim_marked = obs_trim_lower_mark %>% 
    full_join(obs_trim_upper_mark) %>%
    mutate(keep_obs = ifelse(trim_lower == F & trim_upper == F, T, F))
  
  # no way of keeping the middle with this method
  # alternative, mutate records based on filter?
  
  # debugging ---------------------------------------------------------------
  
  # verify that the number of records matches what is expected
  remain_obs_calculated = (nrow(idata) - (nrow(obs_trim_upper) + nrow(obs_trim_lower)))
  remain_obs_check = ifelse(remain_obs_calculated == remain_obs, T, F)
  
  # create tibble to output this
  trim_stats = tibble(param_trim_lower = trim_lower,
                      param_trim_upper = trim_upper,
                      param_trim_percentage = p,
                      n_obs = n_obs,
                      n_obs_trim_lower = n_obs_trim_lower,
                      n_obs_trim_lower_iseven = ruf::is_even(n_obs_trim_lower),
                      n_obs_trim_upper = n_obs_trim_upper,
                      n_obs_trim_upper_iseven = ruf::is_even(n_obs_trim_upper),
                      n_obs_trim_total = n_obs_trim,
                      n_obs_remain = remain_obs,
                      n_obs_remain_calc = remain_obs_calculated,
                      obs_remain_valid = remain_obs_check)
  
  # output ------------------------------------------------------------------
  
  return(list(trim_stats = trim_stats,
              trim_lower = obs_trim_lower,
              trim_upper = obs_trim_upper,
              trim_lower_mark = obs_trim_lower_mark,
              trim_upper_mark = obs_trim_upper_mark,
              trim_marked = obs_trim_marked))
}

#' ruf

#' @name bland_altman_analysis
#' @param df class: dataframe
#' @param id_var class: string
#' @param rt_var class: string
#' @param assay_type_col  class: string
#' @param assay1_name class: string
#' @param assay2_name class: string
#' @keywords to add date features to timestamp
#' @import tidyverse
#' @examples
#' bland_altman_analysis(df, id_var="id", rt_var = "response_time", assay_type_col = "game_type", assay1_name = "native", assay2_name = "script")
#' @export
bland_altman_analysis <- function(df, id_var="id", rt_var = "response_time", assay_type_col = NA, assay1_name = NA, assay2_name = NA) {
  print("For more Bland-Altman Information: https://en.wikipedia.org/wiki/Bland%E2%80%93Altman_plot")
  
  # validation
  if(is.na(assay_type_col)) {
    print("ERROR: enter parameter for `asssay_type_col`")
    valid_run = 0
  }
  
  if(is.na(assay1_name)) {
    print("ERROR: enter parameter for `asssay1_name`")
    valid_run = 0
  }
  
  if(is.na(assay2_name)) {
    print("ERROR: enter parameter for `asssay2_name`")
    valid_run = 0
  }
  
  if(!exists("valid_run")) {
    valid_run = 1
  }
  
  if(valid_run) {
    
    # produce mean of response time and difference between methods
    ba_df <- df %>%
      group_by(UQ(sym(id_var)), UQ(sym(assay_type_col))) %>%
      summarise(m_rt = mean(UQ(sym(rt_var)), na.rm=T)) %>%
      spread(UQ(sym(assay_type_col)), m_rt) %>%
      rowwise() %>%
      mutate(mean_methods = mean(c(UQ(sym(assay1_name)), UQ(sym(assay2_name)))),
             diff_methods = UQ(sym(assay2_name)) - UQ(sym(assay1_name)),
             ratio_methods = UQ(sym(assay1_name))/UQ(sym(assay1_name)))
    
    
    # are the method differences significantly different?
    t_results <- t.test(ba_df$diff_methods, mu=0)
  } else {
    ba_df <- tibble::tibble(error="`valid_run` = 0")
    t_results <- tibble::tibble(error="`valid_run` = 0")
  }

  
  return(list(ba_data = ba_df, t_test = broom::tidy(t_results)))
}

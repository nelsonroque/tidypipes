#' ruf

#' @name bland_altman_plot
#' @param df class: dataframe
#' @param diff_col class: string
#' @param mean_col class: string
#' @param sd_loa  class: numeric
#' @param color_loa class: string
#' @param font_size class: numeric
#' @import tidyverse
#' @examples
#' bland_altman_plot(df, diff_col = NA, mean_col = NA, sd_loa = 1.96, color_loa = "red", font_size=18)
#' @export
bland_altman_plot <- function(df, diff_col = NA, mean_col = NA, sd_loa = 1.96, color_loa = "red", font_size=18) {
  
  # add UQ(sym(x))
  upper_loa = mean(df$diff_methods) + sd_loa*sd(df$diff_methods)
  lower_loa = mean(df$diff_methods) - sd_loa*sd(df$diff_methods)
  central_l = mean(df$diff_methods)
  
  p <- ggplot(df, aes(UQ(sym(mean_col)), UQ(sym(diff_col)))) + 
    geom_point() + 
    geom_hline(yintercept=central_l) +
    geom_hline(yintercept=upper_loa, color=color_loa) +
    geom_hline(yintercept=lower_loa, color=color_loa) +
    theme_minimal(base_size=font_size) +
    xlab("Mean of Assays") + 
    ylab("Difference b/w Assays")
  p
}

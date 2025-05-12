library(tidyverse)

df = data.frame(x=rnorm(100)) %>%
  mutate(x_char = as.character(x)) %>%
  mutate(x_bool = x > 0)



















# how diff from ?
#https://cran.r-project.org/web/packages/skimr/vignettes/skimr.html
ct = get_col_types(df)




library(skimr)
library(dplyr)

# Extend skimr::skim() with additional fields
get_col_types_extended <- function(data) {
  skimmed_data <- skim(data)

  extra_data <- data %>%
    summarise(across(everything(), list(
      sample_values = ~ paste0(head(unique(.), 3), collapse = ", ")
    ), .names = "{.col}_{.fn}")) %>%
    pivot_longer(cols = everything(), names_to = c("variable", "metric"), names_sep = "_") %>%
    pivot_wider(names_from = "metric", values_from = "value")

  full_summary <- left_join(skimmed_data, extra_data, by = "variable")

  return(full_summary)
}

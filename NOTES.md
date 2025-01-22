
# # Load libs
# library(readr)
# library(knitr)
# library(kableExtra)
# library(tidyverse)

# # Load dataframe
# df <- read_csv("~/Downloads/tidy_eas_ema_all_surveys_session_level_2025_01_15_16_50_13_452976_R_READY.csv")

# # Create a table with variable names
# variable_names <- data.frame(
#   Variable = names(df),
#   Question = "INSERT QUESTION",
#   Responses = "INSERT RESPONSES",
#   Description = sapply(df, function(x) paste0(class(x), collapse = ", "))
# )

# # export table ----
# tsfn = format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
# write_csv(variable_names, glue("variable_names_{tsfn}.csv"))

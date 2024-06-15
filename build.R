# Install Package:           'Cmd + Shift + B'
# Check Package:             'Cmd + Shift + E'
# Test Package:              'Cmd + Shift + T'

# Load necessary libraries
library(roxygen2)
library(devtools)

# Re-document package ------
roxygen2::roxygenise() # Generate documentation using roxygen2

# Optional: You can use devtools::document() as an alternative
# devtools::document()

# Check package for errors, warnings, and notes ------
devtools::check() # Run package checks to ensure everything is working correctly

# Build package -----
devtools::build() # Build the package

# Run tests -----

# Ensure your package 'tidypipes' is loaded if it contains the function `run_pipeline_step`
library(tidypipes)

# e.g., a specific pipeline step -----
tidypipes::run_pipeline_step(step = "test_step.R",
                             pipeline_path = "~/Desktop/pipeline/")

# get environment report -----
tidypipes::get_env_report()

# get packages report -----
tidypipes::get_package_report()

# get todos report -------
tidypipes::get_todo_report()

# get timestamps for filenames -----
tidypipes::get_fn_ts()
tidypipes::get_fn_ts(format="%m-%d_%H-%M")

# write any common file type ------
df = data.frame(x=rnorm(100))
tidypipes::write_data_file(data = df,
                           file_path = 'tmp/test.csv')

tidypipes::write_data_file(data = df,
                           file_path = 'tmp/test.xpt')

tidypipes::write_data_file(data = df,
                           file_path = 'tmp/test.xlsx')

tidypipes::write_data_file(data = df,
                           file_path = 'tmp/test.parquet')

# load datasets -----
tf_csv = tidypipes::read_data_file(file_path = 'tmp/test.csv')
tf_xpt = tidypipes::read_data_file(file_path = 'tmp/test.xpt')
tf_xlsx = tidypipes::read_data_file(file_path = 'tmp/test.xlsx')
tf_parquet = tidypipes::read_data_file(file_path = 'tmp/test.parquet')

# validate data ------
# sum(tf_csv$x) == sum(tf_xpt$x)
# sum(tf_csv$x) == sum(tf_xlsx$x)
# sum(tf_csv$x) == sum(tf_parquet$x)
# sum(tf_xlsx$x) == sum(tf_parquet$x)
# sum(tf_xpt$x) == sum(tf_parquet$x)
# sum(tf_xpt$x) == sum(tf_xlsx$x)

# append date features -----

tf_dates = tibble::tibble(dt = sample(seq(anytime::anytime("2000-01-01 00:00:00"),
                                          anytime::anytime("2024-01-01 00:00:00"), 1), 100)) %>%
tidypipes::append_datetime_features(.,
                                    dt_var = 'dt',
                                    time_rounded_features=F) %>%
  arrange(dt_datetime)

tf_dates2 = tibble::tibble(dt = sample(seq(anytime::anydate("2000-01-01"),
                                          anytime::anydate("2024-01-01"), 1), 100)) %>%
  tidypipes::append_datetime_features(.,
                                      dt_var = 'dt',
                                      time_features = F,
                                      time_rounded_features=F) %>%
  arrange(dt_datetime)

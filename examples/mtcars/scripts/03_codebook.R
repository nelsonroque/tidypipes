cfg <- yaml::read_yaml("examples/mtcars/config.yml")
params <- cfg$params

in_csv <- file.path(params$output_dir, params$csv_name)
d <- utils::read.csv(in_csv, stringsAsFactors = FALSE)

tidypipes::generate_codebook(
  data = d,
  output_csv = file.path(params$output_dir, params$codebook_csv),
  output_md = file.path(params$output_dir, params$codebook_md),
  labels = list(
    mpg = "Miles per gallon",
    hp = "Gross horsepower",
    wt = "Weight (1000 lbs)",
    hp_per_wt = "Horsepower per 1000 lbs"
  )
)

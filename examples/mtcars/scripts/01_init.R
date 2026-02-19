cfg <- yaml::read_yaml("examples/mtcars/config.yml")
params <- cfg$params

dir.create(params$output_dir, recursive = TRUE, showWarnings = FALSE)

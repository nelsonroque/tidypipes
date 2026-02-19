cfg <- yaml::read_yaml("examples/mtcars/config.yml")
params <- cfg$params

d <- mtcars
d$car <- rownames(mtcars)
rownames(d) <- NULL
d$cyl <- as.factor(d$cyl)
d$am <- as.factor(d$am)
d$vs <- as.factor(d$vs)
d$gear <- as.factor(d$gear)
d$hp_per_wt <- d$hp / d$wt

out_csv <- file.path(params$output_dir, params$csv_name)
utils::write.csv(d, out_csv, row.names = FALSE)

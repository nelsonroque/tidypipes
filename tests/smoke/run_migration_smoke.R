#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(tidypipes))

cfg_main <- tidypipes:::read_pipeline_config("examples/myEAS/pipelines/eas500-main.yml")
stopifnot(identical(cfg_main$name, "eas500-main"))

cfg_smoke <- tidypipes:::read_pipeline_config("examples/myEAS/pipelines/eas500-smoke.yml")
stopifnot(identical(cfg_smoke$name, "eas500-smoke"))

res <- tidypipes::run_pipeline(
  config_path = "examples/myEAS/pipelines/eas500-smoke.yml",
  root_dir = ".",
  workers = 1,
  write_reports = FALSE
)

if (!identical(res$status, "success")) {
  stop("Smoke pipeline failed")
}

if (!file.exists("logs/smoke-marker.txt")) {
  stop("Smoke marker file not generated")
}

cat("Migration smoke test passed\n")

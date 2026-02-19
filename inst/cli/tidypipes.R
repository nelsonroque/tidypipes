#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Usage: tidypipes.R <run|visualize|retry|resume|schedule|backfill|status> <config> [args]")

cmd <- args[[1]]
config <- if (length(args) >= 2) args[[2]] else NULL

suppressPackageStartupMessages(library(tidypipes))

if (cmd == "run") {
  print(run_pipeline(config))
} else if (cmd == "visualize") {
  out <- if (length(args) >= 3) args[[3]] else "logs/pipeline.mmd"
  cat(visualize_pipeline(config, out_path = out), "\n")
} else if (cmd == "retry") {
  print(retry_pipeline(config))
} else if (cmd == "resume") {
  print(resume_pipeline(config))
} else if (cmd == "schedule") {
  every <- if (length(args) >= 3) as.numeric(args[[3]]) else 300
  schedule_pipeline(config, every_seconds = every)
  cat("scheduled\n")
} else if (cmd == "backfill") {
  if (length(args) < 4) stop("backfill requires start_date end_date")
  print(backfill_pipeline(config, start_date = args[[3]], end_date = args[[4]]))
} else if (cmd == "status") {
  print(scheduler_status())
} else {
  stop("Unknown command: ", cmd)
}

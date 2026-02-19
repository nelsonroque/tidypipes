test_that("pipeline runs and writes audit log + state", {
  td <- withr::local_tempdir()
  withr::local_dir(td)
  root <- getwd()

  dir.create("steps", recursive = TRUE)
  writeLines("x <- 1", "steps/01_a.R")
  writeLines("y <- 2", "steps/02_b.R")

  cfg <- paste(
    "name: mini",
    "params:",
    "  sensorname: demo",
    "  out_dir: output",
    "steps:",
    "  - id: a",
    "    script: steps/01_a.R",
    "    retry:",
    "      max_attempts: 2",
    "      backoff_seconds: 0",
    "  - id: b",
    "    script: steps/02_b.R",
    "    depends_on: [a]",
    "    when: \"TRUE\"",
    "    outputs: [\"{out_dir}/FN_({sensorname})_{date}.csv\"]",
    sep = "\n"
  )
  writeLines(cfg, "pipeline.yml")

  out <- tidypipes::run_pipeline("pipeline.yml", root_dir = root, audit_log_path = file.path(root, "logs", "audit.ndjson"))

  expect_equal(out$status, "success")
  expect_true(file.exists(file.path(root, "logs", "audit.ndjson")))
  expect_true(file.exists(file.path(root, "logs", "state.json")))
  expect_true(file.exists(out$summary_html))
})

test_that("scheduler queue/status works", {
  td <- withr::local_tempdir()
  withr::local_dir(td)
  root <- getwd()

  dir.create("steps", recursive = TRUE)
  writeLines("x <- 1", "steps/01_a.R")
  writeLines("name: mini\nsteps:\n  - id: a\n    script: steps/01_a.R", "pipeline.yml")

  tidypipes::schedule_pipeline("pipeline.yml", every_seconds = 60, root_dir = root)
  s <- tidypipes::scheduler_status(root)
  expect_true(s$queued >= 1)
})

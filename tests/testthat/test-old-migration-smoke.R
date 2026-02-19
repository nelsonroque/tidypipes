test_that("OLD migration configs parse and smoke pipeline runs", {
  root_dir <- normalizePath(testthat::test_path("..", ".."), winslash = "/", mustWork = TRUE)
  main_cfg <- file.path(root_dir, "pipelines", "eas500-main.yml")
  smoke_cfg <- file.path(root_dir, "pipelines", "eas500-smoke.yml")

  cfg_main <- tidypipes:::read_pipeline_config(main_cfg)
  expect_identical(cfg_main$name, "eas500-main")
  expect_true(length(cfg_main$steps) >= 20)

  cfg_smoke <- tidypipes:::read_pipeline_config(smoke_cfg)
  expect_identical(cfg_smoke$name, "eas500-smoke")

  res <- tidypipes::run_pipeline(
    config_path = smoke_cfg,
    root_dir = root_dir,
    workers = 1,
    write_reports = FALSE
  )

  expect_identical(res$status, "success")
  expect_true(file.exists(file.path(root_dir, "logs", "smoke-marker.txt")))
})

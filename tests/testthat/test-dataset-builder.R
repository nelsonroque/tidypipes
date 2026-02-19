test_that("build_dataset reads files, applies filename fields and writes output", {
  td <- withr::local_tempdir()
  withr::local_dir(td)
  dir.create("in", recursive = TRUE)
  writeLines(c("timestamp,value", "2026-01-01,1", "2026-01-02,2"), "in/FN_(temp01)_a.csv")
  writeLines(c("timestamp,value", "2026-01-01,1", "2026-01-03,3"), "in/FN_(temp01)_b.csv")

  spec <- paste(
    "name: test_ds",
    "input:",
    "  dir: in",
    "  glob: '*.csv'",
    "  recursive: false",
    "filename_fields:",
    "  regex: 'FN_\\(([^)]+)\\)'",
    "  fields: [sensorname]",
    "combine:",
    "  mode: bind_rows",
    "  dedupe_keys: [sensorname, timestamp]",
    "hooks:",
    "  mutate:",
    "    value2: 'value * 2'",
    "output:",
    "  format: csv",
    "  path: out/dataset.csv",
    sep = "\n"
  )
  writeLines(spec, "spec.yml")

  out <- tidypipes::build_dataset("spec.yml")
  expect_true(file.exists("out/dataset.csv"))
  expect_true("sensorname" %in% names(out$data))
  expect_equal(nrow(out$data), 3)
})

test_that("generate_codebook writes csv and markdown", {
  td <- withr::local_tempdir()
  withr::local_dir(td)

  d <- data.frame(a = c(1, 2, NA), b = c("x", "y", "x"), stringsAsFactors = FALSE)
  out <- tidypipes::generate_codebook(d, "out/cb.csv", "out/cb.md", labels = list(a = "Metric A"))
  expect_true(file.exists(out$csv))
  expect_true(file.exists(out$markdown))
  expect_true("label" %in% names(out$codebook))
})

test_that("build_duckdb_table writes table", {
  skip_if_not_installed("DBI")
  skip_if_not_installed("duckdb")

  td <- withr::local_tempdir()
  withr::local_dir(td)
  dir.create("in", recursive = TRUE)
  writeLines(c("id,value", "1,10", "2,20"), "in/a.csv")
  writeLines(c("id,value", "3,30"), "in/b.csv")

  out <- tidypipes::build_duckdb_table(
    input_dir = "in",
    db_path = "out/test.duckdb",
    table = "t_readings",
    mode = "replace",
    recursive = FALSE
  )

  expect_equal(out$written_rows, 3)
  expect_true(file.exists("out/test.duckdb"))
})

# Run pipeline
pl <- tidypipes::run_pipeline(
  "examples/mtcars/pipelines/mtcars-main.yml",
  root_dir = ".",
  workers = 1
)

# Build DuckDB table from output folder (requires DBI + duckdb)
if (requireNamespace("DBI", quietly = TRUE) && requireNamespace("duckdb", quietly = TRUE)) {
  tidypipes::build_duckdb_table(
    input_dir = "examples/mtcars/output",
    db_path = "examples/mtcars/output/mtcars.duckdb",
    table = "mtcars_clean",
    mode = "replace",
    pattern = "^mtcars_clean\\.csv$",
    recursive = FALSE
  )
}

# Visualize DAG (Mermaid)
graph_txt <- tidypipes::visualize_pipeline(
  config_path = "examples/mtcars/pipelines/mtcars-main.yml",
  out_path = "logs/mtcars-pipeline.mmd",
  format = "mermaid"
)

# Optional PNG render if Mermaid CLI exists
if (nzchar(Sys.which("mmdc"))) {
  tidypipes::render_pipeline_png(
    mmd_path = "logs/mtcars-pipeline.mmd",
    png_path = "logs/mtcars-pipeline.png"
  )
}

cat(graph_txt, "\n")

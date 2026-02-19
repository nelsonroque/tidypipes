#' Build/append a DuckDB table from files in a folder
#' @param input_dir Folder containing source files.
#' @param db_path DuckDB database file path.
#' @param table Table name.
#' @param mode replace or append.
#' @param pattern Regex pattern for files.
#' @param recursive Recurse into subfolders.
#' @param reader Reader override (auto/csv/tsv/parquet).
#' @param audit_log_path Path to audit log.
#' @param observability_path Path to observability log.
#' @export
build_duckdb_table <- function(input_dir,
                               db_path,
                               table,
                               mode = c("replace", "append"),
                               pattern = "\\.(csv|tsv|parquet)$",
                               recursive = TRUE,
                               reader = "auto",
                               audit_log_path = "logs/audit.ndjson",
                               observability_path = "logs/observability.ndjson") {
  if (!requireNamespace("DBI", quietly = TRUE) || !requireNamespace("duckdb", quietly = TRUE)) {
    rlang::abort("DBI and duckdb packages are required for build_duckdb_table().")
  }

  mode <- match.arg(mode)
  files <- list.files(input_dir, pattern = pattern, recursive = recursive, full.names = TRUE)
  if (!length(files)) rlang::abort("No files found for DuckDB build")

  frames <- lapply(files, function(f) {
    d <- as.data.frame(read_input_file(f, reader = reader), stringsAsFactors = FALSE)
    d$.source_file <- normalizePath(f, winslash = "/", mustWork = FALSE)
    d
  })

  all_cols <- unique(unlist(lapply(frames, names)))
  frames <- lapply(frames, function(d) {
    missing <- setdiff(all_cols, names(d))
    for (m in missing) d[[m]] <- NA
    d[, all_cols, drop = FALSE]
  })
  data <- do.call(rbind, frames)

  fs::dir_create(fs::path_dir(db_path))
  con <- DBI::dbConnect(duckdb::duckdb(dbdir = db_path, read_only = FALSE))
  on.exit({
    DBI::dbDisconnect(con, shutdown = TRUE)
  }, add = TRUE)

  DBI::dbWriteTable(con, table, data, overwrite = identical(mode, "replace"), append = identical(mode, "append"))
  row_count <- as.integer(DBI::dbGetQuery(con, paste0("SELECT COUNT(*) AS n FROM ", DBI::dbQuoteIdentifier(con, table)))[[1]])

  write_audit_event(audit_log_path, list(
    ts = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    event = "duckdb_table_built",
    db_path = db_path,
    table = table,
    mode = mode,
    source_files = files,
    written_rows = nrow(data),
    table_rows = row_count
  ))

  write_observability_event(observability_path, list(
    type = "duckdb_table_built",
    db_path = db_path,
    table = table,
    mode = mode,
    source_files = files,
    written_rows = nrow(data),
    table_rows = row_count
  ))

  list(db_path = db_path, table = table, mode = mode, source_files = files, written_rows = nrow(data), table_rows = row_count)
}

compute_md5 <- function(path) {
  unname(tools::md5sum(path))
}

stamp_datasets <- function(paths,
                          root_dir = ".",
                          run_id = NULL,
                          actor = Sys.info()[["user"]],
                          stamp_path = fs::path(root_dir, "logs", "dataset-integrity.ndjson"),
                          logical_name = NULL) {
  if (!length(paths)) return(list())

  out <- list()
  for (p in paths) {
    abs <- fs::path(root_dir, p)
    if (!fs::file_exists(abs)) {
      tp_log("warn", "⚠️ output not found for MD5 stamp: {.path {p}}")
      next
    }

    stamp_ts <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
    md5 <- compute_md5(abs)
    dataset_name <- logical_name %||% fs::path_ext_remove(fs::path_file(p))

    event <- list(
      ts = stamp_ts,
      event = "dataset_integrity",
      run_id = run_id,
      actor = actor,
      file = p,
      logical_dataset = dataset_name,
      version = paste0(dataset_name, "@", gsub("[-:TZ]", "", stamp_ts), "-", substr(md5, 1, 8)),
      md5 = md5,
      bytes = as.numeric(fs::file_info(abs)$size)
    )

    write_audit_event(stamp_path, event)
    out[[p]] <- event
  }

  out
}

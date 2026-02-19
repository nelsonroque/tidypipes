read_spec_file <- function(path) {
  ext <- tolower(fs::path_ext(path))
  switch(
    ext,
    yml = yaml::read_yaml(path),
    yaml = yaml::read_yaml(path),
    json = jsonlite::fromJSON(path, simplifyVector = FALSE),
    rlang::abort("Spec must be .yml/.yaml/.json")
  )
}

discover_input_files <- function(input) {
  dir <- input$dir %||% "."
  recursive <- isTRUE(input$recursive)

  if (!is.null(input$files)) {
    return(normalizePath(unlist(input$files), winslash = "/", mustWork = FALSE))
  }

  if (!is.null(input$glob)) {
    files <- fs::dir_ls(dir, recurse = recursive, glob = input$glob, type = "file")
    return(normalizePath(files, winslash = "/", mustWork = FALSE))
  }

  pattern <- input$pattern %||% ".*"
  files <- list.files(dir, pattern = pattern, recursive = recursive, full.names = TRUE)
  normalizePath(files, winslash = "/", mustWork = FALSE)
}

read_input_file <- function(path, reader = "auto") {
  ext <- tolower(fs::path_ext(path))
  fmt <- if (identical(reader, "auto")) ext else tolower(reader)

  if (fmt %in% c("csv", "read_csv")) {
    if (requireNamespace("readr", quietly = TRUE)) return(readr::read_csv(path, show_col_types = FALSE))
    return(utils::read.csv(path, stringsAsFactors = FALSE))
  }

  if (fmt %in% c("tsv", "txt", "read_tsv")) {
    if (requireNamespace("readr", quietly = TRUE)) return(readr::read_tsv(path, show_col_types = FALSE))
    return(utils::read.delim(path, stringsAsFactors = FALSE))
  }

  if (fmt %in% c("parquet", "read_parquet")) {
    if (!requireNamespace("arrow", quietly = TRUE)) {
      rlang::abort("arrow is required to read parquet files.")
    }
    return(as.data.frame(arrow::read_parquet(path), stringsAsFactors = FALSE))
  }

  rlang::abort(glue::glue("Unsupported reader/format: {fmt}"))
}

extract_filename_fields <- function(df, file, filename_fields = NULL) {
  if (is.null(filename_fields)) return(df)

  base <- fs::path_file(file)
  regex <- filename_fields$regex %||% NULL
  fields <- unlist(filename_fields$fields %||% character(0))
  if (is.null(regex) || !length(fields)) return(df)

  m <- regexec(regex, base)
  g <- regmatches(base, m)[[1]]
  if (length(g) <= 1) return(df)

  vals <- g[-1]
  for (i in seq_len(min(length(fields), length(vals)))) {
    df[[fields[[i]]]] <- vals[[i]]
  }
  df
}

apply_dataset_hooks <- function(df, hooks = NULL) {
  if (is.null(hooks)) return(df)

  if (!is.null(hooks$filter)) {
    for (expr in unlist(hooks$filter)) {
      keep <- eval(parse(text = expr), envir = df, enclos = parent.frame())
      keep <- as.logical(keep)
      keep[is.na(keep)] <- FALSE
      df <- df[keep, , drop = FALSE]
    }
  }

  if (!is.null(hooks$mutate)) {
    for (nm in names(hooks$mutate)) {
      df[[nm]] <- eval(parse(text = hooks$mutate[[nm]]), envir = df, enclos = parent.frame())
    }
  }

  if (!is.null(hooks$select)) {
    cols <- intersect(unlist(hooks$select), names(df))
    df <- df[, cols, drop = FALSE]
  }

  if (!is.null(hooks$rename)) {
    for (new_nm in names(hooks$rename)) {
      old_nm <- hooks$rename[[new_nm]]
      if (old_nm %in% names(df)) names(df)[names(df) == old_nm] <- new_nm
    }
  }

  if (!is.null(hooks$group_summarise)) {
    gs <- hooks$group_summarise
    by <- unlist(gs$group_by %||% character(0))
    sums <- gs$summarise %||% list()
    if (!length(by)) rlang::abort("group_summarise requires group_by")
    if (!requireNamespace("dplyr", quietly = TRUE) || !requireNamespace("rlang", quietly = TRUE)) {
      rlang::abort("dplyr + rlang are required for group_summarise hook")
    }
    d <- dplyr::as_tibble(df)
    exprs <- lapply(sums, rlang::parse_expr)
    d <- dplyr::group_by(d, dplyr::across(dplyr::all_of(by)))
    d <- dplyr::summarise(d, !!!exprs, .groups = "drop")
    df <- as.data.frame(d, stringsAsFactors = FALSE)
  }

  df
}

combine_frames <- function(frames, behavior = list()) {
  mode <- behavior$mode %||% "bind_rows"
  if (!length(frames)) return(data.frame())

  out <- if (identical(mode, "merge")) {
    by <- unlist(behavior$by %||% character(0))
    if (!length(by)) rlang::abort("merge mode requires behavior.by keys")
    Reduce(function(x, y) merge(x, y, by = by, all = TRUE), frames)
  } else {
    all_cols <- unique(unlist(lapply(frames, names)))
    padded <- lapply(frames, function(d) {
      missing <- setdiff(all_cols, names(d))
      for (m in missing) d[[m]] <- NA
      d[, all_cols, drop = FALSE]
    })
    do.call(rbind, padded)
  }

  dedupe_keys <- unlist(behavior$dedupe_keys %||% character(0))
  if (length(dedupe_keys)) {
    existing <- intersect(dedupe_keys, names(out))
    if (length(existing)) {
      keep <- !duplicated(out[, existing, drop = FALSE])
      out <- out[keep, , drop = FALSE]
    }
  }

  rownames(out) <- NULL
  out
}

write_dataset_output <- function(data, output) {
  path <- output$path
  format <- tolower(output$format %||% fs::path_ext(path))
  fs::dir_create(fs::path_dir(path))

  if (format == "csv") {
    utils::write.csv(data, path, row.names = FALSE)
  } else if (format == "rds") {
    saveRDS(data, path)
  } else if (format == "parquet") {
    if (!requireNamespace("arrow", quietly = TRUE)) rlang::abort("arrow is required to write parquet")
    arrow::write_parquet(data, path)
  } else {
    rlang::abort(glue::glue("Unsupported output format: {format}"))
  }

  path
}

#' Build a dataset from YAML/JSON specification
#' @param spec_path Path to dataset build spec.
#' @param audit_log_path Path to audit log.
#' @param observability_path Path to observability log.
#' @param run_id Optional run id for lineage.
#' @export
build_dataset <- function(spec_path,
                          audit_log_path = "logs/audit.ndjson",
                          observability_path = "logs/observability.ndjson",
                          run_id = paste0("ds-", format(Sys.time(), "%Y%m%d%H%M%S"))) {
  spec <- read_spec_file(spec_path)
  files <- discover_input_files(spec$input %||% list())

  if (!length(files)) rlang::abort("No input files discovered")

  frames <- lapply(files, function(f) {
    d <- read_input_file(f, reader = spec$input$reader %||% "auto")
    d <- as.data.frame(d, stringsAsFactors = FALSE)
    d$.source_file <- f
    extract_filename_fields(d, f, filename_fields = spec$filename_fields)
  })

  data <- combine_frames(frames, behavior = spec$combine %||% list(mode = "bind_rows"))
  data <- apply_dataset_hooks(data, hooks = spec$hooks)

  out_path <- write_dataset_output(data, spec$output)
  lineage <- stamp_datasets(paths = out_path, root_dir = ".", run_id = run_id,
                            logical_name = spec$name %||% fs::path_ext_remove(fs::path_file(out_path)))

  write_audit_event(audit_log_path, list(
    ts = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    event = "dataset_built",
    run_id = run_id,
    spec = normalizePath(spec_path, winslash = "/", mustWork = FALSE),
    output = out_path,
    rows = nrow(data),
    cols = ncol(data),
    files = files
  ))

  write_observability_event(observability_path, list(
    type = "dataset_built",
    run_id = run_id,
    output = out_path,
    row_count = nrow(data),
    source_files = files
  ))

  list(data = data, output = out_path, files = files, lineage = lineage)
}

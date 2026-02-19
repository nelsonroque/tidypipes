as_sample_values <- function(x, n = 3) {
  vals <- unique(x[!is.na(x)])
  vals <- head(as.character(vals), n)
  paste(vals, collapse = " | ")
}

infer_min <- function(x) {
  if (inherits(x, c("Date", "POSIXct", "POSIXt")) || is.numeric(x) || is.integer(x)) {
    return(suppressWarnings(min(x, na.rm = TRUE)))
  }
  NA
}

infer_max <- function(x) {
  if (inherits(x, c("Date", "POSIXct", "POSIXt")) || is.numeric(x) || is.integer(x)) {
    return(suppressWarnings(max(x, na.rm = TRUE)))
  }
  NA
}

#' Generate a variable codebook (csv + markdown)
#' @param data Data frame.
#' @param output_csv Output CSV path.
#' @param output_md Output markdown path.
#' @param labels Optional named list/vector of friendly labels.
#' @export
generate_codebook <- function(data,
                              output_csv,
                              output_md,
                              labels = NULL) {
  stopifnot(is.data.frame(data))

  rows <- lapply(names(data), function(nm) {
    x <- data[[nm]]
    list(
      variable = nm,
      label = if (!is.null(labels) && !is.null(labels[[nm]])) as.character(labels[[nm]]) else "",
      class = paste(class(x), collapse = ","),
      non_missing = sum(!is.na(x)),
      distinct = length(unique(x[!is.na(x)])),
      min = as.character(infer_min(x)),
      max = as.character(infer_max(x)),
      sample_values = as_sample_values(x)
    )
  })

  cb <- do.call(rbind, lapply(rows, as.data.frame, stringsAsFactors = FALSE))

  fs::dir_create(fs::path_dir(output_csv))
  fs::dir_create(fs::path_dir(output_md))
  utils::write.csv(cb, output_csv, row.names = FALSE)

  lines <- c(
    "# Codebook",
    "",
    "| variable | label | class | non_missing | distinct | min | max | sample_values |",
    "|---|---|---:|---:|---:|---|---|---|"
  )

  for (i in seq_len(nrow(cb))) {
    r <- cb[i, ]
    lines <- c(lines, sprintf("| %s | %s | %s | %s | %s | %s | %s | %s |",
                              r$variable, r$label, r$class, r$non_missing, r$distinct, r$min, r$max, r$sample_values))
  }

  writeLines(lines, output_md)
  list(codebook = cb, csv = output_csv, markdown = output_md)
}

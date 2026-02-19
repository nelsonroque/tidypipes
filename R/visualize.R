visualize_pipeline <- function(config_path, out_path = NULL, format = c("mermaid", "text")) {
  format <- rlang::arg_match(format)
  cfg <- read_pipeline_config(config_path)
  steps <- cfg$steps

  ids <- vapply(steps, function(s) s$id, character(1))
  deps <- lapply(steps, function(s) s$depends_on %||% character(0))
  names(deps) <- ids

  if (format == "mermaid") {
    lines <- c("flowchart TD")
    for (id in ids) {
      lines <- c(lines, glue::glue("  {id}[\"{id}\"]"))
      for (d in deps[[id]]) {
        lines <- c(lines, glue::glue("  {d} --> {id}"))
      }
    }
    graph <- paste(lines, collapse = "\n")
  } else {
    chunks <- vapply(ids, function(id) {
      d <- deps[[id]]
      if (!length(d)) glue::glue("{id}: (root)") else glue::glue("{id}: {paste(d, collapse=', ')}")
    }, character(1))
    graph <- paste(chunks, collapse = "\n")
  }

  if (!is.null(out_path)) {
    fs::dir_create(fs::path_dir(out_path))
    writeLines(graph, out_path)
  }

  graph
}

#' Render a Mermaid pipeline graph to PNG using mermaid-cli (mmdc)
#'
#' @param mmd_path Path to Mermaid `.mmd` file.
#' @param png_path Output PNG path.
#' @param background Background color for render (default transparent).
#'
#' @return Path to rendered PNG.
#' @export
render_pipeline_png <- function(mmd_path, png_path = NULL, background = "transparent") {
  if (!fs::file_exists(mmd_path)) {
    rlang::abort(glue::glue("Mermaid file not found: {mmd_path}"))
  }

  if (is.null(png_path)) {
    png_path <- fs::path_ext_set(mmd_path, "png")
  }

  mmdc <- Sys.which("mmdc")
  if (!nzchar(mmdc)) {
    rlang::abort("`mmdc` not found. Install with: npm i -g @mermaid-js/mermaid-cli")
  }

  fs::dir_create(fs::path_dir(png_path))

  res <- system2(
    mmdc,
    args = c("-i", mmd_path, "-o", png_path, "-b", background),
    stdout = TRUE,
    stderr = TRUE
  )

  status <- attr(res, "status") %||% 0L
  if (!identical(status, 0L) || !fs::file_exists(png_path)) {
    msg <- paste(c("Failed rendering Mermaid PNG", res), collapse = "\n")
    rlang::abort(msg)
  }

  tp_log("success", "🖼️ rendered Mermaid PNG -> {.path {png_path}}")
  png_path
}

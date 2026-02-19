require_pins <- function() {
  if (!requireNamespace("pins", quietly = TRUE)) {
    rlang::abort("Package `pins` is required for pin exports. Install with install.packages('pins').")
  }
}

resolve_pin_board <- function(board = c("folder", "local", "temp", "rsconnect"), board_path = "pins", connect_server = NULL, connect_key = NULL) {
  require_pins()
  board <- rlang::arg_match(board)

  if (board == "folder") {
    fs::dir_create(board_path)
    return(pins::board_folder(board_path))
  }

  if (board == "local") {
    return(pins::board_local())
  }

  if (board == "temp") {
    return(pins::board_temp())
  }

  if (board == "rsconnect") {
    if (is.null(connect_server) || is.null(connect_key)) {
      rlang::abort("`connect_server` and `connect_key` are required for board='rsconnect'.")
    }
    return(pins::board_connect(server = connect_server, key = connect_key))
  }

  rlang::abort("Unsupported pins board")
}

#' Export an object as a pin
#'
#' @param x Object to pin.
#' @param pin_name Pin name.
#' @param board Where to store pin: folder/local/temp/rsconnect.
#' @param board_path Folder path when board='folder'.
#' @param versioned Whether to version the pin.
#' @param metadata Named list with extra metadata.
#' @param root_dir Root dir for logs.
#' @param run_id Optional run id for audit context.
#' @param actor Actor/user for audit context.
#' @param connect_server Optional Posit Connect server URL for rsconnect board.
#' @param connect_key Optional API key for rsconnect board.
#'
#' @return Pin metadata invisibly.
#' @export
pin_export <- function(
    x,
    pin_name,
    board = c("folder", "local", "temp", "rsconnect"),
    board_path = "pins",
    versioned = TRUE,
    metadata = list(),
    root_dir = ".",
    run_id = NULL,
    actor = Sys.info()[["user"]],
    connect_server = NULL,
    connect_key = NULL) {

  b <- resolve_pin_board(
    board = board,
    board_path = fs::path(root_dir, board_path),
    connect_server = connect_server,
    connect_key = connect_key
  )

  extra <- c(
    list(
      exported_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
      run_id = run_id,
      actor = actor,
      source = "tidypipes"
    ),
    metadata
  )

  pins::pin_write(b, x = x, name = pin_name, type = "rds", metadata = extra)

  audit_log_path <- fs::path(root_dir, "logs", "audit.ndjson")
  obs_path <- fs::path(root_dir, "logs", "observability.ndjson")

  write_audit_event(audit_log_path, list(
    ts = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    run_id = run_id,
    event = "pin_export",
    status = "success",
    emoji = "📌",
    actor = actor,
    pin_name = pin_name,
    board = board,
    board_path = if (board == "folder") fs::path(root_dir, board_path) else board
  ))

  write_observability_event(obs_path, list(
    type = "pin_export",
    run_id = run_id,
    pin_name = pin_name,
    board = board
  ))

  tp_log("success", "📌 exported pin {.field {pin_name}} to {.field {board}}")
  invisible(list(pin_name = pin_name, board = board))
}

#' Export data from file path as pin
#'
#' @param path File path to dataset.
#' @param ... Passed to pin_export().
#'
#' @return Pin metadata invisibly.
#' @export
pin_export_path <- function(path, ...) {
  if (!fs::file_exists(path)) {
    rlang::abort(glue::glue("Cannot pin missing file: {path}"))
  }

  ext <- tolower(fs::path_ext(path))
  x <- switch(
    ext,
    csv = utils::read.csv(path, stringsAsFactors = FALSE),
    tsv = utils::read.delim(path, stringsAsFactors = FALSE),
    rds = readRDS(path),
    json = jsonlite::fromJSON(path),
    rlang::abort(glue::glue("Unsupported file extension for pin_export_path(): {ext}"))
  )

  pin_export(x = x, ...)
}

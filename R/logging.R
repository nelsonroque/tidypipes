tp_log <- function(level = c("info", "warn", "error", "success"), msg, ...) {
  level <- rlang::arg_match(level)
  text <- cli::format_inline(msg, .envir = parent.frame())

  if (level == "info") cli::cli_alert_info(text)
  if (level == "warn") cli::cli_alert_warning(text)
  if (level == "error") cli::cli_alert_danger(text)
  if (level == "success") cli::cli_alert_success(text)

  invisible(text)
}

emoji_for_status <- function(status) {
  switch(
    status,
    started = "🚀",
    step_started = "🧩",
    step_success = "✅",
    step_failed = "💥",
    finished = "🏁",
    skipped = "⏭️",
    "📝"
  )
}

write_audit_event <- function(path, event) {
  fs::dir_create(fs::path_dir(path))
  json <- jsonlite::toJSON(event, auto_unbox = TRUE, null = "null")
  write(json, file = path, append = TRUE)
  invisible(event)
}

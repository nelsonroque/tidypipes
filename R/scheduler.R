schedule_pipeline <- function(config_path,
                              every_seconds = NULL,
                              cron = NULL,
                              root_dir = fs::path_dir(config_path),
                              queue_path = fs::path(root_dir, "logs", "schedule-queue.ndjson"),
                              state_path = fs::path(root_dir, "logs", "scheduler-state.json"),
                              max_concurrency = 1,
                              max_queue = 100) {
  job <- list(config_path = config_path, enqueued_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
              every_seconds = every_seconds, cron = cron)
  fs::dir_create(fs::path_dir(queue_path))

  existing <- if (fs::file_exists(queue_path)) readLines(queue_path, warn = FALSE) else character(0)
  if (length(existing) >= max_queue) rlang::abort("Scheduler queue is full.")

  write(jsonlite::toJSON(job, auto_unbox = TRUE), file = queue_path, append = TRUE)

  scheduler <- if (fs::file_exists(state_path)) jsonlite::read_json(state_path, simplifyVector = TRUE) else list(active_runs = 0)
  scheduler$max_concurrency <- max_concurrency
  jsonlite::write_json(scheduler, state_path, auto_unbox = TRUE, pretty = TRUE)
  invisible(job)
}

scheduler_status <- function(root_dir = ".") {
  queue_path <- fs::path(root_dir, "logs", "schedule-queue.ndjson")
  state_path <- fs::path(root_dir, "logs", "scheduler-state.json")
  list(
    queued = if (fs::file_exists(queue_path)) length(readLines(queue_path, warn = FALSE)) else 0,
    state = if (fs::file_exists(state_path)) jsonlite::read_json(state_path, simplifyVector = TRUE) else list(active_runs = 0)
  )
}

run_scheduler_once <- function(root_dir = ".") {
  queue_path <- fs::path(root_dir, "logs", "schedule-queue.ndjson")
  state_path <- fs::path(root_dir, "logs", "scheduler-state.json")
  if (!fs::file_exists(queue_path)) return(invisible(NULL))

  lines <- readLines(queue_path, warn = FALSE)
  if (!length(lines)) return(invisible(NULL))

  st <- if (fs::file_exists(state_path)) jsonlite::read_json(state_path, simplifyVector = TRUE) else list(active_runs = 0, max_concurrency = 1)
  if ((st$active_runs %||% 0) >= (st$max_concurrency %||% 1)) {
    tp_log("warn", "⏳ scheduler at concurrency limit")
    return(invisible(NULL))
  }

  job <- jsonlite::fromJSON(lines[[1]], simplifyVector = TRUE)
  remaining <- lines[-1]
  writeLines(remaining, queue_path)

  st$active_runs <- (st$active_runs %||% 0) + 1
  jsonlite::write_json(st, state_path, auto_unbox = TRUE, pretty = TRUE)

  on.exit({
    st2 <- jsonlite::read_json(state_path, simplifyVector = TRUE)
    st2$active_runs <- max(0, (st2$active_runs %||% 1) - 1)
    jsonlite::write_json(st2, state_path, auto_unbox = TRUE, pretty = TRUE)
  }, add = TRUE)

  run_pipeline(config_path = job$config_path, root_dir = root_dir)
}

backfill_pipeline <- function(config_path, start_date, end_date, date_param = "run_date", ...) {
  dseq <- seq.Date(as.Date(start_date), as.Date(end_date), by = "day")
  out <- vector("list", length(dseq))
  for (i in seq_along(dseq)) {
    Sys.setenv(TIDYPIPES_BACKFILL_DATE = as.character(dseq[[i]]))
    out[[i]] <- run_pipeline(config_path, ...)
  }
  out
}

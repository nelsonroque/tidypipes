#' @importFrom digest digest
#' @importFrom glue glue
#' @importFrom cli cli_alert_info
#' @importFrom tibble tibble
#' @importFrom dplyr %>%
#' @importFrom purrr map_df
#' @importFrom stringr str_sub

# Unified Logging Function with Configurable Format ----
log_step <- function(
    file = "log.txt",
    ts = Sys.time(),
    process_id = NA,
    status = NA,
    msg = NA,
    format_fn = NULL
) {
  if (is.na(process_id)) {
    process_id <- digest::digest(ts)
  }

  system_info <- Sys.info()
  log_entry <- list(
    timestamp = ts,
    process_id = process_id,
    system_name = system_info["sysname"],
    system_version = system_info["release"],
    status = status,
    message = msg
  )

  formatted_log <- if (!is.null(format_fn)) format_fn(log_entry) else {
    paste(log_entry$timestamp, log_entry$process_id, log_entry$system_name,
          log_entry$system_version, log_entry$status, log_entry$message, sep = " - ")
  }

  cli::cli_alert_info(formatted_log)
  write(formatted_log, file = file, append = TRUE)
}

# Run a Generic Pipeline Step ----
execute_pipeline_step <- function(step, pipeline_path, process_id, log_format_fn) {
  log_step(ts = Sys.time(), process_id = process_id, status = "INIT", msg = paste("Step:", step), format_fn = log_format_fn)

  tm1 <- proc.time()
  start_time <- Sys.time()

  result <- tryCatch({
    source(file.path(pipeline_path, step))

    tm2 <- proc.time()
    elapsed_secs <- as.numeric(tm2[3] - tm1[3])

    log_step(ts = Sys.time(), process_id = process_id, status = "COMPLETE", msg = paste("Step:", step), format_fn = log_format_fn)
    log_step(ts = Sys.time(), process_id = process_id, status = "ELAPSED", msg = paste(elapsed_secs, "seconds"), format_fn = log_format_fn)

    tibble::tibble(
      process_id = process_id,
      step = step,
      step_result = 1,
      start_proc_time = tm1[1],
      end_proc_time = tm2[1],
      start_clock_time = start_time,
      end_clock_time = Sys.time(),
      elapsed_secs = elapsed_secs,
      errors = NA
    )
  }, error = function(e) {

    tm2 <- proc.time()
    elapsed_secs <- as.numeric(tm2[3] - tm1[3])

    log_step(ts = Sys.time(), process_id = process_id, status = "ERROR", msg = paste("Step:", step, "Error:", e$message), format_fn = log_format_fn)

    tibble::tibble(
      process_id = process_id,
      step = step,
      step_result = 0,
      start_proc_time = tm1[1],
      end_proc_time = tm2[1],
      start_clock_time = start_time,
      end_clock_time = Sys.time(),
      elapsed_secs = elapsed_secs,
      errors = e$message
    )
  })
  return(result)
}

# Run Pipeline Step ----
run_pipeline_step <- function(step = NA, pipeline_path = "pipeline/", config = NA, log_format_fn = NULL) {
  if (is.na(step)) stop("Oops, `step` is missing.")
  if (stringr::str_sub(pipeline_path, -1, -1) != "/") {
    stop("Oops, `pipeline_path` must end with a trailing slash.")
  }

  available_scripts <- list.files(path = pipeline_path)
  if (!(step %in% available_scripts)) {
    stop("Oops, `step` is not a valid script in the `pipeline_path`.")
  }

  process_id <- digest::digest(Sys.time())
  execute_pipeline_step(step, pipeline_path, process_id, log_format_fn)
}

# Run Pipeline from Configuration ----
run_pipeline_from_config <- function(config_file = "config.json", log_format_fn = NULL) {
  config <- tidypipes::read_data_file(config_file)
  step_results <- purrr::map_df(config$steps, function(step) {
    execute_pipeline_step(step, config$pipeline_path, digest::digest(Sys.time()), log_format_fn)
  })
  return(step_results)
}

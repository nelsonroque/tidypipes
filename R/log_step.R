#' Log Format for Each Step
#'
#' This function logs the details of each step in a process, including a timestamp, process ID, status, and message.
#' The log is written to a specified file and also printed to the console.
#'
#' @param file A character string specifying the path to the log file. Defaults to "log.txt".
#' @param ts A timestamp indicating when the log entry is created. Defaults to the current system time (`Sys.time()`).
#' @param process_id A unique identifier for the process. If not provided, a unique ID is generated using the current system time.
#' @param status A character string indicating the status of the process step.
#' @param msg A character string containing a message about the process step.
#'
#' @return This function does not return a value.
#' @export
#'
#' @examples
#' # Log a step with default settings
#' log_step(status = "INFO", msg = "Process started")
#'
#' # Log a step with a specific process ID
#' log_step(process_id = "12345", status = "ERROR", msg = "An error occurred")
## Log format for each step ----
log_step <- function(
    file = "log.txt", # Path to the log file
    ts = Sys.time(), # Timestamp for the log entry
    process_id = NA, # Process ID (optional, will generate if NA)
    status = NA, # Status of the process step
    msg = NA # Message about the process step
    ) {
  # Generate a process ID if not provided
  if (is.na(process_id)) {
    process_id <- digest::digest(ts)
  } else {
    process_id <- process_id
  }

  # Construct the log message
  log_msg <- paste(ts,
    process_id,
    status,
    msg,
    sep = " - "
  )

  # Print the log message to the console
  cli::cli_h1("[LOG]")
  cli::cli_alert_info(log_msg)

  # Write the log message to the specified file
  write(log_msg, file = file, append = TRUE)
}

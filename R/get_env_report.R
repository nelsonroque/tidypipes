#' Get System Environment Report and Export
#'
#' This function collects and returns a detailed report of the current system environment.
#' The report includes details such as the current date, time, timezone, process ID, locale,
#' system information, memory usage, and CPU details.
#'
#' @param output_dir The directory where the environment report should be saved. Defaults to NULL (no file export).
#' @param format The output file format. Can be "csv" (default) or "txt".
#' @return A tibble containing the system environment report.
#' @export
#'
#' @examples
#' # Get environment report without exporting
#' get_env_report()
#'
#' # Get environment report and save to CSV
#' \dontrun{get_env_report(output_dir = "reports", format = "csv")}
#'
get_env_report <- function(output_dir = NULL, format = "csv") {
  # Gather system info
  si <- Sys.info()

  # Construct environment report
  env_report <- tibble::tibble(
    r_home = R.home(),
    r_version = R.version.string,
    r_platform = R.version$platform,
    r_session_info = paste(R.version$nickname, R.version$major, R.version$minor),
    sys_date = Sys.Date(),
    sys_time = Sys.time(),
    sys_timezone = Sys.timezone(),
    sys_pid = Sys.getpid(),
    sys_locale = Sys.getlocale(),
    sys_memory_mb = round(as.numeric(utils::memory.size()) / 1024, 2),
    sys_cpu_cores = parallel::detectCores(),
    sys_info_os = si["sysname"],
    sys_info_release = si["release"],
    sys_info_version = si["version"],
    sys_info_nodename = si["nodename"],
    sys_info_machine = si["machine"],
    sys_info_user = si["user"]
  )

  # Transform into long format
  env_report_final <- env_report %>%
    dplyr::mutate(dplyr::across(everything(), as.character)) %>%
    tidyr::pivot_longer(cols = everything(), names_to = "key", values_to = "value")

  # Export if output directory is provided
  if (!is.null(output_dir)) {
    # Ensure directory exists
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE)
    }

    # Generate timestamped filename
    timestamp <- get_timestamp()
    filename <- file.path(output_dir, paste0("tidypipes_environment_report_", timestamp, ".", format))

    # Export based on format
    if (format == "csv") {
      readr::write_csv(env_report_final, filename)
    } else if (format == "txt") {
      writeLines(capture.output(print(env_report_final)), filename)
    } else {
      stop("Invalid format. Use 'csv' or 'txt'.")
    }

    message("Environment report saved to: ", filename)
  }

  return(env_report_final)
}

#' Get and Export All Reports
#'
#' This function retrieves environment, TODO, and package reports,
#' and optionally exports them to timestamped files.
#'
#' @param output_dir The directory where reports should be saved. Defaults to NULL (no file export).
#' @param format The file format for exports. Can be "csv" (default) or "txt".
#' @return A list containing all generated reports.
#' @export
#'
#' @examples
#' # Get reports without saving to files
#' get_reports()
#'
#' # Get reports and save them as CSV files
#' \dontrun{get_reports(output_dir = "reports", format = "csv")}
#'
get_reports <- function(output_dir = NULL, format = "csv") {
  message("Generating reports...")

  # Function to safely generate reports, avoiding failures in case of errors
  safe_generate <- function(report_function, report_name) {
    tryCatch(
      {
        report <- report_function(output_dir = output_dir, format = format)
        message(paste(report_name, "generated successfully."))
        return(report)
      },
      error = function(e) {
        message(paste("Error generating", report_name, ":", e$message))
        return(NULL)
      }
    )
  }

  # Generate reports
  reports <- list(
    env_report = safe_generate(get_env_report, "Environment Report"),
    todo_report = safe_generate(get_todo_report, "TODO Report"),
    package_report = safe_generate(get_package_report, "Package Report")
  )

  message("All reports generated successfully.")

  return(reports)
}

#' Get TODO Report and Export to File
#'
#' This function generates a report of all TODO comments detected in the code
#' and saves the report to a timestamped file.
#'
#' @param output_dir The directory where the TODO report should be saved. Defaults to the current working directory.
#' @param format The output file format. Can be "txt" (default) or "csv".
#' @return A tibble containing the details of the TODO comments found in the code.
#' @export
#'
#' @examples
#' # Generate a TODO report and save it
#' \dontrun{get_todo_report(output_dir = "reports", format = "csv")}
get_todo_report <- function(output_dir = ".", format = "txt") {
  # Ensure output directory exists
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Generate timestamped filename
  timestamp <- get_timestamp()
  filename <- file.path(output_dir, paste0("tidypipes_todo_report_", timestamp, ".", format))

  # Get TODO report as a tibble
  todo_report <- todor::todor()

  # Export based on selected format
  if (format == "txt") {
    writeLines(capture.output(print(todo_report)), filename)
  } else if (format == "csv") {
    readr::write_csv(todo_report, filename)
  } else {
    stop("Invalid format. Use 'txt' or 'csv'.")
  }

  message("TODO report saved to: ", filename)
  return(todo_report)
}

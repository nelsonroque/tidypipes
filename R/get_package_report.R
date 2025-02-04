#' Get Installed Packages Report and Export
#'
#' This function generates a report of the currently installed packages,
#' returning the information as a cleaned tibble. Optionally, it can
#' filter out base R packages and export the report to a file.
#'
#' @param exclude_base Logical. If TRUE, excludes base R packages. Default is TRUE.
#' @param output_dir The directory where the package report should be saved. Defaults to NULL (no file export).
#' @param format The output file format. Can be "csv" (default) or "txt".
#' @return A tibble containing the details of installed packages.
#' @export
#'
#' @examples
#' # Get installed package report without exporting
#' get_package_report()
#'
#' # Get installed package report and save it to a CSV file
#' \dontrun{get_package_report(output_dir = "reports", format = "csv")}
#'
get_package_report <- function(exclude_base = TRUE, output_dir = NULL, format = "csv") {
  # Get installed packages
  packages <- as.data.frame(installed.packages()) %>%
    tibble::as_tibble() %>%
    janitor::clean_names() %>%
    dplyr::select(package, version, lib_path, priority, depends, imports, linking_to)  # Select useful columns

  # Filter out base R packages if needed
  if (exclude_base) {
    packages <- packages %>% dplyr::filter(is.na(priority))  # Base packages have a "priority" field
  }

  # Sort by package name
  packages <- packages %>% dplyr::arrange(package)

  # Export if output directory is provided
  if (!is.null(output_dir)) {
    # Ensure directory exists
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE)
    }

    # Generate timestamped filename
    timestamp <- get_timestamp()
    filename <- file.path(output_dir, paste0("tidypipes_package_report_", timestamp, ".", format))

    # Export based on format
    if (format == "csv") {
      readr::write_csv(packages, filename)
    } else if (format == "txt") {
      writeLines(capture.output(print(packages)), filename)
    } else {
      stop("Invalid format. Use 'csv' or 'txt'.")
    }

    message("Package report saved to: ", filename)
  }

  return(packages)
}

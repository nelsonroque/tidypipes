#' Get Installed Packages Report
#'
#' This function generates a report of the currently installed packages,
#' returning the information as a cleaned tibble.
#'
#' @return A tibble containing the details of the installed packages.
#' @export
#'
#' @examples
#' # Generate a report of the installed packages
#' \dontrun{get_package_report()}
#'
get_package_report <- function() {
  pr <- installed.packages() %>%
    tibble::as_tibble() %>%
    janitor::clean_names()
  return(pr)
}

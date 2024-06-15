#' Get TODO Report
#'
#' This function generates a report of all TODO comments detected in the code.
#'
#' @return A tibble containing the details of the TODO comments found in the code.
#' @export
#'
#' @examples
#' # Generate a TODO report
#' \dontrun{get_todo_report()}
#'
get_todo_report <- function() {
  # detect any important code comments with TODO
  todor::todor()
}

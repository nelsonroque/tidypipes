#' @section utils_debug
#'
#' @keywords internal

#' Label and Return a Value
#'
#' Returns a named list with the object name and value.
#'
#' @param obj Any object.
#'
#' @return A list with `name` and `value` components.
#' @export
label_value <- function(obj) {
  list(name = deparse(substitute(obj)), value = obj)
}


#' Print Object Name and Value
#'
#' For lightweight debugging of scalars (e.g., strings, integers). Prints the name and value.
#'
#' @param obj An object to print (not a data frame).
#' @param delim A string separator between name and value. Default is " : ".
#'
#' @return NULL. Used for side-effect printing.
#' @export
print_named <- function(obj, delim = " : ") {
  if (is.data.frame(obj)) {
    stop("Use label_value() or describe_object() for data frames.")
  }
  cat(paste0("Object Name", delim, deparse(substitute(obj))), "\n")
  cat(paste0("Object Value", delim, obj), "\n")
}


#' Describe Object in a Pipeline
#'
#' Prints metadata about an object (class, type, size, structure) and returns it unchanged.
#' Useful inside dplyr pipelines for debugging.
#'
#' @param x Any R object.
#' @param verbose Logical. If TRUE, prints details. Default is TRUE.
#'
#' @return The input object `x`, unchanged.
#' @export
describe_object <- function(x, verbose = TRUE) {
  if (verbose) {
    cat("---- Object Info ----\n")
    cat("Class:", class(x), "\n")
    cat("Type:", typeof(x), "\n")
    cat("Size:", format(object.size(x), units = "auto"), "\n")

    if (is.data.frame(x)) {
      cat("Rows:", nrow(x), " Columns:", ncol(x), "\n")
      cat("Column Names:", paste(names(x), collapse = ", "), "\n")
    } else if (is.vector(x)) {
      cat("Length:", length(x), "\n")
    } else if (is.list(x)) {
      cat("List Length:", length(x), "\n")
    }
    cat("---------------------\n")
  }
  return(x)
}


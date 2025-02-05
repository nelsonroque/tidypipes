
#' Print object info in a dplyr pipeline
#'
#' This function prints metadata about an object, including its class, size, dimensions, 
#' and column names (if applicable). It returns the object unchanged so it can be used 
#' within a `dplyr` pipeline.
#'
#' @param x Any R object (data frame, vector, list, etc.).
#' @param message Logical. If `TRUE`, prints additional messages. Defaults to `TRUE`.
#'
#' @return The input object `x`, unchanged.
#' @export
echo_info <- function(x, message = TRUE) {
  if (message) {
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
  
  return(x)  # Return the object unchanged
}


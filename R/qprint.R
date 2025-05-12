#' ruf

#' @name qprint
#' @param . class: data
#' @param delim class: string 
#' @export
qprint <- function(., delim=" : ") {
  if(is_data_frame_tibble(.)) {
    stop("Printing a data.frame to the console is memory intensive. This function is intended to be used with integers, strings, and other small objects. Use lprint() for larger objects.")
  } else {
    print(paste0("object name", delim, deparse(substitute(.))))
    print(paste0("object value", delim, .))
  }
}
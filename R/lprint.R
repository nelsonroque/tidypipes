#' ruf

#' @name lprint
#' @param . class: data
#' @export
lprint <- function(.) {
  return(list(name = deparse(substitute(.)), value= .))
}
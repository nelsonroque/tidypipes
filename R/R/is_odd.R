#' ruf

#' @name is_odd
#' @param x class:numeric
#' @import tidyverse
#' @examples
#' is_even(x)
#' @export
is_odd <- function(x) {
  x %% 2 != 0
}
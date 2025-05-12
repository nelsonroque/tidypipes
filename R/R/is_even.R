#' ruf

#' @name is_even
#' @param x class:numeric
#' @import tidyverse
#' @examples
#' is_even(x)
#' @export
is_even <- function(x) {
  x %% 2 == 0
}
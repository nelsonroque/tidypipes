#' ruf
#' 
#' @name prop_change
#' @param old class: numeric
#' @param new class: numeric
#' @param rd class: numeric
#' @param perc class: boolean
#' @param print_str class: boolean
#' @export
prop_change <- function(old, new, rd = 2, perc=T, print_str=T) {
  old = as.numeric(old)
  new = as.numeric(new)
  change = (((new - old) / old))
  if(perc) {
    change = change * 100
    change = round(change, rd)
  }
  if(print_str & perc) {
    change = paste0(as.character(change), " %")
  }
  return(change)
}
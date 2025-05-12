#' ruf

#' @name make_tidy_datetime
#' @param datetime class: POSIXct
#' @param timezone class: string
#' @import tidyverse
#' @examples
#' make_tidy_datetime(datetime=NA, timezone="UTC")
#' @export
make_tidy_datetime <- function(datetime=Sys.time(), timezone="UTC") {
	dt <- as.POSIXlt(datetime, timezone, "%Y_%m_%dT%H_%M_%S") %>% ruf::make_tidy_colnames()
	return(dt)
}
#' ruf

#' @name read_append_filename
#' @param filename class: string
#' @param verbose class: boolean
#' @import tidyverse
#' @examples
#' read_append_filename(filename, verbose=F)
#' @export
read_append_filename <- function(filename, verbose=F) {
  if(file.info(filename)$size > 0) {
    if(verbose){print("====START====");print(filename)}
    temp_df <- read_delim(filename, 
                          "\t", escape_double = FALSE, trim_ws = TRUE, col_types = cols())
    temp_df$filename <- filename
    if(verbose){print("=====END=====")}
  } else {
    if(verbose){print("====START====");print(filename)}
    if(verbose){print("=====END=====")}
  }
  return(temp_df)
}
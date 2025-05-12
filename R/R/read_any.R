#' ruf
#' @name read_any
#' @export
#' @param filepath class: string
#' @import tidyverse
#' @import foreign
#' @import haven
#' @import readr
#' @examples
#' read_any ("C:/filepath.csv")
read_any <- function(filepath,na=na,delim="|") {
  if(get_file_ext(filepath) == "csv"){
    df <- readr::read_csv(filepath)
  } else{
    if(get_file_ext(filepath) == "sav"){
      df <- foreign::read_spss(filepath)
    } else {
      if(get_file_ext(filepath) == "sas7bdat"){
        df <- haven::read_sas(filepath)
      } else{
        if(get_file_ext(filepath) == "txt"){
          df <- readr::read_delim(filepath, delim, escape_double = FALSE, trim_ws = TRUE, na = na)
        } 
      }
    }
  }
  return(df)
}
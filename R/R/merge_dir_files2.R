#' ruf

#' @name merge_dir_files2
#' @param mypath class: string
#' @param pattern class: string
#' @param recursive class: boolean
#' @param return_list class: boolean
#' @import tidyverse
#' @examples
#' merge_dir_files2(mypath, pattern, recursive=T, return_list = T)
#' @export
merge_dir_files2 = function(mypath, pattern, recursive=T, return_list = T){
  filenames = list.files(path = mypath, pattern = pattern, full.names = TRUE, recursive = recursive)
  datalist = lapply(filenames, function(x){ruf::read_append_filename_csv(filename=x)})
  if(return_list == F) {
    Reduce(function(x,y) {bind_rows(x,y)}, datalist)
  }
}
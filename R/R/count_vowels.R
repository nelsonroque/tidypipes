#' ruf
#' @name count_vowels
#' @export
#' @param str class: string
#' @import stringr
#' @examples
#' count_vowels(str)
count_vowels <- function(str) {
  dtv <- ruf::is_data_tag_valid(str, tag_name="consonant_vowel_string", tag_value=T)
  if(dtv) {
    stringr::str_count(str, "V")
  }
}

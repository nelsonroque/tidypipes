#' ruf
#' @name str_to_cons_vowel
#' @export
#' @param str class: string
#' @examples
#' str_to_cons_vowel(str)
str_to_cons_vowel <- function(str) {
  str_step1 <- gsub("[^aeiouAEIOU]","C", str)
  str_step2 <- gsub("[^C]","V",str_step1)
  str_step3 <- ruf::add_data_tag(str_step2, tag_name = "consonant_vowel_string", tag_value = T)
  return(str_step3)
}
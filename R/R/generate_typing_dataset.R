#' ruf

#' @name generate_typing_dataset
#' @param start_ts class: numeric
#' @param start_ts_offset  class: numeric
#' @param stream_length  class: numeric
#' @param rand_seed  class: numeric
#' @keywords data processing
#' @import tidyverse
#' @examples
#' generate_typing_dataset(start_ts = 1563937206, start_ts_offset=1000, stream_length=100, rand_seed = 999)
#' @export
generate_typing_dataset <- function(start_ts = 1563937206, start_ts_offset=1000, stream_length=100, rand_seed = 999) {
  # for rep
  set.seed(rand_seed)
  
  # create vector of keyboard elements
  symbs <- c("@","#", "$", "%", "^", "&", "*", "<", ">","-","+")
  punct <- c("<backspace>", "!", "(", ")", ",", "'", "?", ":", ";", "."," ")
  numbers <- seq(0,9,1)
  possible_stream_opts <- c(letters, LETTERS, numbers, symbs, punct)
  
  # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  
  # setup data interval
  start_time = start_ts
  end_time = start_time + (start_ts_offset - 1)
  
  # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  
  # generate 1000 timestamps
  full_time_stream <- data.frame(ts = seq(start_time, end_time, 1))
  
  # organize into ordered stream
  arranged_stream <-  tibble::tibble(ts = sample(full_time_stream$ts, stream_length, replace=T))
  
  # might interject code here to make more sensical sequences
  
  # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  
  # generate a 'typed' key for each keypress
  typed_stream <- arranged_stream %>%
    arrange(ts) %>%
    mutate(keypress = row_number(),
           interkey_diff = lead(ts,1) - ts) %>%
    rowwise() %>%
    mutate(tk = sample(possible_stream_opts, 1)) %>%
    mutate(is_lowercase = tk %in% letters,
           is_uppercase = tk %in% LETTERS,
           is_num = tk %in% numbers,
           is_symbol = tk %in% symbs,
           is_punctuation = tk %in% punct) %>%
    mutate(char_type = ifelse(is_lowercase, "letter_lower", 
                              ifelse(is_uppercase, "letter_upper",
                                     ifelse(is_num, "number",
                                            ifelse(is_symbol, "symbol",
                                                   ifelse(is_punctuation, "punctuation")))))) %>%
    mutate(char_type = as.character(char_type)) %>%
    ungroup() %>%
    mutate(char_type_last = dplyr::lag(char_type, 1)) %>%
    mutate(transition_type = paste0(char_type_last,"**",char_type))
  
  return(typed_stream)
}

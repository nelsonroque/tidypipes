#' ruf

#' @name get_googlescholar_yearly_article_count
#' @param search_term class: string
#' @param search_years class: vector
#' @param sleep_times class: Vector
#' @param search_language class: string
#' @import tidyverse
#' @import rvest
#' @examples
#' get_googlescholar_yearly_article_count(search_term, search_years, sleep_times, search_language="en")
#' @export
get_googlescholar_yearly_article_count <- function(search_term, search_years, sleep_times, search_language="en") {
  results <- tibble::tibble()
  for(search_year in search_years) {
    for(search_term in search_terms) {
      rand_sleep <- sample(sleep_times$sleep_times, size=1)
      print(paste0("Searching: ", search_term, " | Year: ", search_year, " | To keep robots happy, will sleep for ", rand_sleep, " second(s). ######################"))
      
      search_url <- paste0("https://scholar.google.com/scholar?q=", search_term, "&hl=", search_language, "&as_sdt=0%2C39&as_ylo=", search_year, "&as_yhi=", search_year)
      result <- html(search_url)
      
      result_c <- result %>%
        html_nodes(".gs_ab_mdw") %>%
        html_text()
      
      result_c2 <- gsub(",", "", unlist(strsplit(result_c[2][1], " "))[2])
      
      result_tib <- tibble::tibble(search_year = search_year, 
                                   search_term = search_term, 
                                   search_url = search_url,
                                   n_results = as.numeric(result_c2), 
                                   sleep_time = rand_sleep)
      
      results <- bind_rows(results, result_tib)
      
      Sys.sleep(rand_sleep)
    }
  }
  return(results)
} 
#' ruf

#' @name plot_googlescholar_citation_trend
#' @param results class: tibble
#' @param color class: string
#' @param size class: numeric
#' @param angle  class: numeric
#' @import tidyverse
#' @examples
#' plot_googlescholar_citation_trend(results, color="#0077ff", size=6, angle=45)
#' @export
plot_googlescholar_citation_trend <- function(results, color="#0077ff", size=6, angle=45) {
  ctp <- ggplot(results, aes(search_year, n_results)) + 
    geom_point(color=color, size=size) +
    geom_line() +
    theme_minimal(base_size = 20) +
    theme(axis.text.x = element_text(angle=angle)) +
    ggtitle(results$search_term[1]) +
    xlab("Result Count") +
    ylab("Year")
  
  return(ctp)
}
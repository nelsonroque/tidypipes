#' ruf

#' @name add_harmonization_columns
#' @param harmonization_table class: tibble
#' @param stacked_dataset class: tibble
#' @import tidyverse
#' @export
add_harmonization_columns <- function(harmonization_table, stacked_dataset) {

  # count and echo number of datasets in stacked data
  n_datasets = harmonization_table %>% select(contains("id_")) %>% ncol(.)
  print(n_datasets)
  
  # create dataset copy (for later comparison)
  data_algop = stacked_dataset
  for(i in 1:nrow(harmonization_table)) {
    # extract current new variable for processing ----
    cur_harmo = harmonization_table[i,]
    cur_colname = cur_harmo$new_var
    
    # get respective column names in each dataset ----
    cur_coalesce_group = cur_harmo %>% select(contains("id_"))
    cur_coalesce_group_str = unlist(cur_coalesce_group, use.names = F)
    print(paste0("Attempting creation of new column: ", cur_colname))
    print("--------------------------------------")

    # create new column ----
    data_algop = data_algop %>% mutate(!!cur_colname := coalesce(!!!syms(cur_coalesce_group_str)))
  }
  
  if(nrow(data_algop) == nrow(stacked_dataset)) {
    print("Harmonization Check #1 -- Success -- nrows match after harmonization")
  }
  
  return(data_algop)
}


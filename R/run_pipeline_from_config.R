#' Run Pipeline from Configuration File
#'
#' This function reads a configuration file and runs the specified pipeline steps.
#'
#' @param config_file A character string specifying the path to the configuration file. Defaults to "config.json".
#' @return A tibble containing the results of each pipeline step.
#' @examples
#' \dontrun{
#' run_pipeline_from_config("path/to/config.json")
#' }
#' @export
run_pipeline_from_config <- function(config_file = "config.json") {
  config <- tidypipes::read_data_file(config_file)

  step_results <- purrr::map_df(config$steps, function(step) {
    step_status <- run_pipeline_step(step = step,
                                     pipeline_path = config$pipeline_path,
                                     config = config)
    step_status %>% dplyr::mutate(step = step)
  })

  return(step_results)
}


run_pipeline_from_config <- function(config_file = "config.json") {
  config = tidypipes::read_data_file(config_file)

  step_results = tibble::tibble()
  for(step in config$steps) {
    step_status = run_pipeline_step(step=step,
                                    pipeline_path = config$pipeline_path,
                                    config = config)
    step_results <- bind_rows(step_results, step_status %>% mutate(step))
  }
  return(step_results)
}

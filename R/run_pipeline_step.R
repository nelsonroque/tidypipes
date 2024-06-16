#' Run pipeline step with validation
#'
#' This function runs a specified pipeline step script located in a given pipeline path
#' after performing a series of validation checks. It logs the start, completion, and
#' elapsed time of the step execution. Additionally, it can handle different time zones.
#'
#' @param step The pipeline step script to run. Should not be NA.
#' @param pipeline_path The path to the pipeline scripts, with a trailing slash.
#'
#' @return Integer 1 for success and 0 for failure.
#' @export
#'
#' @examples
#' run_pipeline_step(step = "step1.R", pipeline_path = "pipeline/")
run_pipeline_step <- function(
    step = NA,
    pipeline_path = "pipeline/",
    config = NA
) {

  # if(!is.na(config)) {
  #   CONSTANTS = config$constants
  # } else {
  #   CONSTANTS = NA
  # }

  ### get available scripts
  pipeline_avail_scripts = list.files(path = pipeline_path)

  ### Set logging vars ----
  process_id = digest::digest(Sys.time())

  # Print the log message to the console
  log_msg <- paste(Sys.time(),
                   process_id,
                   "INIT",
                   "Initiating pipeline step handling",
                   sep = " - "
  )
  cli::cli_h1(glue::glue("[PIPELINE STEP STARTED] Step: {step}"))
  cli::cli_alert_info(log_msg)

  ### VALIDATE PIPELINE SCRIPTS -----
  #### CHECK 1: does pipeline path have trailing slash? ----
  is_pipeline_path_invalid1 = "/" != stringr::str_sub(
    pipeline_path, -1, -1
  )
  if(is_pipeline_path_invalid1) {
    stop("Oops, `pipeline_path` missing trailing slash.")
  }

  #### CHECK 2: step is not NA ----
  is_pipeline_path_invalid2 = is.na(step)
  if(is_pipeline_path_invalid2) {
    stop("Oops, `step` is missing.")
  }

  #### CHECK 3: is pipeline step a valid script in the `pipeline_path`? ----
  is_pipeline_path_invalid3 = step %in% pipeline_avail_scripts
  if(!is_pipeline_path_invalid3) {
    stop("Oops, `step` not a valid script in the `pipeline_path`.")
  }

  #### run pipeline step and log before/after/elapsed time -----
  tm1 <- proc.time()
  start_time = Sys.time()
  log_step(ts=Sys.time(),
           process_id = process_id,
           status = "INIT",
           msg = paste0("step: ", step))

  result <- tryCatch({
    source(paste0(pipeline_path,step))
    tm2 <- proc.time()
    log_step(ts=Sys.time(),
             process_id = process_id,
             status = "COMPLETE",
             msg = paste0("step: ", step))

    #### calculate elapsed run time
    elapsed = tm2 - tm1
    elapsed_secs = as.numeric(elapsed[3][[1]])
    end_time = Sys.time()
    log_step(ts=Sys.time(),
             process_id = process_id,
             status = "ELAPSED",
             msg = paste0(elapsed_secs, " seconds."))
    step_metadata = tibble::tibble(
      process_id = process_id,
      step = step,
      step_result = 1,
      start_proc_time = tm1[[1]],
      end_proc_time = tm2[[1]],
      start_clock_time = start_time,
      end_clock_time = end_time,
      elapsed_secs = elapsed_secs[[1]],
      errors = NA
    ) %>% t_tibble(.)

    cli::cli_h1(glue::glue("[PIPELINE STEP COMPLETED] Step: {step}"))

    return(step_metadata)  # Success
  }, error = function(e) {

    tm2 = proc.time()
    elapsed = tm2 - tm1
    elapsed_secs = as.numeric(elapsed[3][[1]])
    end_time = Sys.time()
    log_step(ts=Sys.time(),
             process_id = process_id,
             status = "ERROR",
             msg = paste0("step: ", step, " error: ", e$message))
    step_metadata = tibble::tibble(
      process_id = process_id,
      step = step,
      step_result = 0,
      start_proc_time = tm1[[1]],
      end_proc_time = tm2[[1]],
      start_clock_time = start_time,
      end_clock_time = end_time,
      elapsed_secs = elapsed_secs[[1]],
      errors = e$message
    ) %>% t_tibble(.)
    return(step_metadata)  # Failure
  })

  return(result)
}

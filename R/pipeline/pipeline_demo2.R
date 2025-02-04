library(visNetwork)
library(igraph)

library(magrittr)
library(jsonlite)
library(purrr)
library(tibble)
library(future)
library(furrr)
library(dplyr)

# Run a single pipeline step ----
execute_pipeline_step <- function(step, pipeline_path, process_id) {
  log_step(ts = Sys.time(), process_id = process_id, status = "INIT", msg = paste("Step:", step$id))

  attempt <- 0
  result <- NULL

  while (attempt < step$retries) {
    attempt <- attempt + 1
    start_time <- Sys.time()

    result <- tryCatch({
      source(file.path(pipeline_path, step$script), local = TRUE)

      elapsed_secs <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

      log_step(ts = Sys.time(), process_id = process_id, status = "COMPLETE", msg = paste("Step:", step$id))

      tibble::tibble(
        process_id = process_id,
        step = step$id,
        step_result = 1,
        start_clock_time = start_time,
        end_clock_time = Sys.time(),
        elapsed_secs = elapsed_secs,
        errors = NA
      )
    }, error = function(e) {
      log_step(ts = Sys.time(), process_id = process_id, status = "ERROR", msg = paste("Step:", step$id, "Error:", e$message))

      if (attempt >= step$retries) {
        return(tibble::tibble(
          process_id = process_id,
          step = step$id,
          step_result = 0,
          start_clock_time = start_time,
          end_clock_time = Sys.time(),
          elapsed_secs = NA,
          errors = e$message
        ))
      }
      NULL
    })

    if (!is.null(result)) break  # Exit loop if success
  }

  return(result)
}

# Run full pipeline with dependencies ----
run_pipeline_from_config <- function(config_file = "config.json") {
  config <- fromJSON(config_file)
  process_id <- digest::digest(Sys.time())

  step_dict <- setNames(config$steps, sapply(config$steps, function(x) x$id))

  results <- list()

  execute_step <- function(step_id) {
    step <- step_dict[[step_id]]

    # Wait for dependencies
    if (length(step$depends_on) > 0) {
      lapply(step$depends_on, function(dep) {
        while (!exists(dep, envir = .GlobalEnv)) {
          Sys.sleep(0.5)  # Wait for dependency to complete
        }
      })
    }

    result <- execute_pipeline_step(step, config$pipeline_path, process_id)
    assign(step_id, result, envir = .GlobalEnv)  # Store step result globally
    return(result)
  }

  # Run steps with parallel processing
  plan(multisession)
  step_results <- future_map(config$steps, ~ execute_step(.x$id))

  results <- bind_rows(step_results)
  return(results)
}

library(visNetwork)
library(igraph)
library(jsonlite)
library(tibble)
library(purrr)

visualize_pipeline_interactive <- function(config_file) {
  # Load JSON safely
  config <- tryCatch(
    fromJSON(config_file),
    error = function(e) {
      stop("Error reading JSON file: ", e$message)
    }
  )

  # Check if steps exist
  if (!"steps" %in% names(config)) stop("No steps found in JSON!")

  # Construct edges for visualization
  edges <- purrr::map_df(config$steps, function(step) {
    if (!is.null(step$depends_on) && length(step$depends_on) > 0) {
      tibble::tibble(from = step$depends_on, to = step$id)
    } else {
      tibble::tibble(from = character(0), to = character(0))  # No dependencies
    }
  })

  # Construct node properties
  nodes <- tibble(
    id = sapply(config$steps, function(x) x$id),
    label = sapply(config$steps, function(x) x$id),
    title = sapply(config$steps, function(x) paste(
      x$description, "<br>Retries:", x$retries, "<br>Parallel:", x$parallel
    )),
    shape = "box",
    color = "lightblue"
  )

  # Render interactive graph
  visNetwork(nodes, edges) %>%
    visNodes(shape = "box") %>%
    visEdges(arrows = "to") %>%
    visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
    visPhysics(stabilization = TRUE) %>%
    visLayout(randomSeed = 42)
}

# Run visualization
visualize_pipeline_interactive("R/pipeline/config.json")

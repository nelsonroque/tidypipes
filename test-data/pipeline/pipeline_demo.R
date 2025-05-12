# Load required libraries
library(magrittr)
library(purrr)
library(dplyr)
library(igraph)
library(ggraph)
library(jsonlite)
library(digest)
library(cli)
library(tibble)

library(jsonlite)
json_content <- jsonlite::fromJSON("R/pipeline/config.json")
print(json_content)

file.exists("R/pipeline/config.json")

# Logging function ----
log_step <- function(file = "log.txt", ts = Sys.time(), process_id = NA, status = NA, msg = NA) {
  if (is.na(process_id)) {
    process_id <- digest::digest(ts)
  }

  system_info <- Sys.info()
  log_entry <- list(
    timestamp = ts,
    process_id = process_id,
    system_name = system_info["sysname"],
    system_version = system_info["release"],
    status = status,
    message = msg
  )

  formatted_log <- paste(log_entry$timestamp, log_entry$process_id, log_entry$system_name,
                         log_entry$system_version, log_entry$status, log_entry$message, sep = " - ")

  cli::cli_alert_info(formatted_log)
  write(formatted_log, file = file, append = TRUE)
}

# Run a single pipeline step ----
execute_pipeline_step <- function(step, pipeline_path, process_id) {
  log_step(ts = Sys.time(), process_id = process_id, status = "INIT", msg = paste("Step:", step))

  tm1 <- proc.time()
  start_time <- Sys.time()

  result <- tryCatch({
    source(file.path(pipeline_path, step))

    tm2 <- proc.time()
    elapsed_secs <- as.numeric(tm2[3] - tm1[3])

    log_step(ts = Sys.time(), process_id = process_id, status = "COMPLETE", msg = paste("Step:", step))
    log_step(ts = Sys.time(), process_id = process_id, status = "ELAPSED", msg = paste(elapsed_secs, "seconds"))

    tibble::tibble(
      process_id = process_id,
      step = step,
      step_result = 1,
      start_clock_time = start_time,
      end_clock_time = Sys.time(),
      elapsed_secs = elapsed_secs,
      errors = NA
    )
  }, error = function(e) {
    tm2 <- proc.time()
    elapsed_secs <- as.numeric(tm2[3] - tm1[3])

    log_step(ts = Sys.time(), process_id = process_id, status = "ERROR", msg = paste("Step:", step, "Error:", e$message))

    tibble::tibble(
      process_id = process_id,
      step = step,
      step_result = 0,
      start_clock_time = start_time,
      end_clock_time = Sys.time(),
      elapsed_secs = elapsed_secs,
      errors = e$message
    )
  })

  return(result)
}

# Run full pipeline from config ----
run_pipeline_from_config <- function(config_file = "config.json") {
  config <- jsonlite::fromJSON(config_file)

  process_id <- digest::digest(Sys.time())

  step_results <- config$steps %>%
    map_df(~ execute_pipeline_step(.x, config$pipeline_path, process_id))

  return(step_results)
}

visualize_pipeline <- function(config_file = "config.json") {
  library(jsonlite)
  library(tibble)
  library(igraph)
  library(ggraph)

  # Load pipeline configuration
  config <- fromJSON(config_file)

  # Create step relationships for visualization (including loops)
  edges <- tibble(
    from = config$steps[-length(config$steps)],  # All but last step
    to = config$steps[-1]  # All but first step
  )

  # Create a directed graph (supports loops)
  graph <- graph_from_data_frame(edges, directed = TRUE)

  # Plot using circular layout (good for loops)
  ggraph(graph, layout = "kk") +  # Alternatives: "circle", "stress", "fr"
    geom_edge_link(aes(start_cap = label_rect(node1.name),
                       end_cap = label_rect(node2.name)),
                   arrow = arrow(type = "closed", length = unit(5, "pt"))) +
    geom_node_point(size = 6, color = "blue") +
    geom_node_text(aes(label = name), vjust = 1.5, hjust = 0.5, size = 5, color = "black") +
    theme_void() +
    ggtitle("Pipeline Execution Flow (with Loops)")
}


# Run pipeline and visualize ----
# Uncomment these lines to run the pipeline when sourcing this script:
run_pipeline_from_config("R/pipeline/config.json")

visualize_pipeline("R/pipeline/config.json")







library(jsonlite)
library(tibble)
library(igraph)
library(visNetwork)

visualize_pipeline_interactive <- function(config_file = "config.json") {
  # Load pipeline configuration
  config <- fromJSON(config_file)

  # Create step relationships (edges)
  edges <- tibble(
    from = config$steps[-length(config$steps)],
    to = config$steps[-1]
  )

  # Convert to an igraph object
  graph <- graph_from_data_frame(edges, directed = TRUE)

  # Create node data
  nodes <- tibble(
    id = unique(c(edges$from, edges$to)),  # Unique step names
    label = unique(c(edges$from, edges$to)),
    title = paste("Step:", unique(c(edges$from, edges$to))),  # Tooltip on hover
    shape = "box",
    color = "lightblue"
  )

  # Create edge data
  edges_vis <- edges %>%
    mutate(arrows = "to")  # Add arrowheads

  # Render interactive graph
  visNetwork(nodes, edges_vis) %>%
    visNodes(shape = "box") %>%
    visEdges(arrows = "to") %>%
    visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
    visPhysics(stabilization = TRUE) %>%
    visLayout(randomSeed = 42)  # Keep layout stable
}

# Run the visualization
visualize_pipeline_interactive("R/pipeline/config.json")



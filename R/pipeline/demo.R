library(shiny)
library(visNetwork)
library(igraph)
library(jsonlite)
library(tibble)
library(purrr)
library(dplyr)
library(DT)

# Load and parse logs
load_logs <- function(log_file) {
  if (!file.exists(log_file)) {
    warning("Log file not found!")
    return(NULL)
  }

  logs <- readLines(log_file)
  log_data <- tibble::tibble(
    timestamp = character(),
    process_id = character(),
    system_name = character(),
    system_version = character(),
    status = character(),
    message = character()
  )

  for (log in logs) {
    log_parts <- strsplit(log, " - ")[[1]]
    if (length(log_parts) == 6) {
      log_data <- add_row(log_data,
                          timestamp = log_parts[1],
                          process_id = log_parts[2],
                          system_name = log_parts[3],
                          system_version = log_parts[4],
                          status = log_parts[5],
                          message = log_parts[6])
    }
  }
  return(log_data)
}

# Load pipeline configuration and build DAG
load_pipeline <- function(config_file, log_file) {
  config <- jsonlite::fromJSON(config_file)
  log_data <- load_logs(log_file)

  edges <- purrr::map_df(config$steps, function(step) {
    if (!is.null(step$depends_on) && length(step$depends_on) > 0) {
      tibble::tibble(from = step$depends_on, to = step$id)
    } else {
      tibble::tibble(from = character(0), to = character(0))
    }
  })

  get_status <- function(step_id) {
    step_logs <- log_data %>% filter(grepl(step_id, message))
    if (nrow(step_logs) == 0) return("Pending")
    if (any(step_logs$status == "ERROR")) return("Error")
    return("Success")
  }

  status_colors <- list("Pending" = "gray", "Success" = "green", "Error" = "red")

  nodes <- tibble(
    id = sapply(config$steps, function(x) x$id),
    label = sapply(config$steps, function(x) x$id),
    title = sapply(config$steps, function(x) {
      step_logs <- log_data %>% filter(grepl(x$id, message))
      if (nrow(step_logs) == 0) return(paste(x$description, "<br>Status: Pending"))
      log_text <- paste("<br>Log:", paste(step_logs$message, collapse = "<br>"))
      return(paste(x$description, "<br>Status:", get_status(x$id), log_text))
    }),
    shape = "box",
    color = sapply(sapply(config$steps, function(x) get_status(x$id)), function(status) status_colors[[status]])
  )

  return(list(nodes = nodes, edges = edges, logs = log_data))
}

# Define UI
ui <- fluidPage(
  titlePanel("Pipeline Execution Viewer"),
  sidebarLayout(
    sidebarPanel(
      fileInput("config_file", "Upload Config JSON", accept = c(".json")),
      fileInput("log_file", "Upload Log File", accept = c(".txt")),
      actionButton("load_pipeline", "Load Pipeline"),
      hr(),
      h4("Selected Step Logs:"),
      DTOutput("log_table")
    ),
    mainPanel(
      visNetworkOutput("pipeline_graph", height = "600px")
    )
  )
)

# Define Server Logic
server <- function(input, output, session) {
  pipeline_data <- reactiveVal(NULL)

  observeEvent(input$load_pipeline, {
    req(input$config_file, input$log_file)

    config_path <- input$config_file$datapath
    log_path <- input$log_file$datapath

    pipeline_data(load_pipeline(config_path, log_path))
  })

  output$pipeline_graph <- renderVisNetwork({
    req(pipeline_data())

    visNetwork(pipeline_data()$nodes, pipeline_data()$edges) %>%
      visNodes(shape = "box") %>%
      visEdges(arrows = "to") %>%
      visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
      visPhysics(stabilization = TRUE) %>%
      visLayout(randomSeed = 42)
  })

  output$log_table <- renderDT({
    req(pipeline_data())
    selected_node <- input$pipeline_graph_selected
    if (is.null(selected_node)) return(NULL)

    pipeline_data()$logs %>%
      filter(grepl(selected_node, message)) %>%
      select(timestamp, status, message) %>%
      datatable(options = list(pageLength = 5))
  })
}

# Run the app
shinyApp(ui, server)

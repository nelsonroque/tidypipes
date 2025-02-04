#' Codebook Generator Module
#'
#' This module provides a Shiny UI and server logic to generate a codebook from a CSV file.
#'
#' @param id A unique module identifier.
#'
#' @return A Shiny module for uploading a CSV, viewing/editing a codebook, and downloading the result.
#' @importFrom shiny NS fluidPage sidebarLayout sidebarPanel fileInput br downloadButton mainPanel DTOutput
#' @importFrom shiny moduleServer reactiveVal observeEvent renderDT datatable downloadHandler
#' @importFrom readr read_csv write_csv
#' @importFrom DT renderDT datatable
#' @importFrom glue glue
#' @importFrom dplyr mutate
#' @export
codebookUI <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Dataset Codebook Generator"),
    sidebarLayout(
      sidebarPanel(
        fileInput(ns("file"), "Choose CSV File",
                  multiple = FALSE,
                  accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
        br(),
        downloadButton(ns("downloadData"), "Download Codebook")
      ),
      mainPanel(
        DTOutput(ns("codebook_table"))
      )
    )
  )
}

#' Codebook Generator Server Module
#'
#' @param id A unique module identifier.
#' @export
codebookServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    codebook_data <- reactiveVal()

    observeEvent(input$file, {
      req(input$file)
      df <- read_csv(input$file$datapath)

      variable_names <- data.frame(
        Variable = names(df),
        Question = "INSERT QUESTION",
        Responses = "INSERT RESPONSES",
        Description = sapply(df, function(x) paste0(class(x), collapse = ", "))
      )

      codebook_data(variable_names)
    })

    output$codebook_table <- renderDT({
      req(codebook_data())
      datatable(codebook_data(),
                editable = TRUE,
                options = list(
                  pageLength = 25,
                  lengthMenu = c(10, 25, 50, 100)
                ))
    })

    observeEvent(input$codebook_table_cell_edit, {
      info <- input$codebook_table_cell_edit
      updated_data <- codebook_data()
      updated_data[info$row, info$col] <- info$value
      codebook_data(updated_data)
    })

    output$downloadData <- downloadHandler(
      filename = function() {
        paste0("codebook_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".csv")
      },
      content = function(file) {
        write_csv(codebook_data(), file)
      }
    )
  })
}

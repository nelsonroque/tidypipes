#' Codebook Generator UI Module
#'
#' This module provides a Shiny UI for uploading a CSV file,
#' viewing/editing a codebook, and downloading the result.
#'
#' @param id A unique module identifier.
#'
#' @return A Shiny UI module for generating a codebook.
#' @importFrom shiny NS fluidPage sidebarLayout sidebarPanel fileInput br downloadButton mainPanel DTOutput titlePanel
#' @export
open_codebook_creator <- function(id) {
  ns <- NS(id)

  fluidPage(
    titlePanel("Dataset Codebook Generator"),
    sidebarLayout(
      sidebarPanel(
        fileInput(ns("file_input"), "Choose CSV File",
                  multiple = FALSE,
                  accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
        br(),
        downloadButton(ns("download_codebook"), "Download Codebook")
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
#' @importFrom shiny moduleServer reactive observeEvent renderDT downloadHandler
#' @importFrom readr read_csv write_csv
#' @importFrom DT datatable
#' @importFrom dplyr mutate
codebook_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    codebook_data <- reactiveVal(NULL)

    # Observe file input and process CSV
    observeEvent(input$file_input, {
      req(input$file_input)

      # Read CSV
      df <- tryCatch(
        read_csv(input$file_input$datapath),
        error = function(e) {
          showNotification("Error reading CSV file", type = "error")
          return(NULL)
        }
      )

      req(df)  # Ensure file was successfully read

      # Generate initial codebook
      initial_codebook <- data.frame(
        variable = names(df),
        question = "INSERT QUESTION",
        responses = "INSERT RESPONSES",
        description = sapply(df, function(x) paste0(class(x), collapse = ", ")),
        stringsAsFactors = FALSE
      )

      codebook_data(initial_codebook)
    })

    # Render the codebook table (editable)
    output$codebook_table <- renderDT({
      req(codebook_data())
      datatable(
        codebook_data(),
        editable = TRUE,
        options = list(
          pageLength = 25,
          lengthMenu = c(10, 25, 50, 100)
        )
      )
    })

    # Update codebook data when user edits the table
    observeEvent(input$codebook_table_cell_edit, {
      info <- input$codebook_table_cell_edit
      updated_data <- codebook_data()
      updated_data[info$row, info$col] <- info$value
      codebook_data(updated_data)
    })

    # Download handler for exporting the codebook
    output$download_codebook <- downloadHandler(
      filename = function() {
        paste0("codebook_", format(Sys.time(), "%Y-%m-%d_%H-%M-%S"), ".csv")
      },
      content = function(file) {
        write_csv(codebook_data(), file)
      }
    )
  })
}

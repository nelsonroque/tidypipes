#' Create a Blank Data Analysis Pipeline
#'
#' This function initializes a structured project for a data analysis pipeline,
#' including essential folders (`data`, `plots`, `tidy`, `vignettes`) and README files.
#'
#' @param root_path Character. The root path where the pipeline folder should be created. Default is the current working directory.
#' @param pipeline_folder_name Character. The name of the pipeline folder to be created. Default is "demo-pipeline".
#' @param additional_folders Character vector. Optional additional subfolders to create inside the pipeline.
#' @param verbose Logical. If TRUE, prints messages indicating folder and file creation. Default is TRUE.
#'
#' @return None. The function creates folders and files in the specified location.
#' @import usethis
#' @importFrom glue glue
#' @importFrom fs file_create dir_create
#' @importFrom rstudioapi isAvailable
#' @importFrom rlang is_interactive
#' @examples
#' \dontrun{
#' create_blank_pipeline("~/Desktop", "my_pipeline", additional_folders = c("scripts", "models"))
#' }
#' @export
create_blank_pipeline <- function(root_path = getwd(),
                                  pipeline_folder_name = "demo-pipeline",
                                  additional_folders = NULL,
                                  verbose = TRUE) {

  # Construct pipeline path
  pipeline_path <- file.path(root_path, pipeline_folder_name)

  # Function to create directories safely
  create_dir_safe <- function(path) {
    if (!dir.exists(path)) {
      fs::dir_create(path, mode = "u=rwx,go=rx", recurse = TRUE)
      if (verbose) message("Created directory: ", path)
    }
  }

  # Function to create files safely
  create_file_safe <- function(path) {
    if (!file.exists(path)) {
      fs::file_create(path)
      if (verbose) message("Created file: ", path)
    }
  }

  # Create the project directory
  create_dir_safe(pipeline_path)

  # Initialize as an RStudio project if available
  usethis::create_project(
    path = pipeline_path,
    rstudio = rstudioapi::isAvailable(),
    open = rlang::is_interactive()
  )

  # Define default folders and files
  default_folders <- c("vignettes", "data", "plots", "tidy")
  default_files <- c("README.md", "TODO.md", "NEWS.md")

  # Create default folders
  lapply(file.path(pipeline_path, default_folders), create_dir_safe)

  # Create default files
  lapply(file.path(pipeline_path, default_files), create_file_safe)

  # Add `.gitkeep` files inside each folder to ensure empty folders are tracked
  lapply(file.path(pipeline_path, default_folders, ".gitkeep"), create_file_safe)

  # Create a sample vignette
  create_file_safe(file.path(pipeline_path, "vignettes", "hello.qmd"))

  # Create additional user-specified folders
  if (!is.null(additional_folders)) {
    lapply(file.path(pipeline_path, additional_folders), create_dir_safe)
  }

  message("Project setup complete at: ", pipeline_path)
}

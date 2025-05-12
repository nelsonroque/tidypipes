#' @section pipeline_project
#'
#' @keywords internal

#' Scaffold a Blank Data Analysis Pipeline
#'
#' Creates a directory structure for a new data analysis project with common folders and files.
#'
#' @param root_path Path to the root directory where the pipeline will be created. Default is current working directory.
#' @param pipeline_folder_name Name of the pipeline folder. Default is \"demo-pipeline\".
#' @param additional_folders Optional character vector of additional subfolders.
#' @param verbose Logical. If TRUE, prints status messages. Default is TRUE.
#'
#' @return None. Creates directories and files on disk.
#' @export
scaffold_pipeline_project <- function(root_path = getwd(),
                                      pipeline_folder_name = "pipeline",
                                      additional_folders = NULL,
                                      verbose = TRUE) {
  pipeline_path <- file.path(root_path, pipeline_folder_name)

  create_dir_safe <- function(path) {
    if (!dir.exists(path)) {
      fs::dir_create(path, recurse = TRUE)
      if (verbose) message("Created directory: ", path)
    }
  }

  create_file_safe <- function(path) {
    if (!file.exists(path)) {
      fs::file_create(path)
      if (verbose) message("Created file: ", path)
    }
  }

  create_dir_safe(pipeline_path)

  usethis::create_project(
    path = pipeline_path,
    rstudio = rstudioapi::isAvailable(),
    open = rlang::is_interactive()
  )

  default_folders <- c("vignettes", "data", "plots", "tidy")
  default_files <- c("README.md", "TODO.md", "NEWS.md")

  lapply(file.path(pipeline_path, default_folders), create_dir_safe)
  lapply(file.path(pipeline_path, default_files), create_file_safe)
  lapply(file.path(pipeline_path, default_folders, ".gitkeep"), create_file_safe)
  create_file_safe(file.path(pipeline_path, "vignettes", "hello.qmd"))

  if (!is.null(additional_folders)) {
    lapply(file.path(pipeline_path, additional_folders), create_dir_safe)
  }

  message("Project scaffolded at: ", pipeline_path)
}

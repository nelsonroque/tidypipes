#' Create a Blank Data Analysis Pipeline
#'
#' This function creates a new project structure for a data analysis pipeline, including
#' folders for data, plots, and tidy data, as well as README and TODO files.
#'
#' @param root_path Character. The root path where the pipeline folder should be created. Default is an empty string.
#' @param pipeline_folder_name Character. The name of the pipeline folder to be created. Default is "demo-pipeline".
#' @return None. The function creates folders and files in the specified location.
#' @import usethis
#' @importFrom glue glue
#' @importFrom fs file_create dir_create
#' @importFrom rstudioapi isAvailable
#' @importFrom rlang is_interactive
#' @examples
#' \dontrun{
#' create_blank_pipeline("~/Desktop", "my_pipeline")
#' }
create_blank_pipeline <- function(root_path = "", pipeline_folder_name = "demo-pipeline") {

  # create path -----
  pp = glue::glue("{root_path}/{pipeline_folder_name}")

  # create project -----
  usethis::create_project(
    pp,
    rstudio = rstudioapi::isAvailable(),
    open = rlang::is_interactive()
  )

  # create documentation files ----
  fs::file_create(glue::glue("{pp}/readme.md"),
                  mode = "u=rw,go=r")

  fs::file_create(glue::glue("{pp}/todo.md"),
                  mode = "u=rw,go=r")

  # create `data` folder ----
  fs::dir_create(glue::glue("{pp}/data"),
                 mode = "u=rwx,go=rx",
                 recurse = TRUE)

  fs::file_create(glue::glue("{pp}/data/.gitkeep"),
                  mode = "u=rw,go=r")

  # create `plots` folder ----
  fs::dir_create(glue::glue("{pp}/plots"),
                 mode = "u=rwx,go=rx",
                 recurse = TRUE)

  fs::file_create(glue::glue("{pp}/plots/.gitkeep"),
                  mode = "u=rw,go=r")

  # create `tidy` folder ----
  fs::dir_create(glue::glue("{pp}/tidy"),
                 mode = "u=rwx,go=rx",
                 recurse = TRUE)

  fs::file_create(glue::glue("{pp}/tidy/.gitkeep"),
                  mode = "u=rw,go=r")

}

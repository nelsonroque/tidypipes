#' @section reporting_system
#'
#' @keywords internal


#' Generate Environment Report
#'
#' Collects system environment metadata and optionally writes to file.
#'
#' @param output_dir Output directory. Default is NULL (no file).
#' @param format File format: "csv" (default) or "txt".
#'
#' @return A tibble of system environment values.
#' @export
get_env_report <- function(output_dir = NULL, format = "csv") {
  info <- Sys.info()

  report <- tibble::tibble(
    r_version = R.version.string,
    sys_date = Sys.Date(),
    sys_time = Sys.time(),
    sys_timezone = Sys.timezone(),
    sys_pid = Sys.getpid(),
    sys_locale = Sys.getlocale(),
    sys_memory_mb = round(as.numeric(utils::memory.size()) / 1024, 2),
    sys_cpu_cores = parallel::detectCores(),
    sys_info_os = info["sysname"],
    sys_info_release = info["release"],
    sys_info_user = info["user"]
  ) %>%
    dplyr::mutate(dplyr::across(everything(), as.character)) %>%
    tidyr::pivot_longer(cols = everything(), names_to = "key", values_to = "value")

  if (!is.null(output_dir)) {
    if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
    path <- file.path(output_dir, paste0("environment_report_", get_timestamp(), ".", format))
    if (format == "csv") {
      readr::write_csv(report, path)
    } else {
      writeLines(capture.output(print(report)), path)
    }
    message("Environment report saved to: ", path)
  }

  return(report)
}

#' Generate TODO Comment Report
#'
#' Searches for TODOs and optionally exports them.
#'
#' @param output_dir Output directory. Default is current dir.
#' @param format File format: "txt" (default) or "csv".
#'
#' @return A tibble of TODO comments.
#' @export
get_todo_report <- function(output_dir = ".", format = "txt") {
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

  path <- file.path(output_dir, paste0("todo_report_", get_timestamp(), ".", format))
  report <- todor::todor()

  if (format == "txt") {
    writeLines(capture.output(print(report)), path)
  } else {
    readr::write_csv(report, path)
  }

  message("TODO report saved to: ", path)
  return(report)
}

#' Generate Installed Package Report
#'
#' Returns a tibble of installed packages and optionally writes to file.
#'
#' @param exclude_base Logical. If TRUE, filters base packages. Default is TRUE.
#' @param output_dir Output directory. Default is NULL (no export).
#' @param format File format: "csv" (default) or "txt".
#'
#' @return A tibble of package metadata.
#' @export
get_package_report <- function(exclude_base = TRUE, output_dir = NULL, format = "csv") {
  pkgs <- installed.packages() %>%
    as.data.frame() %>%
    janitor::clean_names() %>%
    tibble::as_tibble() %>%
    dplyr::select(package, version, lib_path, priority, depends, imports)

  if (exclude_base) pkgs <- dplyr::filter(pkgs, is.na(priority))
  pkgs <- dplyr::arrange(pkgs, package)

  if (!is.null(output_dir)) {
    if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
    path <- file.path(output_dir, paste0("package_report_", get_timestamp(), ".", format))
    if (format == "csv") {
      readr::write_csv(pkgs, path)
    } else {
      writeLines(capture.output(print(pkgs)), path)
    }
    message("Package report saved to: ", path)
  }

  return(pkgs)
}



#' Generate and Optionally Export All System Reports
#'
#' Safely generates environment, TODO, and package reports with optional export.
#'
#' @param output_dir Directory path for file exports. Default is NULL (no export).
#' @param format Output format: "csv" (default) or "txt".
#'
#' @return A named list of report tibbles or NULL values (on failure).
#' @export
generate_all_reports <- function(output_dir = NULL, format = "csv") {
  safe_generate <- function(report_fun, name) {
    tryCatch(
      report_fun(output_dir = output_dir, format = format),
      error = function(e) {
        message(paste("Error generating", name, ":", e$message))
        NULL
      }
    )
  }

  list(
    env_report = safe_generate(get_env_report, "Environment Report"),
    todo_report = safe_generate(get_todo_report, "TODO Report"),
    package_report = safe_generate(get_package_report, "Package Report")
  )
}

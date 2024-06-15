#' Get Environment Report
#'
#' This function collects and returns a report of the current system environment.
#' The report includes details such as the current date, time, timezone, process ID, locale,
#' and various system information.
#' @importFrom magrittr %>%
#'
#' @return A tibble containing the system environment report.
#' @export
#'
#' @examples
#' # Generate an environment report
#' \dontrun{
#' get_env_report()
#' }
get_env_report <- function() {
  si <- Sys.info()
  env_report <- tibble::tibble(
    r_home = R.home(),
    r_version = R.version.string,
    sys_date = Sys.Date(),
    sys_time = Sys.time(),
    sys_timezone = Sys.timezone(),
    sys_pid = Sys.getpid(),
    sys_locale = Sys.getlocale(),
    sys_info_os = si[[1]][1],
    sys_info_release = si[[2]][1],
    sys_info_version = si[[3]][1],
    sys_info_nodename = si[[4]][1],
    sys_info_machine = si[[5]][1],
    sys_info_login = si[[6]][1],
    sys_info_user = si[[7]][1],
  )
  env_report_final <- env_report %>%
    dplyr::mutate(dplyr::across(everything(), as.character)) %>%
    tibble::rownames_to_column(var = "rowname") %>%
    tidyr::pivot_longer(-rowname, names_to = "key", values_to = "value") %>%
    dplyr::select(-rowname)
  return(env_report_final)
}

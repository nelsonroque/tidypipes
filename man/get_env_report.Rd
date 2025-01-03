% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_env_report.R
\name{get_env_report}
\alias{get_env_report}
\title{Get Environment Report}
\usage{
get_env_report()
}
\value{
A tibble containing the system environment report.
}
\description{
This function collects and returns a report of the current system environment.
The report includes details such as the current date, time, timezone, process ID, locale,
and various system information.
}
\examples{
# Generate an environment report
\dontrun{
get_env_report()
}
}

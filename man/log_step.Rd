% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/log_step.R
\name{log_step}
\alias{log_step}
\title{Log Format for Each Step}
\usage{
log_step(
  file = "log.txt",
  ts = Sys.time(),
  process_id = NA,
  status = NA,
  msg = NA
)
}
\arguments{
\item{file}{A character string specifying the path to the log file. Defaults to "log.txt".}

\item{ts}{A timestamp indicating when the log entry is created. Defaults to the current system time (`Sys.time()`).}

\item{process_id}{A unique identifier for the process. If not provided, a unique ID is generated using the current system time.}

\item{status}{A character string indicating the status of the process step.}

\item{msg}{A character string containing a message about the process step.}
}
\value{
This function does not return a value.
}
\description{
This function logs the details of each step in a process, including a timestamp, process ID, status, and message.
The log is written to a specified file and also printed to the console.
}
\examples{
# Log a step with default settings
log_step(status = "INFO", msg = "Process started")

# Log a step with a specific process ID
log_step(process_id = "12345", status = "ERROR", msg = "An error occurred")
}

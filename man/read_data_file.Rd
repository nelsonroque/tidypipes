% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_write.R
\name{read_data_file}
\alias{read_data_file}
\title{Read Data File}
\usage{
read_data_file(file_path)
}
\arguments{
\item{file_path}{A character string representing the path to the file to be read.}
}
\value{
A data frame or list containing the data from the file.
}
\description{
This function reads a data file based on its extension and returns a data frame or list.
It supports various file formats including CSV, JSON, SAS, Parquet, Excel, Feather, and RDS.
}
\examples{
# Read a CSV file
\dontrun{read_data_file("data.csv")}

# Read a JSON file
\dontrun{read_data_file("data.json")}

# Read a SAS file
\dontrun{read_data_file("data.sas7bdat")}

# Read a Parquet file
\dontrun{read_data_file("data.parquet")}

# Read an Excel file
\dontrun{read_data_file("data.xlsx")}

# Read a Feather file
\dontrun{read_data_file("data.feather")}

# Read an RDS file
\dontrun{read_data_file("data.rds")}
}

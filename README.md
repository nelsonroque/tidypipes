# tidypipes <img src="man/figures/logo.png" align="right" />
An R package to help you simplify data pipelines.

# Overview
A lightweight R package with various vignettes.

## A Dataset Utility Package

A comprehensive R package providing utility functions for dataset analysis and logging. This package includes functions to generate dataset statistics, log process steps, detect TODO comments, and more, all using tidyverse principles.

## Inspired By
https://github.com/easystats
https://github.com/easystats/datawizard

# 🚀 Getting Started | Installation

| Type | Source | Command |
|----|----|----|
| Release | CRAN | `install.packages("tidypipes")` |
| Development | GitHub | `remotes::install_github("nelsonroque/tidypipes")` |

## Known Warnings

```
── R CMD build ──────────────────────────────────────────────────────────────
✔  checking for file ‘/Users/nur375/Documents/GitHub/tidypipes/DESCRIPTION’ ...
─  preparing ‘tidypipes’:
✔  checking DESCRIPTION meta-information
─  checking for LF line-endings in source and make files and shell scripts
─  checking for empty or unneeded directories
   Omitted ‘LazyData’ from DESCRIPTION
─  building ‘tidypipes_0.1.0.tar.gz’
   Warning: invalid uid value replaced by that for user 'nobody'
   Warning: invalid gid value replaced by that for user 'nobody'
```

# Citation

To cite the package, run the following command:

``` r
citation("tidypipes")

[INSERT JOSS INFORMATION HERE :) ]
```

# Features

### Data and pipeline reports

#### `get_todo_report`

Generates a report of all TODO comments detected in the code.

##### Example

- Generate a TODO report.

#### `get_package_report`

Generates a report of the currently installed packages, returning the information as a cleaned tibble.

##### Example

- Generate a report of the installed packages.

#### `get_env_report`

Generates a report of the current system environment.

##### Example

- Generate an environment report.

### Prepare metadata

#### `get_column_info`

Generates a tibble with the column names and data types for all columns in a given dataset.

##### Example

- Create a sample dataset and generate the column names and data types report.

#### `get_dataset_stats`

Generates statistics for a given dataset, including the number of columns, number of rows, number of missing values, column names, and an MD5 hash of the dataset.

##### Example

- Create a sample dataset and generate the dataset statistics.

### Data Transformations

#### `append_date_features`

Appends date-based features to a dataset.

##### Example

- Create a sample dataset and append date features to the dataset.

### Interoperable Data

#### `read_data_file`

Reads a data file based on its extension and returns a data frame or list.

##### Example

- Read a CSV file.
- Read a JSON file.
- Read a SAS file.
- Read a Parquet file.
- Read an Excel file.
- Read a Feather file.
- Read an RDS file.

#### `write_data_file`

Writes a data frame to a file based on the specified extension.

##### Example

- Write a data frame to a CSV file.
- Write a data frame to a JSON file.
- Write a data frame to a Parquet file.
- Write a data frame to an Excel file.
- Write a data frame to a Feather file.
- Write a data frame to an RDS file.

### Utilities

#### `get_fn_ts`

Generates a timestamp suitable for use in filenames.

##### Example

- Generate a cleaned timestamp for the current time.
- Generate a cleaned timestamp for a specific time.

#### `log_step`

Logs the details of each step in a process, including a timestamp, process ID, status, and message.

##### Example

- Log a step with default settings.
- Log a step with a specific process ID.


# Outstanding question

variable vs column_name
file vs filename

# Contributions
📢 Contributions welcome! Feel free to open an issue or submit a pull request. (CODE OF CONDUCT LINK GOES HERE)

Let me know if you want a more detailed roadmap or tweaks! 🚀

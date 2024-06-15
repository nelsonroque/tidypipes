# Install Package:           'Cmd + Shift + B'
# Check Package:             'Cmd + Shift + E'
# Test Package:              'Cmd + Shift + T'

# Load necessary libraries
library(roxygen2)
library(devtools)
library(tidypipes) # Ensure your package 'tidypipes' is loaded if it contains the function `run_pipeline_step`

# Re-document package ------
roxygen2::roxygenise() # Generate documentation using roxygen2

# Optional: You can use devtools::document() as an alternative
# devtools::document()

# Check package for errors, warnings, and notes ------
devtools::check() # Run package checks to ensure everything is working correctly

# Build package -----
devtools::build() # Build the package

# Run tests -----
# e.g., a specific pipeline step -----
tidypipes::run_pipeline_step(step = "test_step.R",
                             pipeline_path = "~/Desktop/pipeline/")

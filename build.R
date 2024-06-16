# Install Package:           'Cmd + Shift + B'
# Check Package:             'Cmd + Shift + E'
# Test Package:              'Cmd + Shift + T'

# Load necessary libraries
library(roxygen2)
library(devtools)

sink("tmp/output_for_chatgpt_debugging.txt", append = F)

# Re-document package ------
roxygen2::roxygenise() # Generate documentation using roxygen2

# Optional: You can use devtools::document() as an alternative
# devtools::document()

# Build vignettes
devtools::build_vignettes()

# Check package for errors, warnings, and notes ------
devtools::check() # Run package checks to ensure everything is working correctly

# Build package -----
devtools::build() # Build the package

sink()

# Load usethis
library(usethis)

# Automatically generate and manage NAMESPACE file
usethis::use_namespace()

# build package ----
devtools::check()
devtools::document()
devtools::build()

# Preview your site locally before publishing ----
pkgdown::build_site()
pkgdown::preview_site()

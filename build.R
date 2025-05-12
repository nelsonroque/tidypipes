#' Build & Document `tidypipes` Package
#' Run this from the project root during dev

# 1. Load core devtools
library(usethis)
library(devtools)
library(pkgdown)

# 2. Refresh NAMESPACE & Rd docs
usethis::use_namespace()
document()   # generates Rd files

# 3. Run package check & build
check()
build()

# 4. Preview documentation site
build_site()
preview_site()


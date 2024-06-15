#   Install Package:           'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'

# re-document package ------
roxygen2::roxygenise()
#devtools::document()

# generate build -----
#devtools::check()
devtools::build()

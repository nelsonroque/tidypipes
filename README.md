# tidypipes <img src="man/figures/baseplot.png" align="right" />
An R package to help you simplify data pipelines.

# Overview
A lightweight R package with various vignettes.

## A Dataset Utility Package

A comprehensive R package providing utility functions for dataset analysis and logging. This package includes functions to generate dataset statistics, log process steps, detect TODO comments, and more, all using tidyverse principles.

## Inspired By

https://github.com/easystats

https://github.com/easystats/datawizard

https://gesistsa.github.io/rio/

https://github.com/Stan125/GREA/

https://gallery.shinyapps.io/rioweb

https://github.com/dreamRs/datamods



# 🚀 Getting Started

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

# Contributions
📢 Contributions welcome! Feel free to open an issue or submit a pull request. (CODE OF CONDUCT LINK GOES HERE)

[Let me know](https://bsky.app/profile/nelsonroque.bsky.social) if you want a more detailed roadmap or tweaks! 🚀

---

## Roadmap Voting
integrate rio: https://gesistsa.github.io/rio/

https://rstudio.github.io/renv/news/index.html
Study changelog format and links to Github issues. Eventually want to be that specific.

---

## Notes
# 5. Launch codebook UI (optional, dev-only)
if (interactive()) {
  ui <- open_codebook_creator("codebook_ui")
  server <- function(input, output, session) {
    codebook_server("codebook_ui")
  }
  shiny::shinyApp(ui, server)
}


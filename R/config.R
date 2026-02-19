`%||%` <- function(x, y) if (is.null(x)) y else x

read_pipeline_config <- function(config_path) {
  if (!fs::file_exists(config_path)) {
    rlang::abort(glue::glue("Config not found: {config_path}"))
  }

  ext <- tolower(fs::path_ext(config_path))

  cfg <- switch(
    ext,
    yml = yaml::read_yaml(config_path),
    yaml = yaml::read_yaml(config_path),
    json = jsonlite::fromJSON(config_path, simplifyVector = FALSE),
    rlang::abort("Config must be .yml, .yaml, or .json")
  )

  validate_pipeline_config(cfg)
}

resolve_params <- function(cfg) {
  params <- cfg$params %||% list()
  env_map <- cfg$params_env %||% list()

  if (length(env_map)) {
    for (k in names(env_map)) {
      env_name <- env_map[[k]]
      v <- Sys.getenv(env_name, unset = "")
      if (nzchar(v)) params[[k]] <- v
    }
  }

  params
}

build_template_context <- function(cfg, run_id = NULL, step = NULL, extra = list()) {
  params <- resolve_params(cfg)
  c(
    params,
    list(
      run_id = run_id,
      date = format(Sys.Date(), "%Y-%m-%d"),
      timestamp = format(Sys.time(), "%Y%m%dT%H%M%S"),
      step_id = if (is.null(step)) NULL else step$id
    ),
    extra
  )
}

render_template <- function(x, context = list()) {
  if (is.null(x)) return(NULL)
  if (is.character(x) && length(x) == 1) {
    return(as.character(glue::glue_data(context, x, .open = "{", .close = "}")))
  }
  if (is.character(x)) {
    return(vapply(x, render_template, context = context, character(1)))
  }
  x
}

validate_pipeline_config <- function(cfg) {
  if (is.null(cfg$name) || !nzchar(cfg$name)) {
    rlang::abort("Pipeline config must include a non-empty `name`.")
  }

  if (is.null(cfg$steps) || !length(cfg$steps)) {
    rlang::abort("Pipeline config must include a non-empty `steps` list.")
  }

  ids <- vapply(cfg$steps, function(x) x$id %||% "", character(1))
  scripts <- vapply(cfg$steps, function(x) x$script %||% "", character(1))

  if (any(ids == "")) rlang::abort("Every step must have `id`.")
  if (any(duplicated(ids))) rlang::abort("Step ids must be unique.")
  if (any(scripts == "")) rlang::abort("Every step must have `script`.")

  for (s in cfg$steps) {
    deps <- s$depends_on %||% character(0)
    unknown <- setdiff(deps, ids)
    if (length(unknown)) {
      rlang::abort(glue::glue("Step `{s$id}` has unknown dependency: {paste(unknown, collapse=', ')}"))
    }

    if (!is.null(s$when) && !is.character(s$when)) {
      rlang::abort(glue::glue("Step `{s$id}` field `when` must be a string expression."))
    }

    outs <- s$outputs %||% character(0)
    if (!is.character(outs)) {
      rlang::abort(glue::glue("Step `{s$id}` outputs must be a character vector of file paths/templates."))
    }
  }

  cfg
}

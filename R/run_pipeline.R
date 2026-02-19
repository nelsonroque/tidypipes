#' Run a local script-first data pipeline
#'
#' @param config_path Path to YAML/JSON pipeline config.
#' @param root_dir Root directory for resolving relative script paths.
#' @param audit_log_path Path to NDJSON audit log file.
#' @param actor Optional actor name; defaults to system user.
#' @param env Environment used to execute step scripts.
#' @param workers Number of parallel workers for independent steps.
#' @param state_path Persistent checkpoint state file.
#' @param resume Whether to resume from previous checkpoint state.
#' @export
run_pipeline <- function(
    config_path,
    root_dir = fs::path_dir(config_path),
    audit_log_path = fs::path(root_dir, "logs", "audit.ndjson"),
    actor = Sys.info()[["user"]],
    env = new.env(parent = globalenv()),
    workers = 1,
    state_path = fs::path(root_dir, "logs", "state.json"),
    resume = FALSE,
    write_reports = TRUE,
    include_base_packages = FALSE) {

  cfg <- read_pipeline_config(config_path)
  run_id <- paste0(format(Sys.time(), "%Y%m%d-%H%M%S"), "-", as.integer(stats::runif(1, 1000, 9999)))
  started_at <- Sys.time()
  report_paths <- NULL

  pipeline_ctx <- build_template_context(cfg, run_id = run_id)
  steps <- order_steps(cfg$steps)

  obs_path <- fs::path(root_dir, "logs", "observability.ndjson")
  state <- if (isTRUE(resume)) load_run_state(state_path) else empty_run_state(cfg$name)

  tp_log("info", "🚰 tidypipes: starting pipeline {.strong {cfg$name}} ({length(steps)} steps, workers={workers})")

  write_audit_event(audit_log_path, list(
    ts = format(started_at, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    run_id = run_id,
    event = "started",
    status = "started",
    emoji = emoji_for_status("started"),
    pipeline = cfg$name,
    actor = actor,
    host = Sys.info()[["nodename"]],
    config_path = normalizePath(config_path, winslash = "/", mustWork = FALSE)
  ))

  write_observability_event(obs_path, list(type = "pipeline_started", run_id = run_id, pipeline = cfg$name, workers = workers))

  step_results <- state$steps %||% list()
  finished_ids <- names(Filter(function(x) identical(x$status, "ok"), step_results))
  pending <- setdiff(vapply(steps, function(x) x$id, character(1)), finished_ids)

  while (length(pending)) {
    ready <- pending[vapply(pending, function(id) {
      st <- step_by_id(steps, id)
      deps <- st$depends_on %||% character(0)
      all(deps %in% names(Filter(function(x) identical(x$status, "ok"), step_results)))
    }, logical(1))]

    if (!length(ready)) {
      rlang::abort("No runnable steps found; pipeline may have unresolved failures or dependency cycle.")
    }

    batch_ids <- head(ready, max(1, workers))
    batch_steps <- lapply(batch_ids, function(id) step_by_id(steps, id))

    if (workers > 1 && length(batch_steps) > 1 && .Platform$OS.type != "windows") {
      res_list <- parallel::mclapply(batch_steps, run_one_step, cfg = cfg, root_dir = root_dir, env = env,
                                     actor = actor, audit_log_path = audit_log_path, run_id = run_id,
                                     pipeline_ctx = pipeline_ctx, mc.cores = min(workers, length(batch_steps)))
      names(res_list) <- batch_ids
    } else {
      res_list <- lapply(batch_steps, run_one_step, cfg = cfg, root_dir = root_dir, env = env,
                         actor = actor, audit_log_path = audit_log_path, run_id = run_id,
                         pipeline_ctx = pipeline_ctx)
      names(res_list) <- batch_ids
    }

    for (sid in names(res_list)) {
      step_results[[sid]] <- res_list[[sid]]
      write_observability_event(obs_path, list(type = "step_completed", run_id = run_id, step_id = sid,
                                               status = res_list[[sid]]$status,
                                               elapsed_sec = res_list[[sid]]$seconds %||% NA_real_,
                                               retries = res_list[[sid]]$retries %||% 0))

      state$steps[[sid]] <- step_results[[sid]]
      state$last_updated <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
      save_run_state(state, state_path)

      if (identical(res_list[[sid]]$status, "failed")) {
        maybe_send_alerts(cfg$alerts, status = "failed", run_id = run_id, pipeline = cfg$name,
                          message = paste("Step failed:", sid, res_list[[sid]]$error %||% "unknown error"))
        html_path <- write_html_summary(
          root_dir, cfg$name, run_id, started_at, Sys.time(), step_results,
          config_path = config_path,
          report_paths = report_paths
        )
        return(list(run_id = run_id, status = "failed", steps = step_results, state_path = state_path, summary_html = html_path))
      }
    }

    pending <- setdiff(pending, batch_ids)
  }

  finished <- Sys.time()
  total <- as.numeric(difftime(finished, started_at, units = "secs"))

  tp_log("success", "🏁 pipeline {.strong {cfg$name}} finished in {round(total, 2)}s")

  if (isTRUE(write_reports)) {
    report_paths <- write_run_reports(
      root_dir = root_dir,
      run_id = run_id,
      include_base_packages = include_base_packages
    )
  }

  html_path <- write_html_summary(
    root_dir, cfg$name, run_id, started_at, finished, step_results,
    config_path = config_path,
    report_paths = report_paths
  )
  maybe_send_alerts(cfg$alerts, status = "success", run_id = run_id, pipeline = cfg$name,
                    message = paste("Pipeline succeeded:", cfg$name, run_id))

  write_audit_event(audit_log_path, list(
    ts = format(finished, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    run_id = run_id,
    event = "finished",
    status = "finished",
    emoji = emoji_for_status("finished"),
    pipeline = cfg$name,
    actor = actor,
    elapsed_sec = total
  ))

  list(
    run_id = run_id,
    status = "success",
    elapsed_sec = total,
    steps = step_results,
    reports = report_paths,
    state_path = state_path,
    summary_html = html_path
  )
}

run_one_step <- function(step, cfg, root_dir, env, actor, audit_log_path, run_id, pipeline_ctx) {
  enabled <- isTRUE(step$enabled %||% TRUE)
  step_id <- step$id
  ctx <- c(pipeline_ctx, list(step_id = step_id), step$params %||% list())
  step_script <- fs::path(root_dir, render_template(step$script, ctx))

  if (!enabled) {
    tp_log("warn", "⏭️ skipping disabled step {.field {step_id}}")
    return(list(status = "skipped", script = step$script))
  }

  if (!is.null(step$when)) {
    cond <- tryCatch(isTRUE(eval(parse(text = step$when), envir = list2env(ctx, parent = env))),
                     error = function(e) FALSE)
    if (!cond) {
      tp_log("info", "🧠 condition FALSE for {.field {step_id}} -> skipped")
      return(list(status = "skipped", script = step$script, reason = "condition_false"))
    }
  }

  if (!fs::file_exists(step_script)) {
    msg <- glue::glue("Step script not found: {step_script}")
    tp_log("error", msg)
    return(list(status = "failed", script = step$script, error = msg))
  }

  retry_cfg <- step$retry %||% list(max_attempts = 1, backoff_seconds = 1)
  max_attempts <- as.integer(retry_cfg$max_attempts %||% 1)
  backoff <- as.numeric(retry_cfg$backoff_seconds %||% 1)

  run_contract(step$contracts$before %||% NULL, root_dir, ctx, "before", step_id)

  attempt <- 1
  repeat {
    tp_log("info", "🧩 running step {.field {step_id}} attempt {attempt}/{max_attempts}")
    step_started <- Sys.time()
    res <- tryCatch({
      source(step_script, local = env)
      list(ok = TRUE, error = NULL)
    }, error = function(e) {
      list(ok = FALSE, error = conditionMessage(e))
    })

    elapsed <- as.numeric(difftime(Sys.time(), step_started, units = "secs"))

    if (isTRUE(res$ok)) {
      run_contract(step$contracts$after %||% NULL, root_dir, ctx, "after", step_id)
      outputs <- render_template(step$outputs %||% character(0), ctx)
      lineage <- stamp_datasets(paths = outputs, root_dir = root_dir, run_id = run_id, actor = actor,
                                logical_name = step$dataset_name %||% step_id)
      write_audit_event(audit_log_path, list(ts = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), run_id = run_id,
                                             event = "step", status = "step_success", emoji = emoji_for_status("step_success"),
                                             step_id = step_id, script = step$script, elapsed_sec = elapsed, retries = attempt - 1))
      tp_log("success", "✅ step {.field {step_id}} done in {round(elapsed, 2)}s")
      return(list(status = "ok", seconds = elapsed, script = step$script, outputs = outputs, lineage = lineage, retries = attempt - 1))
    }

    if (attempt >= max_attempts) {
      write_audit_event(audit_log_path, list(ts = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), run_id = run_id,
                                             event = "step", status = "step_failed", emoji = emoji_for_status("step_failed"),
                                             step_id = step_id, script = step$script, elapsed_sec = elapsed, error = res$error,
                                             retries = attempt - 1))
      tp_log("error", "💥 step {.field {step_id}} failed: {res$error}")
      return(list(status = "failed", seconds = elapsed, script = step$script, error = res$error, retries = attempt - 1))
    }

    wait <- backoff * (2 ^ (attempt - 1))
    tp_log("warn", "🔁 retrying {.field {step_id}} in {wait}s (error: {res$error})")
    Sys.sleep(wait)
    attempt <- attempt + 1
  }
}

run_contract <- function(contract, root_dir, ctx, phase, step_id) {
  if (is.null(contract)) return(invisible(TRUE))

  if (!is.null(contract$expr)) {
    ok <- isTRUE(eval(parse(text = contract$expr), envir = list2env(ctx, parent = globalenv())))
    if (!ok) rlang::abort(glue::glue("Contract {phase} failed for `{step_id}`: {contract$expr}"))
  }

  if (!is.null(contract$file_exists)) {
    p <- fs::path(root_dir, render_template(contract$file_exists, ctx))
    if (!fs::file_exists(p)) rlang::abort(glue::glue("Contract {phase} failed for `{step_id}`: missing {p}"))
  }

  invisible(TRUE)
}

empty_run_state <- function(pipeline) list(pipeline = pipeline, steps = list(), last_updated = NULL)
load_run_state <- function(path) if (fs::file_exists(path)) jsonlite::read_json(path, simplifyVector = FALSE) else empty_run_state("unknown")
save_run_state <- function(state, path) {
  fs::dir_create(fs::path_dir(path))
  jsonlite::write_json(state, path, auto_unbox = TRUE, pretty = TRUE)
}

step_by_id <- function(steps, id) {
  idx <- which(vapply(steps, function(s) identical(s$id, id), logical(1)))[1]
  steps[[idx]]
}

order_steps <- function(steps) {
  ids <- vapply(steps, function(s) s$id, character(1))
  deps <- lapply(steps, function(s) s$depends_on %||% character(0))
  names(deps) <- ids

  ordered <- character(0)
  visited <- setNames(rep(FALSE, length(ids)), ids)
  temp <- setNames(rep(FALSE, length(ids)), ids)

  visit <- function(id) {
    if (temp[[id]]) rlang::abort(glue::glue("Cycle detected at step `{id}`"))
    if (visited[[id]]) return(invisible(NULL))

    temp[[id]] <<- TRUE
    for (d in deps[[id]]) visit(d)
    temp[[id]] <<- FALSE
    visited[[id]] <<- TRUE
    ordered <<- c(ordered, id)
  }

  for (id in ids) visit(id)
  steps[match(ordered, ids)]
}

resume_pipeline <- function(config_path, ...) {
  run_pipeline(config_path = config_path, resume = TRUE, ...)
}

retry_pipeline <- function(config_path, step_id = NULL, ...) {
  out <- run_pipeline(config_path = config_path, ...)
  if (!is.null(step_id) && !is.null(out$steps[[step_id]]) && out$steps[[step_id]]$status == "failed") {
    tp_log("info", "🔁 targeted retry requested for {.field {step_id}}")
    out <- run_pipeline(config_path = config_path, ...)
  }
  out
}

env_report <- function() {
  si <- utils::sessionInfo()
  list(
    generated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    r = list(
      version = R.version.string,
      platform = R.version$platform,
      arch = R.version$arch,
      os = R.version$os
    ),
    system = as.list(Sys.info()),
    locale = Sys.getlocale(),
    timezone = Sys.timezone(),
    libpaths = .libPaths(),
    loaded_namespaces = names(si$loadedOnly)
  )
}

package_report <- function(include_base = FALSE) {
  ip <- as.data.frame(utils::installed.packages(), stringsAsFactors = FALSE)
  cols <- c("Package", "Version", "LibPath", "Priority")
  ip <- ip[, cols, drop = FALSE]

  if (!include_base) {
    ip <- ip[is.na(ip$Priority) | ip$Priority == "", , drop = FALSE]
  }

  ip[order(ip$Package), , drop = FALSE]
}

write_run_reports <- function(root_dir, run_id, include_base_packages = FALSE) {
  out_dir <- fs::path(root_dir, "logs", "reports")
  fs::dir_create(out_dir)

  env_path <- fs::path(out_dir, glue::glue("{run_id}-environment.json"))
  pkg_path <- fs::path(out_dir, glue::glue("{run_id}-packages.csv"))

  jsonlite::write_json(env_report(), env_path, auto_unbox = TRUE, pretty = TRUE)
  utils::write.csv(package_report(include_base = include_base_packages), pkg_path, row.names = FALSE)

  list(environment = env_path, packages = pkg_path)
}

write_observability_event <- function(path, event) {
  fs::dir_create(fs::path_dir(path))
  payload <- c(list(ts = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")), event)
  write(jsonlite::toJSON(payload, auto_unbox = TRUE, null = "null"), file = path, append = TRUE)
  invisible(payload)
}

write_html_summary <- function(root_dir, pipeline, run_id, started_at, finished_at, step_results,
                               config_path = NULL, report_paths = NULL) {
  out_dir <- fs::path(root_dir, "logs", "reports")
  fs::dir_create(out_dir)
  p <- fs::path(out_dir, glue::glue("{run_id}-summary.html"))

  rows <- vapply(names(step_results), function(id) {
    s <- step_results[[id]]
    status <- s$status %||% "unknown"
    badge <- if (status %in% c("ok", "success")) "bg-emerald-100 text-emerald-700" else if (status %in% c("failed", "step_failed")) "bg-rose-100 text-rose-700" else "bg-slate-100 text-slate-700"
    glue::glue(
      "<tr class='border-b border-slate-100'>
         <td class='px-4 py-3 font-medium text-slate-800'>{id}</td>
         <td class='px-4 py-3'><span class='inline-flex rounded-full px-2 py-1 text-xs font-semibold {badge}'>{status}</span></td>
         <td class='px-4 py-3 text-slate-700'>{round(s$seconds %||% 0, 2)}</td>
         <td class='px-4 py-3 text-slate-700'>{s$retries %||% 0}</td>
       </tr>"
    )
  }, character(1))

  mermaid <- ""
  if (!is.null(config_path) && fs::file_exists(config_path)) {
    mermaid <- visualize_pipeline(config_path, format = "mermaid")
  }

  env_json <- ""
  if (!is.null(report_paths$environment) && fs::file_exists(report_paths$environment)) {
    env_json <- paste(readLines(report_paths$environment, warn = FALSE), collapse = "\n")
  }

  pkg_rows <- ""
  if (!is.null(report_paths$packages) && fs::file_exists(report_paths$packages)) {
    pkg <- utils::read.csv(report_paths$packages, stringsAsFactors = FALSE)
    pkg <- head(pkg, 25)
    pkg_rows <- paste(vapply(seq_len(nrow(pkg)), function(i) {
      r <- pkg[i, ]
      glue::glue("<tr class='border-b border-slate-100'><td class='px-3 py-2'>{r$Package}</td><td class='px-3 py-2'>{r$Version}</td></tr>")
    }, character(1)), collapse = "")
  }

  artifact_paths <- c(
    environment = report_paths$environment %||% NA_character_,
    packages = report_paths$packages %||% NA_character_,
    summary_html = p,
    observability = fs::path(root_dir, "logs", "observability.ndjson"),
    audit = fs::path(root_dir, "logs", "audit.ndjson"),
    dataset_integrity = fs::path(root_dir, "logs", "dataset-integrity.ndjson"),
    state = fs::path(root_dir, "logs", "state.json")
  )

  artifact_links <- paste(vapply(names(artifact_paths), function(nm) {
    ap <- artifact_paths[[nm]]
    if (is.na(ap) || !fs::file_exists(ap)) return("")
    rel <- tryCatch(fs::path_rel(ap, start = fs::path_dir(p)), error = function(e) ap)
    glue::glue("<li><a class='text-violet-700 underline decoration-violet-300 hover:text-violet-900' href='{rel}'>{nm}: {rel}</a></li>")
  }, character(1)), collapse = "")

  html <- glue::glue(
"<!doctype html>
<html lang='en'>
<head>
  <meta charset='utf-8' />
  <meta name='viewport' content='width=device-width, initial-scale=1' />
  <title>tidypipes run {run_id}</title>
  <script src='https://cdn.tailwindcss.com'></script>
  <script type='module'>import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs'; mermaid.initialize({{ startOnLoad: true }});</script>
</head>
<body class='bg-slate-50 text-slate-900'>
  <main class='mx-auto max-w-6xl px-6 py-10'>
    <div class='mb-6 rounded-2xl bg-gradient-to-r from-violet-700 to-fuchsia-600 p-6 text-white shadow'>
      <h1 class='text-3xl font-bold'>🚰 tidypipes run summary</h1>
      <p class='mt-2 text-violet-100'>Pipeline <span class='font-semibold'>{pipeline}</span></p>
    </div>

    <section class='mb-6 grid gap-4 md:grid-cols-3'>
      <div class='rounded-xl bg-white p-4 shadow-sm ring-1 ring-slate-200'><p class='text-xs uppercase text-slate-500'>Run ID</p><p class='mt-1 font-mono text-sm'>{run_id}</p></div>
      <div class='rounded-xl bg-white p-4 shadow-sm ring-1 ring-slate-200'><p class='text-xs uppercase text-slate-500'>Started</p><p class='mt-1 text-sm'>{started_at}</p></div>
      <div class='rounded-xl bg-white p-4 shadow-sm ring-1 ring-slate-200'><p class='text-xs uppercase text-slate-500'>Finished</p><p class='mt-1 text-sm'>{finished_at}</p></div>
    </section>

    <section class='mb-6 rounded-2xl bg-white shadow-sm ring-1 ring-slate-200 overflow-hidden'>
      <div class='border-b border-slate-100 px-4 py-3'><h2 class='font-semibold'>Step outcomes</h2></div>
      <table class='min-w-full text-sm'>
        <thead class='bg-slate-50 text-left text-slate-600'>
          <tr><th class='px-4 py-3'>Step</th><th class='px-4 py-3'>Status</th><th class='px-4 py-3'>Seconds</th><th class='px-4 py-3'>Retries</th></tr>
        </thead>
        <tbody>{paste(rows, collapse='')}</tbody>
      </table>
    </section>

    <section class='mb-6 rounded-2xl bg-white p-4 shadow-sm ring-1 ring-slate-200'>
      <h2 class='mb-3 font-semibold'>Pipeline graph</h2>
      <pre class='mermaid text-xs'>{mermaid}</pre>
    </section>

    <section class='mb-6 rounded-2xl bg-white p-4 shadow-sm ring-1 ring-slate-200'>
      <h2 class='mb-3 font-semibold'>Artifacts</h2>
      <ul class='list-disc space-y-1 pl-5 text-sm'>
        {artifact_links}
      </ul>
    </section>

    <section class='grid gap-6 md:grid-cols-2'>
      <div class='rounded-2xl bg-white p-4 shadow-sm ring-1 ring-slate-200 overflow-auto'>
        <h2 class='mb-3 font-semibold'>Environment report</h2>
        <pre class='text-xs text-slate-700'>{env_json}</pre>
      </div>
      <div class='rounded-2xl bg-white p-4 shadow-sm ring-1 ring-slate-200 overflow-auto'>
        <h2 class='mb-3 font-semibold'>Package report (top 25)</h2>
        <table class='min-w-full text-xs'><thead><tr><th class='px-3 py-2 text-left'>Package</th><th class='px-3 py-2 text-left'>Version</th></tr></thead><tbody>{pkg_rows}</tbody></table>
      </div>
    </section>
  </main>
</body>
</html>"
  )
  writeLines(html, p)
  p
}

maybe_send_alerts <- function(alerts, status, run_id, pipeline, message) {
  if (is.null(alerts)) return(invisible(NULL))
  payload <- list(ts = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), status = status, run_id = run_id, pipeline = pipeline, message = message)

  if (!is.null(alerts$webhook$url)) {
    tp_log("warn", "📣 webhook alert -> {alerts$webhook$url}")
    body <- jsonlite::toJSON(payload, auto_unbox = TRUE)
    try(system2("curl", c("-sS", "-X", "POST", "-H", "Content-Type: application/json", "-d", shQuote(body), alerts$webhook$url), stdout = FALSE, stderr = FALSE), silent = TRUE)
  }

  if (!is.null(alerts$email$to)) {
    tp_log("warn", "📧 email alert stub for {.field {alerts$email$to}} (configure your local mailer)")
  }

  invisible(payload)
}

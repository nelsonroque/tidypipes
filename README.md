# tidypipes 🚰

Local-first, script-first orchestration for tidyverse pipelines.

## New orchestrator features (v0.0.3 style)

- ⚡ Parallel DAG execution for independent steps (`workers`)
- 🔁 Step retry policy with exponential backoff
- 💾 Resume from failure using persistent `logs/state.json`
- 🧠 Conditional step execution (`when` expression)
- ⏰ Lightweight local scheduler + queue + concurrency limits
- 📆 Backfill helper across date ranges
- 🛡️ Data contracts (`contracts.before` / `contracts.after`)
- 📡 Structured observability events (`logs/observability.ndjson`)
- 🧾 HTML run summary (`logs/reports/<run_id>-summary.html`)
- 🚨 Alert hooks (webhook + email stub)
- 🧬 Lineage metadata with dataset version (`md5 + timestamp + logical name`)
- 🗂️ YAML/JSON config support with path templating

## Where file paths are specified

All paths are explicit in config + function args:

- `run_pipeline(config_path=..., root_dir=...)`
- Per-step script path: `steps[].script`
- Per-step output paths/templates: `steps[].outputs[]`
- Contracts: `contracts.before.file_exists`, `contracts.after.file_exists`
- Scheduler queue/state (defaults):
  - `logs/schedule-queue.ndjson`
  - `logs/scheduler-state.json`
- Run state/checkpoints (default): `logs/state.json`
- Audit log (default): `logs/audit.ndjson`
- Observability events: `logs/observability.ndjson`
- Integrity + lineage stamps: `logs/dataset-integrity.ndjson`
- HTML summary + env/package reports: `logs/reports/`

Relative paths resolve from `root_dir`.

## Path templates (including `FN_(sensorname)` style)

Templates support `{param}` interpolation from `params`, `params_env`, step params, and runtime fields (`run_id`, `date`, `timestamp`, `step_id`).

### YAML example (FN style)

```yaml
name: sensor-pipeline
params:
  sensorname: temp01
  out_dir: data/output
params_env:
  api_key: SENSOR_API_KEY

steps:
  - id: ingest
    script: scripts/01_ingest.R
    outputs:
      - "{out_dir}/FN_({sensorname})_{date}.csv"
    retry:
      max_attempts: 3
      backoff_seconds: 2

  - id: validate
    script: scripts/02_validate.R
    depends_on: [ingest]
    when: "sensorname != ''"
    contracts:
      before:
        file_exists: "{out_dir}/FN_({sensorname})_{date}.csv"
      after:
        expr: "TRUE"

  - id: publish
    script: scripts/03_publish.R
    depends_on: [validate]
    outputs:
      - "{out_dir}/published/FN_({sensorname})_{timestamp}.parquet"
```

### JSON example (same pattern)

```json
{
  "name": "sensor-pipeline-json",
  "params": {"sensorname": "humidity07", "out_dir": "data/output"},
  "steps": [
    {
      "id": "ingest",
      "script": "scripts/01_ingest.R",
      "outputs": ["{out_dir}/FN_({sensorname})_{date}.csv"],
      "retry": {"max_attempts": 4, "backoff_seconds": 1}
    }
  ]
}
```

## CLI (Rscript entrypoint)

`Rscript inst/cli/tidypipes.R <run|visualize|retry|resume|schedule|backfill|status> ...`

Examples:

- `Rscript inst/cli/tidypipes.R run inst/examples/pipelines/sales-demo.yml`
- `Rscript inst/cli/tidypipes.R resume inst/examples/pipelines/sales-demo.yml`
- `Rscript inst/cli/tidypipes.R schedule inst/examples/pipelines/sales-demo.yml 300`
- `Rscript inst/cli/tidypipes.R backfill inst/examples/pipelines/sales-demo.yml 2026-01-01 2026-01-07`

## Secrets/params strategy

- Put non-secret defaults in `params`.
- Map secrets via `params_env` to environment variables.
- Reference both in templates with `{name}`.

## Dataset builder from YAML/JSON spec

Use `build_dataset()` to auto-discover files, parse, enrich from filename regex captures, apply transformation hooks, combine/merge, dedupe, and write output.

```r
tidypipes::build_dataset("inst/examples/dataset-builder.yml")
```

Supported reader flow:
- CSV/TSV: `readr` if installed, fallback to base R readers
- Parquet: `arrow::read_parquet()` (graceful error if arrow missing)

Hooks in config:
- `filter`: vector of expressions
- `mutate`: named expressions
- `select`, `rename`
- `group_summarise` (`dplyr` + `rlang` optional)

`build_dataset()` automatically writes audit + observability events and dataset integrity/lineage stamps (`md5`, version id).

## DuckDB folder-to-table helper

```r
tidypipes::build_duckdb_table(
  input_dir = "data/raw",
  db_path = "data/output/pipeline.duckdb",
  table = "raw_events",
  mode = "replace"
)
```

Features:
- combine files in folder (recursive supported)
- write table with `replace` or `append`
- records row counts + source files in audit/observability logs
- graceful error if `DBI`/`duckdb` are not installed

## Codebook generation

```r
d <- readRDS("data/output/sensor_daily.rds")
tidypipes::generate_codebook(
  d,
  output_csv = "data/output/sensor_daily_codebook.csv",
  output_md = "data/output/sensor_daily_codebook.md",
  labels = list(sensorname = "Sensor ID", avg_value = "Daily average")
)
```

Codebook includes:
- variable names + optional friendly labels
- inferred class/type
- non-missing counts
- distinct counts
- min/max for numeric/date/time columns
- sample values

## GitHub Actions

- Package checks: `.github/workflows/R-CMD-check.yaml`
- Docs site deploy: `.github/workflows/pkgdown.yaml`

## pkgdown site

pkgdown is configured via `_pkgdown.yml` and deploys to GitHub Pages.

1. Update `_pkgdown.yml` `url` to your real GitHub Pages URL.
2. Push to `main`.
3. In GitHub repo settings, set Pages source to branch `gh-pages`.

Then docs auto-build on each push.

## Pins export (portable data sharing)

You can export outputs to `pins` with multiple board targets:

```r
# folder board (good for local/shared drive)
tidypipes::pin_export_path(
  path = "data/output/sensor_dataset.csv",
  pin_name = "sensor_dataset",
  board = "folder",
  board_path = "pins"
)

# local board
tidypipes::pin_export(
  x = readRDS("data/output/model_input.rds"),
  pin_name = "model_input",
  board = "local"
)
```

Supported boards in this helper: `folder`, `local`, `temp`, `rsconnect`.

## Use tidypipes from your own project repo

Keep your study/project in a separate repository and install `tidypipes` from GitHub:

```r
remotes::install_github("elclaudioabierto/tidypipes")
```

Then in your project repo, create your own:
- `pipelines/*.yml`
- `scripts/*.R`
- `config.yml`

This keeps your domain work lightweight while reusing the core pipeline engine.

## Simple mtcars example

A minimal teaching demo lives in `examples/mtcars/`.

Run it:

```r
tidypipes::run_pipeline("examples/mtcars/pipelines/mtcars-main.yml", root_dir = ".", workers = 1)
```

Outputs:
- `examples/mtcars/output/mtcars_clean.csv`
- `examples/mtcars/output/mtcars_codebook.csv`
- `examples/mtcars/output/mtcars_codebook.md`

Render Mermaid DAG to PNG (optional):

```r
tidypipes::render_pipeline_png(
  mmd_path = "logs/mtcars-pipeline.mmd",
  png_path = "logs/mtcars-pipeline.png"
)
```

Requires `mmdc` from Mermaid CLI:
`npm i -g @mermaid-js/mermaid-cli`


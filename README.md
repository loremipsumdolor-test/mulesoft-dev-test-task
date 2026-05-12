# nuvolar_test_task

Mule 4 application: on a schedule it reads a sales CSV from disk, enriches rows with country data (REST Countries), derives EUR amounts (Frankfurter), and POSTs one JSON batch to a configurable HTTPS endpoint (often httpbin locally).

## Configuration

| Topic | Details |
| ----- | ------- |
| Environment | `global.xml` loads `properties/${mule.env}-properties.yaml`. Default is `mule.env=local` (`global-property` in `global.xml`). For `qa`, pass `-Dmule.env=qa` in Studio VM arguments / JVM, or set `mule.env` in cloud properties. |
| Sales CSV | Keys `sales.inputDirectory` and `sales.fileName` in the active YAML. Local profile defaults to `C:/data` and `sales.csv` — copy `src/main/resources/data/sales.csv` there or edit those keys. QA uses `${mule.home}/apps/${domain}/classes/data` so the CSV packaged under `classes/data` is read. |
| Scheduler | `scheduler.triggerFrequency` is in seconds (`implementation.xml` uses `timeUnit="SECONDS"`). |
| Outbound APIs | Keys under `apis` (REST Countries, Frankfurter, Treasury: host, port, basePath / postPath) are already filled per profile. |

## Run

**Studio:** import the project → Run As → Mule Application. With default `mule.env=local`, `local-properties.yaml` applies — adjust `sales` keys if `C:/data` is not used.

**Maven:** from the repo root run `mvn clean package` or `mvn test`.

## Tests and reports

- MUnit suite: `src/test/munit/payment-sync-suite.xml`.
- Fixtures: `src/test/resources/munit/` (`*.json` mocks only; no live HTTP in tests).

HTML coverage / flow reports are under `reports/` at the repo root (for example `reports/summary.html` and per-flow HTML such as `implementation-report.html`). Open `reports/summary.html` in a browser after reports have been generated.

Runtime coverage output from Maven also lands under `target/munit-reports/` during `mvn test` unless your tooling copies or exports HTML elsewhere.

## Design

See `DESIGN.md` for flows, properties, DataWeave module usage, and OVERALL DESIGN OVERVIEW.

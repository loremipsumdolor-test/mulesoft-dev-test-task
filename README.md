# nuvolar_test_task

Mule 4 application: on a schedule it reads a sales CSV from disk, enriches rows with country data (REST Countries), derives EUR amounts (Frankfurter), and POSTs one JSON batch to a configurable HTTPS endpoint (often httpbin locally).

## Configuration


| Topic             | Details                                                                                                                                                                                                                                                                                                                    |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Environment**   | `**global.xml`** loads `**properties/${mule.env}-properties.yaml**`. Default is `**mule.env=local**` ( `**global-property**` in `**global.xml**` ). Use `**qa**` by passing `**-Dmule.env=qa**` in Studio VM arguments / JVM, or set `**mule.env**` in cloud deployment properties.                                        |
| **Sales CSV**     | `**sales.inputDirectory`** + `**sales.fileName**` in the active YAML. **Local** defaults to `**C:/data`** + `**sales.csv**` — copy `**src/main/resources/data/sales.csv**` there or change `**sales.***`. **QA** uses `**${mule.home}/apps/${domain}/classes/data`** so the CSV packaged under `**classes/data**` is read. |
| **Scheduler**     | `**scheduler.triggerFrequency`** is in **seconds** (`**implementation.xml`** uses `**timeUnit="SECONDS"**`).                                                                                                                                                                                                               |
| **Outbound APIs** | `**apis.*`** — REST Countries, Frankfurter, Treasury (**host**, **port**, `**basePath`** / `**postPath**`) per profile.                                                                                                                                                                                                    |


## Run

**Studio:** import the project → **Run As → Mule Application**. With the default `**mule.env=local`**, `**local-properties.yaml**` applies — adjust `**sales.***` if `**C:/data**` is not used.

**Maven:** from the repo root `**mvn clean package`** or `**mvn test**`.

## Tests and reports

- MUnit suite: `**src/test/munit/payment-sync-suite.xml**`.
- Fixtures: `**src/test/resources/munit/**` (`*.json` mocks only; no live HTTP in tests).

**HTML coverage / flow reports** are under `**reports/`** at the repo root (for example `**reports/summary.html**` and per-flow `***-report.html**`). Open `**reports/summary.html**` in a browser after reports have been generated.

## Design

See `**DESIGN.md**` for flows, properties, DataWeave module usage, and OVERALL DESIGN OVERVIEW.
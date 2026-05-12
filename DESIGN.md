# Design — nuvolar_test_task

## Approach

- **Structure**: scheduler in **`implementation.xml`**; steps are **sub-flows** in separate XML files, chained with **`flow-ref`**.
- **HTTP usage**: one batched **REST Countries** call and one **Frankfurter** call per tick (keys from **`vars.salesBatchSummary`**), not per CSV row. Rows updated via **DataWeave** joins from response maps.
- **REST Countries**: API failure → **empty lookup map**, pipeline continues; enriched fields stay empty where relevant.
- **Config**: **`mule.env`** → **`properties/${mule.env}-properties.yaml`**. Shared batch/query helpers in **`modules/SalesBatchKeys.dwl`**.
- **No `batch:job`**: whole file in **`salesRows`** in memory — see **Big files** below.
- **Logging**: **INFO** checkpoints; **DEBUG** for nosier detail.
- **MUnit**: **`flow-ref`** sub-flows only; seeded **`vars`** + **`mock-when`** on **`http:request`**; no full scheduler path. Fixtures under **`src/test/resources/munit/`**.

## External APIs (batch-style calls, retries)

- Each scheduler tick: **one REST Countries GET** with **all** country codes in the query string, and **one Frankfurter GET** with **all** currencies in the query — **not** one HTTP call per CSV row. **Treasury** gets **one POST** whose body holds **all** rows together.
- **Frankfurter** and **Treasury** HTTP calls sit inside **`until-successful`** (Frankfurter: **3** tries, **3 s** apart; Treasury: **2** tries, **1 s** apart). **REST Countries** has **no** retry wrapper; **`try`** + **`on-error-continue`** leaves enrichment empty (empty **`countryByCode`** map) and the flow keeps running.

## Big files and why `batch:job` was omitted

The **whole CSV is loaded into memory** as **`salesRows`**. **`batch:job`** is **not** used. That fits a **small** sample file; for **very large** files, **batch processing** or **reading in chunks** is usually preferred so memory does not grow with file size.

## Possible follow-ups

- **Errors**: REST Countries currently “soft fails” while other steps retry — error handling could be made **more consistent** (same rule everywhere: stop the whole run vs keep going).
- **Batch**: Mule Batch or streaming reads could be applied when files get large.
- **Reuse**: the enrichment and FX flows look alike; common parts could be folded into **one reusable pattern** instead of two copies.
- **Tests**: the **full path** (scheduler + reading the file) could be covered, not only sub-flows with mocks.

## Enrichment vs FX — similar shape, no forced reuse

**`countries_data_enrichment.xml`** and **`enforce_eur_rates.xml`** follow almost the same skeleton: derive a query string from **`salesBatchSummary`** → **`choice`** (skip vs call) → **`try`** → **`http:request` GET** with query params → normalize JSON into a **map** → merge back into **`salesRows`**. Only payload shape, paths, and merge DW differ.

That shape could be merged into **one generic sub-flow** (driven by a few variables) instead of **two separate XMLs**. **Two copies** were kept on purpose so each API stays easy to read in Studio without extra indirection.

## Sub-flows

| Sub-flow                            | File                            | Role                                                                 |
| ----------------------------------- | ------------------------------- | -------------------------------------------------------------------- |
| `file_readSub_Flow`                 | `file_read.xml`                 | CSV → **`vars.salesRows`**, **`vars.salesBatchSummary`**.            |
| `countries_data_enrichmentSub_Flow` | `countries_data_enrichment.xml` | REST Countries → **`countryByCode`** → merge names/regions.          |
| `enforce_eur_rates_sub_flow`        | `enforce_eur_rates.xml`         | Frankfurter → **`fxRateByQuote`** → **`fx_rate`**, **`amount_eur`**. |
| `treasury_postSub_Flow`             | `treasury_post.xml`             | HTTPS POST batch JSON.                                               |

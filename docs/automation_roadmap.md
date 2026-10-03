# Future automation roadmap

The current project provides manual execution helpers, a verified cache, source hashes, validation and transactional SQL loading. It does not yet provide a scheduler, continuously advancing analysis window or automatic watchlist trigger evaluation.

## Source coverage

| Source | Current acquisition | What a scheduled run must handle |
|---|---|---|
| FRED | Notebook API helpers; cached mode needs no key | Secure API key, releases, missing observations, revisions and provider limits |
| ALFRED | Saved BEA vintage reconstructed for the approved analysis | Explicit vintage selection and tracking of later GDP revisions |
| Eurostat | Explicit single-series API queries | Publication timing, geographic aggregates and schema changes |
| ECB | SDMX API requests for rates, spreads and expectations | Frequency differences, series changes and expectation aggregation |
| Yahoo Finance | `yfinance` download helpers | Provider availability, ticker schema and data-use terms |
| Power BI | Local imported CSV report | File connections and a separately configured report refresh |
| Repricing watchlist | Authored nine-row scenario framework | Human interpretation and regime review; qualitative triggers are not yet machine rules |

## Implementation order

1. Parameterize the analysis end month/quarter and make each run's vintage and cutoff explicit. Preserve the approved project rules.
2. Collect sources into a new dated cache; validate coverage and hashes before using it. Record which values changed because of new periods or revisions.
3. Run both notebooks, then the existing DuckDB import/view/validation/export workflow. Fail visibly when inputs, categories or contracts change.
4. Review any changed regime against the authored watchlist. The existing SQL mismatch check must stop publication rather than silently retagging or rewriting commentary.
5. Publish the validated export set with a coherent snapshot/run ID and retain the preceding successful set for recovery.
6. Choose an execution schedule that respects source release timing, then configure Power BI refresh separately. Verify that source refresh and report refresh refer to the same successful run.
7. Add concise failure reporting and a last-success timestamp. Add automated watchlist evaluation only after qualitative triggers have been deliberately specified and reviewed.

## Completion criteria for the later phase

A scheduled run must demonstrate successful acquisition, explicit vintage tracking, validated Python/SQL outputs, a reviewed watchlist state and coherent dashboard data. A failed run must leave the last successful exported snapshot identifiable and recoverable. No application material should claim these scheduling capabilities until they have been implemented and tested.

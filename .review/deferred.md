# Deferred review findings

Findings from the AI Diff Reviewer that were deliberately not fixed in the PR
that raised them. Each entry names the review, the reason, and where the fix
belongs.

## PR #50 — AI Diff Reviewer v3.1.1 on grok (review of `f4e9b49`)

| Fingerprint | Severity | Location | Finding | Why deferred |
|---|---|---|---|---|
| `767178df1b071e59` | info | `.github/workflows/pr-review.yml` (review step) | Pin `grok-version` and `grok-installer-sha256` so a changed xAI installer fails closed. | Pin once the grok lane has a few green runs, together with DailybotHQ/cli, so both repos move the pin in lockstep; an unpinned run still logs the observed hash. |

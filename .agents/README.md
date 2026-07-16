# `.agents/` — contributor kit for this repo

Cross-agent home for personas, thin command aliases, and vendored skills used
**when editing this repository**. Nothing under `.agents/` ships to end users
of the Dailybot skill pack — only `skills/dailybot/` is installed.

- `skills/deepworkplan/` — Deep Work Plan methodology (v2.17.0)
- `skills/ai-diff-reviewer/` — AI Diff Reviewer (v2.0.0), Flow B
- `commands/` — thin `dwp-*` / author aliases
- `agents/` — contributor personas
- `docs/` — catalog that must match what exists on disk

Symlinks: `.claude → .agents`, `.cursor → .agents`.

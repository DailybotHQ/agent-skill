---
description: Re-run the Deep Work Plan onboarding flow on this repository (reconciliation pass — non-destructive by design)
---

# /deepworkplan-onboard — provided by the `deepworkplan` skill

> Thin alias. The flow lives in the installed `deepworkplan` skill — this file
> only routes to it, so there is a single source of truth and no drift.

## What to do

Route this invocation to the **onboard** sub-skill of the installed
`deepworkplan` skill and follow it: read
`.agents/skills/deepworkplan/onboard/SKILL.md` and execute its 9-phase flow.
The flow is **non-destructive by design** — Phase 0 gates consent, every
existing artifact is reconciled rather than clobbered, and addons are explicit
opt-in.

When invoked on a repository that has already been onboarded (this one), the
flow acts as a **reconciliation pass**: it re-detects the stack, re-reads
existing artifacts, and proposes only the diffs needed to stay aligned with
the latest DWP specification (currently
[v1.2](https://deepworkplan.com/spec)).

> Other agents: invoke the skill's `deepworkplan-onboard` sub-skill directly
> (`/deepworkplan-onboard` in Claude Code, `#deepworkplan-onboard` elsewhere).
> This file's purpose is to make the command discoverable in this repo's
> `.agents/commands/` listing alongside the other `dwp-*` delegators.

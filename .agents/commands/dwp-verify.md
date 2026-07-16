---
description: Run an objective Deep Work Plan conformance check on this repository (provided by the installed `deepworkplan` skill)
---

# /dwp-verify — provided by the `deepworkplan` skill

> Thin alias. The flow lives in the installed `deepworkplan` skill — this file
> only routes to it, so there is a single source of truth and no drift.

## What to do

Route this invocation to the **verify** sub-skill of the installed `deepworkplan`
skill and follow it: read `.agents/skills/deepworkplan/verify/SKILL.md` and execute
its repository-conformance checks. The sub-skill emits a binary
**CONFORMANT / NOT CONFORMANT** verdict against the [DWP specification's
Conformance document](https://deepworkplan.com/spec). On a `NOT CONFORMANT`
verdict, fix-then-recheck before reporting done.

> Other agents: invoke the skill's `deepworkplan-verify` sub-skill directly
> (`/deepworkplan-verify` in Claude Code, `#deepworkplan-verify` elsewhere). This
> `dwp-verify` file is the shorter, conventional alias.

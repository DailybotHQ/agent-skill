# Review overrides for Dailybot Agent Skill Pack

This repo ships the **Dailybot agent skill pack** — Markdown + Bash under
`skills/dailybot/` that installs into end-user agent harnesses. Contributor
infrastructure (`.agents/`, `.github/`, `tests/`, `docs/`, `AGENTS.md`) does
**not** ship. Calibrate findings to the ship boundary and consent/security
surface.

Canonical rules: [`AGENTS.md`](../AGENTS.md), [`SECURITY.md`](../SECURITY.md),
[`docs/SUB_SKILL_GUIDE.md`](../docs/SUB_SKILL_GUIDE.md).

## Severity overrides for this codebase

- **Always `critical`:** putting real API keys, tokens, emails, org UUIDs, or
  internal hostnames into anything under `skills/dailybot/` (ships to users)
  or into tracked examples/docs. Use placeholders only.
- **Always `critical`:** weakening or bypassing consent / auth steps in
  `skills/dailybot/shared/auth.md`, report Step 0, or email pre-send
  confirmation — including "helpful" silent defaults that skip confirmation.
- **Always `critical`:** moving end-user-required content out of
  `skills/dailybot/` (users will never see it) or shipping contributor-only
  paths (`.agents/`, `AGENTS.md`, `tests/`) into the install surface.
- **Always `critical`:** recommending `curl | sh` / remote-pipe installers, or
  adding network/telemetry to skill runtime flows that previously had none.
- **Always `critical`:** `shell=True` / unquoted expansions in `setup.sh` or
  `skills/dailybot/shared/context.sh` that can execute attacker-controlled
  input.

- **Always `warning`:** new `SKILL.md` that fails the Open Agent Skills
  frontmatter contract (`python3 scripts/validate-frontmatter.py`).
- **Always `warning`:** changing a documented `dailybot-cli >= X.Y.Z` floor
  without updating README / AGENTS / CHANGELOG / skill prose together.
- **Always `warning`:** shell changes under `setup.sh` /
  `skills/dailybot/shared/context.sh` / `scripts/*.sh` without bats coverage
  and a clean `shellcheck` pass.
- **Always `warning`:** English-only violations (Spanish/other languages) in
  skill prose, comments, or commit messages.
- **Always `warning`:** breaking the router contract in
  `skills/dailybot/SKILL.md` (missing route to a new sub-skill, orphaned
  sub-skill not linked from the router).

- **Always `info` (do not block):** wording polish in contributor-only docs;
  comment nits; reordering tables without behavior change.

## Don't comment on

- Vendored trees under `.agents/skills/deepworkplan/` and
  `.agents/skills/ai-diff-reviewer/` unless the PR deliberately bumps them —
  review the bump intent, not upstream internals.
- Pure `skills-lock.json` hash updates that accompany a deliberate skill bump.
- Auto-release / changelog machinery churn that does not touch
  `skills/dailybot/`.

## Reviewer style additions

- Start findings with **ships?** (`skills/dailybot/`) vs **contributor-only**
  so authors see blast radius immediately.
- Cite `AGENTS.md` / `SECURITY.md` / `docs/SUB_SKILL_GUIDE.md` when a rule
  applies.
- Prefer concrete fix shapes that match existing patterns in
  `shared/auth.md` and sibling sub-skills over inventing new consent UX.

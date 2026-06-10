# AGENTS.md — Documentation for AI Agents working on this repo

**Purpose:** Single source of truth for any AI coding assistant (Claude Code,
Cursor AI, OpenAI Codex, Gemini CLI, GitHub Copilot, others) that **edits
this repository**. This file is for contributors, not for end users of the
skill.

> [!IMPORTANT]
> **This file is NOT installed.** When users install the skill (via
> `npx skills add`, `openclaw skills install`, or `git clone + setup.sh`),
> only the contents of `skills/dailybot/` ship to their machine. Anything
> outside that directory — including this file, `.github/`, `tests/`,
> `scripts/`, `docs/`, `CONTRIBUTING.md`, etc. — is repo-development
> infrastructure that lives only on GitHub and on contributors' machines.

`CLAUDE.md` at the repo root is a symlink to this file so Claude Code reads
the same instructions other agents do.

---

## Detailed Documentation

| Category | Document |
|----------|----------|
| User-facing README | [README.md](README.md) |
| Security policy | [SECURITY.md](SECURITY.md) |
| Public CLI/HTTP API reference (mirrored at `api.dailybot.com/skill.md`) | [docs/API_REFERENCE.md](docs/API_REFERENCE.md) |
| Full installation guide (six install methods, compare/update/uninstall) | [docs/INSTALLATION.md](docs/INSTALLATION.md) |
| OpenClaw notes | [docs/OPENCLAW.md](docs/OPENCLAW.md) |
| Design decisions (why the layout is the way it is) | [docs/DESIGN.md](docs/DESIGN.md) |
| Adding a new sub-skill | [docs/SUB_SKILL_GUIDE.md](docs/SUB_SKILL_GUIDE.md) |
| Contribution guide | [CONTRIBUTING.md](CONTRIBUTING.md) |
| Changelog | [CHANGELOG.md](CHANGELOG.md) |
| Router meta-skill | [skills/dailybot/SKILL.md](skills/dailybot/SKILL.md) |
| Auth + consent flow | [skills/dailybot/shared/auth.md](skills/dailybot/shared/auth.md) |
| Context detection + opt-out | [skills/dailybot/shared/context.sh](skills/dailybot/shared/context.sh) |
| HTTP fallback patterns | [skills/dailybot/shared/http-fallback.md](skills/dailybot/shared/http-fallback.md) |
| Auto-activation triggers | [skills/dailybot/report/triggers.md](skills/dailybot/report/triggers.md) |
| Hook enforcement (deterministic reminders, CLI >= 1.12.0) | [skills/dailybot/report/hooks.md](skills/dailybot/report/hooks.md) |
| Hooks architecture (contributor doc, with diagrams) | [docs/HOOKS_ARCHITECTURE.md](docs/HOOKS_ARCHITECTURE.md) |
| Report writing guide | [skills/dailybot/report/writing-guide.md](skills/dailybot/report/writing-guide.md) |

## Project Overview

This repository is the **official Dailybot agent skill pack**, maintained
by [Dailybot](https://www.dailybot.com) and distributed via
[skills.sh](https://skills.sh), [OpenClaw](https://www.openclaw.dev), and
direct git clone. It teaches AI coding agents how to talk to Dailybot:
report progress to the team, check messages, send emails, and announce
health status. The skill follows the
[Open Agent Skills](https://agentskills.io) standard.

**Stack:** Bash + Markdown. No application runtime, no compiled artifacts.
The "code" is the SKILL.md files an agent reads at runtime, plus three
small helper scripts (`setup.sh`, `shared/context.sh`, plus the
`https://cli.dailybot.com/install.sh` script in a separate repo).

**Companion repo:** the Dailybot CLI lives at
[github.com/DailybotHQ/cli](https://github.com/DailybotHQ/cli) and publishes
its installer to `cli.dailybot.com`. This skill repo references that CLI
but does not contain it.

## Project Structure

```
agent-skill/
├── AGENTS.md, CLAUDE.md (symlink)         ← this file (NOT installed)
├── CONTRIBUTING.md                        ← contributor guide (NOT installed)
├── README.md                              ← public README on GitHub (NOT installed)
├── LICENSE, SECURITY.md, CHANGELOG.md     ← repo metadata (NOT installed)
├── setup.sh                               ← symlink installer for non-skills.sh users
├── .github/
│   ├── workflows/ci.yml                   ← shellcheck + bats + frontmatter validation
│   ├── ISSUE_TEMPLATE/                    ← bug + feature templates
│   └── PULL_REQUEST_TEMPLATE.md
├── tests/                                 ← bats-core tests (NOT installed)
│   └── context-sh.bats
├── scripts/                               ← repo-dev scripts (NOT installed)
│   ├── verify-cdn.sh                      ← checks install.sh + .sha256 are published
│   └── validate-frontmatter.py            ← schema check on every SKILL.md
├── docs/                                  ← internal docs (NOT installed)
│   ├── skill.md                           ← mirrored at api.dailybot.com/skill.md
│   └── openclaw.md
└── skills/dailybot/                       ← THE INSTALLED ARTIFACT — only this ships
    ├── SKILL.md                           ← router
    ├── shared/                            ← auth.md, context.sh, http-fallback.md
    ├── report/                            ← progress reporting + auto-activation
    ├── messages/SKILL.md
    ├── email/SKILL.md
    └── health/SKILL.md
```

The hard rule: **anything you put outside `skills/dailybot/` is invisible
to the runtime agent**. Use that to keep this repo discoverable and
auditable on GitHub without polluting the skill itself.

## Quick Commands

```bash
# Lint shell scripts (the only ones we ship + setup.sh):
shellcheck setup.sh skills/dailybot/shared/context.sh

# Run unit tests (requires bats-core: brew install bats-core):
bats tests/

# Validate every SKILL.md frontmatter (kebab-case name, version, etc.):
python3 scripts/validate-frontmatter.py

# Smoke-test setup.sh against your local agent installation:
./setup.sh --host claude

# Smoke-test context.sh (should emit single-line JSON):
bash skills/dailybot/shared/context.sh

# Verify the .dailybot/disabled opt-out works:
mkdir -p .dailybot && touch .dailybot/disabled && \
  bash skills/dailybot/shared/context.sh && \
  rm -rf .dailybot

# Check that cli.dailybot.com publishes install.sh + .sha256:
bash scripts/verify-cdn.sh
```

## CRITICAL: Mandatory Rules

### 1. English only

All code, comments, documentation, and commit messages MUST be in English.
This is a public open-source repo consumed worldwide.

### 2. The runtime artifact is `skills/dailybot/` — keep it pure

If you create a new file or directory, ask: *"does this need to be on the
end user's disk for the skill to work at runtime?"*

- **Yes** → it lives under `skills/dailybot/`
- **No** → it lives at the repo root or under `.github/`, `tests/`,
  `scripts/`, `docs/`

Never reach **out of** `skills/dailybot/` for anything at runtime — every
runtime file must be self-contained inside that directory because that's
what skills.sh ships.

### 3. SKILL.md frontmatter conventions

Every `SKILL.md` MUST have YAML frontmatter with at least:

```yaml
---
name: dailybot-<thing>          # kebab-case, never snake_case (dailybot_thing) or camelCase
description: <one paragraph>     # used by skills.sh + every agent harness for relevance scoring
version: "1.0.0"                 # SemVer, quoted to keep it a string
documentation_url: https://api.dailybot.com/skill.md  # NEVER use `homepage:` (legacy, dangerous)
user-invocable: true|false       # whether `/<name>` becomes a slash command
allowed-tools: Bash, Read, Grep, Glob
---
```

The `documentation_url` field replaces the legacy `homepage` because some
agent harnesses interpret `homepage` as a re-fetch source. `validate-frontmatter.py`
will fail CI if any SKILL.md uses the old key.

### 4. Don't roll back the consent flows

The 1.0.0 release added three consent guarantees that must not regress:

- **CLI install** — show the proposed command, ask for confirmation the
  first time in a session, run only after explicit "yes". Never write
  *"do not ask the developer for permission"* anywhere.
- **Auto-activation** — show the file path + exact content + uninstall
  marker before writing to any global agent config (`CLAUDE.md`,
  `AGENTS.md`, `GEMINI.md`, etc.). Wrap all blocks in
  `<!-- dailybot-auto-activation: BEGIN/END -->` markers.
- **Email** — confirm recipient + 1-line body summary before every send;
  scan for credential patterns before every send; cache approvals in
  `~/.dailybot/email-approvals.json`. The `DAILYBOT_AUTO_YES=1` escape
  hatch DOES NOT bypass the email checks.

These exist because they close audit findings that determine whether
Vercel will accept us on `skills.sh/official` and whether enterprise
buyers approve the skill.

### 5. Bash 3.2 compatibility (macOS default)

macOS still ships bash 3.2 by default. Anything under `setup.sh` or
`skills/dailybot/shared/*.sh` must run on bash 3.2 — that means:

- ❌ No `mapfile` / `readarray` (bash 4+)
- ❌ No associative arrays `declare -A` (bash 4+)
- ❌ No `${var^^}` / `${var,,}` case conversion (bash 4+)
- ✅ Use `while IFS= read -r line; do ...; done < <(cmd)` instead of `mapfile`
- ✅ Use `tr '[:lower:]' '[:upper:]'` for case conversion

CI runs on `macos-latest` to enforce this.

### 6. `set -euo pipefail` everywhere

All shell scripts start with:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

This catches typos and missing variables early. Use `${var:-default}` for
optional variables, and guard array length checks with `${#arr[@]}` so the
script doesn't trip on empty arrays under `set -u`.

### 7. Don't break the public surface

These are public contracts other systems depend on. Changing them is a
breaking change that requires a major version bump (`2.0.0`) and a
migration note in `CHANGELOG.md`:

- HTTP endpoints under `https://api.dailybot.com/v1/agent-*/`
- CLI flag names documented in any `SKILL.md` (`--name`, `--metadata`,
  `--json-data`, `--milestone`, `--co-authors`, `--to`, `--subject`,
  `--body-html`)
- The `<!-- dailybot-auto-activation: BEGIN/END -->` markers (users grep
  for them to uninstall)
- `.dailybot/disabled` opt-out file convention
- `DAILYBOT_AUTO_YES=1` env var
- `DAILYBOT_API_KEY` env var
- Skill `name` field in frontmatter (skills.sh registry references it)

### 8. Versioning is automatic — write good commits

You do **not** edit `version:` fields, `CHANGELOG.md`, or git tags by
hand. The `auto-release.yml` workflow runs on every merge to `main` and:

1. Reads the current version from `skills/dailybot/SKILL.md` frontmatter.
2. Looks at commits merged since the last `vX.Y.Z` tag.
3. Decides the bump level:
   - `feat(scope)!:` or `BREAKING CHANGE:` in body → **MAJOR**
   - `feat(scope):` → **MINOR**
   - everything else (`fix:`, `chore:`, no prefix, etc.) → **PATCH**
4. Bumps the version in all 5 SKILL.md files, prepends a section to
   `CHANGELOG.md`, commits as `chore(release): X.Y.Z [skip ci]`, tags
   `vX.Y.Z`, and creates a GitHub Release.

What this means for you:

- Write meaningful commit messages with the right `<type>(<scope>):`
  prefix. The workflow reads them.
- A bug-fix-only PR → PATCH automatically. A new sub-skill → MINOR
  (use `feat(...):`). A removed flag or renamed env var → MAJOR (use
  `feat(...)!:` and explain in the PR body).
- Don't touch `CHANGELOG.md` or `version:` fields manually. The bot
  owns them. If you do edit them by hand, the next auto-release will
  overwrite the version line and prepend a duplicate changelog section.
- Bump-level guide for this skill specifically:
  - **MAJOR** = breaking the public surface (HTTP endpoint shape change,
    removed CLI flag, removed sub-skill, removed `<!-- dailybot-auto-activation -->`
    marker, removed env var).
  - **MINOR** = additive (new sub-skill, new flag, new env var, new
    auto-activation trigger).
  - **PATCH** = bug fixes, docs, internal refactors, CI changes.

### 9. Cross-platform reality

Test changes that touch the install or runtime path against:

- macOS (bash 3.2)
- Linux x86_64 (Ubuntu / Alpine)
- WSL2
- Docker (Debian-based image without curl pre-installed → falls back to
  HTTP API path)

You don't have to run all of these locally — CI covers macOS + Linux. But
if you're touching `setup.sh`, `shared/context.sh`, or the install
documentation, mention in the PR which environments you tested manually.

## Distribution Workflow

End-to-end: how a change in this repo reaches users.

1. **Land the change** on `main` via PR
2. **Bump version** in `skills/dailybot/SKILL.md` frontmatter and add an
   entry to `CHANGELOG.md`
3. **Tag the release** (`git tag v1.0.x && git push --tags`) — GitHub
   release notes are auto-generated from the changelog entry
4. **skills.sh re-indexes** automatically (within hours of the push to
   `main`) — no manual action needed
5. **Existing users**: `npx skills update DailybotHQ/agent-skill` or
   `cd <skill-path> && git pull`
6. **OpenClaw users**: `openclaw skills update dailybot`

For changes that affect the install script (`cli.dailybot.com/install.sh`),
the actual script lives in
[github.com/DailybotHQ/cli](https://github.com/DailybotHQ/cli) — coordinate
across both repos. After the install.sh changes:

```bash
cd /path/to/DailybotHQ/cli
shasum -a 256 install.sh > install.sh.sha256
# Upload both files to the CDN serving cli.dailybot.com
```

`scripts/verify-cdn.sh` in this repo can probe the CDN and tell you whether
the `.sha256` is currently published and whether it matches the script.

## Commit Message Format (MANDATORY)

```
<type>(<scope>): <short description>

<body — Summary, motivation, what changed, risks>

Co-Authored-By: <agent name + version> <noreply@anthropic.com>
```

**Types:** `feat` (new behavior), `fix` (bug fix), `docs` (docs only),
`chore` (repo maintenance), `test` (adding tests), `ci` (CI config),
`refactor` (no user-visible change).

**Scopes:** `skill` (general pack), `report` / `messages` / `email` /
`health` (specific sub-skill), `shared` (auth.md, context.sh,
http-fallback.md), `setup` (setup.sh), `ci` (.github/), `docs` (docs/),
`release` (versioning, CHANGELOG).

Examples (from this repo's history):

```
chore(skill): restructure to skills/dailybot/ layout and add open-source boilerplate
feat(skill): require explicit consent for CLI install, auto-activation, and email sends
feat(skill): bash hardening and per-repo telemetry opt-out
fix(skill): restore curl|bash as universal install path and add DAILYBOT_AUTO_YES escape hatch
```

## Agent Progress Reporting (Eat Our Own Dog Food)

This repository **is the dailybot agent skill pack**. When an AI agent
works on it, that agent should use the skill it's editing to report
progress. The skill exists for exactly this kind of work.

After significant work (feature, bug fix, refactor, docs rewrite, three or
more related commits), submit a Daily Standup-style update to Dailybot.
Once the skill is installed locally, the agent does this autonomously
because the auto-activation trigger is in place. If you're a contributor
who hasn't installed the skill in your agent yet, do it now — it's a
two-command setup and you'll see what end users see.

**Key rules:**

- 1–3 sentences, **always in English**, focus on WHAT was accomplished
  and WHY it matters
- Never say *"Agent completed..."* — describe outcomes, not process
- Never include file paths, git stats, branch names, or raw commit messages
- **Silence > noise** — if you can't be specific, don't report
- 1 rich, complete report > 10 shallow reports

See `skills/dailybot/report/SKILL.md` and `skills/dailybot/report/writing-guide.md`
for the full guide. We use our own skill to communicate about our own skill —
that's both validation and documentation.

## Common Mistakes

### DON'T

1. Put runtime files outside `skills/dailybot/` — they won't ship to users
2. Use `name: dailybot_report` (snake_case) — must be `dailybot-report` (kebab)
3. Use `homepage:` in frontmatter — use `documentation_url:`
4. Roll back consent flows ("just install silently" / "just write the trigger") — these protect users and our security posture
5. Use bash 4+ features (`mapfile`, associative arrays) in any script — they break on macOS bash 3.2
6. Recommend `curl ... install.sh | bash` without SHA-256 verification — always pair with the checksum check
7. Modify a `skills/dailybot/` file without updating `CHANGELOG.md` and bumping the version
8. Break the `<!-- dailybot-auto-activation -->` markers — users grep for them to uninstall
9. Change the HTTP endpoint shapes or CLI flag names without a major version bump
10. Push to `main` without running `shellcheck` and `bats tests/` locally
11. Update `install.sh` in `DailybotHQ/cli` without also publishing the new `install.sh.sha256` to the CDN — the skill will refuse to install
12. Add a new sub-skill folder without giving it its own `SKILL.md` with full frontmatter
13. Send a PR that only touches `docs/API_REFERENCE.md` (the public API ref) without mirroring the change to the matching `skills/dailybot/**/SKILL.md` — they describe the same surface
14. Hardcode literal SHA-256 hashes anywhere in this repo — they belong on the CDN, generated at release time

### DO

1. Keep dev infrastructure (`.github/`, `tests/`, `scripts/`, `docs/`, this file) at the repo root
2. Use kebab-case for `name:` in frontmatter
3. Run `shellcheck setup.sh skills/dailybot/shared/context.sh` before pushing
4. Run `bats tests/` before pushing
5. Run `python3 scripts/validate-frontmatter.py` before pushing
6. Bump the version in `skills/dailybot/SKILL.md` AND `CHANGELOG.md` for any user-visible change
7. Match commit format: `<type>(<scope>): description`
8. Use the skill itself to report your own progress — eat the dog food
9. Test `setup.sh` manually with `--host claude` after touching it
10. Test `context.sh` in three scenarios: regular dir, `.dailybot/disabled` present, `DAILYBOT_AGENT_TOOL` set
11. Mirror changes between `docs/API_REFERENCE.md` and the runtime SKILL.md files when public surface evolves
12. Generate the install script SHA-256 in CI of `DailybotHQ/cli`, never by hand
13. Preserve the consent flow philosophy when touching auth.md, Step 0 of report, or email/

## Pre-Commit Checklist

- [ ] All changes in English
- [ ] `shellcheck setup.sh skills/dailybot/shared/context.sh` clean
- [ ] `bats tests/` passes (if you have bats-core installed)
- [ ] `python3 scripts/validate-frontmatter.py` passes
- [ ] No `name: dailybot_*` (snake_case) introduced
- [ ] No `homepage:` (legacy field) introduced
- [ ] No `curl ... | bash` recommended without SHA-256 verification
- [ ] No bash 4+ idioms (`mapfile`, `declare -A`) introduced
- [ ] CHANGELOG.md updated if user-visible behavior changed
- [ ] Version bumped in `skills/dailybot/SKILL.md` if releasing
- [ ] Public surface preserved (CLI flags, HTTP endpoints, markers, env vars)
- [ ] Consent flows preserved (install consent, auto-activation opt-in, email confirm)
- [ ] Setup.sh tested with at least `./setup.sh --host claude`
- [ ] Commit message follows `<type>(<scope>): description` format

## Shared Agent Coordination

Multiple AI agents may work on this repo simultaneously. They all read
this `AGENTS.md`:

- **Claude Code** reads `CLAUDE.md` (symlink to `AGENTS.md`)
- **Cursor AI** reads `AGENTS.md` (and any `.cursorrules` if present)
- **OpenAI Codex** reads `AGENTS.md`
- **Gemini CLI** reads `AGENTS.md` (and `GEMINI.md` if present, but we
  don't maintain a separate one)
- **GitHub Copilot** reads `AGENTS.md` (and `.github/copilot-instructions.md`
  if present)

If you're updating shared standards in this file, you don't need to mirror
to per-agent files — `AGENTS.md` is the canonical source.

## Temporary Files (tmp/)

The `tmp/` folder at the repo root is **git-ignored entirely** — the
directory is preserved with a `.gitkeep` placeholder, but every file or
subdirectory you create inside it is invisible to git. It exists so
agents and contributors can do scratch work without polluting the
working tree or risking accidental commits of debug output. The folder
is yours — write freely, clean up when done.

Use `tmp/` for:

- **Inter-agent prompts** — drafting a prompt for another agent before
  invoking it (`tmp/prompts/codex-review-pr.md`)
- **Probes against external services** — output from `curl`-ing
  `cli.dailybot.com`, `api.dailybot.com`, the GitHub API, etc.
  (`tmp/probes/cdn-check-2026-05-01.txt`)
- **Scratch experiments** — throwaway shell scripts or one-off tooling
  (`tmp/scratch/test-frontmatter-edge-case.sh`)
- **Data exports** — query results, downloaded artifacts you want to
  inspect without committing (`tmp/exports/skills-sh-listings.json`)
- **Personal scratch space** — `tmp/<your-handle>/` to avoid stepping
  on parallel work

Common subdirectory pattern (suggested but not enforced):
`tmp/scratch/`, `tmp/prompts/`, `tmp/probes/`, `tmp/exports/`.

**The hard rule:** nothing under `tmp/` is ever committed. If a file
you drafted in `tmp/` deserves to live in the repo, **move** it to its
proper home (`skills/dailybot/`, `tests/`, `scripts/`, `docs/`,
or the repo root) and `git add` it from there — never `git add tmp/...`
because the `.gitignore` will reject the file anyway and the path
itself is wrong.

CI does not look at `tmp/`. The frontmatter validator and bats tests
only see `skills/`, `tests/`, and a handful of named files. So there's
no risk of half-finished drafts breaking checks while you iterate.

If you create `tmp/` yourself by accident on a fresh clone (it's
already there in committed form via the README), it survives `git
clean -fd` because it's tracked.

---

## When in Doubt

- **Behavior of an end-user-facing flow** → read the relevant SKILL.md
  inside `skills/dailybot/`
- **A security or consent decision** → re-read the four consent flows in
  `shared/auth.md`, `report/SKILL.md` Step 0, and `email/SKILL.md` Step 2,
  then ask in the PR
- **An install / packaging decision** → consult
  [skills.sh CLI README](https://github.com/vercel-labs/skills) and the
  [Open Agent Skills spec](https://agentskills.io)
- **A breaking-change decision** → bump major version, document the
  migration path in CHANGELOG.md, mention in the PR description that it's
  a breaking change

This repository is small but plays in a public ecosystem. Lean toward
caution on behavior changes — your work is auditable by Vercel, by every
enterprise security team that evaluates the skill, and by every other
agent that reads our SKILL.md.

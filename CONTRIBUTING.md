# Contributing to the Dailybot Agent Skill Pack

Thanks for your interest in improving this skill. This guide is the
human counterpart to [`AGENTS.md`](AGENTS.md) — same conventions, more
narrative. If you're an AI agent reading this, prefer `AGENTS.md` —
it's terser and has the canonical rule list.

This repo is small but plays in a public ecosystem (skills.sh, OpenClaw,
direct git clone), so the conventions matter. Read once, refer back
when you need to.

---

## Table of contents

1. [What this repo is](#what-this-repo-is)
2. [Repo layout: runtime vs. dev infrastructure](#repo-layout-runtime-vs-dev-infrastructure)
3. [Local development setup](#local-development-setup)
4. [Making a change end-to-end](#making-a-change-end-to-end)
5. [Commit conventions and the auto-release flow](#commit-conventions-and-the-auto-release-flow)
6. [What CI checks](#what-ci-checks)
7. [Pull request workflow](#pull-request-workflow)
8. [Adding a new sub-skill](#adding-a-new-sub-skill)
9. [What we will and won't merge](#what-we-will-and-wont-merge)
10. [Reporting bugs and security issues](#reporting-bugs-and-security-issues)
11. [Where to find more](#where-to-find-more)

---

## What this repo is

The **official Dailybot agent skill pack**, maintained by
[Dailybot](https://www.dailybot.com). It teaches AI coding agents
(Claude Code, Cursor, OpenAI Codex, Gemini CLI, GitHub Copilot, Cline,
Windsurf, OpenClaw) how to talk to Dailybot — report progress, check
messages, send emails, announce health status. The skill follows the
[Open Agent Skills](https://agentskills.io) standard.

Distribution channels:

- `npx skills add DailybotHQ/agent-skill` (skills.sh registry)
- `openclaw skills install dailybot` (OpenClaw native registry)
- `git clone … && ./setup.sh` (direct, for users who prefer it)

Companion repo: the Dailybot CLI source lives at
[`DailybotHQ/cli`](https://github.com/DailybotHQ/cli). This repo
references that CLI but doesn't contain it.

---

## Repo layout: runtime vs. dev infrastructure

The hard rule: **anything inside `skills/dailybot/` ships to users.
Everything else stays on GitHub and on contributors' machines.**

```
agent-skill/
├── README.md, SECURITY.md, LICENSE, CHANGELOG.md ← repo metadata (NOT installed)
├── AGENTS.md, CLAUDE.md (symlink), CONTRIBUTING.md ← contributor guide (NOT installed)
├── setup.sh                       ← symlink installer for non-skills.sh users
├── .github/workflows/             ← CI + auto-release workflows (NOT installed)
├── tests/*.bats                   ← bats-core tests (NOT installed)
├── scripts/                       ← repo-dev scripts (NOT installed)
│   ├── verify-cdn.sh              ← probe cli.dailybot.com checksums
│   └── validate-frontmatter.py    ← schema check on every SKILL.md
├── docs/                          ← contributor docs (NOT installed)
│   ├── API_REFERENCE.md           ← public CLI/HTTP reference, mirrored at www.dailybot.com/skill.md
│   ├── OPENCLAW.md                ← OpenClaw-specific notes
│   ├── DESIGN.md                  ← why the layout is what it is (10 design decisions)
│   └── SUB_SKILL_GUIDE.md         ← step-by-step for adding a new sub-skill
└── skills/dailybot/               ← THE INSTALLED ARTIFACT — only this ships
    ├── SKILL.md                   ← router meta-skill
    ├── shared/                    ← auth.md, context.sh, http-fallback.md
    ├── report/                    ← progress reporting + auto-activation
    ├── messages/SKILL.md
    ├── email/SKILL.md
    └── health/SKILL.md
```

When you create a new file, ask: *"does the user need this on disk for
the skill to work at runtime?"*

- **Yes** → put it under `skills/dailybot/`.
- **No** → put it at the repo root or under `.github/`, `tests/`,
  `scripts/`, `docs/`.

Why it matters: skills.sh and OpenClaw only copy/symlink the contents
of `skills/dailybot/`. Anything else is invisible to runtime agents.

---

## Local development setup

### Required tools

| Tool | Why | Install |
|------|-----|---------|
| `git` | Obvious | Pre-installed on most systems |
| `bash` (3.2+) | Run `setup.sh`, `context.sh`, tests | macOS ships 3.2 by default; Linux usually 4+. We support 3.2 deliberately — see AGENTS.md rule #5. |
| `shellcheck` | Lint shell scripts | `brew install shellcheck` (macOS), `apt install shellcheck` (Ubuntu) |
| `bats-core` | Run `tests/*.bats` | `brew install bats-core` (macOS), `apt install bats` (Ubuntu) |
| `python3` (3.10+) + `pyyaml` | Run `validate-frontmatter.py` | `python3 -m pip install --user pyyaml` |
| `jq` | Optional, used by `context.sh` if available | `brew install jq` / `apt install jq` |

### Clone and install the skill into your local agent

```bash
git clone https://github.com/DailybotHQ/agent-skill.git
cd agent-skill

# Install into your local agent (replace claude with your agent of choice).
# This creates symlinks, so edits to the cloned repo are picked up live.
./setup.sh --host claude       # or: cursor, codex, windsurf, copilot, cline, gemini

# Or auto-detect every agent on the machine:
./setup.sh
```

`setup.sh --host <agent>` symlinks `skills/dailybot/` into the
appropriate path for that agent (e.g. `~/.claude/skills/dailybot`),
plus per-sub-skill symlinks (`dailybot-report`, `dailybot-messages`,
etc.) so each is invocable as a slash command.

### Verify it's wired up

After `setup.sh --host claude`, restart your agent. In a session, mention
something like *"check messages from my team"* — the agent should route
to the `dailybot-messages` sub-skill. If it doesn't, the symlinks aren't
being seen — try `ls -la ~/.claude/skills/ | grep dailybot` to confirm.

### Use the skill on this repo

Eat your own dog food: install the skill in the same agent you're using
to contribute, and let the auto-activation trigger send progress reports
on your work here. It's both validation (does the skill work for our
own work?) and documentation (PRs come with example reports).

---

## Making a change end-to-end

### 1. Branch from `main`

```bash
git switch main
git pull
git switch -c feat/your-change-name
```

We don't use Gitflow — branches off `main`, PR back into `main`. **Don't push directly to `main`** — branch protection blocks it, and even if it didn't, the auto-release workflow is triggered on every merge to main, so direct pushes would auto-release whatever you pushed.

### 2. Edit, test, commit

Edit anything under `skills/dailybot/` (runtime) or root-level dev
infrastructure (`.github/`, `tests/`, `scripts/`, `docs/`,
`AGENTS.md`, etc.). Your agent picks up runtime changes on its next
session because the install was via symlink.

Run the four local checks before you commit:

```bash
# Lint shell scripts
shellcheck setup.sh skills/dailybot/shared/context.sh scripts/*.sh

# Run unit tests (bats-core)
bats tests/

# Validate every SKILL.md frontmatter (kebab-case name, version, etc.)
python3 scripts/validate-frontmatter.py

# Smoke-test setup.sh against your local agent installation
./setup.sh --host claude
```

If any of these fail, fix before committing — CI runs the same checks
and will block the PR.

Quick sanity tests for the shared helper:

```bash
# context.sh emits valid JSON in a regular directory
bash skills/dailybot/shared/context.sh

# .dailybot/disabled silences output (per-repo opt-out)
mkdir -p .dailybot && touch .dailybot/disabled \
  && bash skills/dailybot/shared/context.sh \
  && rm -rf .dailybot

# DAILYBOT_AGENT_TOOL env var overrides agent detection
DAILYBOT_AGENT_TOOL=test-agent bash skills/dailybot/shared/context.sh
```

### 3. Don't bump the version manually

The `auto-release.yml` workflow owns `version:` fields and `CHANGELOG.md`.
Just write good commit messages — see the next section.

### 4. Push and open a PR

```bash
git push -u origin feat/your-change-name
gh pr create --base main --head feat/your-change-name
```

(Or use the GitHub web UI — `gh` CLI is convenient but optional.)

The PR template (`.github/PULL_REQUEST_TEMPLATE.md`) auto-populates
your PR body with the pre-merge checklist. Fill it in honestly.

---

## Commit conventions and the auto-release flow

Every merge to `main` triggers `auto-release.yml`, which:

1. Reads the current version from `skills/dailybot/SKILL.md` frontmatter.
2. Looks at commits since the last `vX.Y.Z` tag.
3. Decides the bump level from conventional-commit prefixes:
   - `feat(scope)!:` or `BREAKING CHANGE:` in body → **MAJOR**
   - `feat(scope):` → **MINOR**
   - everything else (`fix:`, `chore:`, `docs:`, `ci:`, no prefix) → **PATCH**
4. Updates the version in all 5 SKILL.md files.
5. Prepends a section to `CHANGELOG.md` listing the merged commits.
6. Commits as `chore(release): X.Y.Z [skip ci]`, tags `vX.Y.Z`, creates a GitHub Release.

So your commit messages directly determine the release version. Use
the format documented in [AGENTS.md](AGENTS.md) → "Commit Message
Format":

```
<type>(<scope>): <short description>

<body — Summary, motivation, what changed, risks>
```

**Types:** `feat`, `fix`, `docs`, `chore`, `test`, `ci`, `refactor`.

**Scopes:** `skill` (general pack), `report` / `messages` / `email` /
`health` (specific sub-skill), `shared` (auth.md, context.sh,
http-fallback.md), `setup` (setup.sh), `ci` (.github/), `docs`
(docs/), `release` (versioning, CHANGELOG).

### Bump-level guidance for this skill

| Bump | When | Example |
|------|------|---------|
| **MAJOR** | Breaks the public surface | Rename a CLI flag, change an HTTP endpoint shape, remove `<!-- dailybot-auto-activation -->` markers, remove an env var or sub-skill, drop `.dailybot/disabled` opt-out |
| **MINOR** | Additive — new capability without breaking existing behavior | New sub-skill (e.g. `dailybot-kudos`), new flag (`--dry-run`), new env var (`DAILYBOT_AUTO_YES`), new auto-activation trigger |
| **PATCH** | Bug fix, doc, internal refactor, CI change | Typo fix, regex tweak in credential-pattern scan, CI workflow update |

If you're not sure whether your change is MAJOR or MINOR, lean MAJOR
and explain in the PR body. A spurious major bump is recoverable; a
silent breaking change in a minor release is not.

### What you should *never* edit by hand

- `version:` field in any `SKILL.md` frontmatter
- `CHANGELOG.md` entries (the release section is generated)
- Git tags

If you do edit them by hand, the next auto-release will overwrite the
version line and prepend a duplicate changelog section.

---

## What CI checks

`.github/workflows/ci.yml` runs on every PR and every push to `main`,
with 6 jobs:

| Job | What it checks | Catches |
|-----|----------------|---------|
| **shellcheck** | `setup.sh`, `skills/dailybot/shared/context.sh`, `scripts/*.sh` | Bash syntax issues, unsafe quoting, unused vars |
| **context.sh smoke tests** | Output is valid JSON, `.dailybot/disabled` silences output, `DAILYBOT_AGENT_TOOL` override is honored | Behavioral regressions in the shared context detector |
| **bats tests** | All cases in `tests/*.bats` | Unit-test regressions |
| **SKILL.md frontmatter validation** | Every `skills/dailybot/**/SKILL.md` parses as valid YAML, has kebab-case `name`, has SemVer `version`, uses `documentation_url` (NOT `homepage`), has `user-invocable` boolean | Frontmatter drift, accidental snake_case, regression to legacy `homepage` field |
| **bash 3.2 compatibility** | `setup.sh`, `context.sh` work on macOS bash 3.2 | bash 4+ idioms (`mapfile`, `declare -A`, `${var^^}`) — these break for macOS users |
| **Markdown link check** | Internal cross-references and external links resolve | Dead links in docs |

The `concurrency` group ensures consecutive pushes cancel earlier
still-running jobs (the latest commit's status is authoritative).

---

## Pull request workflow

### Before opening

- [ ] Read [`AGENTS.md`](AGENTS.md) once if you haven't.
- [ ] Run all four local checks (shellcheck, bats, frontmatter, setup smoke).
- [ ] Confirm your commit messages follow the format and reflect the intended bump level.
- [ ] If you touched the public surface (CLI flags, HTTP endpoints, markers, env vars), call it out in the PR body.

### When you open

The PR template auto-populates the body. Fill it in:

- **Summary** — 1-3 sentences on what changed and why.
- **Type** — single checkbox.
- **Scope** — runtime skill, dev infra, or both.
- **Pre-merge checklist** — check items as you verify.
- **Test plan** — what you actually tested, on what platforms.
- **Risks** — anything reviewers should pay extra attention to.

### CI gates

`main` branch protection requires the 6-job CI to pass before merge.
There are no required reviewers (the org is small and trust is high),
but feel free to request a review if you want a second pair of eyes.

### Auto-release happens on merge

Once your PR merges to `main`, `auto-release.yml` fires and creates a
new release. You don't need to do anything — the workflow handles
version bump, CHANGELOG, tag, and GitHub Release.

If the workflow fails (most likely cause: `AUTOMATION_GITHUB_TOKEN`
secret missing or expired), fix the underlying issue and the next
merge will re-fire the release.

---

## Adding a new sub-skill

If you want to add a new capability under `skills/dailybot/` (e.g. a
`dailybot-kudos` skill that gives team recognition), follow the
step-by-step in [`docs/SUB_SKILL_GUIDE.md`](docs/SUB_SKILL_GUIDE.md).

The short version:

1. Decide the name (kebab-case, prefix `dailybot-`).
2. Create `skills/dailybot/<short-name>/SKILL.md` with the standard
   frontmatter (the guide has a copy-paste template).
3. Update the router meta-skill (`skills/dailybot/SKILL.md`) to mention
   the new sub-skill.
4. Add it to the `SKILLS` array in `setup.sh` so symlinks get created.
5. If user-invocable, add a trigger template in
   `skills/dailybot/report/triggers.md`.
6. Write a bats test covering the new behavior.
7. Update the README and the public API ref (`docs/API_REFERENCE.md`)
   if the new skill exposes a new HTTP endpoint or CLI command.

Use `feat(<short-name>):` as your commit prefix so the auto-release
flow detects a MINOR bump.

---

## What we will and won't merge

**We'll merge:**

- Bug fixes with a regression test under `tests/`.
- New sub-skills following the conventions in `docs/SUB_SKILL_GUIDE.md`.
- Documentation improvements — especially clarifications to the
  consent flows, install path, or anything in `docs/DESIGN.md`.
- Cross-platform fixes (bash 3.2 compat, Windows PowerShell, Docker,
  WSL2).
- New tests under `tests/` covering existing behavior.
- CI improvements that are clearly more value than maintenance cost.

**We probably won't merge** without a strong rationale (and we'll ask
for it):

- Removing or weakening a consent flow (CLI install confirmation,
  auto-activation opt-in, email pre-send confirmation + secret scan).
  These are load-bearing for our security posture and audit story.
- Re-introducing the `homepage:` field in frontmatter — agents
  misinterpret it as a re-fetch source. Use `documentation_url:`
  (the validator rejects new `homepage:` entries).
- Snake_case `name:` values in frontmatter (use kebab-case).
- Bash 4+ idioms (`mapfile`, `declare -A`, `${var^^}`) — they break
  for macOS users.
- Hardcoded SHA-256 hashes anywhere in the repo — they belong on
  the CDN, generated at release time by `DailybotHQ/cli`.
- Spanish or any non-English content. The repo is consumed worldwide.

When in doubt, open the PR and explain — we'd rather discuss in
context than reject something whose rationale we don't see yet.

---

## Reporting bugs and security issues

### Bugs

Open an issue using the bug report template
(`.github/ISSUE_TEMPLATE/bug_report.md`). Include:

- The agent you're using (Claude Code, Cursor, etc.) and its version.
- Your OS (macOS / Linux distro / Windows native / WSL2 / Docker).
- The skill version (from `skills/dailybot/SKILL.md` frontmatter, or
  `npx skills list` output).
- The install method (`npx skills add` / `git clone + setup.sh` /
  `openclaw skills install`).
- The exact error message or unexpected behavior.

### Security vulnerabilities

**Do not** open a public issue. Email `security@dailybot.com` per
[`SECURITY.md`](SECURITY.md). Reports against this repo reach the
Dailybot security team directly.

---

## Where to find more

| If you want to know… | Read |
|----------------------|------|
| Every convention and rule (canonical, terse) | [`AGENTS.md`](AGENTS.md) |
| Why the layout / consent flows / etc. are the way they are | [`docs/DESIGN.md`](docs/DESIGN.md) |
| How to add a new sub-skill in detail | [`docs/SUB_SKILL_GUIDE.md`](docs/SUB_SKILL_GUIDE.md) |
| The full install guide (6 methods, compare/update/uninstall) | [`docs/INSTALLATION.md`](docs/INSTALLATION.md) |
| The public CLI / HTTP API the skill calls | [`docs/API_REFERENCE.md`](docs/API_REFERENCE.md) |
| OpenClaw-specific install notes | [`docs/OPENCLAW.md`](docs/OPENCLAW.md) |
| Per-version release notes | [`CHANGELOG.md`](CHANGELOG.md) |
| Security disclosure | [`SECURITY.md`](SECURITY.md) |
| User-facing install / usage (quickstart) | [`README.md`](README.md) |

---

## Code of conduct

Be kind. Assume good faith. We're a small repo trying to make agents
useful for human teams — that goal is incompatible with bad-faith
contributions.

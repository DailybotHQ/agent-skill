# Changelog

All notable changes to the Dailybot agent skill pack are documented in this
file. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] — 2026-05-22

### Changes

- Merge pull request #7 from DailybotHQ/feat/user-scoped-skills
- feat(skill): add checkin, kudos, and forms sub-skills for user-scoped CLI commands


## [1.2.0] — 2026-05-05

### Changes

- Merge pull request #6 from DailybotHQ/security/audit-response
- Adding vscode example
- feat(security): explicit trust model for incoming user-generated content (W011)
- feat(security): defense-in-depth verified install resolves W012 without losing curl|bash UX
- chore: track .vscode_example/ as a shared workspace-settings template
- chore: gitignore VS Code workspace settings (.vscode/ and .vscode_*)
- docs(skill): polish the router SKILL.md to read well on the skills.sh listing


## [1.1.2] — 2026-05-03

### Changes

- Merge pull request #4 from DailybotHQ/docs/installation-guide
- docs(install): add docs/INSTALLATION.md as the canonical install guide


## [1.1.1] — 2026-05-03

### Changes

- Merge pull request #3 from DailybotHQ/docs/contributing-guide
- docs(contributing): expand CONTRIBUTING.md into a full onboarding guide


## [1.1.0] — 2026-05-03

### Changes

- Merge pull request #2 from DailybotHQ/ci/improvements
- ci: rename secret to AUTOMATION_GITHUB_TOKEN to match the CLI repo
- ci: use RELEASE_TOKEN secret in auto-release if available
- ci: dial back to base CI + add auto-release on merge to main
- ci: rename markdownlint config to a name markdownlint-cli2 accepts
- ci: harden the workflow + add markdown lint, spell check, and a CDN monitor
- docs: position the skill explicitly as the official Dailybot agent skill pack
- Merge pull request #1 from DailybotHQ/feat/initial-public-release-v1.0.0
- fix(security): point CLI vulnerability link to the correct repo path
- ci: ignore bare dailybot.com URL so the markdown link checker stops choking on inline JSON in SKILL.md frontmatter
- docs: drop the brand-spelling rule now that the repo has no legacy spellings to contrast against
- docs: update repo references to new DailybotHQ org name (lowercase b)
- feat(skill): align install flow with shipped Dailybot CLI v1.4.0
- docs: restore brand-spelling rule contrast in meta-documentation
- docs: normalize brand spelling to Dailybot across user-facing content
- docs: replace internal microservice names with generic placeholders in examples
- chore: replace tmp/README.md with .gitkeep placeholder
- chore: add .gitignore and tmp/ scratch directory for agents
- docs: align docs/ casing convention and add DESIGN.md + SUB_SKILL_GUIDE.md
- docs(release): flatten changelog to a single 1.0.0 entry
- chore(ci): add AGENTS.md, dev-time infrastructure, and CI workflow
- fix(skill): restore curl|bash as universal install path and add DAILYBOT_AUTO_YES escape hatch
- docs(skill): rewrite README with environment-disclosure section and align api-docs
- feat(skill): bash hardening and per-repo telemetry opt-out
- feat(skill): require explicit consent for CLI install, auto-activation, and email sends
- chore(skill): restructure to skills/dailybot/ layout and add open-source boilerplate
- Improvements on timeout management
- Improvements to skill
- Improving definition
- Improvements
- Initial version
- Initial version
- first commit


## [1.0.0] — 2026-05-01

First public release on the open
[Agent Skills](https://agentskills.io) standard. Distributable via
[skills.sh](https://skills.sh) (`npx skills add DailybotHQ/agent-skill`),
[OpenClaw](https://www.openclaw.dev) (`openclaw skills install dailybot`),
and direct git clone with `setup.sh`.

The skill ships four capabilities (progress reports, message polling,
email, health checks) coordinated by a router meta-skill, with
authentication and context detection shared across all of them. Anything
outside `skills/dailybot/` is repo-development infrastructure and is not
distributed at runtime.

### Highlights

- **Cross-agent compatible** — works with Claude Code, Cursor, OpenAI
  Codex, Gemini CLI, GitHub Copilot, Cline, Windsurf, and OpenClaw out of
  the box. `setup.sh` auto-detects installed agents and creates the
  per-agent symlinks.
- **Universal install path** — the bundled
  `https://cli.dailybot.com/install.sh` auto-detects the OS internally
  (Homebrew on macOS, prebuilt binary on Linux x86_64, pipx/uv/pip
  elsewhere). Native Windows users get a verified PowerShell variant.
- **Consent-first by default** — CLI install asks for confirmation the
  first time in a session and runs only after SHA-256 verification of
  the install script. Auto-activation in agent config files
  (`CLAUDE.md`, `AGENTS.md`, etc.) is opt-in with a visible
  `<!-- dailybot-auto-activation: BEGIN/END -->` marker so users can
  uninstall deterministically. Email sends require per-recipient
  confirmation, cache approvals in `~/.dailybot/email-approvals.json`,
  and abort on credential-pattern matches in the body or subject.
- **Per-repo opt-out** — drop `.dailybot/disabled` in any repo root and
  every outbound call from this skill stops silently for that repo.
- **CI escape hatch** — `DAILYBOT_AUTO_YES=1` skips the interactive
  consent prompts for install and auto-activation. SHA-256 verification
  still runs. Email pre-send checks are not bypassed.
- **Hardened by default** — all shell scripts use `set -euo pipefail`,
  pass `shellcheck` clean, work on bash 3.2 (macOS default), prefer
  vendor environment variables over process-name pattern matching for
  agent detection, and serialize JSON via `jq` (with `python3` and
  hardened-bash fallbacks) so control characters never break the
  payload.
- **Auditable** — `README.md` enumerates every binary the skill may
  install, every file it may create or modify, every network endpoint
  it may reach with the data sent, and the full uninstall recipe.
  `SECURITY.md` documents the disclosure channel
  (`security@dailybot.com`) and response SLA.

### Repository conventions

- All SKILL.md files use kebab-case `name`, quoted SemVer `version`,
  and `documentation_url` (the legacy `homepage` field is rejected by
  CI).
- Public surface that downstream systems depend on: HTTP endpoints
  under `api.dailybot.com/v1/agent-*/`, CLI flag names documented in
  any SKILL.md, the `dailybot-auto-activation` markers, the
  `.dailybot/disabled` opt-out, and the `DAILYBOT_AUTO_YES` and
  `DAILYBOT_API_KEY` environment variables.
- Contributor guide lives in [`AGENTS.md`](AGENTS.md) (with a
  `CLAUDE.md` symlink for Claude Code), with a friendlier human
  counterpart in [`CONTRIBUTING.md`](CONTRIBUTING.md).
- CI runs shellcheck, bats-core tests for `context.sh` and `setup.sh`,
  frontmatter validation, bash 3.2 compatibility checks on macOS
  runners, and markdown link checking on every PR.

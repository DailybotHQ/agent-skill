# Changelog

All notable changes to the Dailybot agent skill pack are documented in this
file. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.6.0] — 2026-07-12

### Changes

- Merge pull request #34 from DailybotHQ/feat/forms-filtering-sorting-automation
- feat(forms): document filtering, sorting, automation, guest identity, and source tracking


## [3.5.0] — 2026-07-12

### Changes

- Merge pull request #33 from DailybotHQ/feat/dashboard-urls-and-3.3.0-sync
- feat(skill): add dashboard URL catalog and sync with CLI 3.3.0


## [3.4.0] — 2026-07-11

### Changes

- Merge pull request #32 from DailybotHQ/feat/conversation-and-form-list-mine
- feat(skill): add conversation sub-skill (Slack group DMs) and document org-scoped form list --mine


## [3.3.0] — 2026-07-10

### Changes

- Merge pull request #31 from DailybotHQ/feat/cli-floor-3.1.2
- feat(skill): set dailybot-cli >= 3.1.2 as the single baseline for every sub-skill


## [3.2.0] — 2026-07-10

### Changes

- Merge pull request #30 from DailybotHQ/feat/channels-and-doc-url
- feat(skill): add the channels sub-skill and move docs URL to www.dailybot.com


## [3.1.0] — 2026-07-10

### Changes

- Merge pull request #29 from DailybotHQ/feat/api-v3-contract-docs
- feat(skill): document the uuid-keyed, always-paginated API contract


## [3.0.1] — 2026-07-10

### Changes

- Merge pull request #27 from DailybotHQ/fix/safer-install-guidance
- docs(skill): standardize on curl -fsSL and document the verified install for agents


## [3.0.0] — 2026-07-10

### Changes

- Merge pull request #26 from DailybotHQ/feat/cli-2.0-surface
- Merge branch 'main' into feat/cli-2.0-surface
- feat!: document CLI 2.0.0 surface and bump skill pack to 2.0.0


## [2.0.0] — 2026-07-10

### Added

- **Browse/read surface for the workspace (requires `dailybot-cli >= 2.0.0`).**
  Documented an entire new read-only capability cluster:
  - **Account context** — `dailybot me` (`GET /v1/me/`), `dailybot org`
    (`GET /v1/organization/`), and `dailybot user get <uuid>`
    (`GET /v1/users/<uuid>/`) in `teams/SKILL.md`.
  - **Kudos browsing** — `kudos list` (with `--filter KUDOS_RECEIVED|KUDOS_GIVEN`),
    `kudos org` (org-wide stats, **API-key-only** — rejects a Bearer login with
    403), and `kudos wall-of-fame` (leaderboard) in `kudos/SKILL.md`.
  - **Workflows (read-only)** — new `dailybot-workflow` sub-skill
    (`workflow/SKILL.md`) covering `workflow list` / `workflow get`. Writes are
    web-app only; the feature is plan-gated.
- **Shared list query flags** — new `shared/list-query-and-errors.md` reference
  documenting pagination (`--page`, `--page-size`, `--all`, `--limit`), search
  (`--search` / `--grep`, max 256 chars), and date filters (`--since`, `--until`,
  `--date`, `--last-week`, `--today`) on `form list` / `kudos list` /
  `workflow list` (plus `--search` on `form responses` and `checkin history`),
  the `{count, next, previous, results}` envelope, the `Showing X of N` footer,
  and the `?paginated=true` behavior on the two forms endpoints.
- **Chat send-as-identity** — documented `dailybot chat send --send-as-user <uuid>`
  and `--send-as-me` (Slack only, admin-only, mutually exclusive with the
  `--bot-*` identity flags, validated client-side) in `chat/SKILL.md`.
- **Machine-readable error codes** — the shared reference now catalogs the stable
  `code` field the CLI dispatches on (never the human `detail`): 403
  (`plan_upgrade_required`, `plan_free_api_keys_forbidden`,
  `plan_missing_core_api_integrations`, `api_key_owner_inactive`,
  `insufficient_role`, `member_in_scope_required`, `org_admin_required`), 400
  (`target_user_inactive`, `search_query_too_long`, `invalid_date_range`,
  `send_as_user_conflict`, `send_as_user_invalid_uuid`, `send_as_user_not_found`),
  and 429 (`free_plan_daily_limit_exceeded`, plus the bounded back-off on generic
  429s).
- **Auth parity + free-plan gating** — documented that `X-API-KEY` works on every
  `/v1/` endpoint except `POST /v1/cli/auth/logout/` (Bearer-only), that API keys
  and Bearer sessions are interchangeable on user-scoped commands, and that FREE
  plans block API keys entirely while restricting Bearer to an allowlist
  (agent-reports, send-email, agent-messages, agent health, agent register+claim,
  and `me` / `org` / `cli status`).

### Changed

- Main `SKILL.md`: extended the frontmatter description, grew the capability
  table to eleven entries (added **Workflows**; noted the new read/browse
  abilities under Kudos, Forms, Teams, Chat), added routing rules for the new
  intents, added a `2.0.0` version-floor block, and linked the new shared doc.

> All 2.0.0 features require **`dailybot-cli >= 2.0.0`**.

## [1.8.6] — 2026-07-10

### Changes

- Merge pull request #25 from DailybotHQ/docs/durable-cli-version-reference
- docs(skill): reference the latest CLI on PyPI instead of a hardcoded version


## [1.8.5] — 2026-07-08

### Changes

- Merge pull request #24 from DailybotHQ/docs/self-contained-onboarding-and-trust
- docs(skill): correct CLI version floors in first-run step 1
- docs(skill): self-contained first-run onboarding + shipped TRUST.md


## [1.8.4] — 2026-07-08

### Changes

- Merge pull request #23 from DailybotHQ/feat/report-continuous-mode-docs
- docs(skill): reference dailybot-cli 1.19.0 as the current published release
- chore(report): enable continuous report mode for this repo (dogfood)
- docs(report): document continuous report mode and soft_turn_threshold


## [1.8.3] — 2026-07-07

### Changes

- Merge pull request #22 from DailybotHQ/docs/reference-cli-1.18.0
- docs(skill): reference dailybot-cli 1.18.0 as current published release


## [1.8.2] — 2026-07-07

### Changes

- Merge pull request #21 from DailybotHQ/docs/checkin-responses-scoping
- docs(checkin): document check-in responses default scoping (all participants)


## [1.8.1] — 2026-07-06

### Changes

- Merge pull request #20 from DailybotHQ/fix/require-questions-on-create
- docs(checkin,forms): questions required at create + reference CLI 1.17.1


## [1.8.0] — 2026-07-06

### Changes

- Merge pull request #19 from DailybotHQ/fix/auto-release-commit-message-quoting
- fix(ci): pass commit messages via env in auto-release (was breaking on quotes)
- Merge pull request #18 from DailybotHQ/docs/checkin-forms-authoring
- fix(skill): valid YAML in authoring descriptions + reference CLI 1.17.0
- feat(checkin,forms): document check-in & form authoring (create/configure/questions)
- Merge pull request #17 from DailybotHQ/docs/installer-version-pinning
- docs(skill): document installer version pinning + bump to CLI 1.16.0
- Merge pull request #16 from DailybotHQ/docs/repo-profile-report-block
- docs(skill): point CLI version references at the current published 1.15.1
- docs(shared): document the report policy block in repo-profile.md
- Merge pull request #15 from DailybotHQ/feat/ask-subskill-full-parity
- docs(checkin): document the full check-in lifecycle in the skill pack
- fix(skill): redact real internal identifiers from examples + add privacy rule
- feat(ask): add headless AI-chat sub-skill + full API-key parity
- Merge pull request #14 from DailybotHQ/chore/report-skill-respect-repo-profile
- chore(repo): pin agent identity to "Agent Skill" via .dailybot/profile.json
- feat(skill): mandatory pre-flight to respect .dailybot/profile.json


## [1.7.1] — 2026-06-12

### Changes

- Merge pull request #13 from DailybotHQ/chore/pin-cli-1.13.1
- docs(chat): bump dailybot-cli pin reference to 1.13.1 (current published)


## [1.7.0] — 2026-06-12

### Changes

- Merge pull request #12 from DailybotHQ/feat/dailybot-chat-skill
- docs(chat): pin dailybot-cli 1.13.0 as the published floor
- feat(chat): add dailybot-chat sub-skill (Slack/Teams/Discord/Google Chat)


## [Unreleased]

### Added

- **Check-in & form authoring** — the `dailybot-checkin` and `dailybot-forms` sub-skills now document the full **create / configure / manage-questions** surface, not just the response lifecycle. An agent can stand up and edit a check-in or form end-to-end:
  - **Check-ins:** `checkin create` / `checkin config` with the complete web-parity config — schedule (weekly + `--frequency-advanced` monthly/custom + `--cron`), **required participants** (users/teams, resolvable by name/email/UUID), reminders (count/interval/condition/**tone**), submission rules, privacy, intro/outro, and **smart/AI** (`--smart`, `--intelligence`, `--max-clarifying`). Anonymous is irreversible.
  - **Forms:** `form create` / **`form config`** with **workflow states** (`--state "Label:#color"`), three **permission audiences** (edit / see / change-states), **anonymous / public / brand / require-identity** (with a returned `public_url`), **approval flow** + approvers, and a **ChatOps command**. Forms may have zero questions.
  - **Questions (both):** all 4 types (`text`, `multiple_choice`, `boolean`, `numeric`), blocker tagging, a **required report title** (`--short-question`, or `--ai-short-question` to let AI generate it), **variations**, and **conditional logic** (`--logic-file` or inline `--jump-if-equals/--jump-to`; operators/actions/connectors, forward-only jumps, `trigger_form`/`trigger_checkin`). Report channels capped at 3; audiences/approvers use full-replace; reorder needs the complete UUID set.
- **`dailybot-chat` sub-skill** — send and edit Dailybot bot messages on the team's connected chat platform (Slack, Microsoft Teams, Discord, Google Chat). Targets user DMs, channels, and whole teams. Supports **report-style threads** (a short headline plus up to 10 replies posted inside its thread in a single call) and **in-place edits** of the parent or any individual thread reply via the returned `bot_message_id`s. Documents the **dual auth model** for `POST /v1/send-message/` — accepts either the login Bearer token (sends *as the user*, role-scoped to what they can reach in their own org) or an organization API key (org-wide). Requires `dailybot-cli >= 1.13.0`. See [`skills/dailybot/chat/SKILL.md`](skills/dailybot/chat/SKILL.md).
- **`setup.sh` symlinks `dailybot-chat` and `dailybot-teams`** — the teams sub-skill was previously missing from the SKILLS array (pre-existing oversight); both are now installed by `setup.sh`. Bats coverage extended to assert all nine sub-skill symlinks exist after install.

### Changed

- Router `skills/dailybot/SKILL.md` updated: "What it does" table now lists nine capabilities (added Chat row), routing rules surface chat-intent phrases, and a new Report-vs-Chat disambiguation note explains when to pick which.
- Router capability list + routing table now surface the check-in/form **authoring** intents ("create a check-in / form", "add workflow states / a ChatOps command", "add a question / conditional logic", …).
- `dailybot-forms` form-detail JSON examples corrected to the canonical nested `workflow` object (`{enabled, states:[{key,label,color,order}]}`), replacing the stale `workflow_enabled` / `workflow_config` keys.
- `README.md` table, install-method snippets, network-call table, repo layout diagram, and uninstall command updated to reflect the new sub-skill and the previously-missing `dailybot-teams` symlink.
- `docs/INSTALLATION.md` symlink list and verification checklist updated to show all nine sub-skills.
- `docs/API_REFERENCE.md` and `shared/http-fallback.md` `POST /v1/send-message/` row expanded to document threads, the dual auth, and the in-place edit semantics — mirroring the CLI's `docs/API_REFERENCE.md`.

### Notes

- The CLI side ([`DailybotHQ/cli` PR #25](https://github.com/DailybotHQ/cli/pull/25), merged 2026-06-12) ships the underlying `dailybot chat send` / `chat update` command group, `--thread-message` (≤10 per call), reply-id editing, and the friendlier error translations (`cli_send_message_target_not_allowed`, `invalid_thread_responses`, `429`). Released as **[`dailybot-cli 1.13.0`](https://pypi.org/project/dailybot-cli/1.13.0/)** on 2026-06-12 ([release notes](https://github.com/DailybotHQ/cli/releases/tag/v1.13.0)).

## [1.6.1] — 2026-06-10

### Changes

- Merge pull request #11 from DailybotHQ/fix/hook-offer-for-existing-trigger-users
- fix(report): offer hook enforcement to developers who already have the prompt trigger


## [1.6.0] — 2026-06-10

### Changes

- Merge pull request #10 from DailybotHQ/feat/hook-enforcement-cli-1-12
- feat(report): add deterministic hook enforcement via dailybot-cli 1.12.0


## [1.5.0] — 2026-06-09

### Changes

- Merge pull request #9 from DailybotHQ/feat/core-2008-agent-report-url
- docs(report): clarify placement link requires CLI 1.11.0
- feat(report): surface report placement link on confirm


## [1.4.0] — 2026-05-26

### Changes

- Merge pull request #8 from DailybotHQ/feat/forms-lifecycle-teams-kudos
- docs(skill): document dailybot-cli >=1.10.0 requirement
- feat(skill): forms lifecycle, teams skill, team-aware kudos


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

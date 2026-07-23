# Dailybot Agent Skill Pack

> The official Dailybot agent skill pack, maintained by [Dailybot](https://www.dailybot.com).

Give your AI coding agent the ability to report progress, check for messages,
send emails, announce status, complete check-ins, give kudos, submit forms,
**send chat messages on Slack / Teams / Discord / Google Chat** (with
report-style threads, interactive buttons, and in-place edits), and **trigger
workflows** — all through Dailybot. Your team sees what the agent
accomplished, sends instructions, and stays coordinated across humans and
agents.

- **License:** [MIT](LICENSE)
- **Security policy:** [SECURITY.md](SECURITY.md)
- **Changes:** [CHANGELOG.md](CHANGELOG.md)
- **Format:** [Open Agent Skills](https://agentskills.io) standard
- **Companion CLI:** [`DailybotHQ/cli`](https://github.com/DailybotHQ/cli)

## Skills

| Skill | What it does |
|-------|-------------|
| **dailybot-report** | Send progress updates after completing meaningful work. Reports read like standup updates — no one can tell they came from an agent. With `dailybot-cli >= 1.12.0`, lifecycle hooks make the reminders deterministic — reporting becomes fully autonomous. |
| **dailybot-messages** | Check for pending messages and instructions from the team. The "what should I work on next?" skill. |
| **dailybot-email** | Send emails via Dailybot. Per-recipient first-use approval, mandatory pre-send confirmation, and a credential-pattern scan run before every send. |
| **dailybot-health** | Announce agent online/offline status. For long-running or scheduled agents to stay visible and pick up instructions. |
| **dailybot-checkin** | Full check-in lifecycle: list/status, complete, inspect questions & schedule, response history, edit/reset a response, and backfill or future-date — all headless with `--json`. Works with a login session **or** an API key (`dailybot-cli >= 1.15.0`). |
| **dailybot-kudos** | Give kudos to a teammate to recognize their contributions. Team-visible recognition through Dailybot. |
| **dailybot-forms** | List and submit form responses (feedback surveys, retros, pulse checks). Works with a login session **or** an API key (`dailybot-cli >= 1.15.0`). |
| **dailybot-chat** | Send and edit bot messages on the team's connected chat platform (Slack / Microsoft Teams / Discord / Google Chat). DMs, channels, or whole teams; report-style threads (headline + replies in one call); interactive buttons (approval flows, workflow triggers, modals, callbacks); edit the parent or any thread reply afterward. Requires `dailybot-cli >= 1.13.0`. |
| **dailybot-workflow** | List, inspect, and trigger Dailybot workflows. Fire API-triggerable workflows on demand with optional JSON payloads. Plan-gated feature. |
| **dailybot-ask** | Ask the Dailybot AI a question headlessly — `dailybot ask "..."` prints the answer to stdout (or `--json`). The primary way an agent queries the Dailybot AI with only an API key. Requires `dailybot-cli >= 1.15.0`. |

A root **dailybot** meta-skill acts as a router — it describes all
capabilities and routes to the right sub-skill based on the developer's
intent.

Each skill can be used independently or together. They share authentication
and context detection through a common `shared/` directory.

## Install

The three most common paths are below. **Six paths in total** are
supported (including OpenClaw's native registry, conversational install
via your agent, manual git clone, and a no-install HTTP-only fallback)
— see [`docs/INSTALLATION.md`](docs/INSTALLATION.md) for the full
guide with comparison table and per-method update / uninstall
instructions.

### Option 1 — `npx skills` (cross-agent, recommended)

The [skills.sh](https://skills.sh) CLI auto-detects your agent and installs
the skill in the right place:

```bash
npx skills add DailybotHQ/agent-skill
```

To target a specific agent or list available skills first:

```bash
npx skills add DailybotHQ/agent-skill --list
npx skills add DailybotHQ/agent-skill -a claude-code
```

### Option 2 — Git clone + setup script

Pick the path for your agent, clone, then run `setup.sh`:

| Agent | Default path |
|-------|--------------|
| Claude Code | `~/.claude/skills/dailybot/` |
| Cursor | `~/.cursor/skills/dailybot/` |
| OpenAI Codex | `~/.codex/skills/dailybot/` |
| Windsurf | `~/.codeium/windsurf/skills/dailybot/` |
| GitHub Copilot | `~/.copilot/skills/dailybot/` |
| Cline | `~/.cline/skills/dailybot/` |
| Gemini CLI | `~/.gemini/skills/dailybot/` |
| OpenClaw | `<workspace>/skills/dailybot/` or `~/.openclaw/skills/` |

```bash
git clone https://github.com/DailybotHQ/agent-skill.git ~/dailybot-skill
cd ~/dailybot-skill
./setup.sh                # auto-detect installed agents
./setup.sh --host claude  # or target one agent explicitly
```

`setup.sh` symlinks each sub-skill (`dailybot-report`, `dailybot-messages`,
`dailybot-email`, `dailybot-health`, `dailybot-checkin`, `dailybot-kudos`,
`dailybot-teams`, `dailybot-forms`, `dailybot-chat`) into the agent's skills
directory so they're discoverable as independent slash commands.

### Option 3 — OpenClaw native registry

```bash
openclaw skills install dailybot
```

OpenClaw loads the pack natively on every eligible session — no trigger
setup required. Configure the API key in `~/.openclaw/openclaw.json` per the
example in `skills/dailybot/report/triggers.md`.

### Invoke a skill

Once installed, mention Dailybot in your IDE and the agent will route to the
right sub-skill:

- "Report this to Dailybot" → **dailybot-report**
- "Do I have messages?" → **dailybot-messages**
- "Email this to Alice" → **dailybot-email**
- "Complete my check-in" → **dailybot-checkin**
- "Give kudos to Jane" / "kudos al equipo Engineering" → **dailybot-kudos**
- "Fill out the feedback form" → **dailybot-forms**
- "Send a Slack message to #releases" / "DM Sergio in chat" / "post a deploy report with the changelog in a thread" / "send an approval request with buttons" → **dailybot-chat**
- "Trigger the deploy workflow" / "list my workflows" → **dailybot-workflow**

Or invoke directly: `/dailybot_report`. The messages, email, and health
skills are agent-only — the agent uses them autonomously without a slash
command.

### Fully autonomous reporting (CLI >= 1.12.0)

With `dailybot-cli >= 1.12.0`, the skill can additionally install
**lifecycle hooks** (with your consent) so your agent harness itself runs
`dailybot hook` commands at session start, after file edits, and at the end
of every turn. A local per-repo ledger detects unreported work — commits
*and* non-commit work like research or documents — and reminds the model to
report at the right moment, with built-in anti-noise gates (30-min interval,
cooldown, snooze, per-repo opt-out). After a one-time `dailybot login`,
reporting needs no human reminders and survives new sessions and container
rebuilds. Details: `skills/dailybot/report/hooks.md`.

On first use, the agent shows the proposed CLI install command and asks for
your confirmation before installing anything. After confirmation, it walks
you through Dailybot login (OTP preferred; API key or HTTP fallback when the
CLI cannot run).

---

## What this skill does to your environment

For full transparency, this section enumerates every external action the
skill takes. Use this to evaluate whether the skill is acceptable for your
environment before installing it.

### Binaries it may install

The skill never installs anything without showing you the command and asking
for confirmation **the first time** in a session. After you confirm once,
later invocations in the same session do not re-prompt.

The CLI ships **one universal install script** that auto-detects your OS:

| OS | What `install.sh` does internally |
|----|-----------------------------------|
| macOS | `brew install dailybothq/tap/dailybot` |
| Linux x86_64 | Downloads the prebuilt binary released on GitHub |
| Linux ARM / Windows / fallback | `pipx install dailybot-cli` (or `uv tool install`, or `pip install --user`) |

So the canonical install command on every system is:

```bash
curl -fsSL https://cli.dailybot.com/install.sh        -o /tmp/install.sh
curl -fsSL https://cli.dailybot.com/install.sh.sha256 -o /tmp/install.sh.sha256
( cd /tmp && shasum -a 256 -c install.sh.sha256 ) && bash /tmp/install.sh
```

For **native Windows without WSL2 / Git Bash**, the equivalent PowerShell
command is documented in `skills/dailybot/shared/auth.md` and uses
`install.ps1` + `install.ps1.sha256` instead. If you have WSL2 or Git Bash,
prefer the bash path above.

If you'd rather drive the install yourself, `brew install dailybothq/tap/dailybot`
(macOS), `pipx install dailybot-cli`, or `uv tool install dailybot-cli`
all produce the same `dailybot` binary.

The skill **declines** to run the install script if its published checksum
(`https://cli.dailybot.com/install.sh.sha256`) is unreachable, and offers to
either skip the install (use HTTP API) or proceed unverified after explicit
extra consent. The checksum is auto-regenerated on every push to the CLI
repo via `sync-installer-checksums.yml`, so this fallback is rare.

### Upgrading the CLI

The CLI owns its own upgrade flow (since v1.4.0):

```bash
dailybot upgrade           # auto-detect install method and run the right upgrade
dailybot version --check   # print current vs latest, with the exact upgrade command
```

The skill does not pin a CLI version or reimplement upgrade logic —
PyPI's `dailybot-cli` is the source of truth.

### Skipping consent prompts (CI, Docker, power users)

Set `DAILYBOT_AUTO_YES=1` in your environment to pre-approve install and
auto-activation prompts for the session. The SHA-256 verification still
runs. **Email pre-send checks are NOT bypassed by this variable** — they
are mandatory.

```bash
export DAILYBOT_AUTO_YES=1
```

### Files it may create or modify

| File | Why | When | How to remove |
|------|-----|------|---------------|
| `~/.dailybot/config` | Stores API key when the developer chooses `dailybot config key=...` | After login | `rm ~/.dailybot/config` |
| `~/.dailybot/email-approvals.json` | Caches addresses you have approved for `dailybot-email` | First time you confirm a recipient | `rm ~/.dailybot/email-approvals.json` |
| `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md`, `~/.cline/.clinerules`, `~/.agents/AGENTS.md` | Auto-activation trigger (only with explicit consent in Step 0 of the report skill) | First time you accept the auto-activation prompt | Delete the block between `<!-- dailybot-auto-activation: BEGIN -->` and `<!-- dailybot-auto-activation: END -->` |
| `~/.cursor/rules/dailybot.mdc`, `.windsurf/rules/dailybot.md` | Auto-activation rule (file is the marker — same opt-in flow) | First time you accept the auto-activation prompt | `rm` the file |
| `~/.claude/settings.json`, `~/.cursor/hooks.json` (or their repo-level equivalents, e.g. `.github/hooks/dailybot.json`) | Lifecycle-hook entries running `dailybot hook ...` for deterministic report reminders (opt-in, requires `dailybot-cli >= 1.12.0`; hook commands are local-only and never call the network) | First time you accept the hook-enforcement prompt | Remove the entries containing `dailybot hook` (or delete the dedicated file) |

The skill does **not** modify any file in your project repos other than
respecting `.dailybot/disabled` (read-only).

### Network calls it makes

All outbound calls go to `api.dailybot.com` over HTTPS:

| Endpoint | Triggered by | Data sent |
|----------|--------------|-----------|
| `POST /v1/agent-reports/` | `dailybot-report` skill | `agent_name`, `content`, `structured` (optional), `metadata` (repo name, branch, agent tool, agent name, model) |
| `POST /v1/agent-health/` | `dailybot-health` skill | `agent_name`, `ok`, `message` |
| `GET /v1/agent-messages/` | `dailybot-messages` skill | `agent_name` query param |
| `POST /v1/agent-email/send/` | `dailybot-email` skill (after confirmation + secret scan) | `agent_name`, `to`, `subject`, `body_html`, `metadata` |
| `GET /v1/cli/status/` | `dailybot-checkin` skill | `X-API-KEY` **or** Bearer |
| `GET /v1/checkins/` `GET /v1/checkins/<uuid>/` | `dailybot-checkin` (status/show) | `X-API-KEY` or Bearer; `?date&include_summary` |
| `GET /v1/templates/<uuid>/` | `dailybot-checkin` (show questions) | `X-API-KEY` or Bearer; `?render_special_vars&followup_id` |
| `GET/POST/PUT/DELETE /v1/checkins/<uuid>/responses/` | `dailybot-checkin` (history/complete/edit/reset) | `X-API-KEY` or Bearer; `?date_start&date_end` |
| `GET /v1/forms/` | `dailybot-forms` skill | `X-API-KEY` **or** Bearer |
| `POST /v1/forms/<uuid>/responses/` | `dailybot-forms` skill | `X-API-KEY` or Bearer, content map |
| `GET /v1/users/` | `dailybot-kudos` and `dailybot-chat` skills (recipient resolution) | `X-API-KEY` **or** Bearer |
| `POST /v1/kudos/` | `dailybot-kudos` skill | `X-API-KEY` or Bearer, `receivers` list, content |
| `GET /v1/teams/` | `dailybot-teams` skill (team-name resolution; used by kudos + chat) | `X-API-KEY` **or** Bearer |
| `POST /v1/cli/chat/completions/` | `dailybot-ask` skill | `X-API-KEY` **or** Bearer; `{message}` → AI answer; 30 req/min per key |
| `POST /v1/send-message/` | `dailybot-chat` skill | **Either** `X-API-KEY` (org-wide) **or** Bearer token (login, role-scoped). Targets users/channels/teams, optional `thread_responses[]` for replies, optional `bot_message_id` to edit a previous message (parent or reply), optional `buttons[]` for interactive buttons |
| `GET /v1/workflows/` | `dailybot-workflow` skill (list/get) | `X-API-KEY` **or** Bearer |
| `POST /v1/workflows/<uuid>/trigger/` | `dailybot-workflow` skill (trigger) | `X-API-KEY` **or** Bearer; optional `{payload}` JSON object (≤8 KiB) |
| `https://cli.dailybot.com/install.sh{,.sha256}` | CLI install on first session, with consent | None (download only) |

### Per-repo opt-out

Drop a `.dailybot/disabled` file in any repo where you don't want the skill
to send anything:

```bash
mkdir -p .dailybot && touch .dailybot/disabled
```

`shared/context.sh` walks up from the current directory looking for that
file. If it finds one, it exits silently and no telemetry leaves the
machine. The check is performed before every report, health check, message
poll, and email send.

### What's never collected

- File contents from your repo (only repo name and branch from git metadata)
- Diff statistics or line counts
- Source code, secrets, environment variables (other than the agent vendor
  detection vars listed in `shared/context.sh`)
- Anything from a repo with `.dailybot/disabled` present

---

## Authentication

Your agent guides you through authentication on first use after you've
confirmed CLI install. You can also set it up manually:

```bash
# Interactive login (email OTP) — recommended
dailybot login

# Store an API key on disk
dailybot config key=your-key

# Or set an environment variable
export DAILYBOT_API_KEY=your-key
```

> **Don't have a Dailybot account?** Register directly from the CLI:
> ```bash
> dailybot agent register --org-name "My Team" --agent-name "Cursor"
> ```
> This creates an organization and API key. Share the claim URL from the
> output with your team admin to connect Slack, Teams, Discord, or Google
> Chat.

---

## Repository Layout

```
agent-skill/
├── README.md
├── LICENSE
├── SECURITY.md
├── CHANGELOG.md
├── setup.sh                       — symlink installer for non-skills.sh users
├── docs/
│   ├── openclaw.md                — OpenClaw-specific notes
│   └── skill.md                   — public API reference (served at www.dailybot.com/skill.md)
└── skills/
    └── dailybot/                  — the discoverable skill (skills.sh entry point)
        ├── SKILL.md               — router meta-skill
        ├── shared/
        │   ├── auth.md            — auth + consent flow
        │   ├── context.sh         — context detection + .dailybot/disabled check
        │   └── http-fallback.md   — HTTP API patterns
        ├── report/
        │   ├── SKILL.md           — progress reporting
        │   ├── triggers.md        — auto-activation templates
        │   ├── hooks.md           — deterministic hook enforcement (CLI >= 1.12.0)
        │   ├── significance.md    — when to report vs stay silent
        │   ├── writing-guide.md   — writing templates
        │   └── examples.md        — good vs bad examples
        ├── messages/SKILL.md      — message polling
        ├── email/SKILL.md         — email sending with safety checks
        ├── health/SKILL.md        — health check / status
        ├── checkin/SKILL.md       — check-in completion (user-scoped)
        ├── kudos/SKILL.md         — user + team recognition (user-scoped)
        ├── teams/SKILL.md         — team listing + name resolver (shared with kudos + chat)
        ├── forms/SKILL.md         — form submission (user-scoped)
        ├── workflow/SKILL.md      — workflow list, inspect, and trigger (plan-gated)
        └── chat/SKILL.md          — Slack/Teams/Discord/Google Chat bot messages (CLI >= 1.13.0; latest on PyPI)
```

## Execution Paths

Every skill supports two execution paths:

- **CLI** (`dailybot agent ...`) — preferred, handles auth and retries automatically
- **HTTP API** (`curl` to `https://api.dailybot.com/v1/...`) — fallback for sandboxed environments, CI, or containers

Both produce identical results.

## Update

```bash
# npx
npx skills update DailybotHQ/agent-skill

# Git clone
cd <skill-path> && git pull && ./setup.sh

# OpenClaw
openclaw skills update dailybot
```

## Uninstall

```bash
# Remove the skill pack itself
rm -rf <skill-path>

# Remove sub-skill symlinks (Claude Code example)
rm -f ~/.claude/skills/dailybot \
      ~/.claude/skills/dailybot-report \
      ~/.claude/skills/dailybot-messages \
      ~/.claude/skills/dailybot-email \
      ~/.claude/skills/dailybot-health \
      ~/.claude/skills/dailybot-checkin \
      ~/.claude/skills/dailybot-kudos \
      ~/.claude/skills/dailybot-teams \
      ~/.claude/skills/dailybot-forms \
      ~/.claude/skills/dailybot-chat

# Remove auto-activation block (if you opted in)
#   Edit the file from the table above and delete the block between
#   <!-- dailybot-auto-activation: BEGIN --> and <!-- dailybot-auto-activation: END -->.
#   For Cursor/Windsurf, just delete the dailybot.mdc / dailybot.md file.

# Remove cached approvals
rm -rf ~/.dailybot

# OpenClaw
openclaw skills remove dailybot
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Agent doesn't know about Dailybot | Verify the skill pack is installed and run `./setup.sh` |
| Skill found but not auto-activating | Invoke the report skill once and accept the auto-activation prompt |
| "Dailybot CLI not found" | Choose one of the install methods in `skills/dailybot/shared/auth.md` |
| "Not authenticated" | Run `dailybot login`, `dailybot config key=<key>`, or set `DAILYBOT_API_KEY` |
| Session seems stale | Run `dailybot logout` then `dailybot login` |
| Reports not appearing | Run `dailybot status --auth` and verify no `.dailybot/disabled` file exists |
| Symlinks not created | Run `./setup.sh` from the skill pack root directory |
| Want to disable for one repo | `mkdir -p .dailybot && touch .dailybot/disabled` |

## Links

- [Dailybot](https://www.dailybot.com)
- [Dailybot CLI on PyPI](https://pypi.org/project/dailybot-cli/)
- [Dailybot Agents feature](https://www.dailybot.com/features/agents)
- [Dailybot API skill reference](https://www.dailybot.com/skill.md)
- [API documentation (Swagger)](https://api.dailybot.com/api/swagger/)
- [Open Agent Skills standard (agentskills.io)](https://agentskills.io)
- [skills.sh](https://skills.sh) — cross-agent skills directory
- [Contributing](CONTRIBUTING.md) — how to change this repo (only `skills/dailybot/` ships to users)
- [AGENTS.md](AGENTS.md) — rules for AI agents editing this repository

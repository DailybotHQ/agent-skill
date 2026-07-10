# Installation Guide

The Dailybot agent skill pack supports six install paths, ordered here
from "easiest, most users should use this" to "edge-case fallback for
sandboxed environments." Pick the one that matches your situation. All
paths produce the same runtime behavior — what differs is the install
ergonomics.

If you're picking for the first time and aren't sure: **use Method 1
(`npx skills add`).** It's the cross-agent, auto-detect, easy-to-update
path. The other five exist for environments where it doesn't fit.

---

## Quick comparison

| Method | When to use | Command (TL;DR) |
|--------|-------------|-----------------|
| 1. `npx skills add` (recommended) | Any agent, any OS, you have Node available | `npx skills add DailybotHQ/agent-skill` |
| 2. OpenClaw native | You're on OpenClaw | `openclaw skills install dailybot` |
| 3. Conversational | You want zero ceremony — just tell your agent | *"install this skill from `https://www.dailybot.com/skill.md`"* |
| 4. Git clone + `setup.sh` | No Node available, you want explicit control | `git clone … && ./setup.sh` |
| 5. Manual per-agent | You want one specific agent and no symlink layer | `git clone … ~/.<agent>/skills/dailybot` |
| 6. HTTP-only (no install) | Sandboxed environment, CI, serverless — agent reads the API reference instead of installing | (no install — see below) |

---

## Method 1 — `npx skills add` (cross-agent, recommended)

Uses the [skills.sh](https://skills.sh) CLI maintained by Vercel. It
auto-detects which AI coding agents you have installed and creates the
appropriate symlinks for each.

```bash
npx skills add DailybotHQ/agent-skill
```

Useful flags:

| Flag | Purpose |
|------|---------|
| `--list` | Show the skills in the repo without installing | 
| `-a <agent>` | Install for a specific agent only (e.g. `-a claude-code`, `-a cursor`) |
| `-g, --global` | Install globally (`~/.<agent>/skills/`) instead of per-project |
| `--copy` | Copy files instead of symlinking (use when symlinks aren't supported) |
| `-y` | Skip all prompts (CI/CD-friendly) |

Examples:

```bash
# Just see what's in the repo
npx skills add DailybotHQ/agent-skill --list

# Install only into Claude Code, globally
npx skills add DailybotHQ/agent-skill -a claude-code -g

# Non-interactive (e.g. inside a Dockerfile or CI step)
npx skills add DailybotHQ/agent-skill -y
```

To update later:

```bash
npx skills update DailybotHQ/agent-skill
```

To uninstall:

```bash
npx skills remove dailybot
```

**Pros:** one command, cross-agent, easy updates.
**Cons:** requires Node.js / `npx`.

---

## Method 2 — OpenClaw native registry

If your agent is [OpenClaw](https://www.openclaw.dev), use its
built-in skill registry — simpler than the cross-agent CLI and
better integrated with OpenClaw's session lifecycle.

```bash
openclaw skills install dailybot
```

Configure the API key in `~/.openclaw/openclaw.json` (see the OpenClaw
section in [`skills/dailybot/report/triggers.md`](../skills/dailybot/report/triggers.md)
for the exact JSON shape).

To update:

```bash
openclaw skills update dailybot
```

To uninstall:

```bash
openclaw skills remove dailybot
```

**Pros:** native to OpenClaw, no Node required, no symlink layer.
**Cons:** OpenClaw-only.

---

## Method 3 — Conversational install (ask your agent)

The "no-tooling" path. If your agent has WebFetch capability (Claude
Code, Cursor, Codex, Gemini, OpenClaw all do), you can install by
asking:

> "Please install this Dailybot skill from `https://www.dailybot.com/skill.md`"

The agent fetches the markdown, sees the install instructions inside
it, and clones this repo into the right place. This is how the very
first version of the skill was distributed — the same magic-moment
pattern still works.

**Pros:** zero local tooling required (no Node, no manual clone).
**Cons:** depends on the agent's interpretation of the markdown — most
modern agents handle it, but it's not guaranteed across every harness.
For consistency, prefer Method 1 or Method 2.

---

## Method 4 — Git clone + `setup.sh`

For users who don't want Node and prefer explicit control. The
included `setup.sh` script auto-detects which agents are installed
and creates symlinks for each.

```bash
git clone https://github.com/DailybotHQ/agent-skill.git ~/dailybot-skill
cd ~/dailybot-skill
./setup.sh                 # auto-detect installed agents
./setup.sh --host claude   # or: cursor, codex, windsurf, copilot, cline, gemini
```

`setup.sh` creates these symlinks for each detected agent:

- `~/.<agent>/skills/dailybot` → the cloned repo's `skills/dailybot/`
- `~/.<agent>/skills/dailybot-report` → `skills/dailybot/report/`
- `~/.<agent>/skills/dailybot-messages` → `skills/dailybot/messages/`
- `~/.<agent>/skills/dailybot-email` → `skills/dailybot/email/`
- `~/.<agent>/skills/dailybot-health` → `skills/dailybot/health/`
- `~/.<agent>/skills/dailybot-checkin` → `skills/dailybot/checkin/`
- `~/.<agent>/skills/dailybot-kudos` → `skills/dailybot/kudos/`
- `~/.<agent>/skills/dailybot-teams` → `skills/dailybot/teams/`
- `~/.<agent>/skills/dailybot-forms` → `skills/dailybot/forms/`
- `~/.<agent>/skills/dailybot-chat` → `skills/dailybot/chat/`

The per-sub-skill symlinks are what make `dailybot-report` etc.
discoverable as standalone slash commands in agents that surface them.

To update later:

```bash
cd ~/dailybot-skill
git pull
./setup.sh
```

To uninstall:

```bash
rm -rf ~/dailybot-skill
rm -f ~/.<agent>/skills/dailybot                        # pack symlink
rm -f ~/.<agent>/skills/dailybot-{report,messages,email,health}   # sub-skill symlinks
```

**Pros:** zero external tools, full control, explicit about what's on disk.
**Cons:** manual updates (no `npx skills update`).

---

## Method 5 — Manual per-agent (no symlink layer)

For users who want the simplest possible filesystem layout for one
specific agent. Just clone the repo directly into the agent's
expected skills directory.

```bash
# Pick the path for your agent:
git clone https://github.com/DailybotHQ/agent-skill.git ~/.claude/skills/dailybot-pack
# or:
git clone https://github.com/DailybotHQ/agent-skill.git ~/.cursor/skills/dailybot-pack
# or any of the agents from the table below.
```

Per-agent paths:

| Agent | Path |
|-------|------|
| Claude Code | `~/.claude/skills/<dir>` |
| Cursor | `~/.cursor/skills/<dir>` |
| OpenAI Codex | `~/.codex/skills/<dir>` |
| Windsurf | `~/.codeium/windsurf/skills/<dir>` |
| GitHub Copilot | `~/.copilot/skills/<dir>` |
| Cline | `~/.cline/skills/<dir>` |
| Gemini CLI | `~/.gemini/skills/<dir>` |
| OpenClaw | `<workspace>/skills/<dir>` or `~/.openclaw/skills/` |

This works because the runnable skill lives inside the cloned repo at
`skills/dailybot/`, and the agent will discover it. **It does not
create the per-sub-skill symlinks** — `dailybot-report` etc. won't
appear as standalone slash commands. If you need those, use Method 4
instead.

**Pros:** no extra tooling, simplest filesystem layout.
**Cons:** no per-sub-skill discoverability, manual updates, only one
agent at a time.

---

## Method 6 — HTTP-only fallback (no install)

Some environments cannot install anything: sandboxed CI runs,
serverless functions, custom integrations. In that case, **the skill
never installs** — the agent reads the public API reference at
<https://www.dailybot.com/skill.md> on demand and uses the HTTP API
directly with `DAILYBOT_API_KEY`.

```bash
export DAILYBOT_API_KEY="<key from Dailybot → Settings → API Keys>"
```

The agent then uses curl directly:

```bash
curl -s -X POST https://api.dailybot.com/v1/agent-reports/ \
  -H "X-API-KEY: $DAILYBOT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"agent_name":"...", "content":"...", "metadata":{...}}'
```

This is documented in [`docs/API_REFERENCE.md`](API_REFERENCE.md) and
in [`skills/dailybot/shared/http-fallback.md`](../skills/dailybot/shared/http-fallback.md).

**Pros:** works in any environment with network access.
**Cons:** no auto-activation, no consent flows, no input validation
(secrets can land in reports without the email pre-send scan), no
slash commands. Strictly weaker than installing the skill — only use
when an actual install is impossible.

---

## Verifying the install

After any install method, restart your agent (close + reopen the
session, or use the agent's "reload" command if it has one) and check
that the skill is discovered.

A quick way to verify in any agent: ask it *"what dailybot skills are
available?"* — a properly installed pack will list `dailybot` and the
nine sub-skills (`dailybot-report`, `dailybot-messages`,
`dailybot-email`, `dailybot-health`, `dailybot-checkin`,
`dailybot-kudos`, `dailybot-teams`, `dailybot-forms`, `dailybot-chat`).

To verify the symlink filesystem state directly:

```bash
ls -la ~/.claude/skills/   # or your agent's path
```

You should see entries for `dailybot`, `dailybot-report`,
`dailybot-messages`, `dailybot-email`, `dailybot-health`,
`dailybot-checkin`, `dailybot-kudos`, `dailybot-teams`,
`dailybot-forms`, and `dailybot-chat` (or just the `dailybot` directory
if you used Method 5).

---

## What happens on first use

After install, the first time you ask an agent to "report this to
Dailybot" (or any other Dailybot action), the skill walks you through:

1. **CLI install** (one prompt, first session only) — the skill
   shows the proposed install command for the Dailybot CLI and asks
   for your confirmation before running it. The script auto-detects
   your OS (Homebrew on macOS, prebuilt binary on Linux x86_64,
   `pipx`/`uv tool`/`pip --user` elsewhere) and verifies its SHA-256
   before executing.
2. **Authentication** — email-OTP login (`dailybot login --email
   you@example.com` then `--code <code>`). If you already have a
   Dailybot API key, the skill detects it and skips this step.
3. **Auto-activation prompt** (one prompt, first session only) — the
   skill asks if it should write a small block to your agent's global
   config file (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, etc.) so
   reports fire automatically in future sessions. The block is wrapped
   in `<!-- dailybot-auto-activation: BEGIN/END -->` markers so you
   can find and remove it later.

Once those three first-time prompts are handled, every subsequent
session is silent.

For CI / Docker / power users who want to skip the prompts:

```bash
export DAILYBOT_AUTO_YES=1
```

This pre-approves the install consent and the auto-activation prompt.
**Email pre-send checks (recipient confirmation + secret-pattern scan)
are not bypassed by this variable** — they always run.

---

## Per-repo opt-out

The skill respects a `.dailybot/disabled` marker in any repository's
root. If present, `shared/context.sh` exits silently and no telemetry
is sent for that repo. Useful for client work, NDA-bound projects, or
personal repos where you don't want progress reports leaking to a
corporate Dailybot dashboard.

```bash
mkdir -p .dailybot && touch .dailybot/disabled
```

The check walks up from `$PWD`, so the marker can live at any
ancestor. To re-enable:

```bash
rm .dailybot/disabled
```

---

## Upgrading the CLI later

The skill never owns CLI upgrades. The CLI ships its own:

```bash
dailybot upgrade           # auto-detect install method, run the right upgrade
dailybot version --check   # print current vs latest, with the exact upgrade command
```

`dailybot upgrade` (since v1.4.0) detects whether the CLI was installed
via pipx / uv / pip / Homebrew / PyInstaller binary / editable, and
either runs the right upgrade in a subprocess or prints the exact
command for installs the CLI shouldn't drive (Homebrew, prebuilt
binary, editable).

---

## Updating the skill itself

| Method used | Update command |
|-------------|----------------|
| 1 (`npx skills add`) | `npx skills update DailybotHQ/agent-skill` |
| 2 (OpenClaw) | `openclaw skills update dailybot` |
| 3 (conversational) | Re-ask the agent to install the skill |
| 4 (git clone + setup) | `cd <skill-path> && git pull && ./setup.sh` |
| 5 (manual per-agent) | `cd <skill-path> && git pull` |
| 6 (HTTP-only) | N/A — no install to update |

---

## Uninstalling

| Method used | Uninstall steps |
|-------------|-----------------|
| 1 | `npx skills remove dailybot` |
| 2 | `openclaw skills remove dailybot` |
| 3 / 4 / 5 | Delete the cloned directory and any per-agent symlinks (see Method 4 for the symlink list) |
| 6 | Unset `DAILYBOT_API_KEY` |

To also remove auto-activation triggers and cached approvals:

```bash
# Auto-activation block: edit the relevant file and delete the block
# between <!-- dailybot-auto-activation: BEGIN --> and <!-- dailybot-auto-activation: END -->.
# Common files:
#   ~/.claude/CLAUDE.md
#   ~/.codex/AGENTS.md
#   ~/.gemini/GEMINI.md
#   ~/.cline/.clinerules
#   ~/.agents/AGENTS.md
# Cursor/Windsurf use a dedicated file — `rm` it:
rm -f ~/.cursor/rules/dailybot.mdc
rm -f .windsurf/rules/dailybot.md

# Cached approvals
rm -rf ~/.dailybot
```

---

## Troubleshooting

| Problem | Likely cause |
|---------|--------------|
| Agent doesn't recognize the skill after install | Restart the session. Agents discover skills at session start, not mid-session. |
| `dailybot` command not on PATH after CLI install | Open a new shell, or check whether `~/.local/bin` (pip) or pipx's shim path is on PATH. |
| `npx skills add` fails with a Git error | The repo URL `DailybotHQ/agent-skill` may need to be wrapped in quotes if your shell expands it. Try `'DailybotHQ/agent-skill'`. |
| Verified install fails with "SHA-256 verification failed" | Stale Cloudflare cache, or `cli.dailybot.com/install.sh.sha256` is genuinely out of sync. Run `bash scripts/verify-cdn.sh` from a clone of this repo to confirm. |
| Agent sends reports but they don't appear in Dailybot | Run `dailybot status --auth` to confirm authentication. Verify `agent_name` is consistent across sessions (Dailybot keys agents by name). |
| Reports leak from a personal repo | Drop `.dailybot/disabled` in that repo's root. |

---

## See also

- [`README.md`](../README.md) — quick-start version of this guide
- [`skills/dailybot/shared/auth.md`](../skills/dailybot/shared/auth.md) — the canonical install + auth flow the agent follows on first use
- [`docs/API_REFERENCE.md`](API_REFERENCE.md) — public CLI / HTTP API for sandboxed-environment fallback
- [`docs/OPENCLAW.md`](OPENCLAW.md) — OpenClaw-specific notes
- [`SECURITY.md`](../SECURITY.md) — security disclosure + what the skill does on your machine

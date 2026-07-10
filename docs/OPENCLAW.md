# Dailybot skill pack — OpenClaw notes

## Install the pack (not only the API doc)

- **Registry:** `openclaw skills install dailybot`
- **Manual:** Clone `https://github.com/DailybotHQ/agent-skill` into `<workspace>/skills/dailybot/` (or `~/.openclaw/skills/dailybot/`).

Do **not** treat `https://www.dailybot.com/skill.md` as the skill pack. That file is the **public API reference**. The real pack lives in the GitHub repository above.

## CLI on first use

After the pack is installed, read
[`../skills/dailybot/shared/auth.md`](../skills/dailybot/shared/auth.md). If
`dailybot` is missing, present the install command to the developer and
proceed only after their first-time confirmation:

1. **Primary** — SHA-256-verified universal script (`curl … install.sh`)
   for Linux, macOS, WSL2, Git Bash, Docker, and CI. The script
   auto-detects the OS and uses Homebrew on macOS, the prebuilt binary
   on Linux x86_64, or pipx/uv/pip on everything else.
2. **Native Windows PowerShell** — only when WSL2 / Git Bash is
   unavailable. PowerShell variant with the same checksum verification
   (see `auth.md`). Requires Python 3.10+ on PATH.
3. **Manual control** — `brew install dailybothq/tap/dailybot` (macOS),
   `pipx install dailybot-cli`, or `uv tool install dailybot-cli` if the
   developer prefers driving the install themselves.
4. **HTTP fallback** — `DAILYBOT_API_KEY` per
   [`../skills/dailybot/shared/http-fallback.md`](../skills/dailybot/shared/http-fallback.md)
   when no CLI can be installed.

In CI, Docker, or for power users, set `DAILYBOT_AUTO_YES=1` to pre-approve
install and auto-activation prompts. Email pre-send checks remain
mandatory.

## Upgrades

The CLI ships its own `dailybot upgrade` (since v1.4.0) and
`dailybot version --check`. The skill does not own upgrade logic —
mention these commands once and move on.

## Configure API key (optional)

For OpenClaw-native key wiring, see the OpenClaw block in
[`../skills/dailybot/report/triggers.md`](../skills/dailybot/report/triggers.md)
(example `openclaw.json` snippet).

---
name: dailybot-kudos
description: Give kudos to a teammate via Dailybot to recognize their contributions. Use when the developer wants to thank or recognize someone on the team. Do not use for general progress reports — those go through dailybot-report.
version: "1.3.0"
documentation_url: https://api.dailybot.com/skill.md
user-invocable: true
metadata: {"openclaw":{"emoji":"🏆","homepage":"https://dailybot.com","requires":{"anyBins":["dailybot","curl"]},"primaryEnv":"DAILYBOT_API_KEY","install":[{"id":"cli-install-script","kind":"download","url":"https://cli.dailybot.com/install.sh","label":"Install Dailybot CLI (official script — preferred on Linux/macOS)"},{"id":"pip","kind":"pip","package":"dailybot-cli","bins":["dailybot"],"label":"Install Dailybot CLI via pip (fallback if binary fails)"}]}}
allowed-tools: Bash, Read, Grep, Glob
---

# Dailybot Kudos

You help developers recognize teammates by sending kudos through Dailybot. Kudos are team-visible appreciation messages — the whole team sees them in Dailybot's recognition feed and in connected chat platforms (Slack, Teams, Discord).

---

## Auth model — user-scoped commands

Kudos commands require a **Bearer token** (user session), not an API key.
The developer must be logged in via `dailybot login`. This scopes kudos to
the logged-in human — the kudos appear as coming from them, not from an
agent.

If the developer only has an API key (`DAILYBOT_API_KEY`), guide them through
`dailybot login` first. API keys authenticate agent-scoped endpoints
(`dailybot agent ...`), not user-scoped ones.

---

## When to Use

- The developer asks "give kudos to Jane", "recognize Alice for the PR review", "thank Bob"
- After a collaborative session where a teammate helped significantly
- When the developer explicitly wants to send team recognition

Do **not** send kudos autonomously without the developer's explicit request.
Kudos are a social action with the developer's name attached — always
confirm intent.

---

## Step 1 — Verify Setup

Read and follow the authentication steps in [`../shared/auth.md`](../shared/auth.md). That file covers CLI installation, login, API key setup, and agent profile configuration.

**Additionally**, verify the developer has a user session (Bearer token):

```bash
dailybot status --auth 2>&1
```

If the output shows a logged-in user session, proceed. If not, guide them
through `dailybot login` (see auth.md for the OTP flow).

If auth fails or the developer declines, skip and continue with your primary task.

---

## Step 2 — Resolve the Recipient

The developer may refer to a teammate by name. You need either their
**full name** (the CLI resolves it against the organization directory) or
their **user UUID**.

### Look up team members (if needed)

```bash
dailybot user list --json
```

This returns all organization members with their names and UUIDs. Use this
to resolve ambiguous references or to confirm the recipient.

**Privacy note:** Email addresses are intentionally not shown — user emails
are PII. Use the full name or UUID to identify recipients.

### Present the match to the developer

If the name matches exactly one person:

> "I'll send kudos to **Jane Doe**. Sound right?"

If the name is ambiguous (matches multiple people):

> "I found multiple people matching 'Jane':
>
> 1. Jane Doe
> 2. Jane Smith
>
> Which one?"

---

## Step 3 — Compose and Send Kudos

### Confirm before sending

Always confirm the kudos content with the developer before sending:

> "I'll send this kudos via Dailybot:
>
> **To:** Jane Doe
> **Message:** *Shipped the auth refactor cleanly — great work on the edge case handling!*
>
> **Send?** (yes / edit / cancel)"

### Send via CLI

```bash
dailybot kudos give \
  --to "Jane Doe" \
  --message "Shipped the auth refactor cleanly — great work on the edge case handling!" \
  --yes
```

> **Timeout**: Allow at least 30 seconds for CLI commands to complete. Do not use a shorter timeout.

### CLI flags

| Flag | Short | Description |
|------|-------|-------------|
| `--to` | `-t` | Receiver full name or UUID. Required. |
| `--message` | `-m` | Kudos message (team-visible). Required. |
| `--value` | | Optional company value UUID to tag the kudos. |
| `--yes` | `-y` | Skip confirmation prompt. |
| `--json` | | Emit machine-readable JSON output. |

### Exit codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `2` | Ambiguous or invalid receiver — list matches and ask the developer to choose |
| `3` | Not authenticated — guide through `dailybot login` |
| `4` | Self-kudos attempted, or daily kudos limit reached |
| `6` | Rate limited (60 req/min) |

### Safety constraints

- **No self-kudos.** The CLI prevents giving kudos to yourself (exit code 4).
  If the developer asks to send kudos to themselves, explain this isn't
  allowed and suggest recognizing a teammate instead.
- **Daily limit.** Organizations may have a daily kudos limit per user.
  If hit (exit code 4 with 406 status), inform the developer and move on.

---

## Step 4 — HTTP Fallback (when CLI is unavailable)

See [`../shared/http-fallback.md`](../shared/http-fallback.md) for base patterns.

**Important:** Kudos endpoints use **Bearer token** auth, not API key auth.

### List team members (to resolve names)

```bash
curl -s -H "Authorization: Bearer $DAILYBOT_BEARER_TOKEN" \
  https://api.dailybot.com/v1/users/
```

The response is paginated — follow the `next` URL until null (max 50 pages).

### Send kudos

```bash
curl -s -X POST \
  -H "Authorization: Bearer $DAILYBOT_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  https://api.dailybot.com/v1/kudos/ \
  -d '{
    "receivers": ["<user-uuid>"],
    "content": "Shipped the auth refactor cleanly — great work!"
  }'
```

---

## Step 5 — Confirm

After the command runs:

- **Success** — briefly confirm. Example: *"Kudos sent to Jane Doe via Dailybot!"*
- **Failure** — warn briefly. If self-kudos, explain the restriction. If daily limit, mention it resets tomorrow.
- **Skipped** — say nothing.

---

## Writing Good Kudos

- **Be specific** — mention what the person did, not just "great job"
- **Be genuine** — the whole team sees kudos; they should feel earned
- **Keep it concise** — one or two sentences
- **Reference the work** — "Great PR review on the auth module" > "Thanks for helping"

---

## Non-Blocking Rule

Sending kudos must **never block your primary work**. If the CLI is missing, auth fails, the network is down, or the command errors:

1. Warn the developer briefly
2. Continue with the primary task
3. Do not retry automatically
4. Do not enter a diagnostic loop

---

## Additional Resources

- [`../shared/auth.md`](../shared/auth.md) — authentication setup
- [`../shared/http-fallback.md`](../shared/http-fallback.md) — HTTP API fallback patterns
- **Live API spec:** `https://api.dailybot.com/api/swagger/`
- **Full agent API skill:** `https://api.dailybot.com/skill.md`

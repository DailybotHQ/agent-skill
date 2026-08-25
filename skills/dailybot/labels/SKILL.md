---
name: dailybot-labels
description: Manage organization Labels via the Dailybot CLI — list, create, update, archive, and inspect entitlement for the shared Forms/Automations/Check-ins taxonomy. Use when the developer asks about org labels, label CRUD, or label entitlement. Not for private Featured stars (use dailybot-featured) or saved views.
version: "1.0.0"
documentation_url: https://www.dailybot.com/skill.md
user-invocable: true
metadata: {"openclaw":{"emoji":"🏷️","homepage":"https://dailybot.com","requires":{"anyBins":["dailybot","curl"]},"primaryEnv":"DAILYBOT_API_KEY","install":[{"id":"cli-install-script","kind":"download","url":"https://cli.dailybot.com/install.sh","label":"Install Dailybot CLI (official script — preferred on Linux/macOS)"},{"id":"pip","kind":"pip","package":"dailybot-cli","bins":["dailybot"],"label":"Install Dailybot CLI via pip (fallback if binary fails)"}]}}
allowed-tools: Bash, Read, Grep, Glob
---

# Dailybot Labels

> **Requires `dailybot-cli >= 3.9.0`** with `dailybot label …` commands. If missing, ask the developer to run `dailybot upgrade`.

Organization **Labels** are a paid, org-shared taxonomy for Forms, Automations (Workflows), and Check-ins. The CLI wraps `/v1/labels/` with the same permissions as the web app.

## When to Use

- List or inspect organization Labels
- Create, update, archive, or delete Labels (when entitled)
- Check Labels entitlement before building automations

Do **not** use for private Featured stars (`dailybot featured …` → `dailybot-featured` skill).

## Step 1 — Verify Setup

Read [`../shared/auth.md`](../shared/auth.md). Then:

```bash
dailybot status --auth 2>&1
dailybot label entitlement --json
```

## Step 2 — Common commands

```bash
# Entitlement
dailybot label entitlement

# List + detail
dailybot label list
dailybot label get <label_uuid>

# Mutations (paid Labels; server enforces permissions)
dailybot label create --name "Release" --color "#4A90E2"
dailybot label update <label_uuid> --name "Shipped"
dailybot label archive <label_uuid>
dailybot label delete <label_uuid> -y
```

## Step 3 — HTTP fallback

When the CLI is unavailable, use curl against `/v1/labels/` with Bearer or `X-API-KEY`. See [`../shared/http-fallback.md`](../shared/http-fallback.md) and [Labels API docs](https://www.dailybot.com/developers/api/labels).

## Non-Blocking Rule

If auth fails or Labels are not entitled, warn briefly and continue the primary task.

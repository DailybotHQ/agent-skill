---
name: dailybot-labels
description: Manage organization Labels via the Dailybot CLI — list, create, update, archive, assign to forms/check-ins/workflows, and inspect entitlement. Use when the developer asks about org labels, label CRUD, tagging entities, or label entitlement. Not for private Featured stars (use dailybot-featured) or saved views.
version: "3.12.0"
documentation_url: https://www.dailybot.com/skill.md
user-invocable: true
metadata: {"openclaw":{"emoji":"🏷️","homepage":"https://dailybot.com","requires":{"anyBins":["dailybot","curl"]},"primaryEnv":"DAILYBOT_API_KEY","install":[{"id":"cli-install-script","kind":"download","url":"https://cli.dailybot.com/install.sh","label":"Install Dailybot CLI (official script — preferred on Linux/macOS)"},{"id":"pip","kind":"pip","package":"dailybot-cli","bins":["dailybot"],"label":"Install Dailybot CLI via pip (fallback if binary fails)"}]}}
allowed-tools: Bash, Read, Grep, Glob
---

# Dailybot Labels

> **Requires `dailybot-cli` with `dailybot label …`** (CRUD from 3.9.0; `label assign` / `label batch` on the personalized-labels CLI). If missing, ask the developer to run `dailybot upgrade` or use the matching CLI branch.

Organization **Labels** are an org-shared taxonomy for Forms, Automations (Workflows), and Check-ins. The CLI wraps `/v1/labels/` plus entity assign/batch endpoints. The web picker on a form / check-in / automation row is a **replace-set** — match that with `dailybot label assign`.

## When to Use

- List or inspect organization Labels
- Create, update, archive, or delete Labels (when entitled)
- Assign Labels to a form, check-in, or workflow (same chip picker as the web app)
- Bulk add/remove Labels with `label batch`
- Check Labels entitlement before building automations

Do **not** use for private Featured stars (`dailybot featured …` → `dailybot-featured` skill). Workflow *states* named "labels" on a form response → `dailybot-forms` transitions.

## Step 1 — Verify Setup

Read [`../shared/auth.md`](../shared/auth.md). Then:

```bash
dailybot status --auth 2>&1
dailybot label entitlement --json
```

Server entitlement (`dailybot label entitlement`) is the source of truth. Point at staging with `--api-url https://staging-api.dailybot.com` when testing there.

## Step 2 — CRUD

```bash
dailybot label entitlement

dailybot label list
dailybot label get <label_uuid>

dailybot label create --name "Release" --color "#4A90E2"
dailybot label update <label_uuid> --name "Shipped"
dailybot label archive <label_uuid>
dailybot label delete <label_uuid> -y
```

Copy UUIDs from `label list` (or `--json`).

## Step 3 — Attach to one entity (web picker parity)

```bash
dailybot label assign <form-uuid> --type forms --label <label-uuid>
dailybot label assign <checkin-uuid> --type checkins --label <label-uuid>
dailybot label assign <workflow-uuid> --type workflows --label <label-uuid>
```

`--type automations` is an alias for workflows. Repeat `--label` (or comma-separate) for several Labels. The list **replaces** whatever was on the entity.

```bash
dailybot label assign <form-uuid> --type forms --clear
```

`dailybot form create` / `checkin create` do **not** take `--labels`. Create first, then `label assign` with the new UUID from `--json`.

## Step 4 — Bulk add / remove

```bash
dailybot label batch --type forms --uuids <uuid1>,<uuid2> --label <label-uuid> --mode add
dailybot label batch --type checkins --uuids <uuid> --label <label-uuid> --mode remove
dailybot label batch --type workflows --uuids <uuid> --label <label-uuid> --mode replace
```

`--mode` is `add` (default), `remove`, or `replace`. Confirm with `dailybot label assign --help` / `dailybot label batch --help`.

## Step 5 — HTTP fallback

When the CLI is unavailable, use curl against `/v1/labels/` and the entity `/labels/` endpoints with Bearer or `X-API-KEY`. See [`../shared/http-fallback.md`](../shared/http-fallback.md) and [Labels API docs](https://www.dailybot.com/developers/api/labels).

## Non-Blocking Rule

If auth fails or Labels are not entitled, warn briefly and continue the primary task.

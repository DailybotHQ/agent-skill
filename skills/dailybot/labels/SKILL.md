---
name: dailybot-labels
description: Create organization Labels and attach them to forms, check-ins, and workflows (automations) via the Dailybot CLI — same taxonomy as the web settings page and row chip picker. Use when the developer wants to add, replace, or clear Labels on those entities, or to create/list Labels.
---

# Dailybot Labels

Organization Labels are a **shared taxonomy** (not private Featured stars). The
web picker on a form / check-in / automation row is a **replace-set**. Match
that with `dailybot label assign`. Bulk add/remove uses `dailybot label batch`.

Requires CLI from the personalized-labels branch (commands `label assign` and
`label batch`). Confirm with `dailybot label assign --help`.

## Auth

Same session as the rest of the CLI (`dailybot login` or `DAILYBOT_API_KEY`).
Point at staging with `--api-url https://staging-api.dailybot.com` when testing
there. Server entitlement (`dailybot label entitlement`) is the source of
truth — do not assume a paid plan is required.

## Create and list Labels

```bash
dailybot label list
dailybot label create --name "Sprint" --color "#4A90E2"
```

Copy UUIDs from `label list` (or `--json`).

## Attach to one entity (web picker parity)

```bash
# Forms
dailybot label assign <form-uuid> --type forms --label <label-uuid>

# Check-ins
dailybot label assign <checkin-uuid> --type checkins --label <label-uuid>

# Workflows / Automations (same API; --type automations is an alias)
dailybot label assign <workflow-uuid> --type workflows --label <label-uuid>
```

Repeat `--label` (or comma-separate) for several Labels. The list **replaces**
whatever was on the entity.

```bash
dailybot label assign <form-uuid> --type forms --clear
```

## Bulk add / remove

```bash
dailybot label batch --type forms --uuids <uuid1>,<uuid2> --label <label-uuid> --mode add
dailybot label batch --type checkins --uuids <uuid> --label <label-uuid> --mode remove
dailybot label batch --type workflows --uuids <uuid> --label <label-uuid> --mode replace
```

`--mode` is `add` (default), `remove`, or `replace`.

## After authoring

`dailybot form create` / `checkin create` do **not** take `--labels`. Create
first, then `label assign` with the new UUID from `--json`.

## Not this skill

Private stars → `dailybot featured`. Workflow *states* named "labels" on a
form response → `dailybot-forms` transitions.

---
name: dailybot-checkin
description: Drive the full check-in lifecycle via Dailybot — list and complete pending check-ins, see pending/completed status for a day, inspect a check-in's questions and schedule, browse response history, edit or reset a submitted response, and backfill or future-date responses. Works headless with an API key. Use when the developer asks to fill in their standup, answer daily questions, check what check-ins they have, edit or reset a check-in, or review past check-in responses. Do not use for free-text progress reports — those go through dailybot-report.
version: "1.7.1"
documentation_url: https://api.dailybot.com/skill.md
user-invocable: true
metadata: {"openclaw":{"emoji":"✅","homepage":"https://dailybot.com","requires":{"anyBins":["dailybot","curl"]},"primaryEnv":"DAILYBOT_API_KEY","install":[{"id":"cli-install-script","kind":"download","url":"https://cli.dailybot.com/install.sh","label":"Install Dailybot CLI (official script — preferred on Linux/macOS)"},{"id":"pip","kind":"pip","package":"dailybot-cli","bins":["dailybot"],"label":"Install Dailybot CLI via pip (fallback if binary fails)"}]}}
allowed-tools: Bash, Read, Grep, Glob
---

# Dailybot Check-in

You help developers complete their pending check-ins (daily standups, weekly surveys, async rituals) through Dailybot. Check-ins are structured questionnaires set up by a team lead — each has a set of questions that the developer answers. This is distinct from free-text progress reports (handled by `dailybot-report`).

---

## Auth model — API key or login

Check-in commands accept **either** a Bearer login session (`dailybot login`)
**or** an org API key (`DAILYBOT_API_KEY`) — as of `dailybot-cli >= 1.15.0`.
A login session is the same one used by the webapp — it scopes actions to the
acting identity's permissions and pending check-ins (the server resolves the
API key's owner).

If the developer has only an API key, check-in commands still work — the CLI
falls back to `X-API-KEY`. Prefer `dailybot login` for the human's own personal
pending check-ins. (On CLIs older than 1.15.0, these required a Bearer session —
`dailybot upgrade` or `dailybot login`.)

---

## When to Use

- "complete my check-in", "fill in my standup", "answer my dailybot"
- "what check-ins do I have?", "any pending standups?", "check-in status"
- "what does my standup ask?" / inspect a check-in's questions or schedule (`show`)
- "show my past check-ins", "check-in history"
- "edit / update my check-in answer", "reset / delete today's check-in" (`edit` / `reset`)
- "submit my standup for yesterday / for a specific date" (backfill / future-date)
- At the start of a work session when the developer wants to catch up on rituals

Do **not** use this skill for free-text progress reports — route those to
`dailybot-report` instead. Check-ins are structured questionnaires with
specific questions; reports are freeform updates.

---

## Step 1 — Verify Setup

Read and follow the authentication steps in [`../shared/auth.md`](../shared/auth.md). That file covers CLI installation, login, API key setup, and agent profile configuration.

**Additionally**, confirm at least one credential is present (a login session or an API key):

```bash
dailybot status --auth 2>&1
```

If the output shows a logged-in user session **or** a configured API key,
proceed. Otherwise guide them through `dailybot login` (see auth.md) or ask
them to set `DAILYBOT_API_KEY`.

If auth fails or the developer declines, skip and continue with your primary task.

---

## Step 2 — List Pending Check-ins

```bash
dailybot checkin list --json
```

This returns today's pending check-ins for the logged-in user.

### JSON output shape

```json
{
  "count": 1,
  "pending_checkins": [
    {
      "followup_name": "Daily Standup",
      "followup_uuid": "<uuid>",
      "template_questions": [
        {
          "uuid": "<question-uuid>",
          "question": "What did you complete yesterday?",
          "question_type": "text_field",
          "is_blocker": false,
          "index": 0
        }
      ]
    }
  ]
}
```

### Present check-ins to the developer

When check-ins are found, summarize them clearly:

> "You have **1 pending check-in** via Dailybot:
>
> 1. **Daily Standup** — 3 questions
>    - What did you complete yesterday?
>    - What are you working on today?
>    - Any blockers?
>
> Want me to help you fill it in?"

When no check-ins are found:

> "No pending check-ins right now. You're all caught up."

---

## Step 3 — Complete a Check-in

Once the developer wants to complete a check-in, you have two approaches:

### 3a. Gather answers from context (recommended for agents)

Use what you know about the developer's recent work to draft answers, then
confirm before submitting. This is the best experience — the developer
reviews and approves rather than typing everything.

> "Based on your recent work, here's what I'd submit for **Daily Standup**:
>
> 1. *What did you complete yesterday?* — "Shipped the auth refactor with full test coverage"
> 2. *What are you working on today?* — "Starting the payment integration"
> 3. *Any blockers?* — "None"
>
> **Should I submit these answers?** (yes / edit / skip)"

### 3b. Ask the developer for each answer

If you don't have enough context, ask for each answer individually:

> "For your **Daily Standup**:
>
> 1. What did you complete yesterday?"

Wait for each answer, then confirm before submitting.

### Submit via CLI (non-interactive)

```bash
dailybot checkin complete <followup_uuid> \
  -a 0="Shipped the auth refactor with full test coverage" \
  -a 1="Starting the payment integration" \
  -a 2="None" \
  --yes
```

> **Timeout**: Allow at least 30 seconds for CLI commands to complete. Do not use a shorter timeout.

### CLI flags

| Flag | Short | Description |
|------|-------|-------------|
| `--answer` | `-a` | `index=response` pair (0-based question index). Repeatable. |
| `--response-date` | | Target date `YYYY-MM-DD`. Defaults to today. |
| `--yes` | `-y` | Skip confirmation prompt. |
| `--json` | | Emit machine-readable JSON output. |

### Exit codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `3` | Not authenticated — guide through `dailybot login` |
| `7` | User aborted the confirmation prompt |

---

## Step 3.5 — The full check-in lifecycle (`dailybot-cli >= 1.15.0`)

Beyond `list` + `complete`, the CLI covers the whole check-in lifecycle. **Every
command below takes `--json` and works headless with an API key** — this is what
lets an agent do almost everything with check-ins from the terminal.

### Status for a day

```bash
dailybot checkin status [--date YYYY-MM-DD] [--json]
```

Each check-in with its **pending/completed** state for that day (default today).
JSON: `{ "date", "count", "checkins": [{ uuid, name, response_completed, ... }] }`.

### Inspect a check-in's questions & schedule

```bash
dailybot checkin show <followup_uuid> [--json]
```

Name, schedule (frequency / time / timezone), and every question with its type
and UUID. Use this to know **what** a check-in asks (and each question's `uuid`)
before completing or editing it.

### Browse response history

```bash
dailybot checkin history <followup_uuid> --days 7 [--json]
dailybot checkin history <followup_uuid> --from 2026-06-01 --to 2026-06-30 --json
```

Your past responses over a date range (date, completed, answer summary).

### Edit an existing response

```bash
dailybot checkin edit <followup_uuid> -a 0="Updated answer" --yes [--json]
dailybot checkin edit <followup_uuid> [--date YYYY-MM-DD]   # prompts each question with the current value
```

Overrides specific answers on the already-submitted response, then re-submits.
Use `dailybot checkin history`/`show` first to learn the question order.

### Reset (delete) a response

```bash
dailybot checkin reset <followup_uuid> [--date YYYY-MM-DD] [--yes] [--json]
```

Deletes your own response for a day (confirms first unless `--yes` / `--json`).

### Backfill (past) & future-dating

`complete` accepts `--response-date`; `edit` / `reset` / `history` accept
`--date` (or `--from/--to`). The server may refuse when the check-in disallows
it — the CLI maps the `code` to a friendly message (and includes it in `--json`
errors):

| `code` | Meaning |
|--------|---------|
| `previous_responses_are_not_allowed` | Backfill is disabled for this check-in |
| `future_responses_are_not_allowed` | Future-dating is disabled |
| `followup_not_allow_responses_before_trigger_time` | Too early (before the trigger time) |
| `user_is_not_a_followup_member` | You're not a participant |
| `responses_not_allowed_on_inactive_followup` | The check-in is inactive |
| `template_questions_version_conflict` | Questions changed — re-run `show` and retry |
| `response_date_format_is_invalid` | Use `YYYY-MM-DD` |

### Interactive terminal chat

In `dailybot ask` (the AI chat), the native slash commands `/checkins`,
`/checkin edit`, and `/checkin reset` drive these same flows with numbered
prompts — handy for humans; agents should use the headless commands above.

---

## Step 4 — HTTP Fallback (when CLI is unavailable)

See [`../shared/http-fallback.md`](../shared/http-fallback.md) for base patterns.

**Important:** Check-in endpoints accept **either** Bearer token or `X-API-KEY` auth.

### List pending check-ins

```bash
curl -s -H "Authorization: Bearer $DAILYBOT_BEARER_TOKEN" \
  https://api.dailybot.com/v1/cli/status/
```

### Complete a check-in

```bash
curl -s -X POST \
  -H "Authorization: Bearer $DAILYBOT_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  https://api.dailybot.com/v1/checkins/<followup_uuid>/responses/ \
  -d '{
    "responses": [
      {"uuid": "<question-uuid>", "index": 0, "response": "Shipped the auth refactor"},
      {"uuid": "<question-uuid>", "index": 1, "response": "Starting payment integration"},
      {"uuid": "<question-uuid>", "index": 2, "response": "None"}
    ],
    "last_question_index": 2
  }'
```

### Obtaining a Bearer token programmatically

```bash
# Step 1 — request OTP
curl -s -X POST https://api.dailybot.com/v1/cli/request-code/ \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com"}'

# Step 2 — verify OTP (returns token)
curl -s -X POST https://api.dailybot.com/v1/cli/verify-code/ \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","code":"123456"}'
# → {"token":"<bearer-token>","organization":"Org Name"}
```

---

## Step 5 — Confirm

After the command runs:

- **Success** — briefly confirm. Example: *"Submitted your Daily Standup check-in to Dailybot."*
- **Failure** — warn briefly. If not authenticated (exit code 3), suggest `dailybot login`.
- **Skipped** — say nothing.

---

## Non-Blocking Rule

Check-in completion must **never block your primary work**. If the CLI is missing, auth fails, the network is down, or the command errors:

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

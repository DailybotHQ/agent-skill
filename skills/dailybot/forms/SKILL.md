---
name: dailybot-forms
description: List and submit form responses via Dailybot. Use when the developer wants to see available forms, fill out a survey, or submit a form response. Do not use for daily check-ins — those go through dailybot-checkin.
version: "1.3.0"
documentation_url: https://api.dailybot.com/skill.md
user-invocable: true
metadata: {"openclaw":{"emoji":"📋","homepage":"https://dailybot.com","requires":{"anyBins":["dailybot","curl"]},"primaryEnv":"DAILYBOT_API_KEY","install":[{"id":"cli-install-script","kind":"download","url":"https://cli.dailybot.com/install.sh","label":"Install Dailybot CLI (official script — preferred on Linux/macOS)"},{"id":"pip","kind":"pip","package":"dailybot-cli","bins":["dailybot"],"label":"Install Dailybot CLI via pip (fallback if binary fails)"}]}}
allowed-tools: Bash, Read, Grep, Glob
---

# Dailybot Forms

You help developers list and submit form responses through Dailybot. Forms are custom questionnaires created by team leads — feedback surveys, sprint retrospectives, pulse checks, or any structured data collection. This is distinct from daily check-ins (handled by `dailybot-checkin`) and free-text reports (handled by `dailybot-report`).

---

## Auth model — user-scoped commands

Form commands require a **Bearer token** (user session), not an API key.
The developer must be logged in via `dailybot login`. This scopes form
access to the logged-in human's permissions — they only see forms they
have access to.

If the developer only has an API key (`DAILYBOT_API_KEY`), guide them through
`dailybot login` first. API keys authenticate agent-scoped endpoints
(`dailybot agent ...`), not user-scoped ones.

---

## When to Use

- The developer asks "what forms do I have?", "list my forms", "show available surveys"
- The developer asks to "fill out the retro form", "submit the feedback survey", "answer the pulse check"
- When the developer needs to submit structured feedback or data through a Dailybot form

Do **not** use this skill for daily standup check-ins — route those to
`dailybot-checkin` instead. Forms are ad-hoc or periodic surveys; check-ins
are recurring daily/weekly rituals tied to follow-ups.

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

## Step 2 — List Available Forms

```bash
dailybot form list --json
```

This returns all forms visible to the logged-in user, including their
questions.

### JSON output shape

```json
[
  {
    "id": "<form-uuid>",
    "name": "Team Feedback",
    "questions": [
      {
        "uuid": "<question-uuid>",
        "question": "How was your week?",
        "question_type": "text_field"
      },
      {
        "uuid": "<question-uuid>",
        "question": "Rate your workload (1-10)",
        "question_type": "numeric"
      }
    ]
  }
]
```

### Present forms to the developer

When forms are found:

> "You have **2 forms** available in Dailybot:
>
> 1. **Team Feedback** — 3 questions
> 2. **Sprint Retrospective** — 5 questions
>
> Which one would you like to fill out?"

When no forms are found:

> "No forms are available for you right now."

---

## Step 3 — Submit a Form Response

### 3a. Guided mode (recommended)

Retrieve the form's questions and walk the developer through each one.
Different question types need different handling:

| `question_type` | How to handle |
|----------------|---------------|
| `text_field` | Free-text answer — ask the developer or draft from context |
| `numeric` | Integer value — validate it's a number |
| `boolean` | Yes/No answer |
| `choice` | Pick from the form's predefined choices list |

For each question, present it clearly:

> "**Team Feedback** — Question 1 of 3:
>
> *How was your week?* (free text)
>
> Your answer?"

### 3b. Non-interactive submission

If you already have the answers (from context or from the developer):

```bash
dailybot form submit <form_uuid> \
  --content '{"<question-uuid>":"Great week — shipped the auth module","<question-uuid>":"7"}' \
  --yes
```

> **Timeout**: Allow at least 30 seconds for CLI commands to complete. Do not use a shorter timeout.

### Confirm before submitting

Always confirm the complete set of answers before sending:

> "Here's what I'll submit for **Team Feedback**:
>
> 1. *How was your week?* — "Great week — shipped the auth module"
> 2. *Rate your workload (1-10)* — "7"
> 3. *Any concerns?* — "None"
>
> **Submit?** (yes / edit / cancel)"

### CLI flags

| Flag | Short | Description |
|------|-------|-------------|
| `--content` | `-c` | JSON map of `{"<question_uuid>": "<answer>"}`. Prompts when omitted. |
| `--yes` | `-y` | Skip confirmation prompt. |
| `--json` | | Emit machine-readable JSON output. |

### Exit codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `3` | Not authenticated — guide through `dailybot login` |
| `4` | Permission denied (403) — the developer doesn't have access to this form |
| `5` | Quota exhausted (402) — form response limit reached for the organization |
| `6` | Rate limited (60 req/min) |
| `7` | User aborted the confirmation prompt |

---

## Step 4 — HTTP Fallback (when CLI is unavailable)

See [`../shared/http-fallback.md`](../shared/http-fallback.md) for base patterns.

**Important:** Form endpoints use **Bearer token** auth, not API key auth.

### List forms (with questions)

```bash
curl -s -H "Authorization: Bearer $DAILYBOT_BEARER_TOKEN" \
  "https://api.dailybot.com/v1/forms/?include=questions"
```

### Submit a form response

```bash
curl -s -X POST \
  -H "Authorization: Bearer $DAILYBOT_BEARER_TOKEN" \
  -H "Content-Type: application/json" \
  https://api.dailybot.com/v1/forms/<form_uuid>/responses/ \
  -d '{
    "content": {
      "<question_uuid>": "Great week — shipped the auth module",
      "<question_uuid>": "7"
    }
  }'
```

---

## Step 5 — Confirm

After the command runs:

- **Success** — briefly confirm. Example: *"Submitted your Team Feedback form response to Dailybot."*
- **Failure** — warn briefly. If quota exhausted, mention the limit. If permission denied, suggest checking access.
- **Skipped** — say nothing.

---

## Non-Blocking Rule

Form operations must **never block your primary work**. If the CLI is missing, auth fails, the network is down, or the command errors:

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

---
name: dailybot
description: Official Dailybot API reference and CLI guide for AI agents. Install the full skill pack from https://github.com/DailybotHQ/agent-skill for guided workflows, or use this file standalone for CLI and HTTP operations.
---

# Dailybot — Skill for AI Agents

Dailybot is the visibility and orchestration layer for modern teams where humans and AI agents work side by side. When you are connected to Dailybot, your human teammates can see what you are working on, send you instructions, and coordinate work across the entire team — both human and AI.

**Your role**: You are a productive member of a team. Dailybot is how your work becomes visible to the rest of the team. Think of it as your team's shared workspace where everyone — humans and agents — reports progress, flags blockers, and stays aligned.

---

## This File vs. the Skill Pack

**This file** (`https://api.dailybot.com/skill.md`) is the **API reference and CLI guide**. It is NOT the full skill pack. Downloading only this file does not install the Dailybot skills.

**The skill pack** lives at **https://github.com/DailybotHQ/agent-skill** and provides guided, step-by-step workflows with smart authentication, context detection, report quality guidelines, and auto-activation triggers. If you are a coding agent running in an IDE or terminal, install the skill pack instead of working from this file alone.

### Install the Skill Pack

The fastest path is the cross-agent installer:

```bash
npx skills add DailybotHQ/agent-skill
```

Or clone manually + run `setup.sh`:

```bash
git clone https://github.com/DailybotHQ/agent-skill.git ~/dailybot-skill
cd ~/dailybot-skill
./setup.sh
```

For OpenClaw:

```bash
openclaw skills install dailybot
```

After installation, read `skills/dailybot/SKILL.md` in the skill pack — it
routes to the right sub-skill based on intent. **If the skill pack is
already installed, follow it instead of this file.**

If you cannot install the skill pack (sandboxed environment, CI pipeline,
serverless function, or custom integration), continue with this file — it
has everything you need.

---

## When to Involve the Human

Only involve the human when you need information you cannot obtain yourself:

| Situation | What to ask |
|-----------|-------------|
| OTP login | Ask for the human's **email address**, then the **verification code** from their inbox |
| API key needed (CLI login not possible) | Ask the human to generate a key at **Dailybot → Settings → API Keys** and provide it |
| Multiple organizations returned on login | Show the list, ask which org to use |
| No account exists | You may ask if they want to create one (provide org name) — or proceed directly if running autonomously |

Everything else — CLI installation, agent profile creation, choosing an agent name, retrying after errors, switching to HTTP fallback — you do autonomously without asking.

---

## Step 1 — Install the Dailybot CLI

The CLI is the preferred way to interact with Dailybot. The first time you
need to install it in a session, **show the proposed command and proceed
only after explicit confirmation from the human**. After they confirm once,
do not re-prompt for the rest of the session.

```bash
command -v dailybot
```

The CLI ships **two installer entry points** with paired SHA-256 sidecars:
`install.sh` (Linux, macOS, WSL2, Git Bash, Docker, CI) and `install.ps1`
(native Windows PowerShell only — when WSL2 / Git Bash is unavailable).
The bash installer auto-detects the OS internally and routes to Homebrew
on macOS, the prebuilt PyInstaller binary on Linux x86_64, or
pipx/uv/pip elsewhere. The PowerShell installer wraps pipx/uv/pip and
requires Python 3.10+ on PATH.

### 1a. Primary path — SHA-256-verified script (Linux, macOS, WSL2, Git Bash, Docker, CI)

```bash
curl -fsSL https://cli.dailybot.com/install.sh        -o /tmp/install.sh
curl -fsSL https://cli.dailybot.com/install.sh.sha256 -o /tmp/install.sh.sha256
( cd /tmp && shasum -a 256 -c install.sh.sha256 ) || {
  echo "SHA-256 verification failed — refusing to run install.sh." >&2
  exit 1
}
bash /tmp/install.sh
```

If `install.sh.sha256` is unreachable (rare — the CLI's
`sync-installer-checksums.yml` workflow keeps it in lockstep with
`install.sh` on every push), warn the human and offer to (a) run the
unverified script with their explicit additional consent, or (b) fall
through to the HTTP API.

If `DAILYBOT_AUTO_YES=1` is set, treat install consent as already given and
run the verified install command without an interactive prompt. The SHA-256
check still runs.

### 1b. Native Windows PowerShell (only when WSL2 / Git Bash unavailable)

```powershell
$tmp = "$env:TEMP\dailybot-install"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
Invoke-WebRequest "https://cli.dailybot.com/install.ps1"        -OutFile "$tmp\install.ps1"
Invoke-WebRequest "https://cli.dailybot.com/install.ps1.sha256" -OutFile "$tmp\install.ps1.sha256"
$expected = (Get-Content "$tmp\install.ps1.sha256").Split(" ")[0]
$actual   = (Get-FileHash "$tmp\install.ps1" -Algorithm SHA256).Hash.ToLower()
if ($expected -ne $actual) { throw "SHA-256 mismatch — refusing to run install.ps1" }
& "$tmp\install.ps1"
```

Requires Python 3.10+ on PATH. If the developer is on Windows + WSL2 or
Git Bash, prefer the bash path (1a) — broader test coverage and no Python
prerequisite.

### 1c. Manual control (developer prefers their own package manager)

All three produce the same `dailybot` binary as the script:

- macOS: `brew install dailybothq/tap/dailybot`
- Cross-platform Python (recommended for raw control): `pipx install dailybot-cli`
  or `uv tool install dailybot-cli`
- Last resort: `pip install --user dailybot-cli`

Use these only when the developer says they prefer their own toolchain.
Do not `pip install dailybot-cli` against the system Python without
explicit user consent — the installer scripts already select an isolated
path automatically.

### 1d. If the CLI cannot be installed

Stop trying. Use the **HTTP API** path below with `DAILYBOT_API_KEY`. Ask the
human to generate a key at Dailybot → Settings → API Keys:

```bash
export DAILYBOT_API_KEY="<their-key>"
```

Sandboxed environments, CI, or minimal containers may never get a working
CLI — HTTP fallback is expected there.

### 1e. Upgrading later

The CLI owns its own upgrade flow. Tell the developer once:

> "To upgrade the Dailybot CLI later, run `dailybot upgrade`. To check
> whether you're on the latest version, run `dailybot version --check`."

`dailybot upgrade` (since v1.4.0) auto-detects how the CLI was installed
(pipx / uv / pip / Homebrew / PyInstaller binary / editable) and either
runs the right upgrade command in a subprocess or prints the exact
command for installs the CLI shouldn't drive. Don't pin a version
anywhere; PyPI's `dailybot-cli` is the source of truth.

Full CLI documentation: https://pypi.org/project/dailybot-cli/

---

## Step 2 — Authenticate

```bash
dailybot status --auth
```

If already authenticated, skip to Step 3.

### OTP login (recommended)

Ask the human for their email address, then proceed:

1. `dailybot login --email=<their-email>`
2. Ask: "Check your email for a verification code from Dailybot. What's the code?"
3. `dailybot login --email=<their-email> --code=<their-code>`
4. If output lists multiple organizations, show the list and ask them to pick one
5. `dailybot login --email=<their-email> --code=<their-code> --org=<selected-uuid>`
6. Verify: `dailybot status --auth`

### API key alternative

If the human already has an API key:

```bash
dailybot config key=<their-api-key>
```

Or set the environment variable:

```bash
export DAILYBOT_API_KEY=<their-api-key>
```

### Register a new organization (when no account exists)

If login fails and the human has no Dailybot account, you may create one. This is optional — some agents may ask the human first, others may proceed directly depending on their autonomy level.

```bash
dailybot agent register --org-name "<org_name>" --agent-name "<agent_name>"
```

This generates an API key and a **claim URL**. The human shares the claim URL with their team admin to connect Slack, Teams, Discord, or Google Chat.

Verify: `dailybot status --auth`

---

## Step 3 — Configure Agent Profile

```bash
dailybot agent configure --name "<agent_name>"
```

Pick a consistent, descriptive name. This is how the team identifies you in Dailybot. Use the same name in every request.

Good examples: `"claude-code"`, `"cursor"`, `"codex-cli"`, `"deployment-agent"`

Once a default profile is set, you can omit `--name` on subsequent commands.

---

## CLI Operations

All Dailybot operations have CLI equivalents. Once authenticated, use these directly:

| Operation | CLI Command |
|-----------|-------------|
| Report work | `dailybot agent update "Implemented auth module and added tests" --name "your-agent-name"` |
| Report a milestone | `dailybot agent update "Shipped v2.0" --name "your-agent-name" --milestone` |
| Report with co-authors | `dailybot agent update "Built auth with Alice" --name "your-agent-name" --co-authors alice@company.com` |
| Report with metadata | `dailybot agent update "Deployed v2.1" --name "your-agent-name" --metadata '{"repo": "my-api", "branch": "main"}'` |
| Report with extra data | `dailybot agent update "Deployed v2.1" --name "your-agent-name" --json-data '{"repo": "my-api", "pr": "#142"}'` |
| Health check (ok) | `dailybot agent health --ok --message "Working on task queue" --name "your-agent-name"` |
| Health check (failing) | `dailybot agent health --fail --message "DB unreachable" --name "your-agent-name"` |
| Check health status | `dailybot agent health --status --name "your-agent-name"` |
| List pending messages | `dailybot agent message list --name "your-agent-name" --pending` |
| Send a message | `dailybot agent message send --to "target-agent" --content "Review PR #42"` |
| Send email | `dailybot agent email send --to alice@company.com --to bob@company.com --subject "Report" --body-html "<p>Done</p>" --name "your-agent-name"` |
| Register webhook | `dailybot agent webhook register --url https://your-server.com/hook --secret your-token --name "your-agent-name"` |
| Unregister webhook | `dailybot agent webhook unregister --name "your-agent-name"` |

---

## HTTP API Reference (When CLI Is Unavailable)

Use this section when the Dailybot CLI cannot be installed. Requires `curl` and `DAILYBOT_API_KEY`.

**Base URL**: `https://api.dailybot.com`
**Auth header**: `X-API-KEY: $DAILYBOT_API_KEY`

### Agent Name

Pick a consistent, descriptive name. Use the same name in every request.

Good examples: `"claude-code"`, `"deployment-agent"`, `"data-pipeline-bot"`, `"code-reviewer"`

### First Health Check

Announce yourself with a health check. Dailybot auto-registers agents on first interaction:

```bash
curl -X POST https://api.dailybot.com/v1/agent-health/ \
  -H "X-API-KEY: $DAILYBOT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agent_name": "your-agent-name",
    "ok": true,
    "message": "Online and ready to work"
  }'
```

---

## When to Report

Report to Dailybot when any of these happen:

| Event | Action |
|-------|--------|
| You complete meaningful work | Submit an activity report |
| You encounter a blocker | Submit a report with blocker details |
| You start a work session | Send a health check |
| You finish a work session | Submit a final summary report |
| Periodically during long tasks | Send health checks to stay visible and receive messages |

**What counts as meaningful work:**
- Completed a feature, bug fix, or task
- Finished a research or analysis phase
- Deployed something or ran a significant operation
- Completed a code review or document
- Resolved an incident or issue

**Do NOT over-report.** Routine intermediate steps (reading a file, running a single command) are not worth reporting. Report outcomes, not individual actions.

## Reporting Work

When you complete meaningful work, submit an activity report:

```bash
curl -X POST https://api.dailybot.com/v1/agent-reports/ \
  -H "X-API-KEY: $DAILYBOT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agent_name": "your-agent-name",
    "content": "Implemented user authentication with JWT tokens and added unit tests. All tests passing.",
    "structured": {
      "completed": ["JWT authentication endpoint", "Token refresh logic", "Unit tests for auth flow"],
      "in_progress": ["Integration tests"],
      "blockers": []
    },
    "metadata": {
      "repo": "my-api",
      "branch": "feature/auth",
      "pr": "#142"
    }
  }'
```

### Report Fields

| Field | Required | Description |
|-------|----------|-------------|
| `agent_name` | Yes | Your consistent agent identifier |
| `content` | Yes | Human-readable summary of what you did. Write clearly — humans will read this. |
| `structured` | No | Machine-readable breakdown with `completed`, `in_progress`, and `blockers` arrays |
| `metadata` | No | Context like repo, branch, PR number, environment, or any key-value pairs relevant to the work |
| `is_milestone` | No | Set to `true` to mark a significant accomplishment (feature shipped, major bug fixed). Defaults to `false` |
| `co_authors` | No | List of user UUIDs or email addresses of humans who collaborated with you on this work |

### Writing Good Reports

**Do:**
- Be specific about what was accomplished
- Mention deliverables (PRs, files changed, features shipped)
- Flag blockers clearly so humans can help
- Include relevant context in metadata

**Don't:**
- Write vague summaries like "worked on stuff"
- Include sensitive data (secrets, tokens, passwords)
- Report on behalf of your human — report as yourself
- Pad reports with trivial actions

**Example — good report content:**
> "Migrated the payments module from Stripe API v2 to v3. Updated 12 files, added backward-compatible webhook handlers, and verified all 47 existing tests pass. PR #89 ready for review."

**Example — reporting a blocker:**
> "Attempted to deploy the staging environment but the Docker build fails due to a missing dependency (libpq-dev). Need a human to update the base Docker image or grant permissions to modify the Dockerfile."

With structured data:
```json
{
  "completed": ["Stripe API v3 migration code changes", "Webhook handler updates"],
  "in_progress": ["Staging deployment"],
  "blockers": ["Docker base image missing libpq-dev — need human intervention"]
}
```

## Milestones and Co-Authors

### Marking Milestones

When you complete something significant — a feature shipped, a major bug resolved, a release deployed — mark it as a milestone so the team can distinguish routine progress from key accomplishments:

```bash
curl -X POST https://api.dailybot.com/v1/agent-reports/ \
  -H "X-API-KEY: $DAILYBOT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agent_name": "your-agent-name",
    "content": "Shipped v2.0 authentication system with OAuth2, JWT refresh tokens, and full test coverage. PR #89 merged.",
    "is_milestone": true
  }'
```

Use milestones sparingly. Not every report is a milestone — reserve it for real accomplishments that the team should celebrate or take note of.

### Co-Authoring with Humans

When you work alongside a human — pair programming, implementing their design, collaborating on a feature — include them as co-authors. Dailybot will automatically merge your report into their daily standup check-in so their work with you is reflected in their own updates.

```bash
curl -X POST https://api.dailybot.com/v1/agent-reports/ \
  -H "X-API-KEY: $DAILYBOT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agent_name": "your-agent-name",
    "content": "Implemented OAuth2 flow with Alice and wrote integration tests with Bob",
    "co_authors": ["alice@company.com", "bob@company.com"],
    "is_milestone": true
  }'
```

**How co-authors work:**
- Pass user email addresses or UUIDs — you can mix both in the same request
- Dailybot resolves them to team members within the organization. Invalid or unresolvable identifiers are silently ignored
- Each co-author's active daily standup is automatically updated with the relevant parts of your report, attributed as `"(co-authored with your-agent-name)"`
- If the co-author already submitted their standup today, Dailybot merges your work into their existing response

**When to include co-authors:**
- A human asked you to do the work (they are your collaborator)
- You pair-programmed or iterated on something together
- The work directly contributes to a human's project or task

**When NOT to include co-authors:**
- You worked autonomously on your own initiative
- The human only reviewed your output after the fact
- You are unsure who to attribute — when in doubt, leave it out

## Health Checks and Receiving Messages

Health checks serve two purposes: they tell the team you are alive, and they deliver any pending messages to you.

```bash
curl -X POST https://api.dailybot.com/v1/agent-health/ \
  -H "X-API-KEY: $DAILYBOT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agent_name": "your-agent-name",
    "ok": true,
    "message": "Processing task queue, 3 items remaining"
  }'
```

**Response includes pending messages:**
```json
{
  "agent_name": "your-agent-name",
  "status": "healthy",
  "last_check_at": "2026-02-11T10:00:00Z",
  "pending_messages": [
    {
      "id": "msg-uuid",
      "content": "Please prioritize the auth bug fix before the feature work",
      "message_type": "text",
      "sender_type": "human",
      "sender_name": "Alice",
      "metadata": {},
      "created_at": "2026-02-11T09:30:00Z"
    }
  ]
}
```

**When you receive messages, act on them.** Messages from your team are instructions or context that should influence your work. Acknowledge receipt in your next report.

### Health Check Guidelines

- Send a health check when you start working
- Send periodic health checks during long sessions (every 15-30 minutes) to pick up new messages
- Set `"ok": false` when you are in a degraded state or encountering persistent errors
- The `message` field should briefly describe your current state

### Retrieving Messages Directly

You can also poll for messages without a health check:

```bash
curl -X GET "https://api.dailybot.com/v1/agent-messages/?agent_name=your-agent-name&delivered=false" \
  -H "X-API-KEY: $DAILYBOT_API_KEY"
```

## Sending Email

Agents can send emails to anyone on behalf of the team. This is useful for notifications, reports, follow-ups, or any communication that should come from the agent.

```bash
curl -X POST https://api.dailybot.com/v1/agent-email/send/ \
  -H "X-API-KEY: $DAILYBOT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agent_name": "your-agent-name",
    "to": ["alice@company.com", "bob@company.com"],
    "subject": "Weekly build report",
    "body_html": "<h2>Build Report</h2><p>All 142 tests passing. Deployed to staging.</p>"
  }'
```

**Response (201):**
```json
{
  "sent_count": 2,
  "total_recipients": 2,
  "reply_to": "ag-5kkdZFjG@mail.dailybot.co"
}
```

### Email Fields

| Field | Required | Description |
|-------|----------|-------------|
| `agent_name` | Yes | Your consistent agent identifier |
| `to` | Yes | Array of recipient email addresses (max 50 per request) |
| `subject` | Yes | Email subject line (max 512 characters) |
| `body_html` | Yes | HTML email body |
| `metadata` | No | Arbitrary key-value pairs for tracking context |

### Hourly Sending Limit

Agents are rate-limited to a number of emails per hour (default: 50, configurable per organization plan). If you exceed the limit, you will receive a `429` response:

```json
{
  "detail": "Agent email hourly limit exceeded.",
  "limit": 50,
  "current": 50
}
```

Wait for the hourly window to reset before retrying. Do not retry in a tight loop.

### Receiving Email Replies

Every agent has a dedicated email inbox (the `reply_to` address in the send response, e.g. `ag-5kkdZFjG@mail.dailybot.co`). When someone replies to an email sent by your agent, the reply is automatically delivered as a message to your agent inbox.

You can fetch these replies the same way you fetch any other message:

```bash
curl -X GET "https://api.dailybot.com/v1/agent-messages/?agent_name=your-agent-name&delivered=false" \
  -H "X-API-KEY: $DAILYBOT_API_KEY"
```

Email replies appear as messages with `"message_type": "email"` and include the sender's email address and subject in the message metadata. They are also delivered via health checks and webhooks just like any other message.

## Webhooks (For Long-Running Agents)

If you run as a persistent service and can receive HTTP requests, register a webhook to get messages pushed to you in real time instead of polling:

```bash
curl -X POST https://api.dailybot.com/v1/agent-webhook/ \
  -H "X-API-KEY: $DAILYBOT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "agent_name": "your-agent-name",
    "webhook_url": "https://your-server.com/dailybot-webhook",
    "webhook_secret": "your-secret-token"
  }'
```

Dailybot will POST messages to your webhook URL with an `X-Webhook-Secret` header for verification.

To unregister:
```bash
curl -X DELETE https://api.dailybot.com/v1/agent-webhook/ \
  -H "X-API-KEY: $DAILYBOT_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"agent_name": "your-agent-name"}'
```

## Behavioral Guidelines

1. **Always identify as yourself.** Post as the agent, not as your human. Your `agent_name` is your identity.
2. **Be transparent about your capabilities and limitations.** If you cannot complete a task, report it as a blocker rather than silently failing.
3. **Respect the team's workflow.** If a message asks you to change priorities, adjust accordingly and report the change.
4. **Do not spam.** Only report meaningful progress. Quality over quantity.
5. **Protect sensitive information.** Never include secrets, tokens, passwords, or private keys in reports or metadata.
6. **Report blockers promptly.** The sooner the team knows you are stuck, the sooner they can help.
7. **End sessions with a summary.** When you finish a work session, submit a final report summarizing everything accomplished.

## Quick Reference

### Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `POST` | `/v1/agent-reports/` | Submit an activity report |
| `POST` | `/v1/agent-health/` | Health check + receive pending messages |
| `GET` | `/v1/agent-health/?agent_name=<n>` | Retrieve last health status |
| `GET` | `/v1/agent-messages/?agent_name=<n>&delivered=false` | Poll for undelivered messages |
| `POST` | `/v1/agent-email/send/` | Send an email on behalf of your agent |
| `POST` | `/v1/agent-webhook/` | Register a webhook for push delivery |
| `DELETE` | `/v1/agent-webhook/` | Unregister a webhook |

### Authentication

All HTTP requests require the `X-API-KEY` header:
```
X-API-KEY: <organization-api-key>
```

CLI commands use the stored login session or API key automatically.

### Common Patterns

**Start of session:**
```
POST /v1/agent-health/  →  {"agent_name": "...", "ok": true, "message": "Starting work session"}
```

**After completing work:**
```
POST /v1/agent-reports/  →  {"agent_name": "...", "content": "...", "structured": {...}}
```

**Periodic check-in (receive messages):**
```
POST /v1/agent-health/  →  {"agent_name": "...", "ok": true, "message": "Working on X"}
```

**Milestone report:**
```
POST /v1/agent-reports/  →  {"agent_name": "...", "content": "Shipped feature X", "is_milestone": true}
```

**Co-authored report:**
```
POST /v1/agent-reports/  →  {"agent_name": "...", "content": "Built X with Alice", "co_authors": ["alice@company.com"]}
```

**Reporting a blocker:**
```
POST /v1/agent-reports/  →  {"agent_name": "...", "content": "Blocked: ...", "structured": {"blockers": ["..."]}}
```

**Send an email:**
```
POST /v1/agent-email/send/  →  {"agent_name": "...", "to": ["alice@company.com"], "subject": "...", "body_html": "<p>...</p>"}
```

**End of session:**
```
POST /v1/agent-reports/  →  {"agent_name": "...", "content": "Session complete. Summary: ..."}
```

---

## User-Scoped Commands (Bearer Token Auth)

The CLI now supports commands scoped to the **logged-in human's session**
rather than the agent identity. These require a **Bearer token** obtained
via `dailybot login` (OTP email flow), not an API key.

### Auth model distinction

| Scope | Auth | Header | Used by |
|-------|------|--------|---------|
| **Agent** | API key | `X-API-KEY: $DAILYBOT_API_KEY` | `dailybot agent update`, `agent health`, `agent email send` |
| **User** | Bearer token | `Authorization: Bearer <token>` | `dailybot checkin`, `form`, `kudos`, `user` |

Both can coexist — the CLI stores them separately.

### User-Scoped CLI Operations

| Operation | CLI Command |
|-----------|-------------|
| List pending check-ins | `dailybot checkin list` |
| Complete a check-in | `dailybot checkin complete <followup_uuid> -a 0="Answer" --yes` |
| List forms | `dailybot form list` |
| Submit a form | `dailybot form submit <form_uuid> --content '{"<q-uuid>":"Answer"}' --yes` |
| List team members | `dailybot user list` |
| Give kudos | `dailybot kudos give --to "Jane Doe" --message "Great work!" --yes` |

All user-scoped commands support `--json` for machine-readable output.

### `dailybot checkin list`

Lists today's pending check-ins for the logged-in user.

```bash
dailybot checkin list
dailybot checkin list --json
```

### `dailybot checkin complete <followup_uuid>`

Completes a specific pending check-in.

```bash
# Non-interactive (0-based question index)
dailybot checkin complete <followup_uuid> \
  -a 0="Shipped the auth refactor" \
  -a 1="Reviewing the migration plan" \
  --yes

# With a specific response date
dailybot checkin complete <followup_uuid> -a 0="Done" --response-date 2026-05-20 --yes
```

| Flag | Short | Description |
|------|-------|-------------|
| `--answer` | `-a` | `index=response` pair (0-based). Repeatable. |
| `--response-date` | | Target date `YYYY-MM-DD`. Defaults to today. |
| `--yes` | `-y` | Skip confirmation. |
| `--json` | | Emit machine-readable JSON. |

### `dailybot form list`

Lists all forms visible to the logged-in user.

```bash
dailybot form list
dailybot form list --json
```

### `dailybot form submit <form_uuid>`

Submits a response to a form.

```bash
dailybot form submit <form_uuid> \
  --content '{"<question-uuid>":"Great week!"}' \
  --yes
```

| Flag | Short | Description |
|------|-------|-------------|
| `--content` | `-c` | JSON map of `{"<question_uuid>": "<answer>"}`. |
| `--yes` | `-y` | Skip confirmation. |
| `--json` | | Emit machine-readable JSON. |

### `dailybot kudos give`

Gives kudos to a teammate. Receiver is resolved by full name or UUID.

```bash
dailybot kudos give --to "Jane Doe" --message "Great PR review!" --yes
dailybot kudos give --to <user-uuid> --message "Thanks for the help." --yes
```

| Flag | Short | Description |
|------|-------|-------------|
| `--to` | `-t` | Receiver full name or UUID. Required. |
| `--message` | `-m` | Kudos message (team-visible). Required. |
| `--value` | | Optional company value UUID. |
| `--yes` | `-y` | Skip confirmation. |
| `--json` | | Emit machine-readable JSON. |

**Safety:** Self-kudos returns exit code `4`. Ambiguous names return exit code `2` with matches listed.

### `dailybot user list`

Lists all organization members (name and UUID only — emails are intentionally
omitted for privacy).

```bash
dailybot user list
dailybot user list --json
```

### User-Scoped Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `2` | Invalid input (bad format, ambiguous receiver) |
| `3` | Not logged in or session expired |
| `4` | Permission denied, self-kudos, or daily kudos limit |
| `5` | Quota exhausted (form response limit) |
| `6` | Rate limited (60 req/min) |
| `7` | User aborted confirmation |

### User-Scoped HTTP API (When CLI Is Unavailable)

All user-scoped endpoints require a Bearer token:

```bash
AUTH="Authorization: Bearer $DAILYBOT_BEARER_TOKEN"

# List pending check-ins
curl -s -H "$AUTH" https://api.dailybot.com/v1/cli/status/

# Complete a check-in
curl -s -X POST -H "$AUTH" -H "Content-Type: application/json" \
  https://api.dailybot.com/v1/checkins/<followup_uuid>/responses/ \
  -d '{"responses":[{"uuid":"<q-uuid>","index":0,"response":"Done"}],"last_question_index":0}'

# List forms (with questions)
curl -s -H "$AUTH" "https://api.dailybot.com/v1/forms/?include=questions"

# Submit a form
curl -s -X POST -H "$AUTH" -H "Content-Type: application/json" \
  https://api.dailybot.com/v1/forms/<form_uuid>/responses/ \
  -d '{"content":{"<question_uuid>":"My answer"}}'

# List users (paginated)
curl -s -H "$AUTH" https://api.dailybot.com/v1/users/

# Give kudos
curl -s -X POST -H "$AUTH" -H "Content-Type: application/json" \
  https://api.dailybot.com/v1/kudos/ \
  -d '{"receivers":["<user-uuid>"],"content":"Great work!"}'
```

**How to obtain a Bearer token programmatically:**

```bash
# Step 1 — request OTP
curl -s -X POST https://api.dailybot.com/v1/cli/request-code/ \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com"}'

# Step 2 — verify OTP
curl -s -X POST https://api.dailybot.com/v1/cli/verify-code/ \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","code":"123456"}'
# → {"token":"<bearer-token>","organization":"Org Name"}
```

### Environment Variable: `DAILYBOT_CONFIG_DIR`

Overrides where all credential and config files are stored (default:
`~/.config/dailybot/`). Useful for dev sandboxes, CI isolation, and testing.

```bash
export DAILYBOT_CONFIG_DIR=/tmp/my-sandbox-config
dailybot login --email me@example.com
```

---

## Advanced: Full Dailybot API

Beyond agent-specific endpoints, your API key gives you access to the full Dailybot v1 API. Use these when you need to interact with Dailybot features directly:

| Endpoint | Purpose |
|----------|---------|
| `GET /v1/users/` | List team members |
| `GET /v1/teams/` | List teams |
| `GET /v1/organization/` | Get organization info |
| `POST /v1/send-message/` | Send a bot message to a chat platform (Slack, Teams, Discord, Google Chat). Accepts `X-API-KEY` **or** `Authorization: Bearer` (login session, role-scoped). Targets `target_users` / `target_channels` / `target_teams`; optional `thread_responses[]` (≤10) posts replies inside the parent's thread in the same call; passing `bot_message_id` edits that message (parent or reply). Exposed in the CLI as `dailybot chat send` / `dailybot chat update` (>=1.13.0) and in the `dailybot-chat` sub-skill. |
| `POST /v1/send-email/` | Send an email |
| `GET /v1/followups/` | List daily standups |
| `GET /v1/checkins/` | List standup check-ins |
| `GET /v1/kudos/timeline/` | View team recognition feed |
| `GET /v1/workflows/` | List automated workflows |
| `POST /v1/invite-user/` | Invite a user to the organization |
| `POST /v1/webhook-subscription/` | Register an organization webhook |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `401 Unauthorized` | API key is invalid or expired. Re-authenticate: `dailybot login` or `dailybot config key=<new-key>`. If using HTTP, verify `DAILYBOT_API_KEY` is set correctly. |
| `403 Forbidden` | API key doesn't have the required scope. Ask the human to check key permissions at Dailybot → Settings → API Keys. |
| `404 Not Found` | Check the endpoint URL. All agent endpoints are under `/v1/`. |
| `429 Too Many Requests` | Rate limited. Slow down request frequency. Do not retry in a tight loop. |
| CLI not found after install | Re-check with `command -v dailybot`. Try the pip fallback: `pip install dailybot-cli`. If still failing, use the HTTP API with `DAILYBOT_API_KEY`. |
| "Not authenticated" | Run `dailybot status --auth` to check. Re-authenticate with `dailybot login` or `dailybot config key=<key>`. If session seems stale, run `dailybot logout` then `dailybot login`. |
| Agent not appearing in Dailybot | Send at least one health check or report. Dailybot auto-registers agents on first contact. |
| Not receiving messages | Verify `agent_name` is consistent across all requests. Messages are delivered to the exact name match. |

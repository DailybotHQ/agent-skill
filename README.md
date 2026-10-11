# Dailybot Agent Skill Pack

The official Dailybot agent skill pack connects coding agents to team
reporting, check-ins, forms, chat, and Dailybot Plan.

Long-running agents need to report outcomes, receive instructions, and keep
human teammates informed across sessions and repositories. This pack teaches
those workflows through a router and focused sub-skills. Your agent uses the
Dailybot CLI when available, or the HTTP API in restricted environments;
authentication, consent, and repository context are shared across the pack.

## Install and quickstart

Install the pinned **v3.23.12** pack with the cross-agent
[skills CLI](https://skills.sh):

```bash
npx skills add DailybotHQ/agent-skill@v3.23.12
```

Then ask your coding agent: **"Set up Dailybot and report this work."** It
shows any proposed CLI installation before asking for consent, guides login,
and offers optional reporting triggers/hooks separately. The pack baseline
is `dailybot-cli >= 3.9.0`; Dailybot Plan commands require `>= 3.25.0`.

With the CLI already installed, the first checks are:

```bash
dailybot --version
dailybot status --auth
dailybot login
```

`--version` prints `dailybot <version>`. Auth status identifies the active
organization; login guides authentication when it is missing. Keep that
account information out of public logs. Do not log in again when the
existing session is already valid.

For a manual, pinned checkout instead of skills.sh:

```bash
git clone --branch v3.23.12 --depth 1 https://github.com/DailybotHQ/agent-skill.git dailybot-skill
cd dailybot-skill
./setup.sh --host codex
```

The setup script creates skill symlinks for the chosen harness. It supports
Claude Code, Codex, Cursor, and other hosts; `./setup.sh --help` lists them.
Only `skills/dailybot/` is installed. Contributor docs, tests, and `.agents/`
remain in the source repository. This pack does not publish a `SHA256SUMS`
release asset; the companion CLI's script installation has its own mandatory
checksum verification. See the [installation guide](docs/INSTALLATION.md)
for alternative hosts, HTTP-only use, updating, and uninstalling.

## Core usage

After authentication, these are the common reporting commands:

```bash
dailybot agent update "Documented the review workflow so integration can wait for verified findings."
dailybot agent message list --pending
dailybot agent health --status
```

A successful report prints `OK Report submitted (id: <report-id>)` and a
`View: https://app.dailybot.com/agents/report/<report-id>` link. Capture that
link when confirming delivery. Message listing reads pending instructions;
health status reads the last reported status.

Before any command, respect the closest `.dailybot/profile.json`: omit
identity, auth-profile, and metadata flags it already provides. An explicit
[developer-authorized lane name](skills/dailybot/report/orchestra.md) is a
narrow exception for report `--name` only. `.dailybot/disabled` opts the
repository out of automated reporting and polling.

### Report from an orchestra lane

Each lead-assigned repository lane owns its significant progress/blocker
updates under a distinct name. The lead sends one integrated completion
milestone. With the developer's explicit authorization for `sample-repo lane`:

```bash
dailybot agent update "Documented lane reporting ownership so parallel work stays visible without duplicate updates." \
  --name "sample-repo lane" \
  --json-data '{"completed":["Lane reporting guidance validated"],"in_progress":["Integration approval"],"blockers":[]}'
```

This per-command name override never edits the repo profile or changes its
auth and metadata defaults. Lane completion is a regular report; it does
not use `--milestone`. Record delivery per logical event and avoid reposting
for the same hook reminder, session restart, or lead handoff. See the
[shipped orchestra reporting guide](skills/dailybot/report/orchestra.md).

### Ask the agent for other team workflows

The router dispatches ordinary requests to these shipped skills:

| Workflow | Sub-skills and scope |
| --- | --- |
| Progress and coordination | [Report](skills/dailybot/report/SKILL.md), [messages](skills/dailybot/messages/SKILL.md), [health](skills/dailybot/health/SKILL.md), and [ask](skills/dailybot/ask/SKILL.md) |
| Check-ins and forms | [Check-ins](skills/dailybot/checkin/SKILL.md) and [forms](skills/dailybot/forms/SKILL.md): author and complete check-ins; author, inspect, submit, and transition forms |
| Team communication | [Chat](skills/dailybot/chat/SKILL.md), [email](skills/dailybot/email/SKILL.md), [kudos](skills/dailybot/kudos/SKILL.md), [teams](skills/dailybot/teams/SKILL.md), [channels](skills/dailybot/channels/SKILL.md), and [conversation](skills/dailybot/conversation/SKILL.md) |
| Automation and organization | [Workflows](skills/dailybot/workflow/SKILL.md), [labels](skills/dailybot/labels/SKILL.md), and [featured](skills/dailybot/featured/SKILL.md) |
| Dailybot Plan | [Tasks](skills/dailybot/tasks/SKILL.md): boards, tasks, projects, goals, milestones, and agent attribution; CLI 3.25.0+ |
| Authentication environments | [Env](skills/dailybot/env/SKILL.md): opt-in repository credentials and environment selection |

For example, ask **"Complete my check-in"**, **"Read the review task I was
handed"**, or **"Send this update to the team channel"**. Permissions and
consent depend on the operation and active credential type; read the
sub-skill rather than assuming all credentials act as a person.

### Optional reporting hooks

With consent, the [report skill](skills/dailybot/report/SKILL.md) can install
prompt triggers and lifecycle hooks. Hooks run local `dailybot hook` commands
to remind the agent about unreported work; they do not send reports themselves.
The repository policy controls reminder cadence, and `dailybot hook dismiss`
snoozes a reminder. Remove the marked trigger/hook entries to uninstall;
see [hook controls](skills/dailybot/report/hooks.md) and the installation guide.

## How it fits with DeepWorkPlan

The optional [Dailybot addon](https://deepworkplan.com/kit/dailybot) connects
DeepWorkPlan's execution lifecycle to team visibility: kickoff, significant
results, blockers, and completion. Reports describe outcomes and their
purpose; plan IDs, file paths, and git statistics belong in technical evidence.

In an orchestra, [coding-agents-kit](https://github.com/DailybotHQ/coding-agents-kit)
selects coding accounts, [herdr-peers](https://github.com/DailybotHQ/herdr-peers)
handles lead/lane coordination, and Dailybot carries human-readable progress.
These are optional companion tools, not prerequisites for reporting.
[devcontainer-kit](https://github.com/DailybotHQ/devcontainer-kit) provides
the development environment; each reporting lane still needs its authorized
Dailybot authentication and identity. Reporting failures never block the
repository's development or validation gates.

## Part of the DeepWorkPlan ecosystem

[DeepWorkPlan](https://deepworkplan.com) turns any repository into an AI-first,
agent-pilotable codebase. These projects ship together; every addon is optional.

| Repository | Role | Purpose |
| --- | --- | --- |
| [deepworkplan-skill](https://github.com/DailybotHQ/deepworkplan-skill) | Pack | The methodology, specification and kit as an installable agent skill |
| [coding-agents-kit](https://github.com/DailybotHQ/coding-agents-kit) | Addon: agentkit | One command for every coding agent: accounts, quota, `ak pick`, headless runs |
| [devcontainer-kit](https://github.com/DailybotHQ/devcontainer-kit) | Addon: devcontainer | A reproducible dev container per repository, wired to Herdr and the host's accounts |
| [herdr-peers](https://github.com/DailybotHQ/herdr-peers) | Addon: Herdr | Ask an agent in another Herdr pane, on any machine, and get one authorized reply |
| [deepworkplan-vim](https://github.com/DailybotHQ/deepworkplan-vim) | Addon: DeepWorkPlan Vim | The terminal editor for plans: plan browser, lanes view, Markdown viewer |
| [ai-diff-reviewer](https://github.com/DailybotHQ/ai-diff-reviewer) | Required local review | Reviews a change set locally and in CI; every Final Review runs it |
| [agent-skill](https://github.com/DailybotHQ/agent-skill) (this repository) | Addon: Dailybot | The Dailybot agent skill: progress reports, check-ins, chat and more |
| [deepworkplan.com](https://deepworkplan.com) ([source](https://github.com/DailybotHQ/deepworkplan-website)) | Site and hub | The methodology, specification, kit catalog and `/init.md`; coordinates the ecosystem |

## Security and trust

CLI installation, global auto-activation, and hook configuration are separate
consent boundaries. Script installation verifies the published checksum;
`DAILYBOT_AUTO_YES=1` does not bypass email pre-send checks. Email requires a
confirmed recipient and content/credential checks. Keep credentials in the
CLI's auth storage or the opt-in gitignored environment file; never place them
in `.dailybot/profile.json`, prompts, examples, or public logs.

Context detection supplies repository/branch metadata rather than reading
source code for reports. Reports and other messages send the content you
choose to Dailybot; review it before sending. The API is not a code backup.
Respect `.dailybot/disabled`, inherited repository identity, and the selected
organization. Read [TRUST.md](skills/dailybot/TRUST.md),
[authentication](skills/dailybot/shared/auth.md), and the
[security policy](SECURITY.md) for the full guarantees and boundaries.

## Documentation and contributing

- [Router skill](skills/dailybot/SKILL.md) and [public CLI/HTTP reference](docs/API_REFERENCE.md)
- [Installation, update, and uninstall](docs/INSTALLATION.md), [OpenClaw notes](docs/OPENCLAW.md), and [docs index](docs/README.md)
- [Report writing guide](skills/dailybot/report/writing-guide.md), [repo profile](skills/dailybot/shared/repo-profile.md), and [hook architecture](docs/HOOKS_ARCHITECTURE.md)
- [Dailybot CLI](https://github.com/DailybotHQ/cli) and [Dailybot](https://www.dailybot.com)
- [Changelog](CHANGELOG.md), [contributing](CONTRIBUTING.md), and [agent instructions](AGENTS.md)
- [MIT license](LICENSE)

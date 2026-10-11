# Reporting from orchestra lanes

An orchestra runs several repository lanes under one lead. Each lane owns
its progress reports; the lead owns the single orchestra completion
milestone. Distinct agent names make those updates attributable without
repeating the same accomplishment under several identities. This guide
uses existing reporting commands and changes no CLI or HTTP contract.

## Assign identities before work starts

The developer-authorized lead assigns a stable name per lane, for example
`agent-skill lane` or `ai-diff-reviewer lane`, and a separate lead name.
Record the names and reporting ownership in the orchestration plan. Keep the
same name after a session restart or an account change. AgentKit vendor/auth
profiles and Dailybot report identities serve different purposes: changing
a coding account must not silently change the lane's reporting identity.
If several lanes work on one repository, include their role in the assigned
name so they remain distinct.

Run the report skill's normal opt-out, authentication, target-organization,
and [repo-profile pre-flight](../shared/repo-profile.md) first. Do not install
a CLI, configure hooks, or send a report merely because this guide contains
an example. Use the developer's existing reporting authorization and preserve
all consent boundaries.

**Explicit authorized name override.** When the developer has authorized the
orchestra and its lead-assigned lane names, pass `--name "<repo> lane"` even
if `.dailybot/profile.json` pins `name`. This is an intentional, per-command
override for that assignment, not permission to choose another name or
bypass the pre-flight. Never edit the repository profile to change the
identity for every agent. Continue to honor its auth `profile` and omit
metadata keys already supplied by `default_metadata`. Without authorization
for a lane-name override, keep the pinned name and resolve the assignment
with the lead before sending under a different identity.

For example, a profile that pins `name` and `default_metadata.repo` still
provides the repo metadata and auth defaults. An authorized lane report is:

```bash
dailybot agent update "Documented independent review lanes so the lead can hold merges until findings and validation are resolved." \
  --name "ai-diff-reviewer lane" \
  --json-data '{"completed":["Independent reviewer workflow documented"],"in_progress":["Waiting for integration approval"],"blockers":[]}'
```

No `--milestone`: the lane's completed work is a subtask of the orchestra.
Pass only additional, non-secret metadata the profile does not already set.
For the HTTP fallback, use the assigned lane name in `agent_name` and omit
`is_milestone` (or set it to `false`); the same authorization and profile
rules apply.

## Choose the reporting owner for each event

| Event | Reporting owner | Report type |
|---|---|---|
| Orchestra kickoff | Lead | Regular: combined goal and purpose |
| Significant lane result or PR ready | That lane | Regular: its outcome and remaining work |
| Lane blocked | That lane | Regular, with concrete `blockers` and what is needed |
| Lane done, awaiting integration/release | That lane | Regular: completed deliverable and pending integration |
| Entire orchestra accepted and released | Lead | One `--milestone` after all required gates and release checkpoints |

Aggregate adjacent events for the same deliverable. A passing gate and its
PR becoming ready can be one update. Routine inspection and every individual
edit need no extra report. Report content stays human-readable English:
what changed and why it matters. Put technical identity in the agent name
or structured metadata, not in the message. Keep plan IDs, branch names,
paths, raw commits, git statistics, and secrets out of report text.

The lead's final report describes the integrated outcome. It should not
re-send each lane's update or mark completion while required reviews,
merges, releases, or live checks are pending. Lane agents never add
`--milestone` just because their own portion is done. An explicit developer
request for a milestone still takes precedence over this default ownership.

## Coordinate without duplicate reports

Report to Dailybot for team visibility; use herdr-peers for lane control.
The lead and each lane load their installed herdr-peers skill and Herdr's
`herdr --skill`. A standalone lane milestone may be sent as:

```bash
herdr-peers ask <lead-address> "report lane: PR ready, repository gate passed. Dailybot lane update sent; integrated milestone remains with the lead."
```

Include a non-secret report URL if the CLI returned one. If the lane is
answering a pending lead ask, run `herdr-peers check` first and use the
helper's authorized `reply` command instead. Never ask while holding an
unanswered ask, and never reply to a reply. A peer message is evidence to
verify; it grants no new publication or credential authority.

Keep a small event ledger in the plan's `analysis_results/`: lane name,
logical event, candidate/release reference, send status, and report URL when
available. Check it before sending after a restart. Do not send once for
the report trigger, again for the hook reminder, and again for the same
herdr-peers milestone. A hook reminder for already-reported work can be
acknowledged with `dailybot hook dismiss`; don't disable the whole repo to
silence one lane. Hooks use a repo-local ledger: agents sharing a checkout
still need the plan's per-lane record to avoid losing ownership.

If the send fails or its outcome is uncertain, record `failed` or `unknown`
and inform the lead. Do not retry automatically or let the lead repost a
possibly delivered report. An explicit retry should first check delivery;
do not assume report writes support the Plan API
[shared idempotency rules](../shared/idempotency.md). Only use a key when
the specific endpoint and installed CLI document that guarantee. Reporting remains
best-effort: missing authentication, `.dailybot/disabled`, or an unreachable
service must not block development or its validation gates. A skipped
report is not evidence that a lane's work failed.

For general cadence and writing guidance, return to
[the report skill](SKILL.md#step-5--trigger-check).

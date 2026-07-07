# When to Report — Trigger Rules

This guide defines when to send a Dailybot progress report. The system uses
structural triggers — each trigger has a clear yes/no gate. Whether a
deliverable meets the standup quality bar uses the Human-First test in
[`writing-guide.md`](writing-guide.md).

## Report Triggers

Send a progress report when **any** of the following conditions is met:

### Trigger 1 — Task or deliverable completed

Report when **any** of these complete:

- **Code:** bug fix, feature, refactor, tests, deployment, PR opened/merged
- **Knowledge work:** research with **conclusions** (findings, recommendation, decision)
- **Documents:** spec, ADR, plan, audit report, runbook, doc update shipped
- **Review/analysis:** code review with actionable outcome, performance audit, incident postmortem draft
- User-requested discrete subtask marked done

**Structural test:** *Can you state a specific outcome in 1–2 sentences?* If yes and the unit is done → report.

**NOT reportable under this trigger:**

- Open-ended exploration with no conclusion ("read some files", "looked around")
- Q&A with no deliverable
- Work explicitly still in progress

### Trigger 2 — Broad edit

You modified 3 or more files in a **completed** batch of edits. Report the
**aggregate outcome**, not "3 files changed". This catches meaningful
cross-cutting changes even when no explicit "task" was defined.

Do not report incomplete work just because you edited 3+ files as part of an
ongoing task. The broad-edit trigger applies to a completed batch of edits,
not work-in-progress mid-stream.

### Trigger 3 — Hook reminder + completed unit

When a Dailybot hook injects a reminder (`commits` or `sustained work`):

- If **any deliverable** from Trigger 1 completed since the last report → **report now** (do not dismiss).
- If genuinely mid-stream on one task → `dailybot hook dismiss` and continue.
- **Never ignore a reminder silently** — report or dismiss.

See [`hooks.md`](hooks.md) § "Responding to reminders — default bias".

### User override

If the developer explicitly says "report this to Dailybot" or "send an update", always report regardless of the triggers above.

## Milestone Rule

Mark a report as a **milestone** only when the **top-level task is fully completed** — all subtasks are done and the entire requested piece of work is wrapped up.

Individual subtask completions are regular reports, not milestones. If the developer explicitly asks for a milestone, always honor it.

## Aggregation Rule

If you completed multiple related changes, combine them into one report. Don't send 3 reports for parts of one feature.

**Instead of:**
- "Updated the user model"
- "Added the preferences endpoint"
- "Wrote tests for preferences"

**Send one:**
- "Built the user preferences system — new data model, API endpoint, and full test coverage."

## Edge Cases

| Scenario | Action |
|----------|--------|
| Completed API audit, no code written | **Report** — findings + what it enables |
| 45 min research, decision made | **Report** — decision + rationale |
| Still implementing, 5 files touched | **Wait** — dismiss if reminded |
| Reported 20 min ago, related follow-up done | **Aggregate** into next report or extend prior if same thread |
| Hook reminder, session had real deliverable | **Report**, not dismiss |
| "I completed a task AND answered some questions" | Report the task completion. Ignore the Q&A. |
| "The developer asked me to report" | Always honor explicit requests |
| "I already reported recently" | If less than 30 minutes ago for the same logical task, aggregate with the next one |

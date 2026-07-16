# Skills & Agents Catalog — Dailybot Agent Skill Pack (contributor kit)

Index of skills and agents available **when editing this repository**.
End users install only `skills/dailybot/` — see the public [README.md](../../README.md).

## Product skill (ships to users)

| Slug | Path | Notes |
|------|------|-------|
| `dailybot` (+ sub-skills) | [`skills/dailybot/`](../../skills/dailybot/) | The installed artifact. Not duplicated under `.agents/`. |

## Deep Work Plan skill pack (vendored from [`DailybotHQ/deepworkplan-skill`](https://github.com/DailybotHQ/deepworkplan-skill))

Vendored at **v2.17.0** under [`.agents/skills/deepworkplan/`](../skills/deepworkplan/).

| Slug | Procedure | Use when |
|------|-----------|----------|
| `deepworkplan-create` (`/dwp-create`) | [`skills/deepworkplan/create/SKILL.md`](../skills/deepworkplan/create/SKILL.md) | Decomposing a contributor goal into a structured plan |
| `deepworkplan-execute` (`/dwp-execute`) | [`skills/deepworkplan/execute/SKILL.md`](../skills/deepworkplan/execute/SKILL.md) | Executing the current plan task-by-task |
| `deepworkplan-refine` (`/dwp-refine`) | [`skills/deepworkplan/refine/SKILL.md`](../skills/deepworkplan/refine/SKILL.md) | Adding / removing / reordering tasks |
| `deepworkplan-resume` (`/dwp-resume`) | [`skills/deepworkplan/resume/SKILL.md`](../skills/deepworkplan/resume/SKILL.md) | Picking up an interrupted plan |
| `deepworkplan-status` (`/dwp-status`) | [`skills/deepworkplan/status/SKILL.md`](../skills/deepworkplan/status/SKILL.md) | Reporting plan progress without changes |
| `deepworkplan-verify` (`/dwp-verify`) | [`skills/deepworkplan/verify/SKILL.md`](../skills/deepworkplan/verify/SKILL.md) | Objective DWP conformance check |
| `deepworkplan-onboard` | [`skills/deepworkplan/onboard/SKILL.md`](../skills/deepworkplan/onboard/SKILL.md) | Re-running onboard as reconciliation |
| `skill-create` / `agent-create` | [`skills/deepworkplan/author/SKILL.md`](../skills/deepworkplan/author/SKILL.md) | Growing this contributor kit |
| `ai-diff-reviewer` (addon) | [`skills/deepworkplan/addons/ai-diff-reviewer/SKILL.md`](../skills/deepworkplan/addons/ai-diff-reviewer/SKILL.md) | DWP addon wiring Security Review ↔ AI Diff Reviewer |
| `dailybot` (addon) | [`skills/deepworkplan/addons/dailybot/SKILL.md`](../skills/deepworkplan/addons/dailybot/SKILL.md) | Optional DWP lifecycle reporting (uses companion CLI / in-repo report skill) |

## AI Diff Reviewer (vendored from [`DailybotHQ/ai-diff-reviewer`](https://github.com/DailybotHQ/ai-diff-reviewer))

Vendored at **v2.0.0**. Flow B: local + CI gated on the **`Ready`** label.
Extension: [`.review/extension.md`](../../.review/extension.md). Workflow: [`.github/workflows/pr-review.yml`](../../.github/workflows/pr-review.yml). Secret: `CURSOR_API_KEY`.

| Slug | Procedure | Use when |
|------|-----------|----------|
| `ai-diff-reviewer` | [`skills/ai-diff-reviewer/SKILL.md`](../skills/ai-diff-reviewer/SKILL.md) | Local review on the current branch |
| `ai-diff-reviewer-generate-extension` | [`skills/ai-diff-reviewer/generate-extension/SKILL.md`](../skills/ai-diff-reviewer/generate-extension/SKILL.md) | Regenerating `.review/extension.md` |
| `ai-diff-reviewer-setup` | [`skills/ai-diff-reviewer/setup/SKILL.md`](../skills/ai-diff-reviewer/setup/SKILL.md) | Re-running the CI wizard |
| `ai-diff-reviewer-open-pr` | [`skills/ai-diff-reviewer/open-pr/SKILL.md`](../skills/ai-diff-reviewer/open-pr/SKILL.md) | Drafting a PR from the diff |
| `ai-diff-reviewer-apply-review` | [`skills/ai-diff-reviewer/apply-review/SKILL.md`](../skills/ai-diff-reviewer/apply-review/SKILL.md) | Walking CI findings per-finding |

## Agents

| Slug | Persona | When to use |
|------|---------|-------------|
| `skill-author` | [`agents/skill-author.md`](../agents/skill-author.md) | Default for edits under `skills/dailybot/` |
| `docs-writer` | [`agents/docs-writer.md`](../agents/docs-writer.md) | Doc-only changes |
| `test-engineer` | [`agents/test-engineer.md`](../agents/test-engineer.md) | bats / shellcheck / frontmatter tests |
| `release-manager` | [`agents/release-manager.md`](../agents/release-manager.md) | Release / version coordination |

# Commands Reference — Dailybot Agent Skill Pack (contributor kit)

Thin delegators in [`.agents/commands/`](../commands/). Procedural content lives
in the matching skill under [`.agents/skills/`](../skills/).

## Deep Work Plan

| Command | Routes to | What it does |
|---------|-----------|--------------|
| `/dwp-create` | `../skills/deepworkplan/create/SKILL.md` | Decompose a goal into a plan under `.dwp/` |
| `/dwp-execute` | `../skills/deepworkplan/execute/SKILL.md` | Execute task-by-task with validation gates |
| `/dwp-refine` | `../skills/deepworkplan/refine/SKILL.md` | Add / remove / reorder tasks |
| `/dwp-resume` | `../skills/deepworkplan/resume/SKILL.md` | Continue an interrupted plan |
| `/dwp-status` | `../skills/deepworkplan/status/SKILL.md` | Progress report without writes |
| `/dwp-verify` | `../skills/deepworkplan/verify/SKILL.md` | CONFORMANT / NOT CONFORMANT check |
| `/deepworkplan-onboard` | `../skills/deepworkplan/onboard/SKILL.md` | Reconcile onboard artifacts |
| `/skill-create` | `../skills/deepworkplan/author/SKILL.md` | Create a contributor skill |
| `/agent-create` | `../skills/deepworkplan/author/SKILL.md` | Create a contributor persona |

## AI Diff Reviewer (Flow B)

| Command / phrase | Routes to | What it does |
|------------------|-----------|--------------|
| "Review my current branch" | `../skills/ai-diff-reviewer/SKILL.md` | Local review (Security Review augmentation) |
| `/ai-diff-reviewer-generate-extension` | `../skills/ai-diff-reviewer/generate-extension/SKILL.md` | Regenerate `.review/extension.md` |
| `/ai-diff-reviewer-setup` | `../skills/ai-diff-reviewer/setup/SKILL.md` | CI workflow wizard |
| `/ai-diff-reviewer-open-pr` | `../skills/ai-diff-reviewer/open-pr/SKILL.md` | Draft PR title/body |
| `/ai-diff-reviewer-apply-review` | `../skills/ai-diff-reviewer/apply-review/SKILL.md` | Walk CI findings (never commits) |

CI trigger: apply the **`Ready`** label on a PR to `main`
([`.github/workflows/pr-review.yml`](../../.github/workflows/pr-review.yml);
requires `CURSOR_API_KEY`).

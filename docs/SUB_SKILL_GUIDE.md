# Adding a New Sub-Skill

Step-by-step for adding a new capability under
`skills/dailybot/`. Use this when you have a new flow that's distinct
enough from the existing four (`report`, `messages`, `email`, `health`)
to deserve its own SKILL.md, but tightly enough coupled to Dailybot
that it belongs in this pack rather than in a separate repo.

If you're not sure whether your idea qualifies, see the decision tree
at the bottom of this file.

---

## 0. Decide the name

Pick a kebab-case name starting with `dailybot-`:

```
dailybot-kudos
dailybot-checkin
dailybot-onboarding
```

Snake_case (`dailybot_kudos`) and camelCase (`dailybotKudos`) are
forbidden — they break skills.sh discovery and `setup.sh` symlink
naming. CI will reject them.

The folder name **drops the `dailybot-` prefix** because it lives
inside `skills/dailybot/`:

```
skills/dailybot/kudos/SKILL.md       # name in frontmatter: dailybot-kudos
```

## 1. Create the directory

```bash
mkdir -p skills/dailybot/<short-name>
```

If your skill has supporting files (templates, examples, scripts),
put them in the same directory:

```
skills/dailybot/<short-name>/
├── SKILL.md
├── examples.md       # optional
└── templates/        # optional
```

## 2. Write `SKILL.md`

Copy this template and adjust:

```markdown
---
name: dailybot-<short-name>
description: <one-sentence description with trigger phrases — when to activate, what it produces, when NOT to use it>
version: "1.0.0"
documentation_url: https://www.dailybot.com/skill.md
user-invocable: true|false
metadata: {"openclaw":{"emoji":"🎯","homepage":"https://dailybot.com","requires":{"anyBins":["dailybot","curl"]},"primaryEnv":"DAILYBOT_API_KEY","install":[{"id":"cli-install-script","kind":"download","url":"https://cli.dailybot.com/install.sh","label":"Install Dailybot CLI (official script — preferred on Linux/macOS)"},{"id":"pip","kind":"pip","package":"dailybot-cli","bins":["dailybot"],"label":"Install Dailybot CLI via pip (fallback if binary fails)"}]}}
allowed-tools: Bash, Read, Grep, Glob
---

# Dailybot <Short Name>

<One paragraph: what this skill does and when an agent should use it.>

---

## When to Use

- <trigger phrase 1>
- <trigger phrase 2>
- <when NOT to use it>

---

## Step 1 — Verify Setup

Read and follow the authentication steps in [`../shared/auth.md`](../shared/auth.md). That file covers CLI installation, login, API key setup, and agent profile configuration.

If auth fails or the developer declines, skip and continue with your primary task.

---

## Step 2 — Choose Execution Path

\`\`\`bash
command -v dailybot
\`\`\`

- **CLI found** → Step 3A
- **CLI not found** → Step 3B (see [`../shared/http-fallback.md`](../shared/http-fallback.md) for base curl patterns)

---

## Step 3A — <action> via CLI

<CLI command examples + flag table>

---

## Step 3B — <action> via HTTP API

<curl examples + field table>

---

## Non-Blocking Rule

This must **never block your primary work**. If the CLI is missing, auth fails, the network is down, or the command errors:

1. Warn the developer briefly
2. Continue with the primary task
3. Do not retry automatically
4. Do not enter a diagnostic loop

---

## Additional Resources

- [`../shared/auth.md`](../shared/auth.md) — authentication setup
- [`../shared/http-fallback.md`](../shared/http-fallback.md) — HTTP API fallback patterns
- **Live API spec:** `https://api.dailybot.com/api/swagger/`
- **Full agent API skill:** `https://www.dailybot.com/skill.md`
```

### Frontmatter checklist

- [ ] `name` is kebab-case and starts with `dailybot-`
- [ ] `description` is one sentence; mentions both *when to use* and *when not to*
- [ ] `version` is `"1.0.0"` (quoted string), bumped from there on subsequent changes
- [ ] `documentation_url` (NOT `homepage`)
- [ ] `user-invocable` is true if the developer should be able to type
      `/<name>` to invoke it explicitly, false otherwise
- [ ] `allowed-tools` lists only what the skill actually uses
- [ ] `metadata.openclaw.emoji` is set (single emoji, used in OpenClaw UI)

## 3. Update the router meta-skill

Add the new sub-skill to `skills/dailybot/SKILL.md`:

- A row in the **Available Skills** table
- A row in the **Routing Rules** table mapping intent phrases → the new
  skill
- A row in **Auto-activation** if the skill should fire without explicit
  invocation

## 4. Update `setup.sh`

Add the short folder name to the `SKILLS` array so symlinks get created:

```bash
SKILLS=("report" "messages" "email" "health" "<short-name>")
```

## 5. Update `triggers.md` (only if `user-invocable: true`)

If your skill is user-invocable AND should auto-activate after a
specific event, add a line to the trigger templates in
`skills/dailybot/report/triggers.md`. Example:

```
At the start of an onboarding session, run the dailybot-onboarding skill.
```

Wrap it inside the existing `<!-- dailybot-auto-activation -->` markers
in each agent template — don't introduce new markers.

If your skill is agent-only (`user-invocable: false`), skip this step.

## 6. Add tests

Create at minimum one bats test verifying the SKILL.md frontmatter is
discoverable and well-formed. The frontmatter validator
(`scripts/validate-frontmatter.py`) will check this in CI automatically,
but a focused test for any custom logic in the skill is worth writing.

If your skill ships a shell helper (like `shared/context.sh`), add a
bats file under `tests/` covering at least the happy path and one
edge case.

## 7. Update documentation

- `README.md` — add the new sub-skill to the **Skills** table
- `CHANGELOG.md` — add an entry under the current version's **Added**
  section
- `docs/API_REFERENCE.md` — if the new skill exposes a new HTTP
  endpoint or CLI command, document it here so the public reference at
  `www.dailybot.com/skill.md` stays in sync

## 8. Pre-merge checks

Same as for any other PR:

```bash
shellcheck setup.sh skills/dailybot/shared/context.sh scripts/*.sh
bats tests/
python3 scripts/validate-frontmatter.py
./setup.sh --host claude   # confirm the new symlink is created
```

## 9. Bump the skill pack version

Adding a new sub-skill is **additive**, so it's a minor bump:

- `1.0.0` → `1.1.0`

If the new sub-skill happens to remove or rename existing functionality
(unusual), it's a major bump:

- `1.x.y` → `2.0.0`

Update the `version` field in `skills/dailybot/SKILL.md` (the router)
and add the changelog entry.

---

## Decision tree: should I add a sub-skill, or do something else?

| Situation | Recommendation |
|-----------|---------------|
| New flow with distinct trigger phrases (e.g. "kudos") | ✅ Add a sub-skill |
| Tweak to an existing flow (e.g. add `--draft` flag to `report`) | ❌ Modify the existing sub-skill, don't fork |
| Helper that multiple sub-skills will use | ❌ Add to `skills/dailybot/shared/`, not as a sub-skill |
| One-off integration with a third-party service | ⚠️ Consider a separate repo + skills.sh listing — don't bloat this pack |
| Internal admin / debug tool for Dailybot devs | ❌ Belongs in `scripts/` at the repo root, never in `skills/` |
| New entire product feature with its own concept space | ⚠️ Often a separate skill pack in its own repo gets discovered better than a 12-skill pack here |

If in doubt, open an issue with the "feature request" template and
sketch the user story before writing code. The router meta-skill works
best when each sub-skill is genuinely distinct — adding a 5th, 6th,
7th overlapping skill makes routing decisions noisier for every agent
that loads us.

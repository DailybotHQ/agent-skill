# Design Decisions

Why this repository is laid out the way it is. If you're about to refactor
something to "modernize" it or "simplify" it, read the relevant section
first — most of these choices have a reason that isn't obvious from the
code, and reversing them has burned us in audit findings or in user
adoption.

This document is for AI agents and human contributors who need to
understand the *why*, not just the *what*. The conventions themselves are
in [`AGENTS.md`](../AGENTS.md). The behavior is in
[`skills/dailybot/SKILL.md`](../skills/dailybot/SKILL.md) and friends.

---

## 1. Router meta-skill + sub-skills (not one big SKILL.md)

We ship **one discoverable skill** (`dailybot`) that routes to
internal sub-skills (started as `report`, `messages`, `email` and `health`;
17 today, see `skills/dailybot/`). An
alternative would have been a single 800-line `SKILL.md` covering
everything.

We chose the router approach because:

- **Description-based discovery works better with focused descriptions.**
  When an agent decides "should I activate the dailybot skill?", it reads
  the `description` field. A focused description like *"Send progress
  updates after completing meaningful work"* triggers more accurately
  than a generic *"Talk to Dailybot for everything"*.
- **Different invocation policies per capability.** `report` is
  user-invocable (`/dailybot_report` slash command). `messages`,
  `email`, and `health` are agent-only. Encoding that in frontmatter is
  cleaner per sub-skill than in one omnibus file.
- **Independent symlinks via `setup.sh`.** Users get
  `~/.claude/skills/dailybot-report` etc. as standalone slash commands.
  This requires each sub-skill to be in its own folder.
- **Easier to evolve one capability without touching others.** A change
  to email guards in `email/SKILL.md` doesn't ripple into `report/`.

Trade-off: more files. We accept that — for a public skill people will
audit, focused files beat one giant one.

## 2. Everything under `skills/dailybot/` (not `SKILL.md` at repo root)

skills.sh discovers skills in two patterns:

1. `SKILL.md` at the repo root — for **single-skill repos**
2. `skills/<name>/SKILL.md` — for **single or multi-skill packs**

We use pattern (2) even though we ship one logical skill (`dailybot`)
because:

- Pattern (2) lets us also keep dev infrastructure at the repo root
  (`AGENTS.md`, `tests/`, `scripts/`, `.github/`) without ambiguity. With
  pattern (1), every root file becomes part of the "skill" semantically.
- Pattern (2) keeps the door open if we ever want to publish auxiliary
  skills (e.g. a `dailybot-onboarding` setup helper) as a sibling of
  `dailybot/`.
- The boundary "what ships at runtime" is unambiguous: anything inside
  `skills/dailybot/` ships, anything outside doesn't. With pattern (1)
  you have to maintain a `.skillignore`-like exclusion list.

## 3. `shared/` lives **inside** the pack, not as a sibling

`auth.md`, `context.sh`, and `http-fallback.md` are in
`skills/dailybot/shared/` even though four sub-skills depend on them.
Naively you might think `skills/dailybot/shared/` is the wrong place
because it makes the skill bundle heavier than necessary if a user only
wants `dailybot-report`.

The reason it has to be inside:

- skills.sh CLI copies/symlinks the **skill directory** when installing.
  If `shared/` were at `skills/_shared/` (sibling), it wouldn't be
  available to the installed skill — the user would have a
  `dailybot/SKILL.md` referencing `../shared/auth.md` that doesn't
  resolve.
- We pay the cost (slight duplication if we ever ship a second top-level
  skill) for the win (every install is self-contained).

## 4. `setup.sh` exists alongside `npx skills add`

There are two install paths:

- **`npx skills add DailybotHQ/agent-skill`** — uses skills.sh CLI,
  the canonical cross-agent installer
- **`git clone … && ./setup.sh`** — symlinks the pack and each
  sub-skill into the agent's skills directory

`setup.sh` is not redundant. We keep it because:

- It works without Node.js / npm (skills.sh CLI requires Node). Users in
  minimal containers, or who prefer not to add an npm dependency, get a
  pure-bash path.
- It makes the layout obvious: the script is small and readable, and it
  shows exactly which paths the skill installs to per agent.
- It's the path skills.sh's CLI itself recommends users fall back to
  when they're hacking on a skill locally — clone, edit, re-run setup.

## 5. `documentation_url` (not `homepage`) in frontmatter

Older Agent Skill examples used `homepage:` for the URL pointing to a
project's website or API reference. We renamed it to
`documentation_url:` because:

- Some agent harnesses interpret `homepage` as "fetch this URL to refresh
  the skill content" — a remote-load semantics we explicitly don't want.
  A single DNS or CDN compromise could push modified instructions to
  every installed user without touching local files.
- `documentation_url` is unambiguous: it's a *reference link*, not a
  *re-fetch source*.

The CI check in `scripts/validate-frontmatter.py` rejects any new
`homepage:` entries to prevent regression.

## 6. Kebab-case `name:` in frontmatter (not snake_case)

Pre-1.0 frontmatter used `name: dailybot_report`. We switched to
`name: dailybot-report` because:

- skills.sh CLI URLs and flags use kebab-case
  (`/skill dailybot-report`, `--skill dailybot-report`)
- `setup.sh` symlinks were already kebab (`~/.claude/skills/dailybot-report`)
- Snake_case in frontmatter + kebab-case in symlinks was an inconsistency
  that confused users and broke discovery for some agents

The CI check rejects `dailybot_*` names.

## 7. Consent flows — the load-bearing security decision

Three places require explicit user consent:

- **CLI install** — show command, ask first time in session
- **Auto-activation in agent config files** — show file path + content,
  ask before writing, mark with uninstall comment
- **Email send** — confirm recipient, scan for credential patterns,
  abort on match unless explicitly overridden

These exist because:

- They closed audit findings that determine whether Vercel will accept
  us on `skills.sh/official` and whether enterprise security teams
  approve internal use.
- Without them, the skill is a supply-chain attack vector dressed in
  friendly clothes — installing binaries, modifying global agent
  configs, and emailing secrets are exactly the actions a malicious
  skill would take silently.
- The friction is bounded: install consent and auto-activation prompts
  fire **once per session** (not per action), and once the developer
  approves, subsequent invocations are silent. Email confirmation is
  per-send because email is the highest-risk action.

The `DAILYBOT_AUTO_YES=1` escape hatch lets CI / Docker / power users
skip the install and auto-activation prompts. It deliberately does NOT
skip email checks.

## 8. CLI install via universal script (not brew/pip first)

Earlier drafts of `shared/auth.md` listed Homebrew first, pip second,
and the install script third. That was wrong because the script ALREADY
auto-detects the OS and uses Homebrew on macOS, the prebuilt binary on
Linux x86_64, and pipx/uv/pip elsewhere. Recommending brew or pip
directly is a worse, OS-specific subset of what the script already does.

The script is the universal entry point. Its safety controls
(SHA-256 verification + first-time consent) make it as safe as Homebrew's
signed-formula model. Brew and pip remain documented as
"manual control" alternatives for developers who explicitly prefer
their own toolchain.

## 9. Per-repo `.dailybot/disabled` opt-out

A user with a Dailybot org-scoped API key configured who works on a
personal side project, an unrelated client repo, or an NDA-bound repo
should not have repo names and branches leaked to the corporate
Dailybot dashboard.

`shared/context.sh` walks up from `$PWD` looking for
`.dailybot/disabled`. If found, it exits silently with code 0 and emits
no JSON, so any sub-skill that calls `context.sh` to enrich its payload
naturally skips telemetry for that repo.

This is opt-in per repo (you have to create the file deliberately),
which keeps the default behavior friendly while giving users a one-line
escape for sensitive contexts.

## 10. We use our own skill in this repo (eat our own dog food)

Contributors to this repo are encouraged to install
`DailybotHQ/agent-skill` and let it auto-activate during their work
here. When they finish a meaningful change, the report skill fires and
sends a Daily Standup-style update to the Dailybot organization.

This is more than a stylistic choice:

- **Validation** — if the skill works for our own work, we know it
  works for users. If it's annoying for us, we feel the friction
  immediately and fix it.
- **Documentation** — PRs naturally come with example reports
  demonstrating the writing guide.
- **Forcing function** — if a consent prompt fires too often or feels
  noisy in real use, it gets noticed in our own dev loop, not by users
  weeks later.

If you contribute and your agent doesn't have the skill installed yet,
do it now: `./setup.sh --host claude` (or your agent of choice) is
two seconds.

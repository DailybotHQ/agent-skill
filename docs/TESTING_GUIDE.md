# Testing guide

The shipped pack is Markdown plus a Bash installer and context helper. Its tests
run without Dailybot credentials or live API calls. Prefer focused unit tests
for a change, then the complete gate before a PR.

## Full validation

```bash
shellcheck setup.sh skills/dailybot/shared/context.sh
bats tests/
python3 scripts/validate-frontmatter.py
```

Bats and ShellCheck are development tools, not runtime dependencies. The
frontmatter validator uses PyYAML. CI covers Linux and the macOS Bash 3.2
runtime; Markdown link checking runs separately in CI.

## Scoped commands and source-to-test mapping

| Touched source | Scoped command | Coverage |
| --- | --- | --- |
| `setup.sh` | `bats tests/setup-sh.bats` | host selection, symlink targets, repeated setup, invalid inputs |
| `skills/dailybot/shared/context.sh` | `bats tests/context-sh.bats` | JSON context, opt-out traversal, tool/name overrides, non-git directories |
| `skills/dailybot/**/SKILL.md` | `python3 scripts/validate-frontmatter.py` | names, versions, required metadata, forbidden legacy keys |
| Skill instructions, trust guidance, docs | full gate plus review of changed links and consent/identity examples | prose contracts require semantic review |

Verified on 2026-10-11: both scoped Bats selections and the full 17-test suite
passed on macOS with temporary HOME/TMPDIR, system-only PATH and no inherited
credentials. ShellCheck and all 19 shipped skill frontmatter checks passed.

## Consumers and blind spots

Changes to shared auth, context, identity or consent affect every consuming
sub-skill: inspect those call sites and run the full gate. A source-only text
change still needs review of CLI flags and the documented HTTP contracts.
Unit tests do not prove a live Dailybot API result, agent harness behavior,
email delivery, global installation, or external CDN availability. Do not
send reports or email, change global agent settings, or read credentials just
to make a test pass. Live checks need their own authorization and outcome record.

## Escalation and fallback

If the mapping is unclear, inspect the relevant Bats test and its consumers,
then choose the full gate. If a tool is unavailable, report the exact missing
tool and use CI as the fallback; never describe an unrun check as passing.
Prefer unit-level coverage for executable behavior. Proposed integration
checks remain separate from the verified commands above.

# Development commands

Run contributor checks from the repository root. No package install or build
is required for the shipped Markdown/Bash skill.

```bash
# Full local gate
shellcheck setup.sh skills/dailybot/shared/context.sh
bats tests/
python3 scripts/validate-frontmatter.py

# Scoped installer/context checks
bats tests/setup-sh.bats
bats tests/context-sh.bats

# Contributor harness checks (repository only; existing plan history is separate)
python3 .agents/skills/deepworkplan/shared/delegators.py check --repo .
python3 .agents/skills/deepworkplan/shared/addon_sync.py plan --repo .
bash .agents/skills/deepworkplan/verify/conformance.sh --repo-only
```

See the [testing map](TESTING_GUIDE.md) for coverage and fallback, and
[installation guide](INSTALLATION.md) for user installation and uninstall.
`setup.sh` writes agent symlinks: use an isolated HOME for a smoke test.
`verify-cdn.sh` contacts the public CLI CDN and is not part of the hermetic gate.

## Temporary Files (tmp/) and `.dwp/`

The `tmp/` folder at the repo root is **git-ignored entirely** — the
directory is preserved with a `.gitkeep` placeholder, but every file or
subdirectory you create inside it is invisible to git. It exists so
agents and contributors can do scratch work without polluting the
working tree or risking accidental commits of debug output. The folder
is yours — write freely, clean up when done.

The gitignored `.dwp/` tree is the **structured** Deep Work Plan output
area (`plans/`, `drafts/`, progress state) — distinct from unstructured
`tmp/` scratch. Do not commit plans unless explicitly asked.

Use `tmp/` for:

- **Inter-agent prompts** — drafting a prompt for another agent before
  invoking it (`tmp/prompts/codex-review-pr.md`)
- **Probes against external services** — output from `curl`-ing
  `cli.dailybot.com`, `api.dailybot.com`, the GitHub API, etc.
  (`tmp/probes/cdn-check-2026-05-01.txt`)
- **Scratch experiments** — throwaway shell scripts or one-off tooling
  (`tmp/scratch/test-frontmatter-edge-case.sh`)
- **Data exports** — query results, downloaded artifacts you want to
  inspect without committing (`tmp/exports/skills-sh-listings.json`)
- **Personal scratch space** — `tmp/<your-handle>/` to avoid stepping
  on parallel work

Common subdirectory pattern (suggested but not enforced):
`tmp/scratch/`, `tmp/prompts/`, `tmp/probes/`, `tmp/exports/`.

**The hard rule:** nothing under `tmp/` is ever committed. If a file
you drafted in `tmp/` deserves to live in the repo, **move** it to its
proper home (`skills/dailybot/`, `tests/`, `scripts/`, `docs/`,
or the repo root) and `git add` it from there — never `git add tmp/...`
because the `.gitignore` will reject the file anyway and the path
itself is wrong.

CI does not look at `tmp/`. The frontmatter validator and bats tests
only see `skills/`, `tests/`, and a handful of named files. So there's
no risk of half-finished drafts breaking checks while you iterate.

If you create `tmp/` yourself by accident on a fresh clone (it's
already there in committed form via the README), it survives `git
clean -fd` because it's tracked.

---

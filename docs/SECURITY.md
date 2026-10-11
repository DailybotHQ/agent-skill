# Contributor security guide

The source skill enforces consent for CLI installation, global auto-activation
and each email send. Preserve those contracts in [the security policy](../SECURITY.md)
and [the shipped trust contract](../skills/dailybot/TRUST.md).

Contributor harness snapshots live under `.agents/skills/` and do not ship as
the product artifact. Install them from exact tags; verify pack/reviewer release
manifests and the Dailybot tag commit, then record refs and computed hashes in
`skills-lock.json`. Keep `.review/extension.md` and repository identity settings.
Never print, log or commit secret values. Hermetic tests receive no credentials;
live API operations require authorization and must respect `.dailybot/disabled`.

Provider-backed PR review runs only on trusted repository branches with the
`Ready` label. Read its actual gate conclusion and current-head findings before
merge; an advisory recommendation alone is not evidence of success.

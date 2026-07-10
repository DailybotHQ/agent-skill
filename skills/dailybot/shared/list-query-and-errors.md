# Shared reference — list query flags, pagination, and machine-readable errors

> **Requires `dailybot-cli >= 2.0.0`.** Everything on this page — the shared
> list query flags, the `{count, next, previous, results}` pagination envelope,
> the `Showing X of N` footer, the machine-readable error `code` dispatch, and
> the API-key / Bearer parity + free-plan gating rules — ships in CLI **2.0.0**.
> Below that, list commands take no query flags and the CLI matches on the human
> `detail` prose rather than the stable `code` field. Ask the developer to run
> `dailybot upgrade` if `dailybot --version` reports below 2.0.0.

This is the **single source of truth** for behavior shared across every
list-style Dailybot command. The sub-skills (`forms`, `kudos`, `workflow`,
`checkin`) link here instead of repeating it. Read it once per session and
cache the answer.

---

## 1. The list query flags

These flags are accepted by the list commands noted below. `--search` is also
accepted on `form responses` and `checkin history`.

| Flag | Alias | Meaning |
|------|-------|---------|
| `--page N` | | Fetch page `N` (1-based). |
| `--page-size N` | | Items per page. **Max 200** — larger values are clamped server-side. |
| `--all` | | Fetch **every** page and concatenate the results. Mutually exclusive with `--limit`. |
| `--limit N` | | Stop after the first `N` items (across pages). Mutually exclusive with `--all`. |
| `--search TEXT` | `--grep TEXT` | Case-insensitive substring filter. **Max 256 chars** — longer queries are truncated client-side before the request. |
| `--since YYYY-MM-DD` | | Start of a date range (inclusive). |
| `--until YYYY-MM-DD` | | End of a date range (inclusive). |
| `--date YYYY-MM-DD` | | A single day (shorthand for `--since D --until D`). |
| `--last-week` | | The previous calendar week (Monday–Sunday). |
| `--today` | | The current day. |

**Which commands take the full set:** `dailybot form list`,
`dailybot kudos list`, `dailybot workflow list`.
**`--search` only** (no pagination/date flags): `dailybot form responses`,
`dailybot checkin history`.

### Defaults and combinations

- **No flags → fetch everything.** With neither `--all`, `--limit`, nor
  `--page`, the CLI transparently walks all pages and returns the full set.
- **`--all` and `--limit` are mutually exclusive** — passing both is a
  client-side error.
- `--page` / `--page-size` fetch **one** explicit page; combine them to page
  manually.
- Date flags compose with `--search` (e.g. `--search retro --since 2026-07-01`).
- `--date`, `--last-week`, and `--today` are conveniences that expand into a
  `--since`/`--until` range for you.

---

## 2. The pagination envelope

Every list endpoint returns a standard envelope:

```json
{
  "count": 137,
  "next": "https://api.dailybot.com/v1/forms/?page=3&paginated=true",
  "previous": "https://api.dailybot.com/v1/forms/?page=1&paginated=true",
  "results": [ ... ]
}
```

- `count` — total items matching the query (across all pages).
- `next` / `previous` — absolute URLs to the adjacent pages, or `null` at the
  ends. The CLI follows `next` internally when you pass `--all` (or no paging
  flags).
- `results` — the items on the current page.

> **`?paginated=true` on the forms endpoints.** For the two forms list
> endpoints — `GET /v1/forms/` and `GET /v1/forms/<uuid>/responses/` — the CLI
> **always** sends `?paginated=true` so the response is the envelope shape
> above. HTTP-fallback callers hitting those endpoints directly should send it
> too, or they get the legacy bare-array shape.

---

## 3. The count footer

Every list command prints a `Showing X of N` footer (human output):

```
Showing 25 of 137
```

- `X` is how many rows were displayed this invocation (honoring `--limit` /
  `--page-size`); `N` is the envelope's `count`.
- When `X < N`, more items exist — re-run with `--all`, a larger `--page-size`,
  or the next `--page` to see them. Surface that to the developer so they know
  the view is truncated.
- In `--json` mode the footer is omitted; read `count` from the envelope
  instead.

---

## 4. Machine-readable error codes

Since 2.0.0 the CLI dispatches on a stable `code` field in the error body and
prints a friendly, actionable message. **Always match on `code`, never on the
human `detail` prose** — `detail` is display text and may change wording.

In `--json` mode the error surfaces as `{ error, status, code, detail }`.

### 403 — permission / plan gating

| `code` | Meaning | What to do |
|--------|---------|------------|
| `plan_upgrade_required` | The feature isn't on the org's current plan. Carries an `upgrade_url`. | Tell the developer the feature needs a plan upgrade; surface the `upgrade_url`. Do not retry. |
| `plan_free_api_keys_forbidden` | API keys are fully blocked on the FREE plan. | Suggest `dailybot login` (a Bearer session) instead of an API key. |
| `plan_missing_core_api_integrations` | The org's plan lacks the core API integration this call needs. | Explain the integration/plan gap; do not retry. |
| `api_key_owner_inactive` | The API key's owning user is deactivated. | The key is unusable — have an admin reactivate the owner or issue a new key. |
| `insufficient_role` | The caller's role is below what the action requires. Carries the required and current role. | Name the required role; suggest an admin/manager runs it. |
| `member_in_scope_required` | The caller must be a member of the targeted scope (team/check-in/form). | Pick a scope the caller belongs to. |
| `org_admin_required` | The action is org-admin only. | Only an org admin can run it. |

### 400 — bad input

| `code` | Meaning | What to do |
|--------|---------|------------|
| `target_user_inactive` | The targeted user is deactivated. | Pick an active user. |
| `search_query_too_long` | `--search` exceeded the limit. | The CLI truncates to 256 chars client-side; if you see this, shorten the query. |
| `invalid_date_range` | `--since`/`--until` are malformed or reversed. | Fix the dates (`YYYY-MM-DD`, since ≤ until). |
| `send_as_user_conflict` | `--send-as-user`/`--send-as-me` combined with `--bot-name`/`--bot-icon-*`. | Drop the custom-identity flags; the two are mutually exclusive. |
| `send_as_user_invalid_uuid` | `--send-as-user` value isn't a valid UUID. | Fix the UUID. (Caught client-side before the request.) |
| `send_as_user_not_found` | The `--send-as-user` UUID doesn't resolve to a user. | Confirm the user exists (`dailybot user list`). |

### 429 — rate limit

| `code` | Meaning | What to do |
|--------|---------|------------|
| `free_plan_daily_limit_exceeded` | A FREE-plan daily allowance is exhausted. | **Do not retry** — it resets tomorrow. Tell the developer. |
| *(generic 429, no code)* | Per-token throttle. | The CLI backs off with a **bounded** retry automatically; don't add your own tight retry loop. |

---

## 5. Auth model — API key ↔ Bearer parity, and plan gating

### Parity

`X-API-KEY` (an org API key) works on **every** `/v1/` endpoint **except**
`POST /v1/cli/auth/logout/`, which is Bearer-only. An API key and a login
Bearer session are otherwise **interchangeable** on user-scoped commands — the
server resolves the API key's owner and scopes the action to that identity.

### Free-plan gating

On a **FREE** plan the two credentials behave very differently:

- **API keys are fully blocked.** Any `X-API-KEY` call returns
  `403 plan_free_api_keys_forbidden` → route the developer to `dailybot login`.
- **Bearer sessions are allowed, but only for an allowlist** of endpoints on
  FREE:
  - agent reports (`50`/day),
  - `send-email` (`20`/day),
  - agent messages,
  - agent health,
  - agent register + claim,
  - `dailybot me`, `dailybot org`, and `dailybot status` (`cli status`).
- **Everything else on FREE** returns `403 plan_upgrade_required` with an
  `upgrade_url`. Surface the upgrade path and stop — do not retry.

Paid plans lift both restrictions (API keys work, the allowlist no longer
applies), subject to the usual role scoping.

---

## 6. Non-blocking rule

As with every Dailybot operation: if a list/read errors, warn briefly, honor
the `code`, and continue the primary task. Never retry in a tight loop —
especially on `free_plan_daily_limit_exceeded` (resets tomorrow) or
`plan_upgrade_required` (needs a plan change, not a retry).

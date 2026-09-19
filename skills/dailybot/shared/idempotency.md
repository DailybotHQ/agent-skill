# Idempotent retries — what a key guarantees, and what it does not

A retry that duplicates a write is worse than a retry that fails. Dailybot's Tasks API
accepts an `Idempotency-Key` on most writes so a call that times out can be sent again
safely. The CLI sends one automatically.

## The rule that matters

**A retry without a key is a new write.** The CLI handles that for you; if you are calling
the HTTP API directly, you are responsible for it.

## The 24-hour window, both halves

| When you reuse a key | What happens |
| --- | --- |
| **within 24 hours** | the server **replays** the original result and writes nothing |
| **after 24 hours** | the slot has expired — this is a **new** write and **will duplicate** |

Knowing only the first half is how a retry loop quietly creates duplicates on day two.

The CLI reports a replay explicitly: *"already applied — the server replayed a previous
identical call; nothing new was written."* Do not report that as a new creation.

## Keys are shared across an organization

The slot is keyed on `(organization, scope, key)`. **Two different API keys in the same
organization share the namespace.** Two agents that both use `retry-1` collide. This is why
the CLI generates uuid4 keys and why you should not invent human-friendly ones.

Pass your own only when you genuinely want a retry to be recognised across separate
invocations:

```bash
dailybot task create --title "Deploy v2" --idempotency-key "deploy-2026-09-19-v2"
```

## The two refusals

| Code | Meaning | What to do |
| --- | --- | --- |
| `idempotency_key_payload_mismatch` | the key was used with a **different body**, and this body was not written | use a **new** key — retrying the same one cannot succeed |
| `idempotency_in_progress` | an identical call is still running | wait and check the result; **do not loop** |

## Doors that ignore the header

Not every write honours it. Where the server ignores it, the CLI does not send one and
offers no `--idempotency-key` flag — advertising a guarantee that does not exist is worse
than having none. Currently: `project update-post`, `milestone complete` / `reopen`, and
task subscription.

`POST /v1/tasks/tasks/bulk/` is the opposite: it **requires** the header.

## A timeout is not a failure

A write that times out is **not known to have failed**. Check the current state before
retrying rather than assuming. The CLI says so in the message for exactly this reason.

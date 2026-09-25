# Tasks — complete command reference

> **Beta** — Tasks is in beta. Everything under `/tasks` in the web app, the CLI and agent skill commands for projects, goals, boards and tasks, and the `/v1/tasks/` public API may change before general availability. Want to try it with your team? Write to **support@dailybot.com**.

This file lists **every** Tasks command in `dailybot-cli >= 3.14.0`: 103 commands across
`tasks`, `task`, `board`, `project` and `goal`. It is generated from the CLI's own command
definitions, so the arguments and flags here match `--help` exactly. [SKILL.md](SKILL.md)
explains *when* and *how* to use them (untrusted content, credentials, delta cursors,
destructive previews, refusals). Use this file to look up *what exists* and *what each
command sends*. Read SKILL.md Step 0 before acting on anything these commands return.

## How to read an entry

- **Arguments.** `TASK` is a task key (`ENG-142`) or a task uuid. Every other argument
  (`BOARD`, `PROJECT`, `GOAL`, `STATE`, `VIEW`, `USER`, …) is a uuid unless the entry says
  otherwise. `[X]` means optional; `X…` means one or more.
- **API.** The door the command calls under `https://api.dailybot.com`. `+key` / `+Idempotency-Key`
  means the CLI sends an `Idempotency-Key` header. It prints the key after a write so a retry
  of the **same** call (`--idempotency-key <key>`) is safe for 24 hours. A dry run never
  sends a key. `(tasks:admin)` marks a structure change that needs an organization admin
  signed in with `dailybot login`. That scope can never be held by an API key.
- **Person-only.** **yes** means the door is defined relative to the signed-in person
  (their inbox, pins, views, who is notified, who can see). With an API key the CLI refuses
  **before sending anything** and exits 3. The fix is `dailybot login`.
- **Flags.** `<type>` is the value type; `a|b|c` lists the accepted values. **required**
  flags must be passed; **repeatable** flags may be given several times. Short aliases are
  listed with the long name.
- **`--json`.** Every command accepts `--json`. It prints the raw API document on stdout,
  and on failure a `{code, message}` object with a non-zero exit. Parse `--json` output;
  never parse the human tables.
- **Destructive commands.** Every archive / delete / remove / unlink / retire command takes
  `--dry-run` (shows the consequence, changes nothing) and `--yes` (skips the prompt). Show the
  consequence to the human first ([destructive previews](../shared/destructive-previews.md)).
  Exit 7 means a person declined. Stop, and never re-run with `--yes`.
- **Exit codes.** 0 ok · 1 partial · 2 bad input · 3 needs a signed-in person · 4 refused ·
  5 not found or not visible · 6 transient · 7 declined · 8 transport · 9 delta cursor expired.

Examples use placeholder uuids (`00000000-0000-0000-0000-00000000000N`) and the key
`ENG-142`. Replace them with real values from a read.

## Index

| Group | Commands |
| --- | --- |
| `tasks` | `activity`, `changes`, `counts`, `cursor`, `entitlements`, `favorites`, `inbox`, `inbox-read`, `inbox-read-all`, `inbox-unread`, `mine`, `search`, `status`, `timeline`, `view delete`, `view get`, `view star`, `view unstar`, `view update` |
| `task` | `activity`, `archive`, `attach`, `attachment delete`, `attachment get`, `attachments`, `bulk`, `children`, `comment`, `comment-delete`, `comment-edit`, `comments`, `create`, `delete`, `duplicate`, `events`, `get`, `labels`, `link`, `list`, `move`, `mute`, `participants add`, `participants list`, `participants remove`, `relations`, `restore`, `set-owner`, `unlink`, `unmute`, `unwatch`, `update`, `watch` |
| `board` | `archive`, `create`, `get`, `label create`, `labels`, `list`, `member add`, `member remove`, `members`, `mentionables`, `restore`, `snapshot`, `star`, `state archive`, `state create`, `state reorder`, `state restore`, `state update`, `states`, `tasks`, `unstar`, `update`, `view save`, `views` |
| `project` | `archive`, `create`, `get`, `list`, `member add`, `member remove`, `members`, `milestone-complete`, `milestone-create`, `milestone-delete`, `milestone-reopen`, `milestone-update`, `milestones`, `restore`, `update`, `update-post`, `updates`, `view save`, `views` |
| `goal` | `archive`, `create`, `get`, `link`, `list`, `restore`, `unlink`, `update` |

## Workspace — `dailybot tasks`

Workspace-level reads, the delta cursor, the signed-in person's inbox and lists, saved views and pins.

### `dailybot tasks activity`

Show the workspace activity feed — the catch-up read after an absence.

- **API:** `GET /v1/tasks/activity/`
- **Person-only:** no
- **Flags:**
  - `--since` `<text>` — Only activity at or after this ISO-8601 time.
  - `--until` `<text>` — Only activity at or before this ISO-8601 time.
  - `--date` `<text>` — One day (YYYY-MM-DD).
  - `--today` — Only today.
  - `--last-week` — Monday to Sunday of last week.
  - `--type` `<text>` — Only this kind of event, e.g. task.moved.
  - `--actor` `<text>` — Only what this person did (user uuid).
  - `--project` `<text>` — Only this project (uuid).
  - `--board` `<text>` — Only this board (uuid).
  - `--task` `<text>` — Only this task (uuid).
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
- **Example:** `dailybot tasks activity --last-week --json`

### `dailybot tasks changes BOARD`

Read what changed on a board since a cursor.

- **API:** `GET /v1/tasks/boards/{b}/delta/?updated_since= (reads boards/{b}/board/ first when no cursor)`
- **Person-only:** no
- **Flags:**
  - `--cursor` `<text>` — Resume from this delta cursor (from a snapshot).
  - `--updated-since` `<text>` — ISO-8601 timestamp to read changes since.
  - `--resync` — If the cursor has expired, read a fresh snapshot instead of failing.
- **Example:** `dailybot tasks changes 00000000-0000-0000-0000-000000000001 --updated-since 2026-09-20T00:00:00Z --json`

### `dailybot tasks counts`

Show how many tasks are yours, by bucket.

- **API:** `GET /v1/tasks/me/tasks/counts/`
- **Person-only:** **yes**
- **Example:** `dailybot tasks counts`

### `dailybot tasks cursor`

Read or move your activity read-mark — "what is new since I last looked".

- **API:** `GET|PUT /v1/tasks/me/activity-cursor/`
- **Person-only:** **yes**
- **Flags:**
  - `--set` `<text>` — Record that you have read activity up to this ISO-8601 time.
  - `--now` — Record that you are caught up as of now.
- **Example:** `dailybot tasks cursor --now`

### `dailybot tasks entitlements`

Show what this organization's plan allows for Tasks.

- **API:** `GET /v1/tasks/entitlements/`
- **Person-only:** no
- **Example:** `dailybot tasks entitlements`

### `dailybot tasks favorites`

List your pinned boards and saved views.

- **API:** `GET /v1/tasks/me/favorites/`
- **Person-only:** **yes**
- **Example:** `dailybot tasks favorites --json`

### `dailybot tasks inbox`

Show your Tasks notifications.

- **API:** `GET /v1/tasks/inbox/`
- **Person-only:** **yes**
- **Flags:**
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
- **Example:** `dailybot tasks inbox --json`

### `dailybot tasks inbox-read ITEM`

Mark an inbox item — and everything older — as read.

- **API:** `POST /v1/tasks/inbox/{item}/read/`
- **Person-only:** **yes**
- **Example:** `dailybot tasks inbox-read 00000000-0000-0000-0000-000000000010`

### `dailybot tasks inbox-read-all`

Mark your whole Tasks inbox as read.

- **API:** `POST /v1/tasks/inbox/read-all/`
- **Person-only:** **yes**
- **Example:** `dailybot tasks inbox-read-all`

### `dailybot tasks inbox-unread`

How many Tasks notifications you have not read.

- **API:** `GET /v1/tasks/inbox/unread-count/`
- **Person-only:** **yes**
- **Example:** `dailybot tasks inbox-unread --json`

### `dailybot tasks mine`

List the tasks that are yours.

- **API:** `GET /v1/tasks/me/tasks/?scope=owned|participating|involved`
- **Person-only:** **yes**
- **Flags:**
  - `--scope` `<text>` — owned (default): you are the owner · participating: you are on the card · involved: owned, participating or created by you.
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
- **Example:** `dailybot tasks mine --scope owned --json`

### `dailybot tasks search`

Search tasks, boards and projects by text.

- **API:** `GET /v1/tasks/search/?q=`
- **Person-only:** no
- **Flags:**
  - `--query`, `-q` `<text>` **required** — Text to search for across the workspace.
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
- **Example:** `dailybot tasks search -q "deploy" --json`

### `dailybot tasks status`

Show the workspace pulse — open, overdue and blocked counts.

- **API:** `GET /v1/tasks/pulse/?include=projects,attention,activity,goal_progress`
- **Person-only:** no
- **Example:** `dailybot tasks status --json`

### `dailybot tasks timeline`

Show a dated view of the workspace.

- **API:** `GET /v1/tasks/timeline/`
- **Person-only:** no
- **Flags:**
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
  - `--since`, `-S` `<text>` — Start date (YYYY-MM-DD).
  - `--until`, `-U` `<text>` — End date (YYYY-MM-DD).
  - `--date`, `-D` `<text>` — Single day (YYYY-MM-DD): sets start and end.
  - `--last-week` — Previous Monday-Sunday week.
  - `--today` — Today only.
- **Example:** `dailybot tasks timeline --today`

### `dailybot tasks view delete VIEW`

Delete one saved view.

- **API:** `DELETE /v1/tasks/views/{v}/`
- **Person-only:** **yes**
- **Flags:**
  - `--dry-run` — Say what would happen and send nothing.
  - `--yes`, `-y` — Skip the confirmation.
- **Example:** `dailybot tasks view delete 00000000-0000-0000-0000-000000000013 --yes`

### `dailybot tasks view get VIEW`

Show one saved view.

- **API:** `GET /v1/tasks/views/{v}/`
- **Person-only:** **yes**
- **Example:** `dailybot tasks view get 00000000-0000-0000-0000-000000000013 --json`

### `dailybot tasks view star VIEW`

Pin a saved view to your favorites.

- **API:** `POST /v1/tasks/me/favorites/ {target_type: view, target_uuid} +Idempotency-Key`
- **Person-only:** **yes**
- **Example:** `dailybot tasks view star 00000000-0000-0000-0000-000000000013`

### `dailybot tasks view unstar VIEW`

Unpin a saved view from your favorites.

- **API:** `GET /v1/tasks/me/favorites/ then DELETE /v1/tasks/me/favorites/{f}/`
- **Person-only:** **yes**
- **Example:** `dailybot tasks view unstar 00000000-0000-0000-0000-000000000013`

### `dailybot tasks view update VIEW`

Edit one saved view.

- **API:** `PATCH /v1/tasks/views/{v}/`
- **Person-only:** **yes**
- **Flags:**
  - `--name`, `-n` `<text>` — New name (max 64 characters).
  - `--view-mode` `<list|board|kanban|timeline|calendar>` — How it is drawn.
  - `--group-by` `<state|owner|priority|category>`
  - `--sort` `<text>` — Sort expression, as the web app saves it.
  - `--visibility` `<personal|shared|board_default>` — `shared` and `board_default` need a board manager.
  - `--filters-file` `<file (`-` = stdin)>` — JSON object of filters (`-` reads stdin); replaces the view's filters.
- **Example:** `dailybot tasks view update 00000000-0000-0000-0000-000000000013 --view-mode kanban --group-by owner`

## One task — `dailybot task`

Everything about a single task (`TASK` is a key such as `ENG-142`, or a uuid), plus the bulk door.

### `dailybot task activity TASK`

Show one task's activity feed — what changed, who changed it, from and to.

- **API:** `GET /v1/tasks/tasks/{t}/activity/ (?updated_since=&type=)`
- **Person-only:** no
- **Flags:**
  - `--updated-since` `<text>` — Only activity after this ISO-8601 timestamp.
  - `--type` `<text>` — Only this kind of activity.
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
- **Example:** `dailybot task activity ENG-142 --updated-since 2026-09-20T00:00:00Z`

### `dailybot task archive TASK`

Archive a task.

- **API:** `POST /v1/tasks/tasks/{t}/archive/?dry_run=true then POST …/archive/ +key`
- **Person-only:** no
- **Flags:**
  - `--dry-run` — Show the consequence and exit without acting.
  - `--yes`, `-y` — Skip the prompt (still previews).
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot task archive ENG-142 --dry-run`

### `dailybot task attach TASK FILE`

Attach a file to a task.

- **API:** `POST /v1/tasks/tasks/{t}/attachments/presign/ → PUT upload_url (storage, no Dailybot credentials) → POST …/{a}/confirm/; with --caption: POST /v1/tasks/tasks/{t}/attachments/ multipart`
- **Person-only:** no
- **Flags:**
  - `--caption` `<text>` — Short caption. Uses the one-request upload, limited to 5 MiB.
- **Example:** `dailybot task attach ENG-142 ./crash.log`

### `dailybot task attachment delete TASK ATTACHMENT`

Remove an attachment from a task.

- **API:** `DELETE /v1/tasks/tasks/{t}/attachments/{a}/`
- **Person-only:** no
- **Flags:**
  - `--dry-run` — Say what would happen and send nothing.
  - `--yes`, `-y` — Skip the confirmation.
- **Example:** `dailybot task attachment delete ENG-142 00000000-0000-0000-0000-000000000009 --yes`

### `dailybot task attachment get TASK ATTACHMENT`

Download an attachment to a file.

- **API:** `GET /v1/tasks/tasks/{t}/attachments/{a}/content/ (follows one redirect to storage, no credentials)`
- **Person-only:** no
- **Flags:**
  - `--output`, `-o` `<file>` **required** — Where to write the file.
  - `--force` — Overwrite the output file if it exists.
- **Example:** `dailybot task attachment get ENG-142 00000000-0000-0000-0000-000000000009 -o ./crash.log`

### `dailybot task attachments TASK`

List a task's attachments.

- **API:** `GET /v1/tasks/tasks/{t}/attachments/`
- **Person-only:** no
- **Example:** `dailybot task attachments ENG-142 --json`

### `dailybot task bulk`

Apply one operation to up to 100 tasks in a single call.

- **API:** `POST /v1/tasks/tasks/bulk/ +key (required); --dry-run → ?dry_run=true, no key`
- **Person-only:** no
- **Flags:**
  - `--operation` `<create|move|update|archive|restore|set_labels|set_owner|set_priority|set_due_date|set_parent|delete>` **required** — Operation to apply to every item.
  - `--file`, `-f` `<file (`-` = stdin)>` **required** — JSON file with the item list, or `-` for stdin.
  - `--board` `<text>` — Board (uuid or key) every created task lands on. Required for --operation create.
  - `--dry-run` — Run the batch on the server and roll it back: shows each change, writes nothing.
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
  - `--yes`, `-y` — Skip the confirmation.
- **Example:** `dailybot task bulk --operation set_owner -f batch.json --dry-run`

### `dailybot task children TASK`

List a task's direct sub-tasks.

- **API:** `GET /v1/tasks/tasks/{t}/children/`
- **Person-only:** no
- **Example:** `dailybot task children ENG-142`

### `dailybot task comment TASK BODY`

Comment on a task.

- **API:** `POST /v1/tasks/tasks/{t}/comments/ +key`
- **Person-only:** no
- **Flags:**
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot task comment ENG-142 "Deployed. <@DB@00000000-0000-0000-0000-000000000004> can you verify?"`

### `dailybot task comment-delete TASK COMMENT`

Delete a comment.

- **API:** `DELETE /v1/tasks/tasks/{t}/comments/{c}/`
- **Person-only:** no
- **Flags:**
  - `--dry-run` — Say what would happen and send nothing.
  - `--yes`, `-y` — Skip the confirmation.
- **Example:** `dailybot task comment-delete ENG-142 00000000-0000-0000-0000-000000000007 --yes`

### `dailybot task comment-edit TASK COMMENT BODY`

Replace a comment's text.

- **API:** `PATCH /v1/tasks/tasks/{t}/comments/{c}/`
- **Person-only:** no
- **Example:** `dailybot task comment-edit ENG-142 00000000-0000-0000-0000-000000000007 "Deployed to prod"`

### `dailybot task comments TASK`

List a task's comments.

- **API:** `GET /v1/tasks/tasks/{t}/comments/`
- **Person-only:** no
- **Flags:**
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--all`, `-a` — Fetch every page (iterate until the end).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
  - `--search`, `--grep`, `-s` `<text>` — Filter by text (max 256 chars; truncated).
  - `--since`, `-S` `<text>` — Start date (YYYY-MM-DD).
  - `--until`, `-U` `<text>` — End date (YYYY-MM-DD).
  - `--date`, `-D` `<text>` — Single day (YYYY-MM-DD): sets start and end.
  - `--last-week` — Previous Monday-Sunday week.
  - `--today` — Today only.
- **Example:** `dailybot task comments ENG-142 --json`

### `dailybot task create`

Create a task.

- **API:** `POST /v1/tasks/tasks/ +Idempotency-Key`
- **Person-only:** no
- **Flags:**
  - `--title`, `-t` `<text>` **required** — Task title.
  - `--board`, `-b` `<text>` — Board to create it on.
  - `--description`, `-d` `<text>` — Task description.
  - `--state` `<text>` — Initial workflow state.
  - `--owner` `<text>` — Owner: a user uuid, or `me`.
  - `--due` `<text>` — Due date (YYYY-MM-DD).
  - `--priority` `<int 1–5>` — Priority 1-5: 1 urgent, 2 high, 3 medium, 4 low, 5 none.
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe. Generated automatically when omitted. The server keeps it for 24h: reusing it inside that window replays the original result, reusing it after duplicates.
- **Example:** `dailybot task create -t "Fix the flaky test" -b 00000000-0000-0000-0000-000000000001 --owner me --priority 2`

### `dailybot task delete TASK`

Archive a task.

- **API:** `alias of archive (same doors)`
- **Person-only:** no
- **Flags:**
  - `--dry-run` — Show the consequence and exit without acting.
  - `--yes`, `-y` — Skip the prompt (still previews).
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot task delete ENG-142 --yes`

### `dailybot task duplicate TASK`

Copy a task into the same column, with a new key.

- **API:** `POST /v1/tasks/tasks/{t}/duplicate/ +key {include[]}`
- **Person-only:** no
- **Flags:**
  - `--include` `<title|description|labels|priority|estimate|owner|start_date|due_date>` repeatable — Fields to copy (repeatable). Default: title, description and labels.
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe. Generated automatically when omitted.
- **Example:** `dailybot task duplicate ENG-142 --include title --include owner`

### `dailybot task events TASK`

List a task's raw event history (created, moved, owner changed, …).

- **API:** `GET /v1/tasks/tasks/{t}/events/`
- **Person-only:** no
- **Example:** `dailybot task events ENG-142 --json`

### `dailybot task get TASK`

Show one task.

- **API:** `GET /v1/tasks/tasks/{t}/`
- **Person-only:** no
- **Example:** `dailybot task get ENG-142 --json`

### `dailybot task labels TASK`

Add, remove or replace a task's labels.

- **API:** `POST /v1/tasks/tasks/{t}/labels/batch/ +key`
- **Person-only:** no
- **Flags:**
  - `--mode` `<add|remove|replace>` **required** — add, remove or replace the task's labels.
  - `--label` `<text>` **required** repeatable — Label uuid. Repeatable, or comma-separated.
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot task labels ENG-142 --mode add --label 00000000-0000-0000-0000-000000000012`

### `dailybot task link TASK OTHER_TASK`

Relate one task to another.

- **API:** `POST /v1/tasks/tasks/{t}/relations/ +key {relation_type: blocks|relates_to|duplicates, target_task}`
- **Person-only:** no
- **Flags:**
  - `--type` `<text>` **required** — blocks, relates_to or duplicates.
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot task link ENG-142 ENG-99 --type blocks`

### `dailybot task list`

List tasks.

- **API:** `GET /v1/tasks/tasks/ (?owner=&sort=&board=&state=&label=&include=)`
- **Person-only:** no
- **Flags:**
  - `--board`, `-b` `<text>` — Only tasks on this board.
  - `--state` `<text>` — Only tasks in this workflow state.
  - `--owner` `<text>` repeatable — Only tasks owned by this user (uuid, `me` or `unowned`). Repeat to OR several.
  - `--label` `<text>` — Only tasks carrying this label.
  - `--sort` `<text>` — Order by rank, priority, due_date, updated_at, created_at or completed_at; prefix with - for descending.
  - `--has-dates` — Only tasks that do (or do not) carry dates.
  - `--include` `<labels|participants|subtasks>` repeatable — Ask for a roll-up. Nothing is included by default — absence is a real answer.
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
- **Example:** `dailybot task list --owner me --owner unowned --sort -updated_at --json`

### `dailybot task move TASK`

Move a task to another column, or to another board.

- **API:** `POST /v1/tasks/tasks/{t}/move/ +key (state name/category resolved via GET boards/{b}/states/); with --board POST /v1/tasks/tasks/{t}/move-board/`
- **Person-only:** no
- **Flags:**
  - `--state` `<text>` — Target column: a name, a category (todo, in_progress, done, …) or a state uuid.
  - `--board` `<text>` — Target board, for a move to another board.
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe (same-board moves; a cross-board move takes none).
- **Example:** `dailybot task move ENG-142 --state done`

### `dailybot task mute TASK`

Stop notifications from a task while staying on it.

- **API:** `GET /v1/me/ then POST /v1/tasks/tasks/{t}/participants/ {user_uuid: me, is_muted: true}`
- **Person-only:** **yes**
- **Example:** `dailybot task mute ENG-142`

### `dailybot task participants add TASK`

Add a participant to a task.

- **API:** `POST /v1/tasks/tasks/{t}/participants/ +key`
- **Person-only:** **yes**
- **Flags:**
  - `--user` `<text>` **required** — User uuid to add as a participant.
  - `--role` `<participant|watcher>` — `participant` is on the card (default); `watcher` follows it without being on it.
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot task participants add ENG-142 --user 00000000-0000-0000-0000-000000000004 --role watcher`

### `dailybot task participants list TASK`

List who is on a task and who watches it.

- **API:** `GET /v1/tasks/tasks/{t}/participants/`
- **Person-only:** no
- **Example:** `dailybot task participants list ENG-142`

### `dailybot task participants remove TASK USER`

Take someone off a task.

- **API:** `DELETE /v1/tasks/tasks/{t}/participants/{u}/`
- **Person-only:** **yes**
- **Flags:**
  - `--dry-run` — Say what would happen and send nothing.
  - `--yes`, `-y` — Skip the confirmation.
- **Example:** `dailybot task participants remove ENG-142 00000000-0000-0000-0000-000000000004 --yes`

### `dailybot task relations TASK`

List a task's links to other tasks.

- **API:** `GET /v1/tasks/tasks/{t}/relations/`
- **Person-only:** no
- **Example:** `dailybot task relations ENG-142 --json`

### `dailybot task restore TASK`

Restore an archived task.

- **API:** `POST /v1/tasks/tasks/{t}/restore/ +key`
- **Person-only:** no
- **Flags:**
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot task restore ENG-142`

### `dailybot task set-owner TASK USER`

Make someone the task's owner — the accountable person.

- **API:** `PATCH /v1/tasks/tasks/{t}/ {owner}`
- **Person-only:** no
- **Flags:**
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot task set-owner ENG-142 me`

### `dailybot task unlink TASK RELATION`

Remove a link between two tasks.

- **API:** `DELETE /v1/tasks/tasks/{t}/relations/{r}/`
- **Person-only:** no
- **Flags:**
  - `--dry-run` — Say what would happen and send nothing.
  - `--yes`, `-y` — Skip the confirmation.
- **Example:** `dailybot task unlink ENG-142 00000000-0000-0000-0000-000000000008 --yes`

### `dailybot task unmute TASK`

Resume notifications from a task you muted.

- **API:** `GET /v1/me/ then POST /v1/tasks/tasks/{t}/participants/ {user_uuid: me, is_muted: false}`
- **Person-only:** **yes**
- **Example:** `dailybot task unmute ENG-142`

### `dailybot task unwatch TASK`

Stop following a task.

- **API:** `DELETE /v1/tasks/tasks/{t}/subscription/`
- **Person-only:** **yes**
- **Example:** `dailybot task unwatch ENG-142`

### `dailybot task update TASK`

Change fields on a task.

- **API:** `PATCH /v1/tasks/tasks/{t}/ +Idempotency-Key`
- **Person-only:** no
- **Flags:**
  - `--title`, `-t` `<text>` — New title.
  - `--description`, `-d` `<text>` — New description.
  - `--state` `<text>` — New workflow state.
  - `--due` `<text>` — New due date (YYYY-MM-DD).
  - `--priority` `<int 1–5>` — Priority 1-5: 1 urgent, 2 high, 3 medium, 4 low, 5 none.
  - `--owner` `<text>` — Owner: a user uuid, or `me`.
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot task update ENG-142 --priority 1 --due 2026-10-01`

### `dailybot task watch TASK`

Follow a task's notifications without being on it.

- **API:** `POST /v1/tasks/tasks/{t}/subscription/`
- **Person-only:** **yes**
- **Example:** `dailybot task watch ENG-142`

## Boards — `dailybot board`

Boards, their states (columns), members, labels, views and pins.

### `dailybot board archive BOARD`

Archive a board.

- **API:** `POST /v1/tasks/boards/{b}/archive/?dry_run=true then …/archive/ +key`
- **Person-only:** no
- **Flags:**
  - `--dry-run` — Show the consequence and exit without acting.
  - `--yes`, `-y` — Skip the prompt (still previews).
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot board archive 00000000-0000-0000-0000-000000000001 --dry-run`

### `dailybot board create`

Create a board.

- **API:** `POST /v1/tasks/boards/ +key (tasks:admin)`
- **Person-only:** **yes**
- **Flags:**
  - `--name`, `-n` `<text>` **required** — Board name.
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot board create --name "Design"`

### `dailybot board get BOARD`

Show one board's metadata.

- **API:** `GET /v1/tasks/boards/{b}/`
- **Person-only:** no
- **Example:** `dailybot board get 00000000-0000-0000-0000-000000000001`

### `dailybot board label create BOARD`

Create an organization label from this board.

- **API:** `POST /v1/tasks/boards/{b}/labels/`
- **Person-only:** **yes**
- **Flags:**
  - `--name`, `-n` `<text>` **required** — Label name.
  - `--color` `<text>` — Label color, e.g. #ef4444.
  - `--description`, `-d` `<text>` — What the label means.
- **Example:** `dailybot board label create 00000000-0000-0000-0000-000000000001 -n bug --color "#ef4444"`

### `dailybot board labels BOARD`

List the labels available on a board.

- **API:** `GET /v1/tasks/boards/{b}/labels/`
- **Person-only:** **yes**
- **Example:** `dailybot board labels 00000000-0000-0000-0000-000000000001`

### `dailybot board list`

List boards.

- **API:** `GET /v1/tasks/boards/`
- **Person-only:** no
- **Flags:**
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--all`, `-a` — Fetch every page (iterate until the end).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
  - `--search`, `--grep`, `-s` `<text>` — Filter by text (max 256 chars; truncated).
  - `--since`, `-S` `<text>` — Start date (YYYY-MM-DD).
  - `--until`, `-U` `<text>` — End date (YYYY-MM-DD).
  - `--date`, `-D` `<text>` — Single day (YYYY-MM-DD): sets start and end.
  - `--last-week` — Previous Monday-Sunday week.
  - `--today` — Today only.
- **Example:** `dailybot board list --json`

### `dailybot board member add BOARD USER`

Give someone sight of a board.

- **API:** `POST /v1/tasks/boards/{b}/members/ +key`
- **Person-only:** **yes**
- **Flags:**
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot board member add 00000000-0000-0000-0000-000000000001 00000000-0000-0000-0000-000000000004`

### `dailybot board member remove BOARD USER`

Take someone's sight of a board away.

- **API:** `DELETE /v1/tasks/boards/{b}/members/{u}/`
- **Person-only:** **yes**
- **Flags:**
  - `--dry-run` — Say what would happen and send nothing.
  - `--yes`, `-y` — Skip the confirmation.
- **Example:** `dailybot board member remove 00000000-0000-0000-0000-000000000001 00000000-0000-0000-0000-000000000004 --yes`

### `dailybot board members BOARD`

List who can see a board, and their role on it.

- **API:** `GET /v1/tasks/boards/{b}/members/`
- **Person-only:** no
- **Example:** `dailybot board members 00000000-0000-0000-0000-000000000001`

### `dailybot board mentionables BOARD`

Who you can @mention on this board, with the token to write.

- **API:** `GET /v1/tasks/boards/{b}/mentionables/`
- **Person-only:** **yes**
- **Flags:**
  - `--query`, `-q` `<text>` — Only people whose name contains this text (case-insensitive).
- **Example:** `dailybot board mentionables 00000000-0000-0000-0000-000000000001 -q jane`

### `dailybot board restore BOARD`

Restore an archived board.

- **API:** `POST /v1/tasks/boards/{b}/restore/ +key`
- **Person-only:** no
- **Flags:**
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot board restore 00000000-0000-0000-0000-000000000001`

### `dailybot board snapshot BOARD`

Show the whole board in one request — the cold-context read.

- **API:** `GET /v1/tasks/boards/{b}/board/`
- **Person-only:** no
- **Example:** `dailybot board snapshot 00000000-0000-0000-0000-000000000001 --json`

### `dailybot board star BOARD`

Pin a board to your favorites.

- **API:** `POST /v1/tasks/me/favorites/ {target_type: board, target_uuid} +Idempotency-Key`
- **Person-only:** **yes**
- **Example:** `dailybot board star 00000000-0000-0000-0000-000000000001`

### `dailybot board state archive BOARD STATE`

Retire a column.

- **API:** `POST /v1/tasks/boards/{b}/states/{s}/archive/?dry_run=true then …/archive/ {migrate_to}`
- **Person-only:** no
- **Flags:**
  - `--migrate-to` `<text>` — Move this column's live tasks to another live column first (state uuid).
  - `--dry-run` — Show the consequence and exit without acting.
  - `--yes`, `-y` — Skip the prompt (still previews).
- **Example:** `dailybot board state archive 00000000-0000-0000-0000-000000000001 00000000-0000-0000-0000-000000000005 --migrate-to 00000000-0000-0000-0000-000000000013 --yes`

### `dailybot board state create BOARD`

Add a column to a board.

- **API:** `POST /v1/tasks/boards/{b}/states/ +key`
- **Person-only:** no
- **Flags:**
  - `--name`, `-n` `<text>` **required** — Column name (max 48 characters).
  - `--category` `<backlog|todo|in_progress|done|canceled>` **required** — Fixed meaning of the column; it survives renames and never changes.
  - `--position` `<int ≥ 0>` — Insert at this 1-based place among live columns; later columns shift right.
  - `--color` `<text>` — Column color, e.g. #3b82f6.
  - `--default` — New tasks land in this column.
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot board state create 00000000-0000-0000-0000-000000000001 -n "In review" --category in_progress --position 3`

### `dailybot board state reorder BOARD STATE...…`

Set the left-to-right order of every live column in one call.

- **API:** `POST /v1/tasks/boards/{b}/states/reorder/ {order[]} (every live column once)`
- **Person-only:** no
- **Example:** `dailybot board state reorder 00000000-0000-0000-0000-000000000001 00000000-0000-0000-0000-000000000005 00000000-0000-0000-0000-000000000013 00000000-0000-0000-0000-0000000000014`

### `dailybot board state restore BOARD STATE`

Bring a retired column back, after the live ones.

- **API:** `POST /v1/tasks/boards/{b}/states/{s}/restore/`
- **Person-only:** no
- **Example:** `dailybot board state restore 00000000-0000-0000-0000-000000000001 00000000-0000-0000-0000-000000000005`

### `dailybot board state update BOARD STATE`

Rename, recolor or move one column.

- **API:** `PATCH /v1/tasks/boards/{b}/states/{s}/`
- **Person-only:** no
- **Flags:**
  - `--name`, `-n` `<text>` — New column name.
  - `--color` `<text>` — New column color.
  - `--position` `<int ≥ 0>` — Move the column to this place.
- **Example:** `dailybot board state update 00000000-0000-0000-0000-000000000001 00000000-0000-0000-0000-000000000005 --name Shipped`

### `dailybot board states BOARD`

List a board's states (its columns), left to right.

- **API:** `GET /v1/tasks/boards/{b}/states/ (?include_archived=true)`
- **Person-only:** no
- **Flags:**
  - `--include-archived` — Also list retired columns.
- **Example:** `dailybot board states 00000000-0000-0000-0000-000000000001 --include-archived`

### `dailybot board tasks BOARD`

List the tasks on one board.

- **API:** `GET /v1/tasks/boards/{b}/tasks/`
- **Person-only:** no
- **Flags:**
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
- **Example:** `dailybot board tasks 00000000-0000-0000-0000-000000000001 --page 2`

### `dailybot board unstar BOARD`

Unpin a board from your favorites.

- **API:** `GET /v1/tasks/me/favorites/ then DELETE /v1/tasks/me/favorites/{f}/`
- **Person-only:** **yes**
- **Example:** `dailybot board unstar 00000000-0000-0000-0000-000000000001`

### `dailybot board update BOARD`

Change a board's name, key, visibility or settings.

- **API:** `PATCH /v1/tasks/boards/{b}/ +key`
- **Person-only:** no
- **Flags:**
  - `--name`, `-n` `<text>` — New board name.
  - `--key` `<text>` — New key prefix. The old key is retired and stays reserved, so old links still resolve.
  - `--visibility` `<org|members>` — `members` makes it private; you are seated as its first member.
  - `--estimate-scale` `<none|fibonacci|linear>`
  - `--archive-after-days` `<int ≥ 1>` — Auto-archive done tasks after this many days.
  - `--project` `<text>` — Move the board under this project (uuid).
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot board update 00000000-0000-0000-0000-000000000001 --key DSN --visibility members`

### `dailybot board view save BOARD`

Replace your saved views on a board with the array in a file.

- **API:** `PUT /v1/tasks/boards/{b}/views/ +If-Match (required)`
- **Person-only:** **yes**
- **Flags:**
  - `--file`, `-f` `<file (`-` = stdin)>` **required** — JSON array of views (`-` reads stdin). It REPLACES your whole list.
  - `--if-match` `<text>` — The ETag `board views` showed. Protects against overwriting a concurrent save.
  - `--fetch-etag` — Read the current ETag first instead of passing --if-match (narrower protection).
- **Example:** `dailybot board view save 00000000-0000-0000-0000-000000000001 -f views.json --if-match "$ETAG"`

### `dailybot board views BOARD`

List your saved views on a board, with the ETag a save needs.

- **API:** `GET /v1/tasks/boards/{b}/views/ (ETag)`
- **Person-only:** no
- **Flags:**
  - `--etag` — Print only the ETag `board view save --if-match` needs, and nothing else.
- **Example:** `ETAG=$(dailybot board views 00000000-0000-0000-0000-000000000001 --etag)`

## Projects — `dailybot project`

Projects, members, views, project updates and milestones.

### `dailybot project archive PROJECT`

Archive a project.

- **API:** `POST /v1/tasks/projects/{p}/archive/?dry_run=true then …/archive/ +key`
- **Person-only:** no
- **Flags:**
  - `--dry-run` — Show the consequence and exit without acting.
  - `--yes`, `-y` — Skip the prompt (still previews).
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot project archive 00000000-0000-0000-0000-000000000002 --dry-run`

### `dailybot project create`

Create a project.

- **API:** `POST /v1/tasks/projects/ +key (tasks:admin)`
- **Person-only:** **yes**
- **Flags:**
  - `--name`, `-n` `<text>` **required** — Project name.
  - `--description`, `-d` `<text>` — Project description.
  - `--visibility` `<org|members>` — `members` makes it private: you plus whoever you invite. It only narrows.
  - `--lead` `<text>` — Lead (user uuid).
  - `--health` `<not_set|on_track|at_risk|off_track>` — Declared health — separate from the derived progress.
  - `--start-date` `<YYYY-MM-DD>` — YYYY-MM-DD.
  - `--target-date` `<YYYY-MM-DD>` — YYYY-MM-DD.
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot project create -n "Apollo" --target-date 2026-12-15`

### `dailybot project get PROJECT`

Show one project.

- **API:** `GET /v1/tasks/projects/{p}/`
- **Person-only:** no
- **Flags:**
  - `--include` `<progress>` repeatable — Ask for a roll-up.
- **Example:** `dailybot project get 00000000-0000-0000-0000-000000000002 --include progress`

### `dailybot project list`

List projects.

- **API:** `GET /v1/tasks/projects/`
- **Person-only:** no
- **Flags:**
  - `--include` `<progress>` repeatable — Ask for a roll-up (nothing is included by default).
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--all`, `-a` — Fetch every page (iterate until the end).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
  - `--search`, `--grep`, `-s` `<text>` — Filter by text (max 256 chars; truncated).
  - `--since`, `-S` `<text>` — Start date (YYYY-MM-DD).
  - `--until`, `-U` `<text>` — End date (YYYY-MM-DD).
  - `--date`, `-D` `<text>` — Single day (YYYY-MM-DD): sets start and end.
  - `--last-week` — Previous Monday-Sunday week.
  - `--today` — Today only.
- **Example:** `dailybot project list --include progress --json`

### `dailybot project member add PROJECT`

Invite a person or a whole team into a project.

- **API:** `POST /v1/tasks/projects/{p}/members/ {user_uuid | team_uuid}`
- **Person-only:** **yes**
- **Flags:**
  - `--user` `<text>` — A person (user uuid).
  - `--team` `<text>` — A whole team (uuid); membership follows the team live.
- **Example:** `dailybot project member add 00000000-0000-0000-0000-000000000002 --team 00000000-0000-0000-0000-000000000011`

### `dailybot project member remove PROJECT USER`

Remove someone from a project.

- **API:** `DELETE /v1/tasks/projects/{p}/members/{u}/`
- **Person-only:** **yes**
- **Flags:**
  - `--dry-run` — Say what would happen and send nothing.
  - `--yes`, `-y` — Skip the confirmation.
- **Example:** `dailybot project member remove 00000000-0000-0000-0000-000000000002 00000000-0000-0000-0000-000000000004 --yes`

### `dailybot project members PROJECT`

List who can see a project — people and whole teams.

- **API:** `GET /v1/tasks/projects/{p}/members/`
- **Person-only:** **yes**
- **Example:** `dailybot project members 00000000-0000-0000-0000-000000000002`

### `dailybot project milestone-complete PROJECT MILESTONE`

Mark a milestone complete.

- **API:** `POST /v1/tasks/projects/{p}/milestones/{m}/complete/?dry_run=true then …/complete/ +key`
- **Person-only:** no
- **Flags:**
  - `--dry-run` — Show the consequence and exit without acting.
  - `--yes`, `-y` — Skip the prompt (still previews).
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot project milestone-complete 00000000-0000-0000-0000-000000000002 00000000-0000-0000-0000-000000000006 --dry-run`

### `dailybot project milestone-create PROJECT`

Commit a project to a dated milestone.

- **API:** `POST /v1/tasks/projects/{p}/milestones/`
- **Person-only:** no
- **Flags:**
  - `--name`, `-n` `<text>` **required** — Milestone name.
  - `--date` `<YYYY-MM-DD>` **required** — Due date (YYYY-MM-DD).
  - `--description`, `-d` `<text>` — What the milestone commits to.
- **Example:** `dailybot project milestone-create 00000000-0000-0000-0000-000000000002 -n Beta --date 2026-11-01`

### `dailybot project milestone-delete PROJECT MILESTONE`

Retire a milestone.

- **API:** `DELETE /v1/tasks/projects/{p}/milestones/{m}/ (retires)`
- **Person-only:** no
- **Flags:**
  - `--dry-run` — Say what would happen and send nothing.
  - `--yes`, `-y` — Skip the confirmation.
- **Example:** `dailybot project milestone-delete 00000000-0000-0000-0000-000000000002 00000000-0000-0000-0000-000000000006 --yes`

### `dailybot project milestone-reopen PROJECT MILESTONE`

Reopen a completed milestone.

- **API:** `POST /v1/tasks/projects/{p}/milestones/{m}/reopen/ +key`
- **Person-only:** no
- **Flags:**
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot project milestone-reopen 00000000-0000-0000-0000-000000000002 00000000-0000-0000-0000-000000000006`

### `dailybot project milestone-update PROJECT MILESTONE`

Rename a milestone or move its date.

- **API:** `PATCH /v1/tasks/projects/{p}/milestones/{m}/`
- **Person-only:** no
- **Flags:**
  - `--name`, `-n` `<text>` — New name.
  - `--date` `<YYYY-MM-DD>` — New date (YYYY-MM-DD).
  - `--description`, `-d` `<text>` — New description.
- **Example:** `dailybot project milestone-update 00000000-0000-0000-0000-000000000002 00000000-0000-0000-0000-000000000006 --date 2026-11-15`

### `dailybot project milestones [PROJECT]`

List milestones, for one project or across the organization.

- **API:** `GET /v1/tasks/milestones/ | GET /v1/tasks/projects/{p}/milestones/`
- **Person-only:** no
- **Flags:**
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--all`, `-a` — Fetch every page (iterate until the end).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
  - `--search`, `--grep`, `-s` `<text>` — Filter by text (max 256 chars; truncated).
  - `--since`, `-S` `<text>` — Start date (YYYY-MM-DD).
  - `--until`, `-U` `<text>` — End date (YYYY-MM-DD).
  - `--date`, `-D` `<text>` — Single day (YYYY-MM-DD): sets start and end.
  - `--last-week` — Previous Monday-Sunday week.
  - `--today` — Today only.
- **Example:** `dailybot project milestones 00000000-0000-0000-0000-000000000002`

### `dailybot project restore PROJECT`

Bring an archived project back.

- **API:** `POST /v1/tasks/projects/{p}/restore/ +key`
- **Person-only:** no
- **Flags:**
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot project restore 00000000-0000-0000-0000-000000000002`

### `dailybot project update PROJECT`

Change a project's name, lead, health, dates or visibility.

- **API:** `PATCH /v1/tasks/projects/{p}/ +key`
- **Person-only:** no
- **Flags:**
  - `--name`, `-n` `<text>` — New project name.
  - `--description`, `-d` `<text>` — New project description.
  - `--visibility` `<org|members>` — `members` makes it private: you plus whoever you invite. It only narrows.
  - `--lead` `<text>` — Lead (user uuid).
  - `--health` `<not_set|on_track|at_risk|off_track>` — Declared health — separate from the derived progress.
  - `--start-date` `<YYYY-MM-DD>` — YYYY-MM-DD.
  - `--target-date` `<YYYY-MM-DD>` — YYYY-MM-DD.
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot project update 00000000-0000-0000-0000-000000000002 --health at_risk`

### `dailybot project update-post PROJECT BODY`

Post a project update — how the team sees what was done.

- **API:** `POST /v1/tasks/projects/{p}/updates/ +key {body, health}`
- **Person-only:** no
- **Flags:**
  - `--health` `<not_set|on_track|at_risk|off_track>` — What you claim about the project today. Does not change the project's own health.
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe. Generated automatically when omitted.
- **Example:** `dailybot project update-post 00000000-0000-0000-0000-000000000002 "Shipped the retry fix" --health on_track`

### `dailybot project updates [PROJECT]`

Read project updates: the batched digest, or one project's updates.

- **API:** `GET /v1/tasks/projects/updates/ | GET /v1/tasks/projects/{p}/updates/`
- **Person-only:** no
- **Flags:**
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--all`, `-a` — Fetch every page (iterate until the end).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
  - `--search`, `--grep`, `-s` `<text>` — Filter by text (max 256 chars; truncated).
  - `--since`, `-S` `<text>` — Start date (YYYY-MM-DD).
  - `--until`, `-U` `<text>` — End date (YYYY-MM-DD).
  - `--date`, `-D` `<text>` — Single day (YYYY-MM-DD): sets start and end.
  - `--last-week` — Previous Monday-Sunday week.
  - `--today` — Today only.
- **Example:** `dailybot project updates 00000000-0000-0000-0000-000000000002 --json`

### `dailybot project view save PROJECT`

Replace your saved views on a project with the array in a file.

- **API:** `PUT /v1/tasks/projects/{p}/views/ +If-Match (required)`
- **Person-only:** **yes**
- **Flags:**
  - `--file`, `-f` `<file (`-` = stdin)>` **required** — JSON array of views (`-` reads stdin). It REPLACES your whole list.
  - `--if-match` `<text>` — The ETag `project views` showed.
  - `--fetch-etag` — Read the current ETag first (narrower).
- **Example:** `dailybot project view save 00000000-0000-0000-0000-000000000002 -f views.json --fetch-etag`

### `dailybot project views PROJECT`

List your saved views on a project, with the ETag a save needs.

- **API:** `GET /v1/tasks/projects/{p}/views/ (ETag)`
- **Person-only:** no
- **Flags:**
  - `--etag` — Print only the ETag `project view save --if-match` needs.
- **Example:** `dailybot project views 00000000-0000-0000-0000-000000000002 --etag`

## Goals — `dailybot goal`

Goals, their status and the projects linked to them.

### `dailybot goal archive GOAL`

Archive a goal.

- **API:** `POST /v1/tasks/goals/{g}/archive/?dry_run=true then …/archive/ +key`
- **Person-only:** no
- **Flags:**
  - `--dry-run` — Show the consequence and exit without acting.
  - `--yes`, `-y` — Skip the prompt (still previews).
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot goal archive 00000000-0000-0000-0000-000000000003 --dry-run`

### `dailybot goal create`

Create a goal.

- **API:** `POST /v1/tasks/goals/ +key (tasks:admin)`
- **Person-only:** **yes**
- **Flags:**
  - `--name`, `-n` `<text>` **required** — Goal name.
  - `--period-start` `<YYYY-MM-DD>` **required** — First day of the goal's period (YYYY-MM-DD).
  - `--period-end` `<YYYY-MM-DD>` **required** — Last day of the goal's period (YYYY-MM-DD).
  - `--description`, `-d` `<text>` — Goal description.
  - `--owner` `<text>` — Accountable person (user uuid).
  - `--team` `<text>` — Team the goal belongs to (uuid).
  - `--idempotency-key` `<text>` — Reuse a key to make a retry safe.
- **Example:** `dailybot goal create -n "Q4 reliability" --period-start 2026-10-01 --period-end 2026-12-31`

### `dailybot goal get GOAL`

Show one goal, with its progress and linked projects.

- **API:** `GET /v1/tasks/goals/{g}/`
- **Person-only:** no
- **Example:** `dailybot goal get 00000000-0000-0000-0000-000000000003 --json`

### `dailybot goal link GOAL PROJECT`

Make a project count toward a goal.

- **API:** `POST /v1/tasks/goals/{g}/projects/ {project}`
- **Person-only:** no
- **Example:** `dailybot goal link 00000000-0000-0000-0000-000000000003 00000000-0000-0000-0000-000000000002`

### `dailybot goal list`

List goals.

- **API:** `GET /v1/tasks/goals/`
- **Person-only:** no
- **Flags:**
  - `--include` `<progress|projects>` repeatable — Ask for a roll-up (nothing is included by default).
  - `--page`, `-P` `<int>` — Page number to fetch.
  - `--page-size`, `-z` `<int>` — Items per page (max 100).
  - `--all`, `-a` — Fetch every page (iterate until the end).
  - `--limit`, `-l` `<int>` — Stop after collecting N items.
  - `--search`, `--grep`, `-s` `<text>` — Filter by text (max 256 chars; truncated).
  - `--since`, `-S` `<text>` — Start date (YYYY-MM-DD).
  - `--until`, `-U` `<text>` — End date (YYYY-MM-DD).
  - `--date`, `-D` `<text>` — Single day (YYYY-MM-DD): sets start and end.
  - `--last-week` — Previous Monday-Sunday week.
  - `--today` — Today only.
- **Example:** `dailybot goal list --include progress --include projects`

### `dailybot goal restore GOAL`

Bring an archived goal back.

- **API:** `POST /v1/tasks/goals/{g}/restore/`
- **Person-only:** no
- **Example:** `dailybot goal restore 00000000-0000-0000-0000-000000000003`

### `dailybot goal unlink GOAL PROJECT`

Stop a project counting toward a goal.

- **API:** `DELETE /v1/tasks/goals/{g}/projects/{p}/`
- **Person-only:** no
- **Flags:**
  - `--dry-run` — Say what would happen and send nothing.
  - `--yes`, `-y` — Skip the confirmation.
- **Example:** `dailybot goal unlink 00000000-0000-0000-0000-000000000003 00000000-0000-0000-0000-000000000002 --yes`

### `dailybot goal update GOAL`

Change a goal, or declare its status.

- **API:** `PATCH /v1/tasks/goals/{g}/`
- **Person-only:** no
- **Flags:**
  - `--name`, `-n` `<text>` — New goal name.
  - `--description`, `-d` `<text>` — New description.
  - `--period-start` `<YYYY-MM-DD>` — YYYY-MM-DD.
  - `--period-end` `<YYYY-MM-DD>` — YYYY-MM-DD.
  - `--owner` `<text>` — Accountable person (user uuid).
  - `--team` `<text>` — Team (uuid).
  - `--status` `<not_started|on_track|at_risk|off_track|achieved|missed>` — Declare where the goal stands. Not derived from progress.
- **Example:** `dailybot goal update 00000000-0000-0000-0000-000000000003 --status at_risk`

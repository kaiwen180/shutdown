# /shutdown — Instructions

Save this session's state for tomorrow's pickup.

## Steps

1. Get today's date from the hook output (already in system-reminder as YYYY-MM-DD). No need to call `date`.
2. Read `SHUTDOWN_HOME/state/last-shutdown`
3. List existing pickup files in `SHUTDOWN_HOME/pickups/{today}/`
   - Derive a kebab-case short name for THIS session from its subject (e.g., `psm-identity-pivot`, `psm-shutdown-skill`, `reefnbid-cors-fix`)
   - If a file with the same short name already exists → already shut down. Skip to step 9.
   - Otherwise → write to `{short-name}.md`.
4. Run `git status --short`, `git log --oneline -5`, `git branch --show-current`, `git stash list` — all in parallel
5. Summarize the key context from THIS conversation — like `/compact`: what was discussed, decisions made, approaches tried, files touched, blockers discovered. This is the "conversation memory" for tomorrow.
6. Write pickup file IMMEDIATELY to `SHUTDOWN_HOME/pickups/{today}/{short-name}.md` — do NOT wait for user input:

```markdown
# Pickup — {short-name} — {date}

## Session Identity
- **Project**: {from package.json name or CLAUDE.md}
- **pwd**: {absolute path}
- **Branch**: {branch}
- **Subject**: {infer from recent conversation context}

## Resume
To resume with full conversation history:
```
cd {pwd}
claude --resume {SESSION_ID}
```
(Session ID will be shown when you type exit)

Or start fresh with context:
```
cd {pwd}
claude
# Then: /pickup {short-name}
```

## Status
- Uncommitted: {file list}
- Last commit: {hash} "{message}"
- Stash: {list or none}

## Tasks
{checklist of in-progress items from THIS session}

## Key Context (conversation summary)
{compact-style summary: decisions made, approaches tried, files read/modified, blockers, key findings — enough for a fresh session to pick up without losing context}

## Referenced Files
{list of plan files, docs, source files that were central to this session's work — absolute paths}

## Tomorrow
{what was in-flight, what's next, what to do first}
```

7. Read existing index.md (if any), append this session's entry, write back to `SHUTDOWN_HOME/pickups/{today}/index.md`
8. Read existing `SHUTDOWN_HOME/pickups/{today}/life.md` (if any). Ask: "Any life tasks? (errands, deadlines, reminders — or 'none')"
   - If user provides life tasks OR life.md already exists with incomplete items → write/update `SHUTDOWN_HOME/pickups/{today}/life.md`:
   ```markdown
   # Life Tasks — {date}

   ## Active
   - [ ] {task} — {deadline if known}

   ## Completed today
   - [x] {any completed items}
   ```
   - Carry forward incomplete items from the previous day's life.md (find latest date dir before today)
9. Use the Write tool to write the date+time from the hook output (e.g. `2026-03-30T22:45`) to `SHUTDOWN_HOME/state/last-shutdown`. No extra `date` call needed.
10. Print:

```
Schedule shutdown, complete. ({short-name})

Pickup file saved. Any last notes for tomorrow?
If nothing, type exit to close this session.

💡 When you exit, note the session ID for resume:
   claude --resume {id}

Overnight ideas → paper inbox.
! = urgent  B = bug  * = idea
Or just write anything.

Good night.
```

If the user adds notes → append to the pickup file's `## Tomorrow` section, then print "Updated. Type exit to close."

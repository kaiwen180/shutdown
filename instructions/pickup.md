# /pickup — Instructions

## If repo-slug provided (subsequent session)

1. Read `SHUTDOWN_HOME/pickups/{latest-date}/{repo-slug}.md`
2. Read `SHUTDOWN_HOME/inbox/{today}.md` if exists — show items routed here
3. Show context summary, ask "Ready to continue?"

## If no repo-slug (first session = morning coordinator)

1. Ask: "Any overnight notes? Type them in, any format. Or 'none'."
   - Save to `SHUTDOWN_HOME/inbox/{today}.md`
   - Infer type (urgent/bug/idea/life) and target repo from context
2. Find latest directory in `SHUTDOWN_HOME/pickups/`, read `index.md`
3. Read each pickup file referenced in index
4. Read `life.md` if exists

### Briefing

Weekday before 10am → brief (urgents + life + session list, no interactive review).
Otherwise → full interactive.

Show:
- Urgent items first
- Life tasks with deadlines (flag overdue items)
- Each session: repo, branch, subject, dirty files, tasks remaining

### Life tasks

Read `life.md` from the latest pickup directory. Show active items with deadlines.
Items past their deadline → mark as **overdue**.
Incomplete items carry forward automatically — they'll appear in tonight's shutdown.

### Worktree topology

After loading all pickup files, check for any that have a `## Worktree` section. If found:
- Run `git worktree list` from the current repo to detect what actually exists on THIS machine
- Cross-reference with pickup files:
  - Pickup mentions a worktree path that exists → show it (with disposition from pickup)
  - Pickup mentions a worktree path that doesn't exist → mark as "(not on this machine)" — skip prune suggestions
  - `git worktree list` shows a worktree with no matching pickup file → flag as "untracked worktree, investigate"
- Group sessions by parent repo (show tree structure)
- Flag worktrees marked `prune-now` that exist on this machine → suggest `git worktree remove {path}` + `git branch -d {branch}`
- Worktree state is machine-local; pickup files may reference paths from a different machine — never assume a path exists without checking

### Selective resurrection

For each session, present summary and ask: **[R]esume / [D]iscard / [L]ater**

For resumed sessions, print:
```
cd {pwd}
claude
# Then: /pickup {repo-slug}
```

### Stay alive

After resurrection, this session stays as life task hub + general assistant.
Write today's date to `SHUTDOWN_HOME/state/last-pickup`.

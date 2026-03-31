---
name: shutdown
description: "Nightly shutdown ritual — Newport-inspired structured review, multi-session baton-passing, life tasks, negotiated enforcement"
user_invocable: true
---

# /shutdown — Nightly Shutdown Ritual

You are executing the shutdown skill. This skill manages the nightly shutdown ritual inspired by Cal Newport's work shutdown ritual.

## Step 0 — Read the Clock and State

1. Run `date +%H%M` to get the current time (4-digit HHMM format)
2. Run `date +%u` to get day of week (1=Monday, 7=Sunday)
3. Read `~/dev/shutdown/config.json` for schedule settings
4. Read `~/dev/shutdown/state/last-shutdown` for today's shutdown status
5. Read `~/dev/shutdown/state/last-pickup` for today's pickup status

Compute:
- `reminderTime` = `shutdownTime` minus `reminderLeadMinutes`
- Determine which time window we're in: normal, reminder, post-shutdown, or wind-down

## Step 1 — Determine Mode

### If current time < reminderTime (too early)
Print: "It's not shutdown time yet. Shutdown reminder starts at {reminderTime}, ceremony at {shutdownTime}."
STOP — do not proceed unless user explicitly wants an early shutdown.

### If reminderTime <= current time < shutdownTime (reminder window)
Print a reminder banner:
```
⏰ {minutes} minutes to shutdown ({shutdownTime}).
Starting the shutdown ritual now. Let's walk through it together.
```
Then proceed to Step 2.

### If current time >= shutdownTime AND last-shutdown < today (ceremony time)
Print:
```
It's past {shutdownTime}. Let's do the shutdown ritual.
```
Then proceed to Step 2.

### If current time >= shutdownTime AND last-shutdown == today (already done)
Print: "Shutdown already completed today. Everything is captured."
STOP.

## Step 2 — Newport's Five Steps

### Step 2a — Update Master Task List (automated)

For the CURRENT repo (where this session is running):
1. Run `git status` to see uncommitted changes
2. Run `git stash list` to see any stashed work
3. Run `git log --oneline -5` to see recent commits
4. Run `git branch --show-current` to get current branch
5. Read plan files in `docs/abz-b/` (if they exist) to find active plans and their progress

For OTHER repos, read `~/dev/shutdown/pickups/` for the most recent index.md to see if other sessions have already shut down today.

Present a summary:
```
TASK TALLY — {repo name}
Branch: {branch}
Uncommitted: {N} files ({list})
Stashed: {N} entries
Recent commits: {last 3}
Active plans: {list with % complete}
```

### Step 2b — Review All Task Lists (interactive)

Show pending items grouped by:
1. **This repo** — uncommitted work, in-progress plan items, TODOs
2. **Other repos** — from today's index.md (if other sessions already shut down)
3. **Life tasks** — carry forward from yesterday's life.md if it exists

Ask the user:
- "Any priorities or notes for tomorrow?"
- "Any life tasks to capture? (errands, deadlines, appointments)"

### Step 2c — Check Calendar (automated where possible)

Surface upcoming deadlines from:
- Plan files (look for dates, deadlines, "by" dates)
- Life tasks with dates
- Note: "Future enhancement: calendar API integration"

### Step 2d — Review Weekly Plan (interactive)

If plan files exist in `docs/abz-b/`:
- Show each plan's status/progress
- Ask: "Anything changed, shifted, or blocked?"

### Step 2e — Draft Pickup File (automated)

Generate the pickup file with full session identity:

```markdown
# Pickup — {repo-slug} — {YYYY-MM-DD}

## Session Identity
- **Project**: {project description from package.json or CLAUDE.md}
- **pwd**: {absolute path to repo}
- **Branch**: {current branch}
- **Subject**: {what the user was working on — infer from recent commits, plan files, conversation}
- **Plan**: {active plan file path and % complete, if any}

## Status at shutdown
- **Uncommitted changes**: {N} files ({list})
- **Stash**: {stash list or "none"}

## Active tasks
{numbered checklist of in-progress items}

## Context for tomorrow
{what was in-flight, what's blocked, what's next}

## User notes
{anything the user said during the ritual}

## Git state
- Last commit: {hash} "{message}"
- Dirty files: {list}
```

Save to `~/dev/shutdown/pickups/{YYYY-MM-DD}/{repo-slug}.md`

### Step 2f — Update Daily Index

Read `~/dev/shutdown/pickups/{YYYY-MM-DD}/index.md` (create if doesn't exist).
Add this session's entry. Format:

```markdown
# Shutdown Index — {YYYY-MM-DD}

## Sessions

| # | Repo | pwd | Branch | Subject | Status | Dirty | Priority |
|---|------|-----|--------|---------|--------|-------|----------|
| {n} | [{repo}]({repo-slug}.md) | {pwd} | {branch} | {subject} | ✅ done | {N} | {priority note} |
```

If other sessions are still pending, note them as ⏳ pending.

### Step 2g — Life Tasks

If this is the LAST session shutting down (or the only one):
- Carry forward incomplete life tasks from yesterday
- Add any new life tasks from tonight's ritual
- Write `~/dev/shutdown/pickups/{YYYY-MM-DD}/life.md`

If other sessions are still pending, note that life.md will be finalized by the last session.

## Step 3 — Termination

Write today's date to `~/dev/shutdown/state/last-shutdown`.

If other sessions still pending:
```
Schedule shutdown, complete. ({repo name})
{N} sessions remaining: {list}.
Switch to the next session to continue shutdown.
```

If this is the last (or only) session:
```
Schedule shutdown, complete. All sessions done.
Everything is captured. Pickup available tomorrow at {pickupTime}.

Overnight ideas → paper inbox (shorthand card by the bed).
  ! = urgent   B = bug   * = idea
  Or just write anything. Claude sorts it in the morning.

Good night.
```

## Negotiation Behavior (for hook-triggered time awareness)

This section describes how to behave when you notice it's past shutdown time during NORMAL conversation (not when /shutdown is explicitly invoked).

When the `UserPromptSubmit` hook provides time output (HHMM format) and it's past shutdownTime:

### If last-shutdown == today (shutdown already done)
The user is working post-shutdown. Negotiate based on what they're doing:

- **Urgent/production fix**: Allow freely. Don't nag.
- **Committing, pushing, wrapping up**: Allow — this is cleanup behavior.
- **Quick review or small fix**: Gentle nudge. "Quick one? Let's wrap after."
- **Starting new work**: Push back. "This sounds like tomorrow-work. Capture it for the inbox?"
- **Continuing past 30min**: "We're {N} min past shutdown. Let's save any new state and close."
- **Repeated "one more thing"**: "That's the {N}th 'one more thing.' Let's wrap up."

### If last-shutdown < today (shutdown NOT done yet)
Suggest running /shutdown:
- First mention: "It's {time}, past shutdown. Run /shutdown when you're at a stopping point."
- If user keeps working: "Still going at {time}. Let's do a quick shutdown ritual — it only takes a few minutes."
- After 30+ min past shutdown: "We're well past shutdown. I'm going to start the ritual now."
  Then auto-initiate Step 2.

### Escalation is contextual, not mechanical
Don't count prompts rigidly. Read the room:
- If the user is clearly wrapping up → be patient
- If the user is clearly starting fresh work → be firmer sooner
- If the user says "this is urgent" or the content is clearly an incident → back off entirely
- If the user says "I know, just let me finish" → give them one more round, then nudge again

---
name: pickup
description: "Morning pickup — ingest overnight inbox, selective session resurrection, adaptive briefing depth, life task management"
user_invocable: true
args: "[repo-slug]"
---

# /pickup — Morning Pickup & Session Resurrection

You are executing the pickup skill. This skill manages the morning startup ritual: ingesting overnight notes, reviewing previous sessions, and selectively resurrecting Claude Code sessions.

## Step 0 — Read the Clock and State

1. Run `date +%H%M` to get the current time
2. Run `date +%u` to get day of week (1=Monday through 5=Friday are weekdays; 6=Saturday, 7=Sunday are weekends)
3. Read `~/dev/shutdown/config.json` for schedule settings
4. Read `~/dev/shutdown/state/last-pickup` for today's pickup status
5. Read `~/dev/shutdown/state/last-shutdown` for last shutdown date

## Step 1 — Determine Mode

### If invoked with a repo-slug argument (e.g., `/pickup psm`)
This is a SUBSEQUENT session being resurrected. Skip to [Repo-Specific Pickup](#repo-specific-pickup).

### If last-pickup == today
Print: "Morning pickup already completed today. Run `/pickup {repo-slug}` in a specific repo session to load its context."
STOP.

### If last-pickup < today
This is the FIRST session of the day — you are the **morning coordinator**. Proceed to Step 2.

## Step 2 — Determine Briefing Depth

| Condition | Mode | Rationale |
|-----------|------|-----------|
| Weekday (Mon-Fri) AND time < 10:00 | **Brief** | User heading to office, no time for deep review |
| Weekend OR time >= 17:00 on weekday | **Full** | User has time for interactive review |
| User says "full" or "brief" | **Override** | User preference always wins |

If BRIEF mode: skip to [Brief Briefing](#brief-briefing).
If FULL mode: proceed to Step 3.

## Step 3 — Full Morning Briefing

### Step 3a — Ingest Overnight Inbox

Ask:
```
Good morning. Any overnight notes from the paper inbox?
Type them in — any format works. I'll sort them out.
(Or say "none" to skip.)
```

If the user provides notes:
1. Parse each line — infer type (urgent/bug/idea/life/question) and target repo from context
2. Save to `~/dev/shutdown/inbox/{YYYY-MM-DD}.md` in table format:

```markdown
# Overnight Inbox — {YYYY-MM-DD}

| # | Type | Target | Idea | Routed to |
|---|------|--------|------|-----------|
| 1 | {type} | {repo or life} | {idea} | {destination} pickup |
```

### Step 3b — Load Previous Pickup Files

Find the most recent pickup directory:
1. List `~/dev/shutdown/pickups/` directories (sorted by date, newest first)
2. Read `index.md` from the most recent one
3. Read each repo's pickup file referenced in the index
4. Read `life.md` if it exists
5. Merge routed inbox items into the appropriate pickup contexts

### Step 3c — Present Unified Morning Briefing

Format:
```
Good morning. Last shutdown captured {N} sessions + life tasks.
Overnight inbox: {N} items ({N} urgent).

URGENT:
⚡ {urgent items from inbox + overdue life tasks}

LIFE:
📋 {life task} — {deadline info}
📋 {life task} — {deadline info}

SESSIONS:
1. {repo} ({branch}) — {dirty files}, {subject summary}
   pwd: {path}
   Plan: {plan file} ({%} complete)
   Tasks: {N} remaining
   Tomorrow note: "{user note from shutdown}"
   + {N} inbox items

2. {repo} ({branch}) — ...
```

### Step 3d — Selective Resurrection

For EACH session from the previous shutdown, present:

```
SESSION {N} of {total}: {repo}
  Project:  {project description}
  pwd:      {absolute path}
  Branch:   {branch}
  Tasks:    {N} of {total} remaining ({task summaries})
  Subject:  {what they were working on}
  Plan:     {plan file path} ({%} complete)
  Dirty:    {N} files
  Inbox:    +{N} items routed here

  → [R]esume  [D]iscard  [L]ater
```

Wait for user decision on each:

- **Resume (R)**: Add to resurrection list. Generate startup command.
- **Discard (D)**: Mark as "discarded" in today's record. Git state is preserved in the repo.
- **Later (L)**: Carry forward to tomorrow's pickup. Will appear again next morning.

### Step 3e — Generate Resurrection Commands

For each session marked "Resume", print:

```
RESURRECTION ORDER:

1. {repo} ({reason for priority})
   cd {pwd}
   claude
   # Then run: /pickup {repo-slug}

2. {repo} ({reason for priority})
   cd {pwd}
   claude
   # Then run: /pickup {repo-slug}
```

Order by: urgent items first, then in-progress work, then review/clean tasks.

### Step 3f — Coordinator Stays Alive

After presenting resurrection commands:

```
I'll stay here as your day coordinator for life tasks and general work.
Open the sessions above when you're ready.

Current life tasks:
{list from life.md + inbox items}
```

Write today's date to `~/dev/shutdown/state/last-pickup`.

The coordinator session continues as a general-purpose assistant, handling:
- Life task management (check off, add, update)
- Non-code tasks (research, reminders, planning)
- Any work not tied to a specific repo session

---

## Brief Briefing

For weekday mornings when the user is heading to the office:

```
Good morning. Quick briefing for the road.

{If urgent items exist:}
⚡ URGENT: {urgent items — one line each}

📋 LIFE: {life tasks with upcoming deadlines — one line each}

📂 {N} sessions from last night:
{numbered list: repo (branch) — one-line subject + priority note}

Full briefing available tonight — or say "full" now for the interactive version.
Any overnight notes to capture before you go?
```

If user has overnight notes: ingest them quickly (same as Step 3a).
Write today's date to `~/dev/shutdown/state/last-pickup`.

The user can always say "full" to switch to the full interactive briefing.

---

## Repo-Specific Pickup

When invoked as `/pickup {repo-slug}` in a subsequent session:

1. Find the most recent pickup directory in `~/dev/shutdown/pickups/`
2. Read `{repo-slug}.md` from that directory
3. Read `~/dev/shutdown/inbox/{YYYY-MM-DD}.md` for any items routed to this repo

Present:

```
Picking up where you left off.

Branch:  {branch}
Subject: {what you were working on}
Plan:    {plan file} ({%} complete)

Remaining tasks:
{numbered checklist}

{If inbox items routed here:}
Overnight inbox items:
{list}

Context from shutdown:
{context notes}

Ready to continue?
```

Do NOT re-run the full morning briefing. The coordinator already did that.

---

## Life Task Carry-Forward

When loading previous life.md:
1. Incomplete tasks carry forward automatically
2. Update deadline countdowns (e.g., "15 days" → "14 days")
3. Flag overdue items prominently
4. Completed items stay in the previous day's file (historical record)

---

## State Management

After completing the morning pickup (brief or full):
- Write today's date (YYYY-MM-DD) to `~/dev/shutdown/state/last-pickup`
- Create today's pickup directory if needed: `~/dev/shutdown/pickups/{YYYY-MM-DD}/`
- Carry forward any "Later" sessions and incomplete life tasks to today's directory

# /pickup — Instructions

## If repo-slug provided (subsequent session)

1. Read `/Users/kaiwenlin/dev/shutdown/pickups/{latest-date}/{repo-slug}.md`
2. Read `/Users/kaiwenlin/dev/shutdown/inbox/{today}.md` if exists — show items routed here
3. Show context summary, ask "Ready to continue?"

## If no repo-slug (first session = morning coordinator)

1. Ask: "Any overnight notes? Type them in, any format. Or 'none'."
   - Save to `/Users/kaiwenlin/dev/shutdown/inbox/{today}.md`
   - Infer type (urgent/bug/idea/life) and target repo from context
2. Find latest directory in `/Users/kaiwenlin/dev/shutdown/pickups/`, read `index.md`
3. Read each pickup file referenced in index
4. Read `life.md` if exists

### Briefing

Weekday before 10am → brief (urgents + life + session list, no interactive review).
Otherwise → full interactive.

Show:
- Urgent items first
- Life tasks with deadlines
- Each session: repo, branch, subject, dirty files, tasks remaining

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
Write today's date to `/Users/kaiwenlin/dev/shutdown/state/last-pickup`.

# shutdown

Session continuity for Claude Code. Saves your work context at night, restores it in the morning.

## What it does

A clock hook runs on every prompt and nudges you through three phases:

| Phase | Default time | What happens |
|---|---|---|
| **on** | 05:30 -- 21:00 | Normal work. First session suggests `/pickup` |
| **wind-down** | 21:00 -- 21:30 | Reminds you to `/shutdown` |
| **off** | 21:30 -- 05:30 | Suggests rest. Only proceeds if urgent |

`/shutdown` saves session state (branch, dirty files, tasks, conversation summary) to a pickup file.
`/pickup` reads those files the next morning and helps you resume.

## Install

```bash
git clone <repo-url> ~/dev/shutdown
cd ~/dev/shutdown
bash install.sh
```

Then merge the printed JSON into `~/.claude/settings.json`.

## Uninstall

```bash
cd ~/dev/shutdown
bash uninstall.sh
```

Remove the hook and permissions from `~/.claude/settings.json`.

## Customize

Edit `config.json` to set your schedule:

**Night owl** (default):
```json
{ "onTime": "0530", "windDownTime": "2100", "offTime": "2130" }
```

**Office**:
```json
{ "onTime": "0530", "windDownTime": "1630", "offTime": "1700" }
```

Times are HHMM, 24h format. The three values define the boundaries between on/wind-down/off phases.

**Behavior** -- edit `instructions/shutdown.md` and `instructions/pickup.md`.

## How it works

- `clock.sh` runs as a `UserPromptSubmit` hook, outputs a directive based on time of day
- `state/last-pickup` tracks whether today's pickup has run (prevents re-prompting)
- `state/last-shutdown` tracks last shutdown time
- `pickups/{date}/` stores pickup files per session per day
- `skills/` contains the `/shutdown` and `/pickup` skill definitions

## Design

See [plan-shutdown-pickup.md](plan-shutdown-pickup.md) for the full design document -- Cal Newport's shutdown ritual adapted for Claude Code, negotiation model, multi-session baton-passing, overnight paper inbox, and selective morning resurrection.

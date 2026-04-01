#!/bin/bash
# Hook output — time-aware directives for Claude Code sessions
SHUTDOWN_HOME="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SHUTDOWN_HOME/config.json"

now=$(date +%H%M)
today=$(date +%Y-%m-%d)

# Read schedule from config.json (defaults: night owl schedule)
on=$(grep -o '"onTime"[^"]*"[^"]*"' "$CONFIG" | grep -o '[0-9]\{4\}')
wind=$(grep -o '"windDownTime"[^"]*"[^"]*"' "$CONFIG" | grep -o '[0-9]\{4\}')
off=$(grep -o '"offTime"[^"]*"[^"]*"' "$CONFIG" | grep -o '[0-9]\{4\}')
on=${on:-0530}
wind=${wind:-2100}
off=${off:-2130}

# Read state
last_shutdown=""
if [ -f "$SHUTDOWN_HOME/state/last-shutdown" ]; then
  last_shutdown=$(cat "$SHUTDOWN_HOME/state/last-shutdown")
fi
last_pickup=""
if [ -f "$SHUTDOWN_HOME/state/last-pickup" ]; then
  last_pickup=$(cat "$SHUTDOWN_HOME/state/last-pickup")
fi

if [ "$now" -ge "$wind" ] && [ "$now" -lt "$off" ]; then
  echo "⏰ WIND-DOWN ($now, $today): Shutdown at $off. Mention this to the user before proceeding."

elif [ "$now" -ge "$off" ] || [ "$now" -lt "$on" ]; then
  # Late ceremony: no shutdown was done today
  if [ "${last_shutdown%T*}" != "$today" ]; then
    echo "🚫 OFF ($now, $today): No shutdown done today. Offer a quick /shutdown before anything else."
  else
    # Escalation: count post-off prompts
    counter="$SHUTDOWN_HOME/state/off-prompts"
    count=0
    if [ -f "$counter" ]; then
      count=$(cat "$counter")
    fi
    count=$((count + 1))
    echo "$count" > "$counter"

    if [ "$count" -le 1 ]; then
      echo "🚫 OFF ($now, $today): It's past shutdown. Wrapping up or something urgent?"
    elif [ "$count" -le 3 ]; then
      echo "🚫 OFF ($now, $today): That's prompt $count past shutdown. This sounds like tomorrow-work — add to inbox instead?"
    else
      echo "🚫 OFF ($now, $today): Prompt $count past shutdown. Time to rest. Only proceed if truly urgent."
    fi
  fi

elif [ "$now" -ge "$on" ] && [ "$now" -lt "$wind" ]; then
  # Reset off-prompt counter when back online
  rm -f "$SHUTDOWN_HOME/state/off-prompts"

  if [ "$last_pickup" != "$today" ]; then
    echo "📋 PICKUP ($today): Suggest /pickup to start the day."
  else
    echo "ok $today"
  fi
else
  echo "ok $today"
fi

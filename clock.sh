#!/bin/bash
# Hook output formatter — turns time into a directive Claude can't ignore
now=$(date +%H%M)
today=$(date +%Y-%m-%d)
if [ "$now" -ge 2100 ] && [ "$now" -lt 2130 ]; then
  echo "⏰ SHUTDOWN REMINDER ($now, $today): Shutdown at 2130. Mention this to the user before proceeding."
elif [ "$now" -ge 2130 ] || [ "$now" -lt 0900 ]; then
  echo "⏰ PAST SHUTDOWN ($now, $today). BEFORE responding, ask: wrapping up, urgent, or new work? If new work, suggest capturing for tomorrow."
elif [ "$now" -ge 0900 ] && [ "$now" -lt 0905 ]; then
  echo "📋 MORNING PICKUP ($today): Suggest /pickup to start the day."
else
  echo "ok $today"
fi

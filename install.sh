#!/bin/bash
set -e

SHUTDOWN_HOME="$(cd "$(dirname "$0")" && pwd)"
SETTINGS="$HOME/.claude/settings.json"

echo "Installing shutdown/pickup to: $SHUTDOWN_HOME"

# Patch instruction files with resolved path
for f in skills/shutdown.md skills/pickup.md instructions/shutdown.md instructions/pickup.md; do
  sed -i.bak "s|SHUTDOWN_HOME|$SHUTDOWN_HOME|g" "$SHUTDOWN_HOME/$f"
  rm -f "$SHUTDOWN_HOME/$f.bak"
done

# Ensure state directory exists
mkdir -p "$SHUTDOWN_HOME/state" "$SHUTDOWN_HOME/pickups" "$SHUTDOWN_HOME/inbox"

# Make clock.sh executable
chmod +x "$SHUTDOWN_HOME/clock.sh"

echo ""
echo "Done. Add the following to $SETTINGS:"
echo ""
cat <<EOF
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash $SHUTDOWN_HOME/clock.sh"
          }
        ]
      }
    ]
  },
  "permissions": {
    "allow": [
      "Read($SHUTDOWN_HOME/**)",
      "Write($SHUTDOWN_HOME/**)",
      "Edit($SHUTDOWN_HOME/**)",
      "Bash(mkdir -p $SHUTDOWN_HOME/*)"
    ]
  }
}
EOF
echo ""
echo "Skills are auto-discovered from $SHUTDOWN_HOME/skills/."
echo "Customize times in clock.sh. Customize behavior in config.json."

#!/bin/bash
set -e

SHUTDOWN_HOME="$(cd "$(dirname "$0")" && pwd)"

echo "Uninstalling shutdown/pickup."
echo ""

# Revert instruction files to portable placeholders
for f in skills/shutdown.md skills/pickup.md instructions/shutdown.md instructions/pickup.md; do
  sed -i.bak "s|$SHUTDOWN_HOME|SHUTDOWN_HOME|g" "$SHUTDOWN_HOME/$f"
  rm -f "$SHUTDOWN_HOME/$f.bak"
done

echo "Paths in instruction files reverted to placeholders."
echo ""
echo "Manually remove from ~/.claude/settings.json:"
echo "  - The UserPromptSubmit hook referencing clock.sh"
echo "  - The permission rules referencing $SHUTDOWN_HOME"
echo ""
echo "Your pickups/ and state/ data are preserved. Delete manually if unwanted."

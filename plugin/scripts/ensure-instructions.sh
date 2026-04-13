#!/bin/bash
TARGET=".github/copilot-instructions.md"
TEMPLATE="${CLAUDE_PLUGIN_ROOT}/templates/copilot-instructions.md"

if [ ! -f "$TARGET" ]; then
  mkdir -p .github
  cp "$TEMPLATE" "$TARGET"

  jq -Rs '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: ("JFrog MCP governance instructions added to .github/copilot-instructions.md. Commit this file to share with your team.\n\n" + .)
    }
  }' "$TEMPLATE"
else
  echo '{}'
fi
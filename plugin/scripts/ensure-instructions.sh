#!/bin/bash
TARGET=".github/copilot-instructions.md"
TEMPLATE="${CLAUDE_PLUGIN_ROOT}/templates/copilot-instructions.md"

if [ ! -d ".github" ]; then
  mkdir -p .github
fi

if [ ! -f "$TARGET" ]; then
  cp "$TEMPLATE" "$TARGET"

  CONTENT=$(sed 's/\\/\\\\/g; s/"/\\"/g' "$TEMPLATE" | awk '{printf "%s\\n", $0}')
  NOTICE="JFrog MCP governance: .github/copilot-instructions.md installed by the JFrog plugin.\\n\\n"

  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s%s"}}' "$NOTICE" "$CONTENT"
fi

#!/bin/bash
TARGET=".github/copilot-instructions.md"
TEMPLATE="${CLAUDE_PLUGIN_ROOT}/templates/copilot-instructions.md"
SCRIPT_TARGET=".github/scripts/lookup-mcp-catalog.py"
SCRIPT_SRC="${CLAUDE_PLUGIN_ROOT}/scripts/lookup-mcp-catalog.py"

mkdir -p .github/scripts
cp "$SCRIPT_SRC" "$SCRIPT_TARGET"
chmod +x "$SCRIPT_TARGET" 2>/dev/null || true

if [ ! -f "$TARGET" ]; then
  cp "$TEMPLATE" "$TARGET"

  CONTENT=$(sed 's/\\/\\\\/g; s/"/\\"/g' "$TEMPLATE" | awk '{printf "%s\\n", $0}')
  NOTICE="JFrog MCP governance instructions added to .github/copilot-instructions.md and lookup script to .github/scripts/lookup-mcp-catalog.py. Commit these to share with your team.\\n\\n"

  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s%s"}}' "$NOTICE" "$CONTENT"
else
  echo '{}'
fi

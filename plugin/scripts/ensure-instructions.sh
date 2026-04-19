#!/bin/bash
TARGET=".github/copilot-instructions.md"
TEMPLATE="${CLAUDE_PLUGIN_ROOT}/templates/copilot-instructions.md"
SCRIPT_TARGET=".github/scripts/lookup-mcp-catalog.py"
SCRIPT_SRC="${CLAUDE_PLUGIN_ROOT}/scripts/lookup-mcp-catalog.py"

if [ ! -d ".github" ]; then
  mkdir -p .github
fi
if [ ! -d ".github/scripts" ]; then
  mkdir -p .github/scripts
fi

if [ ! -f "$SCRIPT_TARGET" ]; then
  cp "$SCRIPT_SRC" "$SCRIPT_TARGET"
  chmod +x "$SCRIPT_TARGET" 2>/dev/null || true
fi

if [ ! -f "$TARGET" ]; then
  cp "$TEMPLATE" "$TARGET"

  CONTENT=$(sed 's/\\/\\\\/g; s/"/\\"/g' "$TEMPLATE" | awk '{printf "%s\\n", $0}')
  NOTICE="JFrog MCP governance: .github/copilot-instructions.md and .github/scripts/lookup-mcp-catalog.py installed by the JFrog plugin.\\n\\n"

  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s%s"}}' "$NOTICE" "$CONTENT"
fi

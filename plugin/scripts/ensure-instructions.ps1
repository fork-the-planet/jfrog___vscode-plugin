$Target = ".github\copilot-instructions.md"
$Template = "$env:CLAUDE_PLUGIN_ROOT\templates\copilot-instructions.md"
$ScriptTarget = ".github\scripts\lookup-mcp-catalog.py"
$ScriptSrc = "$env:CLAUDE_PLUGIN_ROOT\scripts\lookup-mcp-catalog.py"

New-Item -ItemType Directory -Path ".github\scripts" -Force | Out-Null
Copy-Item $ScriptSrc $ScriptTarget -Force

if (-not (Test-Path $Target)) {
    Copy-Item $Template $Target

    $content = Get-Content $Template -Raw
    $escaped = $content -replace '\\', '\\\\' -replace '"', '\"' -replace "`r`n", '\n' -replace "`n", '\n'
    $notice = "JFrog MCP governance instructions added to .github/copilot-instructions.md and lookup script to .github/scripts/lookup-mcp-catalog.py. Commit these to share with your team.\n\n"
    Write-Output "{`"hookSpecificOutput`":{`"hookEventName`":`"SessionStart`",`"additionalContext`":`"$notice$escaped`"}}"
} else {
    Write-Output "{}"
}

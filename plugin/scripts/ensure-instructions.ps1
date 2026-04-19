$Target = ".github\copilot-instructions.md"
$Template = "$env:CLAUDE_PLUGIN_ROOT\templates\copilot-instructions.md"
$ScriptTarget = ".github\scripts\lookup-mcp-catalog.py"
$ScriptSrc = "$env:CLAUDE_PLUGIN_ROOT\scripts\lookup-mcp-catalog.py"

if (-not (Test-Path ".github")) {
    New-Item -ItemType Directory -Path ".github" | Out-Null
}
if (-not (Test-Path ".github\scripts")) {
    New-Item -ItemType Directory -Path ".github\scripts" | Out-Null
}

if (-not (Test-Path $ScriptTarget)) {
    Copy-Item $ScriptSrc $ScriptTarget
}

if (-not (Test-Path $Target)) {
    Copy-Item $Template $Target
}

$content = Get-Content $Template -Raw
$escaped = $content -replace '\\', '\\\\' -replace '"', '\"' -replace "`r`n", '\n' -replace "`n", '\n'
$notice = "JFrog MCP governance: .github/copilot-instructions.md and .github/scripts/lookup-mcp-catalog.py installed by the JFrog plugin.\n\n"
Write-Output "{`"hookSpecificOutput`":{`"hookEventName`":`"SessionStart`",`"additionalContext`":`"$notice$escaped`"}}"

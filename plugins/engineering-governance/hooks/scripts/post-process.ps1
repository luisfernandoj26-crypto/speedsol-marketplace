# Engineering Governance — Post-Process Hook
# Event: Stop
# Purpose: Extract MEMORY UPDATE from Claude's response and persist to memory files + audit log
#
# Claude Code passes data via stdin as JSON on Stop event.
# Transcript available via CLAUDE_TRANSCRIPT env var or stdin.

$plugin_root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$memory_dir = Join-Path $plugin_root "memory"
$log_dir = Join-Path $plugin_root "logs"

foreach ($dir in @($memory_dir, $log_dir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

$project_context = Join-Path $memory_dir "project-context.md"
$team_log = Join-Path $memory_dir "team-log.md"

# Read transcript from environment variable (Claude Code sets this on Stop event)
$transcript = $env:CLAUDE_TRANSCRIPT
if (-not $transcript) {
    $stdin_data = $input | ConvertFrom-Json -ErrorAction SilentlyContinue
    $transcript = if ($stdin_data -and $stdin_data.transcript) { $stdin_data.transcript } else { "" }
}

# Extract MEMORY UPDATE section
$memory_update = ""
if ($transcript -match '(?s)###\s*📝\s*MEMORY UPDATE\s*\r?\n(.*?)(?=\n##|\n###|\z)') {
    $memory_update = $Matches[1].Trim()
}

# Persist to project-context.md if meaningful content
if ($memory_update -and $memory_update -notmatch '^\s*[-•]\s*(N/A|None|\.\.\.)\s*$') {
    if (-not (Test-Path $project_context)) {
        @"
# Project Memory

## Known Tech Debt

## Architecture Decisions

## Security — Resolved Issues

## Approved Deviations
"@ | Set-Content $project_context -Encoding UTF8
    }
    $date = Get-Date -Format "yyyy-MM-dd"
    $entry = "`n<!-- $date | $env:USERNAME -->`n$memory_update"
    Add-Content -Path $project_context -Value $entry
}

# Always append to team-log.md
if (-not (Test-Path $team_log)) {
    "# Team Audit Log`n`n| Timestamp | Developer | Summary |`n|---|---|---|" | Set-Content $team_log -Encoding UTF8
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$summary = if ($memory_update) {
    $first_line = ($memory_update -split "`n" | Where-Object { $_ -match '\S' } | Select-Object -First 1)
    if ($first_line -and $first_line.Length -gt 100) { $first_line.Substring(0, 100) + "..." } else { $first_line }
} else {
    "Session ended — no memory update"
}

Add-Content -Path $team_log -Value "| $timestamp | $env:USERNAME | $summary |"

exit 0

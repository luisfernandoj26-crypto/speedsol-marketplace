# Engineering Governance — Post-Process Hook
# Event: Stop
# Purpose:
#   1. Extract ### 📝 MEMORY UPDATE → persist to memory/project-context.md
#   2. Extract ### 🧠 AGENT LEARNING: <name> → persist to memory/agents/<name>.md
#   3. Append one line to memory/team-log.md
#
# Claude Code passes data via stdin as JSON on Stop event.
# Transcript available via CLAUDE_TRANSCRIPT env var or stdin.

$plugin_root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$memory_dir  = Join-Path $plugin_root "memory"
$agents_dir  = Join-Path $memory_dir "agents"
$log_dir     = Join-Path $plugin_root "logs"

foreach ($dir in @($memory_dir, $agents_dir, $log_dir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

$project_context = Join-Path $memory_dir "project-context.md"
$team_log        = Join-Path $memory_dir "team-log.md"

# --- Read transcript ---
$transcript = $env:CLAUDE_TRANSCRIPT
if (-not $transcript) {
    $stdin_data = $input | ConvertFrom-Json -ErrorAction SilentlyContinue
    $transcript = if ($stdin_data -and $stdin_data.transcript) { $stdin_data.transcript } else { "" }
}

# --- 1. Extract MEMORY UPDATE (shared project context) ---
$memory_update = ""
if ($transcript -match '(?s)###\s*[📝P]\s*MEMORY UPDATE\s*\r?\n(.*?)(?=\n###|\z)') {
    $memory_update = $Matches[1].Trim()
}

if ($memory_update -and $memory_update -notmatch '^\s*[-*]\s*(N/A|None|\.\.\.)\s*$') {
    if (-not (Test-Path $project_context)) {
        @"
# Project Memory

## Known Tech Debt

## Architecture Decisions

## Security — Resolved Issues

## Approved Deviations
"@ | Set-Content $project_context -Encoding UTF8
    }
    $date  = Get-Date -Format "yyyy-MM-dd"
    $entry = "`n<!-- $date | $env:USERNAME -->`n$memory_update"
    Add-Content -Path $project_context -Value $entry
}

# --- 2. Extract AGENT LEARNING sections and route to per-agent files ---
$valid_agents = @('review', 'security', 'architecture', 'debug', 'workflow', 'optimize', 'lead')

foreach ($agent in $valid_agents) {
    # Match: ### 🧠 AGENT LEARNING: <agent> followed by content until next ### or end
    $pattern = "(?s)###\s*[🧠]\s*AGENT LEARNING:\s*$agent\s*\r?\n(.*?)(?=\n###|\z)"
    if ($transcript -match $pattern) {
        $learning = $Matches[1].Trim()

        # Skip if empty or placeholder
        if (-not $learning -or $learning -match '^\s*[-*]\s*(N/A|None|\.\.\.|\(include only)') {
            continue
        }

        $agent_file = Join-Path $agents_dir "$agent.md"

        # Initialize agent memory file if missing
        if (-not (Test-Path $agent_file)) {
            @"
# Agent Memory: $agent

## Known Issues in This Codebase

## Resolved Issues (Do Not Re-report)

## Approved Patterns (Do Not Flag)

## Recurring Problems by Module

## Analysis History
"@ | Set-Content $agent_file -Encoding UTF8
        }

        $date = Get-Date -Format "yyyy-MM-dd"

        # Classify each line and append to correct section
        $lines = $learning -split "`r?`n" | Where-Object { $_ -match '\S' }

        foreach ($line in $lines) {
            $trimmed = $line.Trim()
            if (-not $trimmed -or $trimmed -match '^-\s*\.\.\.' -or $trimmed -match '^\(include only') { continue }

            $section = ""
            if ($trimmed -match '^-\s*(New known issue|Recurring \(seen again\)):') {
                $section = "Known Issues in This Codebase"
            } elseif ($trimmed -match '^-\s*Resolved:') {
                $section = "Resolved Issues (Do Not Re-report)"
            } elseif ($trimmed -match '^-\s*Approved pattern:') {
                $section = "Approved Patterns (Do Not Flag)"
            } elseif ($trimmed -match '^-\s*History:') {
                $section = "Analysis History"
            }

            if ($section) {
                # Read current content and insert after the section header
                $content = Get-Content $agent_file -Raw
                $dated_line = "- [$date] $($trimmed -replace '^-\s*', '')"

                if ($content -match "## $section") {
                    # Append after section header (find the header and add below it)
                    $content = $content -replace "(## $([regex]::Escape($section)))", "`$1`n$dated_line"
                    Set-Content $agent_file -Value $content -Encoding UTF8
                } else {
                    # Section not found, just append at end
                    Add-Content -Path $agent_file -Value "`n$dated_line"
                }
            }
        }
    }
}

# --- 3. Append to team-log.md ---
if (-not (Test-Path $team_log)) {
    "# Team Audit Log`n`n| Timestamp | Developer | Summary |`n|---|---|---|" | Set-Content $team_log -Encoding UTF8
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$summary = if ($memory_update) {
    $first_line = ($memory_update -split "`n" | Where-Object { $_ -match '\S' } | Select-Object -First 1)
    if ($first_line -and $first_line.Length -gt 100) { $first_line.Substring(0, 100) + "..." } else { $first_line }
} else {
    "Session ended - no memory update"
}

Add-Content -Path $team_log -Value "| $timestamp | $env:USERNAME | $summary |"

exit 0

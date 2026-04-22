# Engineering Governance Plugin — One-Time Developer Setup
# Run from the repository root:
#   ./plugins/engineering-governance/hooks/setup.ps1
#
# What this does:
#   1. Registers 3 hooks in .claude/settings.json
#   2. Initializes memory/ directory and files
#   3. Creates logs/ directory
#   4. Updates .gitignore

$ErrorActionPreference = "Stop"

# Resolve directories
$plugin_dir  = Split-Path $PSScriptRoot -Parent
$project_root = (Get-Location).Path
$claude_dir   = Join-Path $project_root ".claude"
$settings_file = Join-Path $claude_dir "settings.json"
$scripts_dir  = Join-Path $PSScriptRoot "scripts"

Write-Host ""
Write-Host "🔧 Engineering Governance Plugin — Setup" -ForegroundColor Cyan
Write-Host "   Plugin root  : $plugin_dir"
Write-Host "   Project root : $project_root"
Write-Host ""

# 1. Create .claude directory if missing
if (-not (Test-Path $claude_dir)) {
    New-Item -ItemType Directory -Path $claude_dir -Force | Out-Null
    Write-Host "✅ Created .claude/" -ForegroundColor Green
}

# 2. Load or create settings.json
if (Test-Path $settings_file) {
    $settings_raw = Get-Content $settings_file -Raw
    try {
        $settings = $settings_raw | ConvertFrom-Json
    } catch {
        Write-Error "❌ .claude/settings.json is not valid JSON. Fix it manually and re-run setup."
        exit 1
    }
    Write-Host "✅ Loaded existing .claude/settings.json" -ForegroundColor Green
} else {
    $settings = [PSCustomObject]@{}
    Write-Host "✅ Creating new .claude/settings.json" -ForegroundColor Green
}

# 3. Build hook entries with absolute paths
$pre_script   = (Join-Path $scripts_dir "pre-process.ps1").Replace("\", "/")
$post_script  = (Join-Path $scripts_dir "post-process.ps1").Replace("\", "/")
$error_script = (Join-Path $scripts_dir "error-handler.ps1").Replace("\", "/")

$hook_definitions = @{
    PreToolUse = [PSCustomObject]@{
        matcher = "Write|Edit"
        hooks   = @([PSCustomObject]@{
            type    = "command"
            command = "powershell -ExecutionPolicy Bypass -File `"$pre_script`""
        })
    }
    Stop = [PSCustomObject]@{
        matcher = ".*"
        hooks   = @([PSCustomObject]@{
            type    = "command"
            command = "powershell -ExecutionPolicy Bypass -File `"$post_script`""
        })
    }
    PostToolUse = [PSCustomObject]@{
        matcher = "Bash"
        hooks   = @([PSCustomObject]@{
            type    = "command"
            command = "powershell -ExecutionPolicy Bypass -File `"$error_script`""
        })
    }
}

# 4. Ensure hooks property exists
if (-not ($settings | Get-Member -Name "hooks" -MemberType NoteProperty)) {
    $settings | Add-Member -NotePropertyName "hooks" -NotePropertyValue ([PSCustomObject]@{})
}

# 5. Merge — add only if not already registered
foreach ($event in $hook_definitions.Keys) {
    if (-not ($settings.hooks | Get-Member -Name $event -MemberType NoteProperty)) {
        $settings.hooks | Add-Member -NotePropertyName $event -NotePropertyValue @()
    }

    $new_entry   = $hook_definitions[$event]
    $new_command = $new_entry.hooks[0].command

    $already_registered = $settings.hooks.$event | ForEach-Object {
        $_.hooks | ForEach-Object { $_.command }
    }

    if ($already_registered -contains $new_command) {
        Write-Host "⏭  $event hook already registered — skipping" -ForegroundColor Yellow
    } else {
        $settings.hooks.$event = @($settings.hooks.$event) + $new_entry
        Write-Host "✅ Registered $event hook" -ForegroundColor Green
    }
}

# 6. Save settings.json
$settings | ConvertTo-Json -Depth 10 | Set-Content $settings_file -Encoding UTF8
Write-Host "✅ Saved .claude/settings.json" -ForegroundColor Green

# 7. Initialize memory directory
$memory_dir = Join-Path $plugin_dir "memory"
if (-not (Test-Path $memory_dir)) {
    New-Item -ItemType Directory -Path $memory_dir -Force | Out-Null
}

$project_context = Join-Path $memory_dir "project-context.md"
if (-not (Test-Path $project_context)) {
    @"
# Project Memory

## Known Tech Debt

## Architecture Decisions

## Security — Resolved Issues

## Approved Deviations
"@ | Set-Content $project_context -Encoding UTF8
    Write-Host "✅ Initialized memory/project-context.md" -ForegroundColor Green
} else {
    Write-Host "⏭  memory/project-context.md already exists — skipping" -ForegroundColor Yellow
}

$team_log = Join-Path $memory_dir "team-log.md"
if (-not (Test-Path $team_log)) {
    "# Team Audit Log`n`n| Timestamp | Developer | Command | File/Target | Summary |`n|---|---|---|---|---|" | Set-Content $team_log -Encoding UTF8
    Write-Host "✅ Initialized memory/team-log.md" -ForegroundColor Green
}

$session_file = Join-Path $memory_dir "session.md"
if (-not (Test-Path $session_file)) {
    "# Session Context`n`n_This file is cleared each session. Not committed to git._`n`n## Files Analyzed This Session`n`n## Intermediate Results" | Set-Content $session_file -Encoding UTF8
}

# 8. Initialize per-agent memory files
$agents_dir = Join-Path $memory_dir "agents"
if (-not (Test-Path $agents_dir)) {
    New-Item -ItemType Directory -Path $agents_dir -Force | Out-Null
    Write-Host "✅ Created memory/agents/" -ForegroundColor Green
}

$agent_template = @"
# Agent Memory: {0}

## Known Issues in This Codebase

## Resolved Issues (Do Not Re-report)

## Approved Patterns (Do Not Flag)

## Recurring Problems by Module

## Analysis History
"@

foreach ($agent_name in @('review', 'security', 'architecture', 'debug', 'workflow', 'optimize', 'lead')) {
    $agent_file = Join-Path $agents_dir "$agent_name.md"
    if (-not (Test-Path $agent_file)) {
        ($agent_template -f $agent_name) | Set-Content $agent_file -Encoding UTF8
        Write-Host "✅ Initialized memory/agents/$agent_name.md" -ForegroundColor Green
    } else {
        Write-Host "⏭  memory/agents/$agent_name.md already exists — skipping" -ForegroundColor Yellow
    }
}

# 10. Create logs directory
$log_dir = Join-Path $plugin_dir "logs"
if (-not (Test-Path $log_dir)) {
    New-Item -ItemType Directory -Path $log_dir -Force | Out-Null
    Write-Host "✅ Created logs/" -ForegroundColor Green
}

# 11. Update .gitignore
$gitignore = Join-Path $plugin_dir ".gitignore"
$required_entries = @("memory/session.md", "logs/", "logs/*")

$existing = if (Test-Path $gitignore) { Get-Content $gitignore } else { @() }
$to_add = $required_entries | Where-Object { $existing -notcontains $_ }
if ($to_add.Count -gt 0) {
    Add-Content -Path $gitignore -Value ($to_add -join "`n")
    Write-Host "✅ Updated .gitignore" -ForegroundColor Green
}

# Done
Write-Host ""
Write-Host "🎉 Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "   Hooks registered:" -ForegroundColor White
Write-Host "   PreToolUse  (Write|Edit) → pre-process.ps1   blocks hardcoded secrets in .cs files" -ForegroundColor Gray
Write-Host "   Stop                     → post-process.ps1  persists MEMORY UPDATE to project memory" -ForegroundColor Gray
Write-Host "   PostToolUse (Bash)        → error-handler.ps1 logs failed commands to logs/" -ForegroundColor Gray
Write-Host ""
Write-Host "   Available commands:" -ForegroundColor White
Write-Host "   /lead  /review  /security  /architecture  /workflow  /debug  /optimize" -ForegroundColor Cyan
Write-Host ""

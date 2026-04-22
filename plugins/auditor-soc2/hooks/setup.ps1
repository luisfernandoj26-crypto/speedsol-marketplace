# Setup hook para auditor-soc2 plugin
# Registra los hooks en settings.json de Claude Code

param(
    [string]$SettingsPath = "$env:USERPROFILE\.claude\settings.json"
)

if (-not (Test-Path $SettingsPath)) {
    Write-Error "Settings file not found at $SettingsPath"
    exit 1
}

$settings = Get-Content $SettingsPath | ConvertFrom-Json

if (-not $settings.hooks) {
    $settings | Add-Member -MemberType NoteProperty -Name "hooks" -Value @()
}

$hookScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$hooks = @(
    @{
        name = "auditor-soc2-pre-process"
        event = "PreToolUse"
        command = "powershell.exe $hookScriptsDir\scripts\pre-process.ps1"
    },
    @{
        name = "auditor-soc2-post-process"
        event = "Stop"
        command = "powershell.exe $hookScriptsDir\scripts\post-process.ps1"
    }
)

foreach ($hook in $hooks) {
    $existing = $settings.hooks | Where-Object { $_.name -eq $hook.name }
    if (-not $existing) {
        $settings.hooks += $hook
    }
}

$settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsPath
Write-Host "✅ Auditor-soc2 hooks registered successfully"

# Engineering Governance — Error Handler Hook
# Event: PostToolUse (matcher: Bash)
# Purpose: Log failed Bash commands to audit trail
#
# Claude Code passes data via stdin as JSON:
# { "tool_name": "Bash", "tool_input": {...}, "tool_response": { "output": "...", "exit_code": 1 } }

$input_data = $input | ConvertFrom-Json -ErrorAction SilentlyContinue

# Extract exit code
$exit_code = 0
if ($input_data -and $input_data.tool_response) {
    $exit_code = $input_data.tool_response.exit_code
    if ($null -eq $exit_code) { $exit_code = 0 }
}

# Only log failures
if ($exit_code -eq 0) { exit 0 }

$plugin_root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$log_dir = Join-Path $plugin_root "logs"

if (-not (Test-Path $log_dir)) {
    New-Item -ItemType Directory -Path $log_dir -Force | Out-Null
}

$log_file = Join-Path $log_dir "claude-errors.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$command = if ($input_data -and $input_data.tool_input -and $input_data.tool_input.command) {
    $cmd = $input_data.tool_input.command
    if ($cmd.Length -gt 150) { $cmd.Substring(0, 150) + "..." } else { $cmd }
} else { "unknown command" }

$error_output = if ($input_data -and $input_data.tool_response -and $input_data.tool_response.output) {
    $out = $input_data.tool_response.output
    $first_line = ($out -split "`n")[0]
    if ($first_line.Length -gt 200) { $first_line.Substring(0, 200) + "..." } else { $first_line }
} else { "no output captured" }

Add-Content -Path $log_file -Value "$timestamp | $env:USERNAME | ExitCode=$exit_code | $command | $error_output"

exit 0

# Engineering Governance — Pre-Process Hook
# Event: PreToolUse (matcher: Write|Edit)
# Purpose: Block .cs files containing hardcoded secrets before they are written
# Exit 0 = allow | Exit 1 = block operation
#
# Claude Code passes tool data via stdin as JSON:
# { "tool_name": "Write", "tool_input": { "file_path": "...", "content": "..." } }

$input_data = $input | ConvertFrom-Json -ErrorAction SilentlyContinue

$tool_input = if ($input_data) { $input_data.tool_input | ConvertTo-Json -Depth 5 } else { "" }

# Only inspect .cs files
if ($tool_input -notmatch '\.cs') {
    exit 0
}

$secret_patterns = @(
    'password\s*=\s*"[^"]{3,}"',
    'Password\s*=\s*"[^"]{3,}"',
    'apikey\s*=\s*"[^"]{3,}"',
    'ApiKey\s*=\s*"[^"]{3,}"',
    'api_key\s*=\s*"[^"]{3,}"',
    'connectionString\s*=\s*"[^"]{3,}"',
    'ConnectionString\s*=\s*"[^"]{3,}"',
    'secret\s*=\s*"[^"]{3,}"',
    'Secret\s*=\s*"[^"]{3,}"',
    'token\s*=\s*"[^"]{3,}"'
)

$found_secret = $false
$matched_pattern = ""

foreach ($pattern in $secret_patterns) {
    if ($tool_input -match $pattern) {
        $found_secret = $true
        $matched_pattern = $pattern
        break
    }
}

# Log directory relative to plugin root (hooks/scripts/ -> hooks/ -> plugin root)
$plugin_root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$log_dir = Join-Path $plugin_root "logs"
if (-not (Test-Path $log_dir)) {
    New-Item -ItemType Directory -Path $log_dir -Force | Out-Null
}

$log_file = Join-Path $log_dir "pre-process.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$status = if ($found_secret) { "BLOCKED" } else { "ALLOWED" }
Add-Content -Path $log_file -Value "$timestamp | $env:USERNAME | $status | $matched_pattern"

if ($found_secret) {
    Write-Error "🚨 SECURITY BLOCK: Hardcoded secret detected in .cs file. Use Azure Key Vault or environment variables. Pattern: $matched_pattern"
    exit 1
}

exit 0

# Post-process hook para auditor-soc2
# Extrae hallazgos y los persiste

param(
    [string]$StdOutput,
    [string]$StdError
)

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logFile = "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\..\..\logs\audit.log"

$logDir = Split-Path -Parent $logFile
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

"[$timestamp] Audit execution completed`n$StdOutput" | Add-Content $logFile

exit 0

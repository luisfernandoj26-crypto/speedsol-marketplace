# Error handler hook para auditor-soc2
# Registra errores en auditoría

param(
    [string]$ErrorMessage,
    [int]$ExitCode
)

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logFile = "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\..\..\logs\errors.log"

$logDir = Split-Path -Parent $logFile
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

"[$timestamp] Error (Code: $ExitCode): $ErrorMessage" | Add-Content $logFile

exit 0

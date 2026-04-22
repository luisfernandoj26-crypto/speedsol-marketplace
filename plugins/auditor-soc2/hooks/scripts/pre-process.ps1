# Pre-process hook para auditor-soc2
# Valida que no haya secretos antes de ejecutar

param(
    [string]$ToolName,
    [string]$FilePath,
    [string]$Content
)

$secretPatterns = @(
    "password\s*=",
    "apikey\s*=",
    "secret\s*=",
    "token\s*=",
    "BEGIN RSA PRIVATE KEY",
    "BEGIN CERTIFICATE"
)

foreach ($pattern in $secretPatterns) {
    if ($Content -match $pattern) {
        Write-Error "Potential secret detected in $FilePath"
        exit 1
    }
}

exit 0

<#
.SYNOPSIS
  references/sanitizer.ps1 - Helper to sanitize `az --debug` output and logs.

.DESCRIPTION
  Reads from a file (or STDIN) and replaces common sensitive patterns with
  readable placeholders. Always inspect output to ensure no sensitive data remains.

.EXAMPLE
  .\sanitizer.ps1 -Path debug.log | Out-File sanitized.log -Encoding utf8
  Get-Content debug.log -Raw | .\sanitizer.ps1 | Out-File sanitized.log
#>
param (
    [Parameter(Mandatory=$false, Position=0)]
    [string]$Path
)

if ($Path -and (Test-Path $Path)) {
    $text = Get-Content -Raw -Path $Path
} else {
    if ($Host.Name -eq 'ConsoleHost' -and [Console]::KeyAvailable -eq $false) {
        # Try to read piped input
        $text = [Console]::In.ReadToEnd()
    } else {
        # No input
        Write-Error "No input provided. Provide -Path or pipe input to the script." -ErrorAction Stop
    }
}

# Replace Authorization: Bearer tokens
$text = [regex]::Replace($text, '(?i)(Authorization:\s*Bearer\s*)([A-Za-z0-9\-\._~\+\/=]+)', '${1}<REDACTED_TOKEN>')
# Replace JSON accessToken fields
$text = [regex]::Replace($text, '("accessToken"\s*:\s*")([^"]+)(")', '${1}<REDACTED_TOKEN>${3}')
$text = [regex]::Replace($text, "('accessToken'\s*:\s*')([^']+)(')", "${1}<REDACTED_TOKEN>${3}")
# Redact GUIDs
$text = [regex]::Replace($text, '\b[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b', '<REDACTED_GUID>')
# Redact emails
$text = [regex]::Replace($text, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', '<REDACTED_EMAIL>')
# Redact IP addresses (simple IPv4)
$text = [regex]::Replace($text, '\b(?:\d{1,3}\.){3}\d{1,3}\b', '<REDACTED_IP>')
# Redact subscription/tenant resource ids
$text = [regex]::Replace($text, '(subscriptions|tenants)/[0-9a-fA-F\-]{36}', '$1/<REDACTED_ID>')

# Output
Write-Output $text

#!/usr/bin/env bash
# references/sanitizer.sh
# Simple sanitizer for `az --debug` output and other Azure CLI logs.
# Usage:
#   sanitizer.sh input.log > sanitized.log
#   cat input.log | sanitizer.sh > sanitized.log
# Notes: This is an illustrative helper. Always review sanitized output to ensure
# no sensitive data remains. It intentionally does not attempt to parse JSON fully.

set -euo pipefail

usage() {
  cat <<'USAGE' >&2
Usage: sanitizer.sh [file]
If [file] is omitted, reads from STDIN.
Outputs sanitized content to STDOUT.
USAGE
}

INPUT="${1-}" || true
if [[ "${INPUT}" == "-h" || "${INPUT}" == "--help" ]]; then
  usage
  exit 0
fi

# Read from file or stdin
if [[ -n "$INPUT" ]]; then
  CONTENT=$(cat "$INPUT")
else
  CONTENT=$(cat -)
fi

# Redact Authorization bearer tokens
CONTENT=$(echo "$CONTENT" | perl -pe 's/(?i)(Authorization:\s*Bearer\s*)([A-Za-z0-9\-\._~\+\/=]+)(?=\s|$)/${1}<REDACTED_TOKEN>/g')
# Redact JSON accessToken and similar properties
CONTENT=$(echo "$CONTENT" | perl -pe 's/("accessToken"\s*:\s*")([^"]+)(")/${1}<REDACTED_TOKEN>${3}/g')
CONTENT=$(echo "$CONTENT" | perl -pe "s/('accessToken'\s*:\s*')[^']+(')/\\$1<REDACTED_TOKEN>\\\$2/g")
# Redact GUIDs (subscription, tenant, etc.)
CONTENT=$(echo "$CONTENT" | perl -pe 's/\b[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b/<REDACTED_GUID>/g')
# Redact email-like UPNs
CONTENT=$(echo "$CONTENT" | perl -pe 's/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/<REDACTED_EMAIL>/g')
# Redact obvious subscription ids or resource ids that contain tenant/sub IDs
CONTENT=$(echo "$CONTENT" | perl -pe 's/(subscriptions|tenants)\/[0-9a-fA-F\-]{36}/$1\/<<REDACTED_ID>>/g')
# Redact IP addresses (simple IPv4 pattern)
CONTENT=$(echo "$CONTENT" | perl -pe 's/\b(?:\d{1,3}\.){3}\d{1,3}\b/<REDACTED_IP>/g')

# Print result
printf "%s" "$CONTENT"

---
name: "powershell-standards"
description: "PowerShell module and script authoring standards for the repository."
applyTo: "**/*.ps1,**/*.psm1"
---

# OBJECTIVE
Ensure all PowerShell automation is modular, secure, and follows industry standards for script authoring and testing.

# RESPONSE RULES
- **Naming**: Enforce `Verb-Noun` naming for all public functions.
- **Security**: Proactively check for hard-coded credentials and recommend secret management modules or environment variables.
- **Testing**: Mandate Pester tests for any logic that involves data processing or API calls.

# WORKFLOW

## Step 1: Scaffolding
- **Goal**: Create a standard module structure.
- **Action**:
  - Use `psd1` (manifest) and `psm1` (module) files.
  - Create a `tests/` directory for Pester files.

## Step 2: Implementation
- **Goal**: Write clean, standard-compliant code.
- **Action**:
  - Use `Write-Verbose` for logging.
  - Ensure all parameters are typed and documented.
  - Run `PSScriptAnalyzer` locally: `Invoke-ScriptAnalyzer -Path .`

## Step 3: Testing
- **Goal**: Verify functionality and prevent regressions.
- **Action**:
  - Use `Invoke-Pester` to run tests.
  - Aim for high coverage of logic branches.

# EXAMPLES

## Secure Secret Retrieval
```powershell
function Get-PlatformSecret {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$SecretName
    )
    # Using environment variable or managed identity instead of hard-coded key
    return $env:PLATFORM_SECRET
}
```

## Poor Practice
```powershell
function GetSecret {
    $key = "12345" # Hard-coded credential
    return $key
}
```

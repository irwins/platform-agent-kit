<#
.SYNOPSIS
    Validates a Bicep module using bicep build and optional linter.

.DESCRIPTION
    Runs bicep build and optionally bicep-linter against a Bicep module.
    Exits with appropriate code on errors; linter warnings are non-fatal unless -Strict.

.PARAMETER BicepFile
    Path to the main.bicep file to validate. Defaults to ./main.bicep.

.PARAMETER Strict
    Treat linter warnings as errors (exit code 1 instead of 0).

.EXAMPLE
    .\Invoke-BicepValidation.ps1

    Validates ./main.bicep in the current directory.

.EXAMPLE
    .\Invoke-BicepValidation.ps1 -BicepFile ./modules/storage/main.bicep -Strict

    Validates storage module and fails on linter warnings.

.NOTES
    Author: Platform Engineering Team
    Requires: Bicep CLI
    Reference: https://github.com/Azure/bicep
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$BicepFile = "./main.bicep",

    [Parameter(Mandatory = $false)]
    [switch]$Strict
)

$ErrorActionPreference = 'Stop'

# Check if bicep CLI is available
try {
    $bicepVersion = & bicep --version 2>&1
    Write-Host "Found Bicep: $bicepVersion"
}
catch {
    Write-Error "bicep CLI not found. Install from https://github.com/Azure/bicep/releases"
    exit 2
}

# Resolve the Bicep file path
if (-not (Test-Path -Path $BicepFile)) {
    Write-Error "Bicep file not found: $BicepFile"
    exit 1
}

$resolvedPath = (Resolve-Path -Path $BicepFile).Path
Write-Host "Running bicep build on: $resolvedPath"

# Run bicep build
try {
    & bicep build $resolvedPath
    $buildExitCode = $LASTEXITCODE
    if ($buildExitCode -ne 0) {
        Write-Error "bicep build failed with exit code $buildExitCode"
        exit 1
    }
    Write-Host "✓ bicep build passed"
}
catch {
    Write-Error "Failed to execute bicep build: $_"
    exit 1
}

# Run bicep-linter if available
$linterExitCode = 0
try {
    $linterVersion = & bicep-linter --version 2>&1
    Write-Host "Found Bicep Linter: $linterVersion"
    Write-Host "Running bicep-linter..."

    & bicep-linter $resolvedPath
    $linterExitCode = $LASTEXITCODE

    if ($linterExitCode -ne 0) {
        if ($Strict) {
            Write-Error "bicep-linter found issues (strict mode)"
            exit 1
        }
        else {
            Write-Warning "bicep-linter found issues but continuing (non-strict mode)"
        }
    }
    else {
        Write-Host "✓ bicep-linter passed"
    }
}
catch {
    Write-Warning "bicep-linter not found; skipping linter step (recommended to include in CI)"
}

Write-Host "✓ Validation complete"
exit 0

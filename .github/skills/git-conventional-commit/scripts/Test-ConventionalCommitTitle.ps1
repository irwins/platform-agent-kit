<#
.SYNOPSIS
    Validates Conventional Commit titles against project pattern.

.DESCRIPTION
    Validates that a commit title follows the Conventional Commits standard:
    type(scope): description

    Types: feat, fix, chore, docs, perf, refactor, test, ci, style, build
    Scope: optional, lowercase alphanumeric and hyphens
    Breaking change indicator: optional !

.PARAMETER Title
    Commit title to validate.

.PARAMETER Test
    Run self-tests to validate the script's logic.

.EXAMPLE
    .\Test-ConventionalCommitTitle.ps1 -Test

    Runs validation self-tests.

.EXAMPLE
    .\Test-ConventionalCommitTitle.ps1 "feat(auth): add JWT login"

    Validates a specific commit title.

.NOTES
    Author: Platform Engineering Team
    Reference: https://www.conventionalcommits.org/
#>
[CmdletBinding(DefaultParameterSetName = 'Validate')]
param (
    [Parameter(Mandatory = $false, Position = 0, ParameterSetName = 'Validate')]
    [string]$Title,

    [Parameter(Mandatory = $false, ParameterSetName = 'Test')]
    [switch]$Test
)

$ErrorActionPreference = 'Stop'

# Conventional Commits pattern
# type(scope): description
# type is required, scope is optional, breaking change indicator (!) is optional
$CommitPattern = "^(feat|fix|chore|docs|perf|refactor|test|ci|style|build)(\([a-z0-9\-]+\))?!?:\s.+$"

# Test vectors: (title, shouldPass)
$TestVectors = @(
    @{ Title = "feat(auth): add JWT login and token refresh"; Expected = $true }
    @{ Title = "fix(reports): correct timezone handling in report generation"; Expected = $true }
    @{ Title = "perf: improve rendering speed"; Expected = $true }
    @{ Title = "feat(auth) add JWT login"; Expected = $false }  # missing ':'
    @{ Title = "Add JWT login"; Expected = $false }  # no type
    @{ Title = "docs(README): Update"; Expected = $false }  # uppercase scope + vague verb
)

function Test-CommitTitle {
    <#
    .SYNOPSIS
        Validates a commit title against Conventional Commits pattern.

    .PARAMETER CommitTitle
        The commit title to validate.

    .OUTPUTS
        PSCustomObject with properties: Valid (bool), Message (string)
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$CommitTitle
    )

    if ($CommitTitle -cmatch $CommitPattern) {
        return @{
            Valid = $true
            Message = "OK"
        }
    }
    else {
        return @{
            Valid = $false
            Message = "Title does not match required Conventional Commits pattern"
        }
    }
}

function Invoke-SelfTests {
    <#
    .SYNOPSIS
        Runs validation self-tests.

    .OUTPUTS
        Exit code: 0 if all tests pass, 1 if any fail
    #>
    Write-Host "Running validation self-tests...`n"

    $failures = 0

    foreach ($testCase in $TestVectors) {
        $result = Test-CommitTitle -CommitTitle $testCase.Title
        $status = if ($result.Valid) { "PASS" } else { "FAIL" }
        $expectedStatus = if ($testCase.Expected) { "PASS" } else { "FAIL" }
        $testPassed = ($result.Valid -eq $testCase.Expected)

        Write-Host "$($testCase.Title) -> $status (expected: $expectedStatus) - $($result.Message)"

        if (-not $testPassed) {
            $failures++
        }
    }

    if ($failures -gt 0) {
        Write-Host "`n$failures test(s) failed"
        return 1
    }
    else {
        Write-Host "`nAll tests passed"
        return 0
    }
}

# Main execution
if ($Test) {
    $exitCode = Invoke-SelfTests
    exit $exitCode
}

if ([string]::IsNullOrWhiteSpace($Title)) {
    Write-Host "Usage:"
    Write-Host "  .\Test-ConventionalCommitTitle.ps1 -Test"
    Write-Host "  .\Test-ConventionalCommitTitle.ps1 `"feat(scope): description`""
    Write-Host ""
    Write-Host "Conventional Commits Format: type(scope): description"
    Write-Host "Types: feat, fix, chore, docs, perf, refactor, test, ci, style, build"
    Write-Host "Scope: optional, lowercase alphanumeric and hyphens"
    Write-Host "Breaking change: optional ! before colon"
    exit 2
}

$result = Test-CommitTitle -CommitTitle $Title

if ($result.Valid) {
    Write-Host "VALID: $Title"
    exit 0
}
else {
    Write-Host "INVALID: $Title"
    Write-Host $result.Message
    exit 1
}

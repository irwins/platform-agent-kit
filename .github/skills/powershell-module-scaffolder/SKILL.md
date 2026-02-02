---
name: "powershell-module-scaffolder"
description: "Scaffold PowerShell modules with Pester tests. Use when the user requests a new PowerShell module or sample functions; keywords: powershell, psm1, psd1, pester, PSScriptAnalyzer, scaffold"
---

# PowerShell Module Scaffolder Skill

Summary: Create a skeleton PowerShell module (`.psm1`/`.psd1`), sample function, and Pester test harness.

Usage:
- Inputs: module name, functions list
- Outputs: module folder, `README.md`, `tests/` with Pester examples

Requirements:
- PowerShell 7.x available for local development and CI
- Pester 5.x for unit tests (`Invoke-Pester`)
- `PSScriptAnalyzer` configured with a repository baseline (recommended)

Steps:
1. Enforce approved verb-noun names and module layout (see verb-validation micro-procedure below).
2. Add `PSScriptAnalyzer` settings and sample Pester tests.

Example scaffold (expected output):

```
MyModule/
├── MyModule.psd1
├── MyModule.psm1
├── Public
│   └── Get-MyThing.ps1
├── README.md
├── tests
│   └── Get-MyThing.Tests.ps1
└── .vscode/ (optional dev settings)
```

Example function (`Public/Get-MyThing.ps1`):

```powershell
function Get-MyThing {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    process {
        return @{ Name = $Name; Created = (Get-Date) }
    }
}

Export-ModuleMember -Function Get-MyThing
```

Example Pester test (`tests/Get-MyThing.Tests.ps1`):

```powershell
Describe 'Get-MyThing' {
    It 'returns an object with Name and Created' {
        $result = Get-MyThing -Name 'Test'
        $result | Should -Not -BeNullOrEmpty
        $result.Name | Should -Be 'Test'
    }
}
```

NEVER / Anti-Patterns:
- **NEVER commit secrets or credentials** to the scaffolded module. Use Key Vault or secure pipelines for secrets.
- **NEVER disable `PSScriptAnalyzer` rules globally.** If a rule is noisy, scope an exception and document why it was relaxed.
- **NEVER skip tests in CI.** Scaffolding should include a baseline test that runs in CI.
- **NEVER use unapproved verbs.** Prefer Microsoft-approved verbs (see verb-validation micro-procedure).

Verb-validation micro-procedure (how to verify approved verbs):
1. Check the requested verb against the Microsoft Approved Verbs list: https://learn.microsoft.com/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell
2. If the verb is not on the list, suggest an alternative approved verb and explain mapping (e.g., `Get` → read-like operations, `New` → create-like operations).
3. For ambiguous cases, prefer broader verbs (`Get`, `Set`, `Remove`, `Test`, `Invoke`) and document the justification in `README.md`.

Integration Test Checklist (how to validate the scaffolder output):
- Test 1: Scaffold a module `MyModule` with function `Get-MyThing` and verify the file tree exists as in the example scaffold.
- Test 2: Run `Import-Module` and `Invoke-Pester` locally to confirm tests pass.
- Test 3: Run `Invoke-ScriptAnalyzer` with the repo baseline and ensure no new high-severity issues are introduced.

Implementation notes for the Agent:
1. Ask for module name, list of functions, and preferred verbs.
2. Validate verbs (use micro-procedure) and prompt for replacements if needed.
3. Generate files, add minimal `README.md` and `PSScriptAnalyzer` baseline, and include example tests.
4. Return a checklist the user can run locally: `pwsh -Command "Import-Module .; Invoke-Pester; Invoke-ScriptAnalyzer -Path ."`.


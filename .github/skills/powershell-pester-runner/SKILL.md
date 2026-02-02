---
name: "powershell-pester-runner"
description: "Run Pester tests and summarize results. Use when the user requests test execution or a test summary for a module; keywords: powershell, pester, Invoke-Pester, tests, CI"
---

# PowerShell Pester Runner Skill

Summary: Run Pester tests and provide a concise, actionable summary of results and remediation suggestions.

Requirements:
- PowerShell 7.x for local dev and CI
- Pester 5.x available in runner environment

Usage:
- Inputs: test folder or module path (path to `tests/` or module root)
- Outputs: test summary (counts), list of failing `Describe`/`It` blocks, probable causes, and remediation hints

Runner steps:
1. Run `Invoke-Pester` with CI-friendly options (e.g., `Invoke-Pester -Path <tests> -OutputFormat NUnitXml -PassThru`).
2. Parse the result object or XML to extract totals, failures, and stack traces.
3. Map failing `Describe/It` names to the module code (search for tested function name), then provide concise remediation steps.

Triage micro-procedure (reproduce and local debug):
1. Re-run the failing test locally: `Invoke-Pester -Tests 'DescribeName -It "ItName"' -PassThru -Show <debug>` or run the specific test file.
2. Capture error message and stack trace; identify the assertion (property mismatch, null, exception).
3. Search repository for the asserted function/feature to find the implementation line(s).
4. Propose remediation: (a) fix function output to meet expectations; (b) adjust test if expectation is incorrect; (c) add guard clauses or mocks where appropriate.
5. Re-run tests and confirm pass.

Example summary template (what the Agent should return):

Test summary:
- Total: 12, Passed: 11, Failed: 1, Skipped: 0, Duration: 2.3s

Failing tests:
- `Describe 'Get-MyThing' / It 'returns Name'` — Error: "Property 'Name' not found" — Likely cause: function does not populate Name property. Remediation: check `Get-MyThing` implementation and `Export-ModuleMember`.

NEVER / Anti-Patterns:
- **NEVER ignore failing tests in CI.** Treat failures as immediate blockers.
- **NEVER commit test secrets or credentials.** Use environment variables or secret stores.
- **NEVER suppress errors by broad `try/catch` in tests.** Tests should fail loudly and provide clear diagnostics.

Evaluation scenarios (minimal tests for verification):
1. **All tests pass** — Provide a pass summary with totals and duration.
2. **Single failing assertion** — Provide failing test details, stack trace excerpt, probable cause, and a remediation step.
3. **Flaky or timeout test** — Detect timeouts or intermittent failures, advise re-running isolated test and suggest flakiness mitigation (isolate external dependencies, add retries, or fix race conditions).

Agent steps when invoked:
1. Ask for the path to tests or module and any environment flags (e.g., `-SkipIntegration`).
2. Run `Invoke-Pester` with `-PassThru` and parse results (or use `-OutputFormat NUnitXml` for machine-readable output).
3. Return the example summary template filled with real data and include exact command lines to reproduce locally.

---

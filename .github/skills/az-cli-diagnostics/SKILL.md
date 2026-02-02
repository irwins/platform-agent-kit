---
name: "az-cli-diagnostics"
description: "Collect `az` CLI context and produce reproducible, sanitized troubleshooting steps for failing `az` commands or Azure deployments. Use when a user reports failing `az` commands, `--debug` output, or deployment logs; includes redaction guidance and reproducible-step templates. Keywords: --debug, redact, repro, deployment logs, az --version"
---

# AZ CLI Diagnostics Skill

Summary: Collect contextual `az` outputs and produce reproducible troubleshooting steps.

Usage:
- Inputs: failing `az` command(s), subscription and resource group context, deployment names, environment details (CLI version, OS).
- Outputs: sanitized debug output and step-by-step reproduction

Steps:
1. Suggest minimal `az` commands to reproduce the issue.

When to use:
- User reports failing `az` commands or Azure deployment errors (CLI errors, ARM/Provider failures, provider timeouts).
- User provides `--debug` output or deployment logs that need interpretation.
- Triage of environment-specific failures where CLI version, subscription state, or provider registration may matter.

MANDATORY — What to collect (minimum):
1. `az --version`
2. `az account show` (sanitized)
3. `az account get-access-token` (never paste raw token; only indicate whether token exists)
4. Resource group and deployment info: `az group show --name <rg>`, `az deployment operation group list --name <deployment> -g <rg>`
5. The exact failing command(s) and any parameters used (copy/paste the literal command)
6. `--debug` output for the failing command (see Sanitization checklist)
7. Exact CLI invocation environment: OS, shell, any used environment variables, and whether `AZURE_EXTENSIONS` or preview flags were present.

Sanitization checklist (REQUIRED before sharing):
- **Redact** any sensitive values: Bearer tokens, client secrets, client IDs, tenant IDs, subscription IDs, user principal names (emails), IP addresses, and private endpoints.
- **Replace** with placeholders and keep structure, e.g. `"accessToken": "<REDACTED_TOKEN>"` or `"subscriptionId": "<REDACTED_SUBSCRIPTION>"`.
- **Do not** share raw `az account get-access-token` output. Instead, state whether a token was present and its expiration.
- **Use** deterministic redaction examples and a small helper script if available.

Redaction regex examples (illustrative):
- Bearer tokens: `(?i)(bearer\s+)[A-Za-z0-9\-\._~\+/]+=*`
- GUIDs (subscription/tenant): `\b[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b`
- Email-like UPNs: `[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}`

Sanitized `--debug` example (non-sensitive fields preserved):
```
Sending request to https://management.azure.com/subscriptions/<REDACTED_SUBSCRIPTION>/resourceGroups/<REDACTED_RG>/providers/Microsoft.Resources/deployments/<REDACTED_DEPLOYMENT>/validate?api-version=2021-04-01
Request headers:
  x-ms-client-request-id: <REDACTED>
  Authorization: Bearer <REDACTED>
Response status: 400
Response body:
{
  "error": {
    "code": "InvalidTemplate",
    "message": "The template resource '...' is invalid because..."
  }
}
```

Repro Steps Template (share this with triage reports):
1. Environment: `OS: macOS 13.5`, `az version: 2.46.0`, `subscription: <REDACTED>`
2. Exact command (copy/paste): `az deployment group create -g my-rg -f main.bicep --parameters x=1`
3. Minimal repro: provide the smallest parameter set or resource that reproduces the error. If possible, use `--what-if` and `--validate` for safe simulation:
   - `az deployment group what-if -g my-rg -f small-sample.bicep`
4. Expected result vs observed result (paste sanitized `--debug` snippet if available).
5. Any non-default provider registrations or preview features enabled.

Non-destructive checks & safety (default behavior):
- Prefer `--what-if` / `--validate` before proposing creation/deletion commands.
- **Confirm with the user** before suggesting any destructive command (create/delete/role assignments).
- Always recommend running repros in a disposable or test subscription when feasible.

NEVER list (anti-patterns) — explicit DO NOTs:
- **NEVER** ask the user to paste raw secrets, tokens, or full `--debug` output without redaction.
- **NEVER** perform destructive commands without explicit consent and a rollback plan.
- **NEVER** assume the presence of preview features or provider registrations — check first.
- **NEVER** share sanitized logs that still contain identifiable account or tenant information.

War stories — short, concrete examples of what not to do:
- **War story:** A triage report inadvertently included a subscription GUID in a sanitized log and it was posted publicly; the GUID was linked to customer resources. Always scrub subscription/tenant IDs and GUID-like strings even when other fields appear redacted.
- **War story:** A suggested repro included a delete/create sequence and was executed without confirmation in the customer's subscription, causing brief downtime. Prefer `--what-if` / `--validate` and explicitly require written consent before any destructive steps.
- **War story:** A helper script was suggested and executed without review; it contained a hard-coded file path that overwrote a production template. **MANDATORY**: read and verify any shared scripts before running them — never execute unreviewed code in production contexts.

Progressive disclosure & references (on-demand):
- Keep the Skill concise; load large sample logs, sanitizer scripts, and parsing helpers only when needed.
- **MANDATORY**: If you plan to run or provide a `sanitizer.sh`/`sanitizer.ps1` script, **READ** and **VERIFY** the script before execution. Prefer copying the script contents into the conversation for review rather than executing unknown code.
- Recommended reference files (place under `references/` when added):
  - `references/sanitizer.sh` — example redaction script
  - `references/sanitized-examples.md` — longer examples of sanitized `--debug` outputs
  - `references/repro-templates.md` — additional repro templates for common services (Deployments, Storage, KeyVault)

Keywords / discoverability (include in description):
`--debug`, `redact`, `repro`, `deployment logs`, `az --version`, `sanitizer`, `what-if`

Quick triage checklist (short):
- [ ] Do we have `az --version` and environment?
- [ ] Do we have the exact command and `--debug` output (sanitized)?
- [ ] Can we reproduce with `--what-if` or a smaller template?
- [ ] Did we redact tokens/ids/UPNs?


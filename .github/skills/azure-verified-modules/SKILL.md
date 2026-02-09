---
name: "azure-verified-modules"
description: "Recommend and reference Azure Verified Modules (AVMs) for common Azure resource patterns. Use when a user asks whether to reimplement or customize core resources (Key Vault, Storage, Log Analytics) or when weighing trade-offs between reuse vs custom code; keywords: azure verified modules, AVM, modules, reuse, keyvault, storage, loganalytics, compliance, region"
---

# Azure Verified Modules (AVM) Skill

Summary: Enforce **AVM-First** policy. Azure Verified Modules are the mandatory default for all common infrastructure patterns in this repository.

Decision Rules:
1. **Mandatory Use**: You MUST use an AVM if a pattern exists in the [AVM Index](https://azure.github.io/Azure-Verified-Modules/).
2. **Rejection Criteria**: A custom module is ONLY permitted if:
   - No AVM equivalent exists.
   - The AVM version is currently broken (documented bug).
   - Enterprise-specific sovereignty or security overrides cannot be achieved via AVM parameters.
3. **Justification**: If rejection criteria are met, the agent MUST write a "Justification for Custom Module" in the resulting code's README.

Usage:
- Reference AVMs using the `br/avm` or `br/public` aliases defined in `bicepconfig.json`.
- Pin to specific versions (e.g., `0.5.1`). NEVER use `latest`.

Trade-offs (short):
- AVMs: upstream maintenance, security patches, standard conventions, faster time-to-deploy
- Custom: full control, possible feature coverage gaps, higher ongoing maintenance cost

NEVER / Anti-Patterns (specific + why):
- **NEVER fork an AVM into your repo without an upstream tracking link and a documented update process.** Forking without tracking prevents receiving important security and bug fixes.
- **NEVER assume AVM defaults satisfy compliance.** Explicitly validate RBAC, retention, encryption scopes, and document deviations.
- **NEVER pin to `latest` in production.** Always pin to a stable version and add an update cadence.

References (MANDATORY guidance):
- AVM catalog: https://aka.ms/azure-verified-modules
**MANDATORY**: When recommending a module, open the module's README and pick a stable version that has release notes. Load the module documentation to confirm features and constraints before advising it.

Repository examples / mappings:
- Local: `modules/keyvault/`  → Recommend an AVM `key-vault` module (pin version and verify RBAC/diagnostics)
- Local: `modules/storage/`   → Recommend an AVM `storage-account` module (check for lifecycle management and redundancy)
- Local: `modules/loganalytics/` → Recommend an AVM `log-analytics-workspace` module (verify retention and linked services)

Recommendation snippet (example output):
- Module: `Microsoft/azure-verified-modules/key-vault@v1.4.0`
- Rationale: Upstream security patches, standard RBAC patterns; meets required features (soft-delete, purge protection)
- Action: Pin to `v1.4.0`, add an OWNERS note to track upstream releases, and run integration tests on upgrade

Agent steps when invoked:
1. Ask for required features, region, and any compliance constraints.
2. **MANDATORY**: Open AVM README and confirm feature parity and supported regions.
3. Return the recommendation snippet with link and rationale, or explain precisely why a custom implementation is required and what features would need to be added.

---

## Implementation Checklist (for repository maintainers)
- [x] Update skill frontmatter to include WHAT/WHEN/KEYWORDS
- [x] Add decision tree and trade-offs guidance
- [x] Add explicit NEVER/anti-pattern list with reasons
- [x] Add MANDATORY reference guidance and sample mapping examples
- [x] Add recommendation snippet and Agent steps

## Integration Test Checklist (how to validate recommendations)
- Test 1: Ask the skill for a Key Vault recommendation with features [soft-delete, purge protection] and region `eastus`. Expect: a pinned AVM version with rationale and link to README.
- Test 2: Ask for a Storage recommendation requiring immutable blobs (legal hold). Expect: either an AVM that supports immutability with reasoning, or a clear explanation that custom implementation is required with required features listed.
- Test 3: Ask for Log Analytics with a strict retention and cross-subscription diagnostics. Expect: AVM recommendation or explicit custom rationale.

**Pass criteria**: Recommendations include module name + version, direct link to module README, rationale, and a clear action (pin/version, tests to run).

---


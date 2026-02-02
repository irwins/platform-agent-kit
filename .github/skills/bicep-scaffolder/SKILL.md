---
name: "bicep-scaffolder"
description: "Scaffold parameterized Bicep modules. Use when the user requests a new Bicep module or asks to scaffold infrastructure code."
---

# Bicep Scaffolder Skill

Summary: Scaffold a small, parameterized Bicep module (idempotent `main.bicep` + `parameters.json`) and guidance for production use. Use when a user requests a new Bicep module, needs a repeatable module scaffold, or asks whether to use an Azure Verified Module (AVM) vs a custom module.

When to use (triggers):
- "scaffold bicep module", "create bicep module", "generate bicep scaffold"
- When the user provides a resource type, a name pattern, or a Git diff of infra changes

Inputs
- `resource_type` (string): Azure resource type, e.g., `Microsoft.Storage/storageAccounts`.
- `name_pattern` (string, optional): pattern for resource names (short prefix, environment token)
- `parameters` (object, optional): minimal parameter hints (types and example defaults)

Outputs
- `module_dir/` with `main.bicep`, `parameters.json`, `README.example.md` and `scripts/validate_bicep.sh` (automation helpers)

Core workflow
1. Validate requested resource type and suggest latest API version (consult Azure resource type list).
2. Decide: Prefer Azure Verified Module (AVM) when available and matches requirements; otherwise scaffold an idempotent, modular Bicep module.
3. Populate `main.bicep` with clear parameter metadata, `@description()` and safe defaults for test deployments.
4. Add small `README.example.md` and a `scripts/validate_bicep.sh` to run `bicep build` and `bicep linter`.
5. Return `pr_description` and `pr_checks` describing CI validation steps to use in a PR.

NEVER — Anti-patterns (explicit examples + WHY)
- **Bad:** Use string concatenation for child resource names (e.g., `name: '${vnetName}-subnet'`).
  - **Why:** Loses implicit relationships; use nested resources or `parent` instead.
- **Bad:** Overly restrictive `@allowed` decorators for parameters.
  - **Why:** Breaks reusability and may block valid SKUs across environments.
- **Bad:** Exposing secrets in outputs (returning connection strings unmasked).
  - **Why:** Use `@secure()` on outputs or avoid emitting secrets altogether.
- **Bad:** Skipping `bicep build` or linter checks in CI.
  - **Why:** Fails fast and prevents broken modules from merging.
- **Bad:** Putting large examples in SKILL.md body.
  - **Why:** Increases token cost and reduces discoverability; put examples in `references/` and mark them **MANDATORY - READ** when needed.

Decision checklist — AVM vs Custom
- Prefer AVM when:
  - An Azure Verified Module exists for the resource and matches required configuration
  - You need a well-tested, supported pattern with versioning
- Prefer Custom when:
  - AVM does not cover the required configuration (custom behavior or preview features)
  - You need to control resource naming, parents, or unusual lifecycle semantics

Progressive disclosure & references
- Heavy examples, templates, and extended guidance live in `references/`:
  - `references/main.bicep` (template)
  - `references/parameters.json` (example params)
  - `references/README.example.md` (deploy + linter + CI usage)
- Use explicit triggers inside workflows to **MANDATORY - READ ENTIRE FILE** for large references when needed.
- Keep SKILL.md < 500 lines and one-level references deep.

Validation & CI
- Provide `scripts/validate_bicep.sh` to run `bicep build` and `bicep linter` and exit non‑zero on failure.
- Example GitHub Actions snippet (see `.github/workflows/validate-bicep.yml`) to run validation on PRs.

Evaluation scenarios
1. Create module for `Microsoft.Storage/storageAccounts` with `env=dev` and verify `bicep build` passes.
2. Scaffold module where AVM exists — verify decision suggests AVM and includes rationale.
3. Generate module with sensitive output — assert `@secure()` used and linter flags are resolved.

References
- Microsoft Learn Bicep best practices (naming, parameters, linter): https://learn.microsoft.com/azure/azure-resource-manager/bicep/best-practices
- Azure Verified Modules guidance: https://azure.github.io/Azure-Verified-Modules/
- CLAUDE Skill Best Practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices

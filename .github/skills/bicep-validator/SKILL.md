---
name: "bicep-validator"
description: "Validate Bicep modules and parameter files. Use for PR checks, CI validation, or manual validation of generated modules; keywords: bicep, bicepparam, validate, PR, CI, bicepconfig"
---

# Bicep Validator

Summary: Validate Bicep modules and parameter files using Azure CLI. Use this Skill on PRs touching `*.bicep` / `*.bicepparam` or manually: `Validate the bicep file at path X`.

## Validation Commands

### For Bicep Modules (.bicep)
```bash
az bicep build --file <path-to-file.bicep>
```

Validates:
- Syntax errors
- Type mismatches
- Invalid resource references
- Missing required properties
- Linter warnings (unused params, deprecated APIs, best practices)

### For Bicep Parameter Files (.bicepparam)
```bash
az bicep build-params --file <path-to-file.bicepparam>
```

Validates:
- Parameter file syntax (using statement, param declarations)
- Object property syntax (must use `:` not `=` in objects)
- Type compatibility with target Bicep module
- Parameter name matching

## Common Issues

### Bicep Modules
- **BCP036**: Type mismatch (e.g., wrong SKU name format)
- **BCP037**: Unknown property name
- **BCP073**: Missing required property
- **no-unused-params**: Parameter declared but never used

### Parameter Files
- **BCP018**: Expected `:` character (object properties must use colons)
- **BCP009**: Expected literal value (syntax error in parameter value)
- **BCP033**: Parameter not defined in target module

## Usage Examples

Validate single Bicep file:
```
Validate modules/storage/main.bicep
```

Validate parameter file:
```
Validate modules/storage/parameters.bicepparam
```

Validate multiple files:
```
Validate all bicep files in modules/storage/
```

## Exit Codes
- `0`: Validation passed (no errors)
- `1`: Validation failed (syntax errors or build failures)
- Warnings do not cause failure unless using strict linter configuration

## Requirements
- Azure CLI with Bicep extension (automatically installed)
- Run `az bicep upgrade` to get latest Bicep version
- Optional: `bicepconfig.json` for custom linter rules

## Notes
- `az bicep build` includes built-in linter checks
- Linter rules can be configured per module with `bicepconfig.json`
- Build output (ARM JSON) is written to same directory with `.json` extension
- Parameter files require the target `.bicep` file to exist for validation

## NEVER / Anti-Patterns
- **NEVER ignore linter warnings in CI.** Warnings often indicate deprecated APIs or configuration drift; treat them as first-class signals or document an explicit exception.
- **NEVER pin CI environments to a very-old Bicep CLI without verifying on latest.** Test changes against the latest Bicep and provider API versions before locking versions for long-term stability.
- **NEVER validate parameter files without the target module present.** Parameter validation requires the target module to ensure type compatibility and correct parameter names.

## Triage micro-procedure (reproduce and fix BCP errors)
1. Reproduce locally: run `az bicep build --file <path-to-file.bicep>` and `az bicep build-params --file <path-to-file.bicepparam>` as applicable. Add `--debug` if output is unclear.
2. Capture the BCP code (e.g., `BCP036`, `BCP037`, `BCP073`) and look it up in the **Common Issues** section above.
3. For type mismatches (`BCP036`): compare the parameter/module types and provider property expectations; inspect the provider schema in Azure REST docs if needed.
4. For missing properties (`BCP073`): verify required resource properties in the module and provider docs; check for naming/casing mismatches.
5. Re-run the builds after changes; if tests exist, run unit/integration tests or a dry-run deployment to a sandbox subscription.
6. If still failing or unclear, capture `az bicep build --file <file> --debug` output and search upstream issues or open an issue with a minimal repro.

**Tip:** Add a CI job that runs `az bicep build` and `az bicep build-params` for touched files so regressions are caught early.

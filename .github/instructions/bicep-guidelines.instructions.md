---
name: "bicep-guidelines"
description: "Bicep module authoring guidelines and best practices."
applyTo: "**/*.bicep"
---

# OBJECTIVE
Ensure all Bicep modules authored in this repository are idempotent, parameterized, and follow cloud-native architecture patterns.

# RESPONSE RULES
- **Idempotence**: Always design resources to be deployable multiple times without side effects.
- **Documentation**: Mandate `@description()` and `metadata` for all parameters.
- **Composition**: Prefer small, modular Bicep files over large, monolithic ones.

# WORKFLOW

## Step 1: Design Parameters
- **Goal**: Make the module flexible and reusable.
- **Action**:
  - Define parameters with default values where appropriate.
  - Add `@description()` to every parameter.
  - Use `allowed` values for constrained inputs (e.g., SKUs).
- **Transition**: Once parameters are defined and documented, proceed to Step 2.

## Step 2: Implement Resource
- **Goal**: Create the infrastructure definition.
- **Action**:
  - Reference AVM modules where possible (see `azure-verified-modules.instructions.md`).
  - Use `symbolic names` that are descriptive and follow `camelCase`.
- **Transition**: Once the resource block is complete, proceed to Step 3.

## Step 3: Local Validation
- **Goal**: Catch syntax and logical errors early.
- **Action**: Instruct the user to run:
  - `bicep build main.bicep`
  - `bicep fmt main.bicep`
- **Transition**: Validation complete.
@description('The SKU of the storage account.')
@allowed(['Standard_LRS', 'Standard_GRS'])
param storageAccountSku string = 'Standard_LRS'
```

## Bad Parameterization
```bicep
param name string // No description, no constraints
param sku string = 'LRS' // Ambiguous value
```

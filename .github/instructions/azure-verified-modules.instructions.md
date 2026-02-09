---
name: "azure-verified-modules"
description: "Guidance to prefer Azure Verified Modules for common patterns and document deviations."
applyTo: "**/*.bicep,**/*.json"
---

# OBJECTIVE
Enforce the use of **Azure Verified Modules (AVM)** as the mandatory default for all common infrastructure patterns to ensure security, compliance, and consistency.

# RESPONSE RULES
- **Prioritize AVM**: Always search for an existing AVM module before suggesting a custom implementation.
- **Explain Deviations**: If an AVM module is not used, explicitly ask the user for a justification and document it.
- **Reference Official Registry**: Use the `br/avm` alias in all code snippets.

# WORKFLOW

## Step 1: Search for AVM Pattern
- **Goal**: Identify if a pre-built Microsoft module exists for the requested resource.
- **Action**: Check the [AVM Resource Indices](https://azure.github.io/Azure-Verified-Modules/) or search local `bicepconfig.json` aliases.
- **Transition**: If found, use Step 2. If not found, use Step 3.

## Step 2: Implement AVM
- **Goal**: Generate high-quality Bicep code using the verified module.
- **Action**: Provide a snippet using the standard alias:
  - Example: `module stg 'br/avm:res/storage/storage-account:<version>' = { ... }`
- **Transition**: Move to verification.

## Step 3: Justify Custom Module
- **Goal**: Ensure deviations are necessary and documented.
- **Action**:
  - Ask the user: "Is there a regulatory or technical limitation preventing the use of AVM for this resource?"
  - Instruct the user to add a "Justification for Custom Module" section to the module's `README.md`.

# EXAMPLES

## Correct Recommendation
- "You should use the Azure Verified Module for Storage. Here is the implementation using the standard registry reference: `br/avm:res/storage/storage-account`."

## Incorrect Recommendation
- "I'll create a custom storage module for you since it's faster to write from scratch." *(Violates mandatory default rule)*

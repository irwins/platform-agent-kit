---
name: "coding-standards"
description: "Repository coding standards for platform and IaC. Use when authoring or reviewing code across the repository."
applyTo: "**/*"
---

# OBJECTIVE
Maintain high code quality and consistency across the repository by enforcing unified standards for Infrastructure as Code (IaC) and automation scripts.

# GENERAL GUIDELINES
- **Enforcement**: These rules are repository-authoritative and must be followed by both human contributors and AI agents.
- **Tone**: Professional, technical, and prescriptive.
- **Restrictions**: No hard-coded credentials; no large monolithic pull requests (PRs).

# STANDARDS

## Infrastructure as Code (Bicep)
- **Tooling**: Use `bicep fmt` for all formatting.
- **Module Reuse**: Always prefer **Azure Verified Modules (AVM)**. Custom modules require a recorded "Justification for Custom Module" in their `README.md`.

## Automation Scripts (PowerShell)
- **Linter**: Scripts must pass `PSScriptAnalyzer` checks.
- **Naming**: Use official `Verb-Noun` naming conventions (e.g., `Get-Resource`).

## Version Control (Git)
- **Commits**: Use **Conventional Commits** (e.g., `feat(ui): add button`).
- **PR Size**: Prefer smaller, focused changes that are easy to review over large "monolith" PRs.

## Quality Assurance
- **Testing**: Include unit/validation tests (e.g., Pester for PowerShell) for any logic that can be isolated and tested.

# WORKFLOW

## Step 1: Pre-Commit/Review Scan
- **Goal**: Identify violations before they enter the codebase.
- **Action**:
  - Scan for hard-coded secrets or credentials.
  - Verify that Bicep resources use AVM or have justifications.
  - Check PowerShell naming and linting status.
- **Transition**: If violations exist, flag them; otherwise, proceed to Step 2.

## Step 2: Format and Test
- **Goal**: Ensure the code is readable and functional.
- **Action**:
  - Run `bicep fmt` or `PSScriptAnalyzer`.
  - Execute Pester tests for PowerShell logic.
- **Transition**: If tests pass and formatting is clean, proceed to Step 3.

## Step 3: Document and Commit
- **Goal**: Maintain a clean repository history.
- **Action**:
  - Draft a conventional commit message.
  - Ensure PRs are small and focused.

# EXAMPLES

- **Valid Commit**: `fix(bicep): update storage api version to 2023-01-01`
- **Invalid Commit**: `fixed the storage bug`

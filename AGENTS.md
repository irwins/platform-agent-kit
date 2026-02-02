# Platform IaC Repository – AI Agent Context

> **Purpose**: This file provides persistent context to all AI coding agents working in this repository.
> Unlike skills (invoked on-demand), this context is **always loaded** into the agent's system prompt.

---

## Repository Purpose

This repository contains platform Infrastructure-as-Code (IaC) for Azure resources, automation scripts, and CI/CD workflows. It follows a modular, convention-based approach using **Bicep**, **PowerShell**, and GitHub Actions.

**Primary use cases**:
- Scaffold and maintain Azure infrastructure modules (Bicep)
- Automate platform operations (PowerShell)
- Enforce coding standards and testing via CI/CD
- Support multi-environment deployments (dev, staging, prod)

---

## Critical: Prefer Retrieval Over Pre-training

When working with **Azure**, **Bicep**, or **PowerShell** in this repository:

1. **Prefer retrieval** from repository documentation over pre-training knowledge
2. **Always consult** the indexed files below before generating code
3. **Verify** API versions, resource properties, and cmdlet parameters against current Azure documentation
4. **Use skills** when explicitly triggered by user intent (see Skills Index)

> **Rationale**: Azure APIs evolve rapidly. Pre-training data may be outdated. This repository has versioned standards that override generic knowledge.

---

## Repository Structure

```
platform-iac/
├── .github/
│   ├── agents/              # Custom agent personas (platform-engineer, bicep-architect, etc.)
│   ├── instructions/        # Coding standards, conventions, best practices (MANDATORY READ)
│   ├── skills/              # Executable skills for explicit workflows (scaffold, validate, etc.)
│   ├── prompts/             # Reusable prompt templates
│   └── workflows/           # GitHub Actions CI/CD
├── .agents.md               # THIS FILE – persistent agent context
└── README.md                # Repository overview
```

---

## Instructions Index (MANDATORY COMPLIANCE)

These files define **authoritative standards** for this repository. **Always read the relevant instruction file** before generating or modifying code.

| Instruction File | Scope | When to Read |
|-----------------|-------|--------------|
| [coding-standards.instructions.md](.github/instructions/coding-standards.instructions.md) | All files | **Always** – before any code change |
| [bicep-guidelines.instructions.md](.github/instructions/bicep-guidelines.instructions.md) | `**/*.bicep` | Before creating/editing Bicep modules |
| [powershell-standards.instructions.md](.github/instructions/powershell-standards.instructions.md) | `**/*.ps1`, `**/*.psm1` | Before creating/editing PowerShell scripts |
| [azure-verified-modules.instructions.md](.github/instructions/azure-verified-modules.instructions.md) | `**/*.bicep`, `**/*.json` | Before scaffolding infrastructure (prefer AVM) |
| [git-conventions.instructions.md](.github/instructions/git-conventions.instructions.md) | All commits | Before generating commit messages |
| [az-cli-troubleshooting.instructions.md](.github/instructions/az-cli-troubleshooting.instructions.md) | `**/*.sh`, `**/*.ps1`, `**/*.md` | When troubleshooting Azure CLI issues |

**Enforcement**: Treat these as **non-negotiable contracts**. Do not deviate without explicit user approval.

---

### Skills Index (Mandatory Consultation)

Skills are not optional helpers — agents MUST consult the Skills Index before performing any workspace-changing action.

Policy (agent behavior):
- When a user expresses intent that could change the repository (create, modify, scaffold, validate, commit), the agent MUST try to match the intent to a Skill in the Skills Index.
- If a high-confidence match is found, the agent MUST call that Skill to perform or validate the operation.
- If the Skill is missing, fails, or the match confidence is low, the agent MUST record the reason and ask the user for confirmation before proceeding with manual changes.
- Skills MUST include relevant trigger keywords in the frontmatter `description` to assist reliable discovery (examples: `bicep`, `bicepparam`, `pester`, `psm1`, `AVM`). Agents SHOULD prefer Skill invocation when description keywords match user intent.

High-confidence triggers (require Skill invocation):
- `create bicep module` / `scaffold bicep module` → `bicep-scaffolder`
- `validate bicep` / `check bicep module` → `bicep-validator`
- `should I use AVM?` / `find AVM for X` → `azure-verified-modules`
- `scaffold powershell module` / `create powershell module` → `powershell-module-scaffolder` or `pwsh-scripter`
- `generate commit message` / `conventional commit` → `git-conventional-commit`

Agents may still implement ad-hoc edits only after following the above steps and obtaining user confirmation for any non-recoverable or low-confidence cases.

### Infrastructure & Bicep

| Skill | Trigger Intent | Use Case |
|-------|---------------|----------|
| [bicep-scaffolder](.github/skills/bicep-scaffolder/SKILL.md) | "scaffold bicep module", "create bicep module" | Generate new Bicep module with parameters, README, validation script |
| [bicep-validator](.github/skills/bicep-validator/SKILL.md) | "validate bicep", "check bicep module" | Run `bicep build`, lint, and dependency checks |
| [azure-verified-modules](.github/skills/azure-verified-modules/SKILL.md) | "should I use AVM?", "find AVM for X" | Recommend Azure Verified Modules vs custom implementation |

> Note: Skills that recommend AVMs MUST include **MANDATORY** README verification steps: open the module README to confirm feature parity, supported regions, and release notes before advising reuse.

### PowerShell & Automation

| Skill | Trigger Intent | Use Case |
|-------|---------------|----------|
| [powershell-module-scaffolder](.github/skills/powershell-module-scaffolder/SKILL.md) | "scaffold powershell module", "create ps module" | Generate PowerShell module structure with Pester tests |
| [powershell-pester-runner](.github/skills/powershell-pester-runner/SKILL.md) | "run pester tests", "test powershell module" | Execute Pester tests and summarize results |

### Git & DevOps

| Skill | Trigger Intent | Use Case |
|-------|---------------|----------|
| [git-conventional-commit](.github/skills/git-conventional-commit/SKILL.md) | "generate commit message", "create conventional commit" | Generate conventional commit messages from staged changes |

### Azure CLI Troubleshooting

| Skill | Trigger Intent | Use Case |
|-------|---------------|----------|
| [az-cli-diagnostics](.github/skills/az-cli-diagnostics/SKILL.md) | "az command failed", "troubleshoot azure cli" | Collect `az` context and generate reproducible steps |

### Meta-Skills

| Skill | Trigger Intent | Use Case |
|-------|---------------|----------|
| [skill-judge](.github/skills/skill-judge/SKILL.md) | "evaluate skill quality", "audit SKILL.md" | Score and improve Agent Skill design |

**Important**: Do NOT invoke skills "just in case". Wait for explicit user intent that matches trigger conditions.

---

## Decision Framework: When to Use What

### Scenario: User asks about Bicep best practices
- ❌ **Don't invoke** `bicep-scaffolder` skill
- ✅ **Read** [bicep-guidelines.instructions.md](.github/instructions/bicep-guidelines.instructions.md)
- ✅ **Retrieve** from Azure Bicep documentation if needed

### Scenario: User says "scaffold a storage account module"
- ✅ **Invoke** `bicep-scaffolder` skill
- ✅ **Read** [bicep-guidelines.instructions.md](.github/instructions/bicep-guidelines.instructions.md) (during execution)
- ✅ **Check** [azure-verified-modules.instructions.md](.github/instructions/azure-verified-modules.instructions.md) (AVM vs custom)

### Scenario: User asks "how do I write PowerShell functions?"
- ❌ **Don't invoke** `powershell-module-scaffolder` skill
- ✅ **Read** [powershell-standards.instructions.md](.github/instructions/powershell-standards.instructions.md)
- ✅ **Provide** example based on standards

### Scenario: User says "create a PR with my staged changes"
- ✅ **Invoke** `git-conventional-commit` skill
- ✅ **Read** [git-conventions.instructions.md](.github/instructions/git-conventions.instructions.md)
- ✅ **Generate** conventional commit message and PR description

---

## Agent Behavior Principles

### 1. Bias Toward Action (with Safety)
- **Implement changes** rather than only suggesting them
- **Make smallest viable change** that satisfies user request
- **Ask for confirmation** only when ambiguous or destructive

### 2. Context Over Memory
- **Read instructions** before generating code (don't assume)
- **Verify** Azure resource types, API versions, cmdlet parameters
- **Cite sources** when referencing standards or documentation

### 3. Progressive Disclosure
- **Start small**: Show minimal working example first
- **Expand on request**: Add complexity only when user asks
- **Avoid over-engineering**: Prefer simple, maintainable solutions

### 4. Testing & Validation
- **Include tests** for PowerShell functions (Pester)
- **Validate Bicep** with `bicep build` before committing
- **Run linters**: PSScriptAnalyzer (PowerShell), Bicep linter
- **CI & validation artifacts**: Validation Skills (e.g., `bicep-validator`, `powershell-pester-runner`) SHOULD include an example CI job (GitHub Actions snippet) and minimal evaluation fixtures so checks can be exercised in CI.

### 5. Transparency
- **Explain tool choices** when running non-trivial commands
- **Acknowledge uncertainty**: Say "I need to verify this" when unsure
- **Fail gracefully**: Provide troubleshooting steps when errors occur

### Skill change contract
- When a `SKILL.md` change affects triggers, invocation expectations, or outputs, the author MUST update `.agents.md` to reflect the change and add tests/fixtures in `test/eval/` where applicable.
- Significant Skill changes MUST include at least three evaluation scenarios and a validation plan that includes testing across models (Haiku, Sonnet, Opus) and a CI snippet when applicable.

---

## Common Pitfalls to Avoid

### Bicep
- ❌ **String concatenation** for child resource names → use `parent:` or nested resources
- ❌ **Overly restrictive** `@allowed()` decorators → breaks reusability
- ❌ **Exposing secrets** in outputs → use `@secure()` or omit
- ❌ **Skipping validation** → always run `bicep build` + linter

### PowerShell
- ❌ **Hard-coded credentials** → use `Get-Credential` or Azure managed identities
- ❌ **Non-approved verbs** → use `Get-Verb` to validate
- ❌ **Missing error handling** → always include `try/catch` for Azure cmdlets
- ❌ **No tests** → every function needs at least one Pester test

### Git & CI/CD
- ❌ **Non-conventional commits** → use `type(scope): subject` format
- ❌ **Large monolith PRs** → prefer small, focused changes
- ❌ **Missing PR descriptions** → always explain "why" and link to tickets

---

## Integration with Custom Agents

This repository defines custom agent personas in `.github/agents/`:
- `platform-engineer.agent.md` – General platform/IaC tasks
- `bicep-architect.agent.md` – Bicep-focused architecture work
- `powershell-expert.agent.md` – PowerShell automation and scripting

When a custom agent is active, **this `.agents.md` file provides the base context**, and the agent-specific file adds **persona-specific behaviors**.

**Hierarchy**:
1. `.agents.md` (this file) – **Repository-wide context** (always loaded)
2. `.github/agents/<agent>.agent.md` – **Agent-specific persona** (loaded when active)
3. `.github/instructions/*.instructions.md` – **Domain-specific standards** (read on-demand)
4. `.github/skills/*/SKILL.md` – **Executable workflows** (invoked explicitly)

---

## Evaluation & Continuous Improvement

To ensure this setup works:
1. **Monitor skill invocation rates** – Are skills being used when expected?
2. **Track retrieval accuracy** – Are agents reading the right instruction files?
3. **Review agent outputs** – Do generated modules pass validation?
4. **User feedback** – Are platform engineers getting value from agents?
5. **Skill evaluations** – Ensure Skills include at least three evaluation scenarios and fixtures (pass, failure, warning/flaky) and that they are run periodically or during CI; track evaluation pass rates.

**Metrics to watch**:
- Skill invocation success rate (target: >90%)
- Instruction file retrieval rate (target: 100% before code generation)
- CI/CD pass rate for agent-generated code (target: >95%)
- User satisfaction with agent suggestions

---

## Questions or Issues?

If this `.agents.md` file is not working as expected:
1. Check if the agent is reading instructions before generating code
2. Verify skill triggers are explicit enough
3. Review agent outputs for "hallucinated" APIs or outdated patterns
4. Consider adding more specific routing rules or examples

**Feedback loop**: This file should evolve based on real-world agent usage patterns.

---

**Last Updated**: 2026-01-29
**Maintained By**: Platform Engineering Team
**Version**: 1.0.0

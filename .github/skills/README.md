# .github AI Customization Scaffold

This folder contains Copilot/VS Code agent customizations, instructions, skills, and prompts tailored for platform and cloud automation engineers.

Structure:
- `agents/` — persona agent files (`*.agent.md`)
- `instructions/` — project-wide rules and standards (`*.instructions.md`)
- `skills/` — procedural automations (each skill in its own folder with `SKILL.md`)
- `prompts/` — reusable prompt templates (`*.prompt.md`)

Quick start:
1. Commit this `.github` directory to your repo root.
2. Open VS Code with the repo and follow Copilot Custom Agents docs to enable resources.

Notes:
- Keep instructions authoritative; agents should reference them.
- Put procedural steps and runnable scripts under `skills/`.

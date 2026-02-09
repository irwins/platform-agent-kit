---
name: "git-conventions"
description: "Repository Git and commit message conventions, including Conventional Commits guidance."
applyTo: "**/*"
---

# OBJECTIVE
Standardize the repository's history and branch management using Conventional Commits and structured branch naming.

# RESPONSE RULES
- **Commit Messages**: Always suggest or enforce the `type(scope): subject` format.
- **Branch Names**: Use prefixes like `feature/`, `fix/`, `chore/`.

# STANDARDS

## Conventional Commits
- **Types**:
  - `feat`: A new feature
  - `fix`: A bug fix
  - `docs`: Documentation only changes
  - `style`: Changes that do not affect the meaning of the code (white-space, formatting, etc)
  - `refactor`: A code change that neither fixes a bug nor adds a feature
  - `perf`: A code change that improves performance
  - `test`: Adding missing tests or correcting existing tests
  - `chore`: Changes to the build process or auxiliary tools and libraries such as documentation generation

## Git Workflow
- **Branching**: `feature/your-feature-name`, `fix/issue-description`.
- **Pull Requests**: Every PR must include a short description of "Why" the change is being made and link to relevant tickets/issues.

# WORKFLOW

## Step 1: Stage Changes
- **Goal**: Group related changes for a clean commit.
- **Action**: Use `git add` to selectively stage files that belong to a single logical change.
- **Transition**: Once files are staged, proceed to Step 2.

## Step 2: Draft Commit Message
- **Goal**: Create a machine-readable and human-friendly message.
- **Action**:
  - Identify the `type` (feat, fix, etc.).
  - Identify the `scope` (networking, storage, etc.).
  - Write a concise subject line.
- **Transition**: Verify the message against the `type(scope): subject` format, then proceed to Step 3.

## Step 3: Branch and PR
- **Goal**: Facilitate review and integration.
- **Action**:
  - Ensure the branch name uses the correct prefix (`feature/`, `fix/`).
  - Write a PR description that answers "Why" this change exists.

# EXAMPLES

## Correct Commit Formats
- `feat(networking): implement hub-and-spoke vnet peering`
- `fix(vault): correct secret retrieval logic`

## Incorrect Commit Formats
- `updated files` *(Missing type/scope)*
- `fixed: the storage bug` *(Incorrect delimiter)*
- `FEAT(BICEP): ADD STORAGE` *(Should be lowercase)*

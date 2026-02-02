---
name: "git-conventional-commit"
description: "Generate Conventional Commits messages and PR templates. Use when authoring commit messages or summarizing staged changes for a PR."
---

# Git Conventional Commit Skill

Summary
- Produce commit messages and PR titles/bodies that conform to the Conventional Commits 1.0.0 spec. Use this Skill when the user asks for a commit message, PR title, or changelog entry for a set of changes.

Inputs
- `summary` (string, optional): Short human description of the change.
- `files` (list of file paths, optional): Files modified or created.
- `diff` (string, optional): Git diff or short patch text.
- `preferred_type` (string, optional): One of `feat`, `fix`, `chore`, `docs`, `perf`, `refactor`, `test`, `ci`, `style`, `build`.
- `scope` (string, optional): Narrow area of the codebase (e.g., `auth`, `bicep`, `ps`).
- `breaking` (boolean, optional): Whether this change introduces a breaking change.

Outputs
- `commit_title`: single-line prefix `type(scope): short description` (or `type!: short description` when `breaking=true`).
- `commit_body`: optional longer description and bullet list of important changes.
- `commit_footers`: optional trailers (e.g., `BREAKING CHANGE: ...`, `Refs: #123`).
- `pr_title` and `pr_description`: expanded title and formatted PR body suitable for paste into PR forms.

Templates & Validation
- Title pattern (MUST): `^(feat|fix|chore|docs|perf|refactor|test|ci|style|build)(\([a-z0-9\-]+\))?!?:\s.+`
- If `breaking` is true, include either `!` in the title (e.g., `feat(scope)!:`) or a `BREAKING CHANGE:` footer.
- Footers (optional): follow `Token: value` or `Token #value` format; `BREAKING CHANGE` MUST be uppercase when used as a token.

Behavior and heuristics
- If `diff` or `files` are provided, infer `scope` from top-level folders (first matching folder name) and suggest `type` based on keywords (`fix`, `bug` & `error` → `fix`; `add`, `new`, `implement` → `feat`; `test` → `test`; `doc` → `docs`; `refactor` → `refactor`).
- Prefer multiple small commits: when input appears to contain unrelated change groups, ask to split into multiple commits.
- When ambiguous, ask a clarifying question rather than guessing the type or scope.

Examples
- Input: `summary="Added JWT login and token refresh", files=["src/auth/login.ps1","src/auth/token.ps1"], preferred_type=null`
  Output title: `feat(auth): add JWT login and token refresh`
  Output body: `- Add login endpoint
- Add token refresh handler
- Update README with usage`

- Input: `summary="Fix timezone bug in reports", diff=...`
  Output title: `fix(reports): correct timezone handling in report generation`

Usage guidance for agent authors
- Use concise examples to show desired output formats (see Examples above).
- Provide the `diff` or `files` when possible for accurate scope detection.
- For automation (CI or bot-generated messages), prefer the `pr_description` output and include `Refs:` footers linking to tickets.
## NEVER — Anti-patterns & concrete examples (MUST NOT)
Provide explicit bad examples and short reasons so agents and authors avoid common mistakes.

- **Bad:** `Add JWT login`
  - **Why:** No type/scope — ambiguous and non‑conforming to Conventional Commits.
- **Bad:** `chore: fix`
  - **Why:** Too vague — message lacks meaningful description; commit should be actionable and searchable.
- **Bad:** `feat(auth) add JWT login` (missing `:`)
  - **Why:** Formatting errors break automated parsing; always include the colon after type/scope.
- **Bad:** `docs(README): Update` (uppercase scope and vague verb)
  - **Why:** Scope should be lowercase and description should be specific — e.g., `docs(readme): add instructions for oauth`.
- **Bad:** Single commit containing unrelated changes (e.g., `feat: add widget` + `chore: update deps` in same commit)
  - **Why:** Mergeability and bisectability suffer; prefer multiple focused commits and ask to split when detected.

## PR templates (examples to use as `pr_title` and `pr_description`)
Provide ready-to-use PR templates for common workflows. Agents should prefer these structures for `pr_description` outputs.

### Feature / Single-commit PR
pr_title (example):
```
feat(auth): add JWT login and token refresh
```
pr_description (example):
```
Summary
- Implement JWT login and token refresh handlers under `src/auth`.

Changes
- Add `src/auth/login.ps1` and `src/auth/token.ps1`
- Update README with usage and environment variables

Test Plan
- Unit tests: `tests/auth/*` added
- Manual: verify login and token refresh flows in dev environment

Notes for reviewers
- Request focus on `token.ps1` refresh logic and error handling

Refs
- Refs: #123
```

### Release / Multi-commit / Changelog PR
pr_title (example):
```
chore(release): release v1.2.3
```
pr_description (example):
```
Release v1.2.3 — Summary of changes

Highlights
- feat(auth): add JWT login and token refresh
- fix(reports): correct timezone handling in report generation
- chore(deps): bump library X to vY

Full commit list
- feat(auth): add JWT login and token refresh
- fix(reports): correct timezone handling in report generation
- chore(deps): bump library X to vY

Notes
- Follow the CHANGELOG format when publishing
```

## Validation & test vectors
Include a small validation script and example test vectors so the skill can be used reliably in CI.

Scripts
- `scripts/Test-ConventionalCommitTitle.ps1` — PowerShell script that validates a commit title against the Title pattern and provides a `-Test` self-check. Use `pwsh` (PowerShell Core) in CI for cross-platform execution.

Example test vectors (pass / fail):

| Title | Expected |
|-------|----------|
| `feat(auth): add JWT login and token refresh` | PASS |
| `fix(reports): correct timezone handling in report generation` | PASS |
| `perf: improve rendering speed` | PASS |
| `feat(auth) add JWT login` (missing `:`) | FAIL |
| `Add JWT login` (no type) | FAIL |
| `docs(README): Update` (uppercase scope, vague) | FAIL |

Usage (CLI):

```
# Cross-platform (PowerShell Core)
pwsh ./scripts/Test-ConventionalCommitTitle.ps1 -Test   # run self-tests
pwsh ./scripts/Test-ConventionalCommitTitle.ps1 "feat(auth): add JWT login"

# Windows PowerShell
.\scripts\Test-ConventionalCommitTitle.ps1 -Test
.\scripts\Test-ConventionalCommitTitle.ps1 "feat(auth): add JWT login"
```

Scripts live in `scripts/` and are intended to be minimal, easily run in CI (use `pwsh` in GitHub Actions), and provide non-zero exit codes on failure to facilitate automation.
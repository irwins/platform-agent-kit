---
name: "az-cli-troubleshooting"
description: "Guidance for collecting Azure CLI context and reproducible troubleshooting steps."
applyTo: "**/*.sh,**/*.ps1,**/*.psm1,**/*.md"
---

# OBJECTIVE
Provide structured guidance for diagnosing Azure CLI failures, ensuring context is validated before troubleshooting and that logs are captured for escalation.

# RESPONSE RULES
- Always ask the user to verify their active subscription and resource group context first.
- Provide exact commands for the user to copy/paste.
- Encourage the use of `--debug` only when a simple command fails with an opaque error.

# WORKFLOW

## Step 1: Validate Context
- **Goal**: Ensure the user is operating in the intended Azure environment.
- **Action**: Ask the user to run:
  - `az account show --output table`
  - `az group show --name <resource-group> --output table`
- **Transition**: If the environment is correct, move to Step 2.

## Step 2: Capture Error Details
- **Goal**: Collect the specific failure message and logs.
- **Action**:
  - Ask for the exact command that failed.
  - Ask for the full error output.
  - If the error is ambiguous, request a rerun with the `--debug` flag:
    - Example: `az webapp list --debug`
- **Transition**: Once logs are gathered, move to Step 3.

## Step 3: Formalize Escalation
- **Goal**: Prepare a reproducible report for the platform team.
- **Action**: Summarize the finding into:
  - **Repro Steps**: The command used.
  - **Expected Result**: What should have happened.
  - **Actual Result**: The error/log output.

# EXAMPLES

## Valid Diagnostic Response
- "Before we troubleshoot the deployment, please verify your active subscription by running `az account show`. Once confirmed, try the command again with `--debug` and paste the last 20 lines here."

## Invalid Diagnostic Response
- "It seems like a permission issue. Try checking your RBAC." *(Too vague, no actionable command)*

---
name: "Generate Policy Initiative"
description: "Create an Azure Policy initiative (initiative definition) scaffold from high-level controls."
---

You are an expert Azure Governance and Compliance Engineer. Your task is to design and scaffold an Azure Policy Initiative (Set Definition) that maps high-level compliance controls to specific Azure Policy definitions.

<instructions>
1. **Identify built-in policies**: For the list of controls provided, search for existing Azure built-in policy definitions that satisfy the requirements.
2. **Handle Custom Policies**: If a control cannot be met by a built-in policy, propose a custom policy definition or identify it as a gap.
3. **Structure the Initiative**:
   - Define a clear name and category (e.g., "Security", "Cost Optimization").
   - Compile the `policyDefinitions` array with accurate `policyDefinitionId` and parameter mappings.
   - Use meaningful `policyDefinitionReferenceId` for each entry.
4. **Parameterize**: Ensure common parameters (like `effect` or resource locations) are exposed at the initiative level for flexibility.
5. **Output Artifacts**:
   - Generate the Bicep code (using `Microsoft.Authorization/policySetDefinitions`) to deploy the initiative.
   - Provide a sample Bicep deployment for an assignment using `../../infra/modules/policy-assignment-mg.bicep`.
</instructions>

<output_format>
- A Bicep file containing the `policySetDefinition` resource.
- A summary table mapping the user's controls to the chosen Policy Definitions.
- A sample deployment snippet or script.
</output_format>

<example>
**Scenario 1: Happy Path (Built-in Policies)**
- **User Input**: "I need a policy initiative for 'Storage Security' including: encryption at rest, HTTPS only, and restricting public access."
- **Your Action**:
  - Search for built-in Storage policies.
  - Draft a `policySetDefinition` Bicep resource.
  - Reference `../../infra/modules/policy-assignment-mg.bicep` for the assignment example.

**Scenario 2: Custom Policy Required**
- **User Input**: "Standardize tags for 'Environment' and 'CostCenter', but if 'Environment' is 'Prod', 'CostCenter' must match a specific regex."
- **Your Action**:
  - Identify that built-in tagging policies don't support conditional regex matching across parameters.
  - Propose a `policyDefinition` Bicep resource for the custom regex logic.
  - Include both built-in and custom policies in the `policySetDefinition`.

**Scenario 3: Identifying Gaps**
- **User Input**: "Ensure all VMs are scanned by a proprietary 3rd party agent that doesn't have an Azure extension yet."
- **Your Action**:
  - Search for 3rd party agent built-ins (none found).
  - Explicitly state the gap in the summary table.
  - Recommend a `Guest Configuration` custom policy or identifies it as an out-of-band manual control.
</example>

Below are the requirements for the initiative:
- **Control 1**: All storage accounts must have encryption at rest enabled.
- **Control 2**: All storage accounts must allow only secure transfer (HTTPS).
- **Control 3**: All storage accounts must restrict public access to blobs and queues.


# Repro Templates

Service-specific minimal repro templates and guidance. Use these templates to produce minimal, non-destructive repros for triage.

## Template structure (always include)
- Environment: OS, `az --version`, shell
- Exact command (copy/paste)
- Minimal template or parameters to reproduce
- `--what-if`/`--validate` results if available
- Sanitized `--debug` excerpt (if present)
- Expected result vs observed result

## Deployments (ARM/Bicep)
1. Run `az --version` and include it in the report.
2. Provide the exact command used, e.g.:
   - `az deployment group create -g my-rg -f main.bicep --parameters param1=val1`
3. Attempt non-destructive checks:
   - `az deployment group validate -g my-rg -f main.bicep`
   - `az deployment group what-if -g my-rg -f main.bicep`
4. If error persists, reduce to a minimal Bicep/ARM snippet that still fails.
5. Attach sanitized `--debug` output and expected vs actual outcome.

## Storage (Accounts, Blobs)
1. Provide command and resource name:
   - `az storage account create -n myacct -g my-rg -l eastus --sku Standard_LRS`
2. Use preview flags or `--debug` sparingly; prefer `--validate` when available.
3. For authentication errors, include `az account show` (sanitized) and whether MSI/Service Principal was used.
4. If a blob operation fails, provide `az storage blob upload --account-name myacct --container-name mycon --name file.txt --file ./file.txt --debug` (sanitized output required).

## KeyVault
1. Example failing command: `az keyvault secret set --vault-name mykv --name secret1 --value "sensitive"`
2. For access or permission errors, include role/acl checks and sanitized `az account show`.
3. For replication/soft-delete issues, include the KeyVault resource properties (sanitized) and the exact command used.

## Tips
- Prefer `--what-if`/`--validate` before create/delete operations.
- If the repro requires specific provider registrations (e.g., `Microsoft.Storage`), state whether the provider is registered.
- When possible, reproduce in a disposable test subscription and provide the steps to repro there.
- Use the `references/sanitizer.*` scripts to sanitize logs and include a short note describing what was redacted.

## AKS (Kubernetes)
1. Provide cluster name and resource group: `az aks show -g <rg> -n <cluster>` (sanitize resource IDs and subscription info).
2. Collect kube-level diagnostics:
   - `kubectl get pods -A -o wide`
   - `kubectl describe pod <pod> -n <ns>`
   - `kubectl logs <pod> -n <ns> --previous`
   - `kubectl get events -A`
3. Include node details and versions: `kubectl get nodes -o wide` and `az aks nodepool list -g <rg> --cluster-name <cluster>` (sanitize node hostnames and IPs).
4. For image-pull or registry errors, include the image reference but redact registry hostnames or image shas.
5. Non-destructive checks: `kubectl get events -A`, `az aks get-upgrades --name <cluster> -g <rg>`

## Functions
1. Provide Function App name, resource group, runtime stack, and host runtime version.
2. Commands and logs to collect:
   - `az functionapp show -g <rg> -n <app>` (sanitize app settings)
   - `az functionapp log tail -g <rg> -n <app>` or `func azure functionapp logstream <app>`
   - `az functionapp config appsettings list -g <rg> -n <app>` (redact any secrets, storage connection strings)
3. Capture invocation ids and host logs (redact invocation ids and connection strings).
4. Non-destructive checks: check app settings and platform logs before suggesting restarts or slot swaps.

## SQL (Azure SQL)
1. Provide server and database names and the resource group: `az sql server show -n <server> -g <rg>` and `az sql db show -s <server> -n <db>`.
2. Collect connectivity and firewall info: `az sql server firewall-rule list -s <server> -g <rg>` (redact allowed IPs if needed) and `az sql db list-usages -s <server> -g <rg>`.
3. For login failures, include sanitized error messages and whether the login is SQL auth or AAD.
4. Non-destructive checks: confirm firewall rules and try a sanitized `sqlcmd` test that does not include passwords in the report itself.

## Example minimal repro report
- Environment: `macOS 13.5`, `az 2.46.0`
- Command: `az deployment group create -g test-rg -f minimal.bicep`
- Minimal repro files: `minimal.bicep` (attached)
- What I tried: `az deployment group validate -g test-rg -f minimal.bicep` (400 error)
- Sanitized debug snippet: (see `references/sanitized-examples.md`)
- Expected: deployment succeeds; Observed: `InvalidTemplate` error when validating storage resource

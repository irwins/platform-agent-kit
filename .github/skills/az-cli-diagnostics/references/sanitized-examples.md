# Sanitized Examples

This file contains short before/after examples to show how to redact `az --debug` output and common logs. Always review sanitized output manually.

## Example 1 — `az deployment group create` (raw snippet)
```
Request URL: POST https://management.azure.com/subscriptions/123e4567-e89b-12d3-a456-426614174000/resourceGroups/my-rg/providers/Microsoft.Resources/deployments/my-deploy/validate?api-version=2021-04-01
Request headers:
  Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...longtoken...
  x-ms-client-request-id: 3f8a9f2e-abc1-4f3b-9b77-4a1f2d9c2a6b
Response status: 400
Response body:
{
  "error": {
    "code": "InvalidTemplate",
    "message": "The template resource 'Microsoft.Storage/storageAccounts' is not valid..."
  }
}
```

### Sanitized
```
Request URL: POST https://management.azure.com/subscriptions/<REDACTED_SUBSCRIPTION>/resourceGroups/<REDACTED_RG>/providers/Microsoft.Resources/deployments/<REDACTED_DEPLOYMENT>/validate?api-version=2021-04-01
Request headers:
  Authorization: Bearer <REDACTED_TOKEN>
  x-ms-client-request-id: <REDACTED>
Response status: 400
Response body:
{
  "error": {
    "code": "InvalidTemplate",
    "message": "The template resource 'Microsoft.Storage/storageAccounts' is not valid..."
  }
}
```

## Example 2 — JSON output with tokens and emails (raw)
```
{
  "accessToken": "ya29.A0ARrdaM...",
  "subscriptionId": "123e4567-e89b-12d3-a456-426614174000",
  "user": {
    "name": "alice@example.com",
    "type": "user"
  }
}
```

### Sanitized
```
{
  "accessToken": "<REDACTED_TOKEN>",
  "subscriptionId": "<REDACTED_GUID>",
  "user": {
    "name": "<REDACTED_EMAIL>",
    "type": "user"
  }
}
```

## Example 3 — AKS pod/cluster logs (raw)
```
E1123 12:34:56.789012  1234 kuberuntime_manager.go:111] ContainerStart failed for container "app" in pod "my-app-5d7f7d6b9-xyz12_default": rpc error: code = Unknown desc = failed to start container "app": Error response from daemon: pull access denied for myprivateregistry.azurecr.io/myapp:sha-256:abcdef1234567890, repository does not exist or may require 'docker login'
Node: aks-nodepool1-12345678-0 (10.240.0.4)
Pod IP: 10.244.0.12
ServiceAccount token: eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...
```

### Sanitized
```
E1123 12:34:56.789012  1234 kuberuntime_manager.go:111] ContainerStart failed for container "app" in pod "my-app-<REDACTED_POD_SUFFIX>_<REDACTED_NS>": rpc error: code = Unknown desc = failed to start container "app": Error response from daemon: pull access denied for <REDACTED_REGISTRY>/<REDACTED_IMAGE>:<REDACTED_SHA>, repository does not exist or may require 'docker login'
Node: <REDACTED_NODE>
Pod IP: <REDACTED_IP>
ServiceAccount token: <REDACTED_TOKEN>
```

## Example 4 — Function App host log (raw)
```
2025-11-03T14:22:11.123 [Information] Executing 'Functions.HttpTrigger' (Reason='This function was programmatically called via the host APIs.', Id=2f9b8c12-4bdc-4f7f-9e2b-1a2b3c4d5e6f)
Binding exception: Could not establish connection to DefaultEndpointsProtocol=https;AccountName=mystorageacct;AccountKey=ABCDEFG...;EndpointSuffix=core.windows.net
InvocationId: 2f9b8c12-4bdc-4f7f-9e2b-1a2b3c4d5e6f
```

### Sanitized
```
2025-11-03T14:22:11.123 [Information] Executing 'Functions.HttpTrigger' (Reason='Triggered via host APIs', Id=<REDACTED_INVOCATION_ID>)
Binding exception: Could not establish connection to DefaultEndpointsProtocol=https;AccountName=<REDACTED_STORAGE_ACCOUNT>;AccountKey=<REDACTED_KEY>;EndpointSuffix=core.windows.net
InvocationId: <REDACTED_INVOCATION_ID>
```

## Example 5 — Azure SQL connectivity error (raw)
```
Msg 18456, Level 14, State 1, Server mysqlserver.database.windows.net
Login failed for user 'sqladmin@contoso'. Client IP: 52.160.12.34
Connection string: Server=tcp:myserver.database.windows.net,1433;Initial Catalog=mydb;Persist Security Info=False;User ID=sqladmin@contoso;Password=VerySecret!;
```

### Sanitized
```
Msg 18456, Level 14, State 1, Server <REDACTED_SQL_SERVER>
Login failed for user '<REDACTED_USERNAME>'. Client IP: <REDACTED_IP>
Connection string: Server=tcp:<REDACTED_SQL_SERVER>,1433;Initial Catalog=<REDACTED_DB>;Persist Security Info=False;User ID=<REDACTED_USERNAME>;Password=<REDACTED_PASSWORD>;
```

## Notes
- The sanitizer scripts are conservative; always scan output for remaining identifiers.
- Watch for connection strings, service/principal emails, storage account names, and container registry references — redact them.
- If you see a GUID-like string, an IP, an email, or a connection string, replace it with `<REDACTED_GUID>`, `<REDACTED_IP>`, `<REDACTED_EMAIL>`, or `<REDACTED_CONNECTION>` respectively.
- Do not include full `az account get-access-token` output in reports; only include a note whether a token was present and its expiry if relevant.

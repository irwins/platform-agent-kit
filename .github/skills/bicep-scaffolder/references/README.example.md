# Example: Bicep module scaffold

This folder contains a minimal example module scaffold and example parameters.

Validate locally

```bash
# build
bicep build main.bicep
# run linter
bicep linter main.bicep
```

Deploy locally (example)

```bash
az group create -n rg-example -l eastus
az deployment group create -g rg-example --template-file main.json --parameters @parameters.json
```

Notes
- Use small defaults for parameters so test deployments cost little.
- Add `@secure()` to sensitive outputs and avoid printing secrets in CI logs.

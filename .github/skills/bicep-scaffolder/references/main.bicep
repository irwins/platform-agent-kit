@description('Short name for the app, used in resource names')
param shortAppName string = 'myapp'

@description('Deployment environment - e.g. dev|stg|prod')
param environment string = 'dev'

@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
@description('Storage account kind/sku - prefer minimal defaults')
param storageSku string = 'Standard_LRS'

var resourcePrefix = '${shortAppName}-${environment}-${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: '${resourcePrefix}st'
  location: resourceGroup().location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
}

output storageAccountId string = storageAccount.id


@description('Name of the Azure Container Registry')
param acrName string = 'acr-${uniqueString(resourceGroup().id)}'

param vaultName string = 'kv-${uniqueString(resourceGroup().id)}'

param servicePrincipalObjectId string = '00000000-0000-0000-0000-000000000000' // Replace with the actual object ID of the user or service principal

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: acrName
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: vaultName
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
        {
          tenantId: subscription().tenantId
          objectId: servicePrincipalObjectId
          permissions: {
            secrets: [
              'get'
              'list'
              'set'
            ]
          }
        }
    ]
  }
}

output acrLoginServer string = acr.properties.loginServer
output keyVaultUri string = keyVault.properties.vaultUri


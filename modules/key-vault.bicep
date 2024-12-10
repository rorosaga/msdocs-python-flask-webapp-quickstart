param name string
param location string = resourceGroup().location
param sku string = 'standard'
param enableVaultForDeployment bool = true

param roleAssignments array = [
  {
    principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
  }
]

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  properties: {
    enabledForDeployment: enableVaultForDeployment
    sku: {
      name: sku
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in roleAssignments: {
  name: guid(keyVault.id, role.principalId, role.roleDefinitionIdOrName)
  scope: keyVault
  properties: {
    principalId: role.principalId
    roleDefinitionId: role.roleDefinitionIdOrName
    principalType: role.principalType
  }
}]

output keyVaultId string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri

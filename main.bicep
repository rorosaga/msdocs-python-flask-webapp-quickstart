param userAlias string = 'rorosaga'
param location string = resourceGroup().location


// App Service Plan
param appServicePlanName string 

module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlan-${userAlias}'
  params: {
    name: appServicePlanName
    location: location
  }
}

// Key Vault
param keyVaultName string
param keyVaultRoleAssignments array

module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault-${userAlias}'
  params: {
    name: keyVaultName
    location: location
    roleAssignments: keyVaultRoleAssignments
  }
}

// Container Registry
param containerRegistryName string
param containerRegistryUsernameSecretName string 
param containerRegistryPassword0SecretName string 
param containerRegistryPassword1SecretName string 

module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistry-${userAlias}'
  params: {
    name: containerRegistryName
    location: location
    keyVaultResourceId: keyVault.outputs.keyVaultId
    usernameSecretName: containerRegistryUsernameSecretName
    password0SecretName: containerRegistryPassword0SecretName
    password1SecretName: containerRegistryPassword1SecretName
  }
}

// Container App Service
param containerName string
param dockerRegistryImageName string
param dockerRegistryImageVersion string

resource keyVaultReference 'Microsoft.KeyVault/vaults@2023-07-01'existing = {
  name: keyVaultName
}

module containerAppService 'modules/container-appservice.bicep' = {
  name: 'containerAppService-${userAlias}'
  params: {
    name: containerName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    registryName: containerRegistryName
    registryImageName: dockerRegistryImageName
    registryImageVersion: dockerRegistryImageVersion
    registryServerUserName: keyVaultReference.getSecret(containerRegistryUsernameSecretName)
    registryServerPassword: keyVaultReference.getSecret(containerRegistryPassword0SecretName)
  }
}



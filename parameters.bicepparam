using './main.bicep'

// App Service Plan
param appServicePlanName = 'appServicePlan'

// Key Vault
param keyVaultName = 'rorosaga-kv'
param keyVaultRoleAssignments = [
  {
    principalId: '25d8d697-c4a2-479f-96e0-15593a830ae5' // BCSAI2024-DEVOPS-STUDENTS-A-SP
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
  }
]

// Container Registry
param containerRegistryName = 'rorosagacr'
param containerRegistryUsernameSecretName = 'rorosaga-cr-username'
param containerRegistryPassword0SecretName = 'rorosaga-cr-password0'
param containerRegistryPassword1SecretName = 'rorosaga-cr-password1'

// Container App Service
param containerName = 'rorosaga-appservice'
param dockerRegistryImageName = 'rorosaga-dockerimg'
param dockerRegistryImageVersion = 'latest'

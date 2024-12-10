using './main.bicep'

// App Service Plan
param appServicePlanName = 'appServicePlan'

// Key Vault
param keyVaultName = 'rorosaga-kv'

// Container Registry
param containerRegistryName = 'rorosaga-cr'
param containerRegistryUsernameSecretName = 'rorosaga-cr-username'
param containerRegistryPassword0SecretName = 'rorosaga-cr-password0'
param containerRegistryPassword1SecretName = 'rorosaga-cr-password1'

// Container App Service
param containerName = 'rorosaga-appservice'
param dockerRegistryImageName = 'rorosaga-dockerimg'
param dockerRegistryImageVersion = 'latest'

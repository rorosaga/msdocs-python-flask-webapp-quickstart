## **Configuring Docker Application Locally**

### Step 1: Create a Dockerfile

```bash
touch Dockerfile
```
Example Dockerfile:
```Dockerfile
# syntax=docker/dockerfile:1
FROM python:3.11
WORKDIR /code
COPY requirements.txt .
RUN pip3 install -r requirements.txt
COPY . .
EXPOSE 50505
ENTRYPOINT ["gunicorn", "app:app"]
```

### Step 2: Create a .dockerignore file

```bash
touch .dockerignore
```

Example .dockerignore file:
```bash
.git*
**/*.pyc
.venv/
```

### Step 3: Configure gunicorn
```bash
touch gunicorn.conf.py
```

Example gunicorn.conf.py file:
```bash
# Gunicorn configuration file
import multiprocessing

max_requests = 1000
max_requests_jitter = 50

log_file = "-"

bind = "0.0.0.0:50505"

workers = (multiprocessing.cpu_count() * 2) + 1
threads = workers

timeout = 120
```

### Step 4: Build the Docker image

Build image:

```bash
docker build --tag flask-demo .
```
> Note: check the image is created by running `docker images`

```bash
docker run --detach --publish 5000:50505 flask-demo
```
> Note: check the container is running by running `docker ps`

In this case the application is running on port 5000, you can access it by visiting `http://localhost:5000` in your browser.

> Note: To stop the container run `docker stop <container_id>`


## **Deploy the infrastructure to Azure via GitHub Workflows**

```bash
mkdir modules
cd modules
```
Get modules from final project repo [here](https://github.com/ie-safebank/safebank-infra/tree/main/modules)

`container-registry.bicep` file:

```bicep

param name string
param location string = resourceGroup().location
param sku string = 'Basic'
param adminUserEnabled bool = true

#disable-next-line secure-secrets-in-params
param keyVaultResourceId string
param usernameSecretName string
#disable-next-line secure-secrets-in-params
param password0SecretName string
#disable-next-line secure-secrets-in-params
param password1SecretName string

// creates container registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
  }
}

// Reference the existing Key Vault
resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: last(split(keyVaultResourceId, '/')) // Extract the name from the resource ID
}

// Store the admin username in Key Vault
resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: usernameSecretName
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().username
  }
}

// Store the first admin password in Key Vault
resource secretAdminUserPassword0 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: password0SecretName
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
}

// Store the second admin password in Key Vault
resource secretAdminUserPassword1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: password1SecretName
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[1].value
  }
}

// Output values for verification (optional, avoid exposing sensitive data)
output containerRegistryName string = containerRegistry.name
output containerRegistryLoginServer string = containerRegistry.properties.loginServer

```

`app-service-plan.bicep` file:

```bicep
param location string = resourceGroup().location
param name string
param sku string = 'B1'

resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
  name: name
  location: location
  sku: {
    name: sku
    capacity: 1
    family: 'B'
    size: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name

```


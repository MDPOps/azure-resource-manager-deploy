// Inputs
@description('ContainerApp Name')
param containerAppName string

@description('ContainerAppsEnvironment Name')
param containerAppsEnvironmentName string

@description('ContainerRegistry Name')
param containerRegistryName string 

@description('ContainerRegistry Credentials')
@secure()
param containerRegistryCredentials object

@description('minReplicas')
param minReplicas string = ''

@description('maxReplicas')
param maxReplicas string = ''


// Variables
@description('sku=[Basic: 0.5 CPU, 1.0 RAM], [Standard: 1.0 CPU, 2.0 RAM], [Premium: 2.0 CPU, 4.0 RAM]')
@allowed(['Basic', 'Standard', 'Premium', ''])
param sku string = ''

var skuCPU = {
  Basic: '0.5'
  Standard: '1.0'
  Premium: '2.0'
}

var skuMemory = {
  Basic: '1.0Gi'
  Standard: '2.0Gi'
  Premium: '4.0Gi'
}

@description('location')
param location string = resourceGroup().location


// ContainerAppsEnvironment
resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerAppsEnvironmentName
}

// ContainerApp
resource containerApp 'Microsoft.App/containerApps@2023-05-01' =  {
  name: containerAppName
  location: location  
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id    
    configuration: {
      activeRevisionsMode: 'Single'  
      registries: [
        {
          server: '${containerRegistryName}.azurecr.io'
          username: containerRegistryCredentials.username
          passwordSecretRef: 'container-registry-credentials-password'
        }
      ]
      secrets: [
        {
          name: 'container-registry-credentials-password'
          value: containerRegistryCredentials.password
        }
      ]
      ingress: {
        external: true
        targetPort: 80
      }
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: containerRegistryCredentials.image
          resources: {
            cpu: json(!empty(sku) ? skuCPU[sku] : skuCPU.Basic)
            memory: !empty(sku) ? skuMemory[sku] : skuMemory.Basic
          }
        }
      ]
      scale: {
        minReplicas: !empty(minReplicas) ? int(minReplicas) : 0
        maxReplicas: !empty(maxReplicas) ? int(maxReplicas) : 1
      }
    }
  }
}


// Outputs
output id string = containerApp.id
output name string = containerApp.name
output principalId string = containerApp.identity.principalId
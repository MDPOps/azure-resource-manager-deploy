// Inputs
@description('ContainerAppsEnvironment Name')
param containerAppsEnvironmentName string = ''

@description('LogAnalyticsWorkspace Name')
param logAnalyticsWorkspaceName string


// Variables
@description('sku=[Basic: log-analytics], [Standard: log-analytics], [Premium: log-analytics]')
@allowed(['Basic', 'Standard', 'Premium', ''])
param sku string = ''

var skuDestination = {
  Basic: 'log-analytics'
  Standard: 'log-analytics'
  Premium: 'log-analytics'
}

@description('location')
param location string = resourceGroup().location


// LogAnalyticsWorkspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

// ContainerAppsEnvironment
resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: !empty(containerAppsEnvironmentName) ? containerAppsEnvironmentName : '${resourceGroup().name}-env' 
  location: location
  properties: {
    appLogsConfiguration: {
      destination: !empty(sku) ? skuDestination[sku] : skuDestination.Basic
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}


// Outputs
output id string = containerAppsEnvironment.id
output name string = containerAppsEnvironment.name
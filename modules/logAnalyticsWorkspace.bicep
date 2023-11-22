// Inputs
@description('LogAnalyticsWorkspace Name')
param logAnalyticsWorkspaceName string = ''


// Variables
@description('sku=[Basic: PerGB2018], [Standard: PerGB2018], [Premium: PerGB2018]')
@allowed(['Basic', 'Standard', 'Premium', ''])
param sku string = ''

var skuName = {
  Basic: 'PerGB2018'
  Standard: 'PerGB2018'
  Premium: 'PerGB2018'
}

@description('location')
param location string = resourceGroup().location


// LogAnalyticsWorkspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' =  {
  name: !empty(logAnalyticsWorkspaceName) ? logAnalyticsWorkspaceName : '${resourceGroup().name}-logs' 
  location: location
  properties: {
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: !empty(sku) ? skuName[sku] : skuName.Basic
    }
  }
}


// Outputs
output id string = logAnalyticsWorkspace.id
output name string = logAnalyticsWorkspace.name
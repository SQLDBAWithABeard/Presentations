targetScope = 'resourceGroup'

@minLength(5)
@maxLength(50)
@description('The name of the container registry - between 5 and 50 alphanumeric characters')
param name string
@description('The tags for the resource')
param tags object = {}

@allowed([
  'Classic'
  'Basic'
  'Standard'
])
@description('The Sku Name for the resource')
param skuName string

@description('Is the Admin User enabled')
param adminUserEnabled bool = false
@description('Enable a single data endpoint per region for serving data.')
param dataEndpointEnabled bool = false
@description('Enables registry-wide pull from unauthenticated clients.')
param anonymousPullEnabled bool = false
@allowed([
  'Enabled'
  'Disabled'
])
@description('Whether or not zone redundancy is enabled for this container registry')
param zoneRedundancy string = 'Disabled'

@allowed([
  'AzureServices'
  'None'
])
@description('Whether to allow trusted Azure services to access a network restricted registry. defaults to AzureServices - other option None')
param networkRuleBypassOptions string = 'AzureServices'

resource acr 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: name
  location: resourceGroup().location
  tags: tags
  sku: {
    name: skuName
  }

  properties: {
    adminUserEnabled: adminUserEnabled
    dataEndpointEnabled: dataEndpointEnabled
    networkRuleBypassOptions: networkRuleBypassOptions
    zoneRedundancy: zoneRedundancy
    anonymousPullEnabled: anonymousPullEnabled
  }
}

output loginServer string = acr.properties.loginServer
output username string = listCredentials(acr.id,'2020-11-01-preview').username
output password string = listCredentials(acr.id,'2020-11-01-preview').passwords[0].value

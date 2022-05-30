targetScope = 'resourceGroup'

@minLength(5)
@maxLength(50)
@description('The name of the container registry - between 5 and 50 alphanumeric characters')
param name string
@description('The tags for the resource')
param tags object = {}

@allowed([
  'Premium'
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
  'Enabled'
  'Disabled'
])
@description('Whether or not public network access is allowed for the container registry')
param publicNetworkAccess string = 'Disabled'

@allowed([
  'Allow'
  'Deny'
])
@description('The default action of allow or deny when no other network rules match.')
param networkDefaultAction string

@description('Array of objects specifying required IP rules -  value: Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed. action:	The action of virtual network rule. Allow ')
param ipRules array = []
@description('Array of objects specifying VNet Rules -  id: Resource ID of a subnet, action:	The action of virtual network rule. Allow ')
param virtualNetworkRules array = []

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
    networkRuleSet: {
      defaultAction: networkDefaultAction
      ipRules: ipRules
      virtualNetworkRules: virtualNetworkRules
    }
    dataEndpointEnabled: dataEndpointEnabled
    publicNetworkAccess: publicNetworkAccess
    networkRuleBypassOptions: networkRuleBypassOptions
    zoneRedundancy: zoneRedundancy
    anonymousPullEnabled: anonymousPullEnabled
  }
}

output loginServer string = acr.properties.loginServer

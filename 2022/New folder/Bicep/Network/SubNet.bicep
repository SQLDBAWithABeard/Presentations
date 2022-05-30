@minLength(1)
@maxLength(80)
@description('The subnet name - vNetName/subnetName')
param name string
@description('Address Prefix for this subnet in CIDR notation')
param addressPrefix string
@description('Designate a subnet to be used by a dedicated service wiht / eg Microsoft.Databricks/workspaces')
param delegations string = ''
@description('The name of the network security group to associate with the subnet')
param networkSecurityGroup string = ''
@description('The name of the network security group Resource Group to associate with the subnet')
param networkSecurityGroupResourceGroup string = ''
@description('The name of the routeTable to associate with the subnet')
param routeTable string = ''
@description('The name of the routeTable Resource Group to associate with the subnet')
param routeTableResourceGroup string = ''
@allowed([
  'Enabled'
  'Disabled'
])
@description('Enable or Disable apply network policies on private end point in the subnet.')
param privateEndpointNetworkPolicies string = 'Enabled'
@allowed([
  'Enabled'
  'Disabled'
])
@description('Enable or Disable apply network policies on private link service in the subnet.')
param privateLinkServiceNetworkPolicies string = 'Enabled'
@description('An array of serviceEndpoints for the subnets objects - service: Name ; locations: []')
param serviceEndpoints array = []
var serviceEndpointarray = [for serviceEndpoint in serviceEndpoints: {
  service: serviceEndpoint.service
  locations: serviceEndpoint.locations
}]

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: name
  properties: {
    addressPrefix: addressPrefix
    delegations: !empty(delegations) ? [
      {
        name: replace(delegations,'/','.') // Microsoft.Databricks.workspaces
        properties: {
          serviceName: delegations // Microsoft.Databricks/workspaces
        }
      }
    ] : []
    networkSecurityGroup: !empty(networkSecurityGroup) ? {
      id: !empty(networkSecurityGroupResourceGroup) ? resourceId(networkSecurityGroupResourceGroup,'Microsoft.Network/networkSecurityGroups',networkSecurityGroup) : resourceId('Microsoft.Network/networkSecurityGroups',networkSecurityGroup)
    } : null
    routeTable: !empty(routeTable) ? {
      id: !empty(routeTableResourceGroup) ? resourceId(routeTableResourceGroup,'Microsoft.Network/routeTables',routeTable) : resourceId('Microsoft.Network/routeTables',routeTable)
    } : null
    privateEndpointNetworkPolicies: privateEndpointNetworkPolicies
    privateLinkServiceNetworkPolicies: privateLinkServiceNetworkPolicies
    serviceEndpoints: serviceEndpointarray
  }
}

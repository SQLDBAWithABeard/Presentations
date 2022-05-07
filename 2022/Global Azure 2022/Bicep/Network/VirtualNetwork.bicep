targetScope = 'resourceGroup'

@minLength(2)
@maxLength(64)
@description('The name of the Virtual Network')
param name string
@description('The location - uses the resource group location by default')
param location string = ''
@description('A list of address blocks reserved for this virtual network in CIDR notation')
param addressPrefixes array
@description('An array of subnet objects - subnetName: Name ; addressPrefix: CIDR notation')
param subnets array
@description('An array of serviceEndpoints for the subnets objects - service: Name ; locations: []')
param serviceEndpoints array = []
var serviceEndpointarray = [for serviceEndpoint in serviceEndpoints: {
  service: serviceEndpoint.service
  locations: serviceEndpoint.locations
}]
@description('The tags for the VNet')
param tags object = {}

@description('Is DDoS protection is enabled for all the protected resources in the virtual network. It requires a DDoS protection plan associated with the resource.')
param enableDdosProtection bool = false
@description('Is VM protection is enabled for all the subnets in the virtual network')
param enableVmProtection bool = false
@description('The FlowTimeout value (in minutes) for the Virtual Network 0 to disable or between 4 minutes and 30 minutes (inclusive)')
param flowTimeoutInMinutes int = 0
@description('Array of DNS Server IP Addresses')
param dnsServers array = []

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: name
  location: !empty(location) ? location : resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [for addressPrefix in addressPrefixes: addressPrefix]
    }
    subnets: [for subnet in subnets: {
      name: subnet.subnetName
      properties: {
        addressPrefix: subnet.addressPrefix
        serviceEndpoints: serviceEndpointarray
      }
    }]
    enableDdosProtection: enableDdosProtection
    enableVmProtection: enableVmProtection
    flowTimeoutInMinutes: flowTimeoutInMinutes == 0 ? null : flowTimeoutInMinutes
    dhcpOptions: {
      dnsServers: dnsServers
    }

  }
  tags: tags
}

output vnetName string = virtualNetwork.name
output vnetID string = virtualNetwork.id
output vnetSubnets array = virtualNetwork.properties.subnets

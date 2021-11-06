targetScope = 'resourceGroup'
@minLength(1)
@maxLength(80)
@description('The name of the Network Interface')
param name string
@description('The location - uses the resource group location by default')
param location string = ''
@minLength(2)
@maxLength(64)
@description('The name of the Virtual Network')
param virtualNetwork string
@minLength(1)
@maxLength(90)
@description('The name of the Resource Group the vnet is in')
param virtualNetworkResourceGroupName string
@minLength(1)
@maxLength(80)
@description('The name of the subnet')
param subnetName string

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-06-01' =  {
  name: name
  location: !empty(location) ? location : resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${resourceId(virtualNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', virtualNetwork)}/subnets/${subnetName}'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}


output networkInterfaceId string = networkInterface.id
output networkInterfaceIpConfigurations array = networkInterface.properties.ipConfigurations

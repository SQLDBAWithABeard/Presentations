targetScope = 'resourceGroup'

@minLength(1)
@maxLength(80)
@description('The name of the public IP - Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore')
param name string

@description('The location - uses the resource group location by default')
param location string = ''

@description('The tags')
param tags object = {}

@allowed([
  'Basic'
  'Standard'
])
@description('Name of a public IP address SKU')
param skuName string = 'Basic'
@allowed([
  'Global'
  'Regional'
])
@description('Tier of a public IP address SKU')
param skuTier string = 'Regional'

@allowed([
  'Delete'
  'Detach'
])
@description('Specify what happens to the public IP address when the VM using it is deleted')
param deleteOption string = 'Delete'
@allowed([
  'IPv4'
  'IPv6'
])
@description('IP address version.')
param publicIPAddressVersion string = 'IPv4'
@allowed([
  'Dynamic'
  'Static'
])
@description('IP address allocation method.')
param publicIPAllocationMethod string = 'Dynamic'

resource publicIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: name
  location: !empty(location) ? location : resourceGroup().location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    deleteOption: deleteOption

    publicIPAddressVersion: publicIPAddressVersion
    publicIPAllocationMethod: publicIPAllocationMethod
  }
  zones: []
}

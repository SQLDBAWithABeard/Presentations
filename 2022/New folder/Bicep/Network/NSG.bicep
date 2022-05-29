@minLength(1)
@maxLength(80)
@description('The name of the NSG')
param name string

@description('The location - uses the resource group location by default')
param location string = ''

@description('The tags')
param tags object = {}

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: name
  location: !empty(location) ? location : resourceGroup().location
  tags: tags
  properties:{
    securityRules:[]
  }
}

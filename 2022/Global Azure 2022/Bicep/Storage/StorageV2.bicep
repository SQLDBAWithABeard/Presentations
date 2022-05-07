targetScope = 'resourceGroup'

@minLength(3)
@maxLength(24)
@description('The name of the storage account -3-24	Lowercase letters and numbers.')
param name string
@description('The location - uses the resource group location by default')
param location string = resourceGroup().location

@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
@description('The name of the sku for the storage account')
param skuName string
@description('Account HierarchicalNamespace enabled - This allows the collection of objects/files within an account to be organized into a hierarchy of directories and nested subdirectories in the same way that the file system on your computer is organized. With a hierarchical namespace enabled, a storage account becomes capable of providing the scalability and cost-effectiveness of object storage, with file system semantics that are familiar to analytics engines and frameworks')
param isHnsEnabled bool
@description('Allows https traffic only to storage service')
param supportsHttpsTrafficOnly bool = true
// @description('Allow or disallow public access to all blobs or containers in the storage account')
// param allowBlobPublicAccess bool = false
@description('ndicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD')
param allowSharedKeyAccess bool = false
@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
@description('Set the minimum TLS version to be permitted on requests to storage')
param minimumTlsVersion string = 'TLS1_2'
@allowed([
  'AzureServices'
  'Logging'
  'Metrics'
  'None'
])
@description('Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging|Metrics|AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics.')
param networkAclsBypass string
@description('An array of allowed ResourceGroup/VirtualNetwork/Subnet for access to the storage account')
param rgVirtualNetworksSubnets array
var virtualNetworkRules = [for allowed in rgVirtualNetworksSubnets: {
  id: resourceId(first(split(allowed, '/')), 'Microsoft.Network/virtualNetworks/subnets',substring(allowed, indexOf(allowed, '/') + 1, (lastIndexOf(allowed, '/') - indexOf(allowed, '/')) -1) , last(split(allowed, '/')))
  action: 'Allow'
}]
@allowed([
  'Allow'
  'Deny'
])
@description('Specifies the default action of allow or deny when no other rules match.')
param defaultAction string = 'Deny'
@allowed([
  'Cool'
  'Hot'
])
@description('The access tier used for billing')
param accessTier string = 'Hot'
param tags object = {}

resource storage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: name
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: isHnsEnabled
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowBlobPublicAccess: true
    allowSharedKeyAccess: allowSharedKeyAccess
    minimumTlsVersion: minimumTlsVersion

    networkAcls: {
      bypass: networkAclsBypass
      virtualNetworkRules: virtualNetworkRules
      defaultAction: defaultAction
    }
    accessTier: accessTier
  }
  tags: tags
}

output storageID string = storage.id
output storagePrimaryEndpoints object = storage.properties.primaryEndpoints
output storagenetworkAcls object = storage.properties.networkAcls

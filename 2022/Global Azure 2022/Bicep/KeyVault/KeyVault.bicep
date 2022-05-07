targetScope = 'resourceGroup'
@minLength(3)
@maxLength(24)
@description('The name of the key vault - between 3 and 24 alphanumeric characters and hyphens')
param name string
@description('The Tags for the resource')
param tags object = {}
@description('The location for the Key Vault - defaults to the resource group location')
param location string = ''
@allowed([
  'premium'
  'standard'
])
@description('The Sku Name for the resource - default sto standard')
param skuName string = 'standard'
@description('specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = false
@description('specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = false
@description('specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = false
@description('specify whether the soft delete functionality is enabled for this key vault. If its not set to any value(true or false) when creating new key vault, it will be set to true by default. Once set to true, it cannot be reverted to false')
param enableSoftDelete bool = true
@minValue(7)
@maxValue(90)
@description('softDelete data retention days. Between 7 and 90')
param softDeleteRetentionInDays int = 90 
@description('controls how data actions are authorized. When true, the key vault will use Role Based Access Control (RBAC) for authorization of data actions, and the access policies specified in vault properties will be ignored (warning: this is a preview feature). When false, the key vault will use the access policies specified in vault properties, and any policy stored on Azure Resource Manager will be ignored. If null or not specified, the vault is created with the default value of false. Note that management actions are always authorized with RBAC.')
param enableRbacAuthorization bool = false
@allowed([
  'default'
  'recover'
])
@description('The vaults create mode to indicate whether the vault need to be recovered or not.')
param createMode string = 'default' 
@description('whether protection against purge is enabled for this vault. Setting this property to true activates protection against purge for this vault and its content - only the Key Vault service may initiate a hard, irrecoverable deletion. The setting is effective only if soft delete is also enabled. Enabling this functionality is irreversible - that is, the property does not accept false as its value.')
param enablePurgeProtection bool = true
@allowed([
  'AzureServices'
  'None'
])
@description('Tells what traffic can bypass network rules. This can be AzureServices or None. If not specified the default is AzureServices.')
param networkAclsBypass string = 'None' 
@allowed([
  'Allow'
  'Deny'
])
@description('	The default action when no rule from ipRules and from virtualNetworkRules match. This is only used after the bypass property has been evaluated.')
param networkAclsDefaultAction string = 'Deny' 

@description('Array of objects specifying required IP rules -  value: Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed. action:	The action of virtual network rule. Allow ')
param ipRules array = []
@description('Array of objects specifying VNet Rules -  id: Resource ID of a subnet, action:	The action of virtual network rule. Allow ')
param virtualNetworkRules array = []

resource keyvault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: name
  location: location == '' ? resourceGroup().location : location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: skuName
    }
    accessPolicies: []
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: enableRbacAuthorization
    createMode: createMode
    enablePurgeProtection: enablePurgeProtection == true ? true : null
    networkAcls: {
      bypass: networkAclsBypass
      virtualNetworkRules: virtualNetworkRules
      defaultAction: networkAclsDefaultAction
      ipRules: ipRules
    }
  }
}

output kvresource string = keyvault.id
output kvname string = keyvault.name

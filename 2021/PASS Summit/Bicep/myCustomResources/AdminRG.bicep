targetScope = 'subscription'

var tags = {
  Role: 'administration'
  Bicep: true
  Demo: 'Correct - this is demo'
}
var resourceGroupName = 'beard-admin-rg'

module adminResourceGroup '../ResourceGroup.bicep' = {
  name: 'admin-rg-deployment'
  params: {
    location: 'uksouth'
    name: resourceGroupName
    tags: tags
  }
}

module adminKeyVault '..//KeyVault/keyvault.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: 'keyvault-deployment'
  params: {
    name: 'beardy-admin-kv'
    skuName: 'standard'
    tags: tags
    networkAclsDefaultAction: 'Allow' // becasue this is demo
  }
  dependsOn: [
    adminResourceGroup
  ]
}

// permissions for the Rob 
module adminKeyVaultPermissions '../KeyVault/KeyVaultaccessPolicies.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: 'AdminOwnersPermissions'
  params: {
    keyVault: adminKeyVault.outputs.kvname
    objectid: '33bd0624-48e3-467e-9341-7e2ed3a50cab'
    certificatePermissions: [
      'all'
    ]
    keyPermissions: [
      'all'
    ]
    secretPermissions: [
      'all'
    ]
    storagePermissions: [
      'all'
    ]
  }
  dependsOn: [
    adminKeyVault
  ]
}

module containerregistry '..//ContainerRegistry/containerregistry.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: 'ContainerRegistry-Deployment'
  params: {
    name: 'bearddemoacr'
    skuName: 'Standard'
    tags: tags
    adminUserEnabled: true
    anonymousPullEnabled: true
  }
  dependsOn: [
    adminResourceGroup
  ]
}

module loginserversecret '..//KeyVault/KeyVaultSecret.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: 'loginserversecret-deployment'
  params: {
    contentType: 'The bearddemoacr login server'
    name: '${adminKeyVault.outputs.kvname}/bearddemoacr-loginserver'
    value: containerregistry.outputs.loginServer
  }
  dependsOn: [
    adminKeyVault
    containerregistry
  ]
}

module acrusername '../KeyVault/KeyVaultSecret.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: 'acrusernamesecret-deployment'
  params: {
    contentType: 'The bearddemoacr username'
    name: '${adminKeyVault.outputs.kvname}/bearddemoacr-username'
    value: containerregistry.outputs.username
  }
  dependsOn: [
    loginserversecret
  ]
}

module acrpassword '../KeyVault/KeyVaultSecret.bicep' = {
  scope: az.resourceGroup(resourceGroupName)
  name: 'acrpasswordsecret-deployment'
  params: {
    contentType: 'The bearddemoacr password'
    name: '${adminKeyVault.outputs.kvname}/bearddemoacr-password'
    value: containerregistry.outputs.password
  }
  dependsOn: [
    acrusername
  ]
}

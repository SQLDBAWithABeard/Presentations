targetScope = 'subscription'

var tags = {
  role: 'production admin'
  owner: 'Beardy McBeardFace'
  budget: 'Ben Weissman personal account'
  bicep: true
  BenIsAwesome: 'Always'
}
var scope = az.resourceGroup('PassBeard-Admin')

module resourceGroup '../ResourceGroup.bicep' = {
  name: 'Deploy-Admin-Rg-PassBeard-Admin'
  params: {
    location: 'uksouth'
    name: 'PassBeard-Admin'
    tags: tags
  }
}

module loganalytics '../LogAnalytics/LogAnalytics.bicep' = {
  scope: scope
  name: 'LogAnalytics-beard-diag'
  params: {
    name: 'beard-diag'
    retentionDays: 90
    tags: tags
  }
  dependsOn:[
    resourceGroup
  ]
}

module keyvault '../KeyVault/KeyVault.bicep' = {
  scope: scope
  name: 'Key-vault-passbeard-kv'
  params: {
    name: 'passbeard-kv'
    tags: tags
    enableSoftDelete: false  // because demo
    enablePurgeProtection: false // because demo
  }
  dependsOn:[
    resourceGroup
  ]
}

// Robs KeyVault Permissions

module kvpermsrob '../KeyVault/KeyVaultAccessPolicies.bicep' = {
  scope: scope
  name: 'robs-kv-perms'
  params: {
    keyVault: keyvault.outputs.kvname
    objectid: '33bd0624-48e3-467e-9341-7e2ed3a50cab'
    certificatePermissions: [
      'all'
    ]
    keyPermissions: [
      'all'
    ]
    secretPermissions:  [
      'all'
    ]
    storagePermissions:  [
      'all'
    ]
  }
  dependsOn:[
    keyvault
  ]
}

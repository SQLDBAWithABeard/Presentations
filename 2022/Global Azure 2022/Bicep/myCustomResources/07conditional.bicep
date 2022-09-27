// this will deploy with modules

@minLength(1)
@maxLength(63)
@description('The name of the SQL server - Lowercase letters, numbers, and hyphens.Cant start or end with hyphen.')
param name string

@description('The location for the SQL Server')
param location string

@description('The name of the administrator login')
param administratorLogin string

@description('The password for the SQL Server Administratoe')
@secure()
param administratorLoginPassword string

@allowed([
  'dev'
  'test'
  'prod'
])
@description('The environment that is being deployed')
param environment string

@description('The name of the database')
param databasename string

@description('The name of the workspace')
param workspaceName string = ''

@description('The resource group the workspace is in defautls to deployment resource group')
param workspaceResourceGroup string = ''

var tags = {
  role: 'production admin'
  owner: 'Beardy McBeardFace'
  budget: 'Ben Weissman personal account'
  bicep: true
  BenIsAwesome: 'Always'
}

module sqlserver '../Data/sqlserver.bicep' = {
  name: 'Deploy_${environment}_the_SQL_Server'
  params: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    location: location
    name: '${name}-${environment}'
    tags: tags
  }
}

module sqldatabase '../Data/database.bicep' = {
  name: 'Deploy_${environment}_The_Database'
  params: {
    sqlServerName: '${name}-${environment}'
    location: location
    name: databasename
    environment: environment
    workspaceName: workspaceName
    workspaceResourceGroup: workspaceResourceGroup
  }
  dependsOn: [
    sqlserver
  ]
}

resource KeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: 'AzureBeard-kv'
  scope: resourceGroup('AzureBeard-Admin')
}

module adminpwdtokev '../KeyVault/KeyVaultSecret.bicep' = {
  name: 'admin-pwd-to-kv-${environment}'
  scope: resourceGroup('AzureBeard-Admin')
  params: {
    contentType: 'The password for the ${name}-${environment} SQL Server'
    name: '${KeyVault.name}/${name}-${environment}-admin-pwd'
    value: administratorLoginPassword
    tags: tags
  }
}

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

var tags = {
  role: 'Azure SQL'
  owner: 'Beardy McBeardFace'
  budget: 'Ben Weissman personal account'
  bicep: true
  BenIsAwesome: 'Always'
}

@description('the name of the storage account')
param storagename string

module sqlserver '../Data/sqlserver.bicep' = {
  name: 'Deploy_the_${name}_SQL_Server'
  params: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    location: location
    name: name
    tags: tags
  }
}

output thesqlserver string = sqlserver.outputs.sqlservername

module storage '../Storage/StorageV2.bicep' = {
  name: 'deploy-storage-${storagename}'
  params: {
    location: location
    isHnsEnabled: false
    name: storagename
    networkAclsBypass: 'AzureServices'
    rgVirtualNetworksSubnets: []
    skuName: 'Standard_LRS'
  }
}

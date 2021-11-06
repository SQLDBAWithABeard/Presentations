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

@description('The name of databases to create ')
param databaseNames array

module sqlserver '../Data/sqlserver.bicep' = {
  name: 'Deploy_the_${name}_SQL_Server'
  params: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    location: location
    name: name
  }
}

module sqldatabase '../Data/database.bicep' = [for databaseName in databaseNames: {
  name: 'Deploy_The_${databaseName}_Database'
  params: {
    sqlServerName: name
    location: location
    name: databaseName
  }
  dependsOn: [
    sqlserver
  ]
}]

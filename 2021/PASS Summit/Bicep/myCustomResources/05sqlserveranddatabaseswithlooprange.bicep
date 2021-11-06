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

@description('The name of the database')
param databasename string 

@description('The number of databases to create - these will be named databasename-X where databasename is the parameter and X is the number')
param numberOfDatabases int

module sqlserver '../Data/sqlserver.bicep' = {
  name: 'Deploy_the_${name}_SQL_Server'
  params: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    location: location
    name: name
  }
}

module sqldatabase '../Data/database.bicep' = [for x in range(0, numberOfDatabases): {
  name: 'Deploy_The_${databasename}-${x}_Database'
  params: {
    sqlServerName: name
    location: location
    name: '${databasename}-${x}'
  }
  dependsOn: [
    sqlserver
  ]
}]

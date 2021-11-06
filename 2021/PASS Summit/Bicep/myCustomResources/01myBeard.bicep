resource sqlserver 'Microsoft.Sql/servers@2021-05-01-preview' = {
  name: 'beardsqlserver1'
  location: 'uksouth'
  properties: {
    administratorLogin: 'jeremy'
    administratorLoginPassword: 'dbatoolsIsAwe$some'
  }
}

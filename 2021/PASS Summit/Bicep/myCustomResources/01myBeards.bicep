resource sqlserver 'Microsoft.Sql/servers@2021-05-01-preview' = {
  name: 'beardsqlserver11'
  location: 'uksouth'
  properties: {
    administratorLogin: 'jermey'
    administratorLoginPassword: 'dbatoolsIsAwe$some'
  }
}

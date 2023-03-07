resource sqlserver 'Microsoft.Sql/servers@2021-05-01-preview' = {
  name: 'beardsqlserver11'
  location: 'eastus'
  properties: {
    administratorLogin: 'jermey'
    administratorLoginPassword: 'dbatoolsIsAwe$some'
  }
  tags: {
    role: 'Azure SQL'
    owner: 'Beardy McBeardFace'
    budget: 'Ben Weissman personal account'
    bicep: 'true'
    BenIsAwesome: 'Always'
  }
}

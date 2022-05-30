resource sqlserver 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: 'beardsqlserver1'
  location: 'eastus'
  properties: {
    administratorLogin: 'jeremy'
    administratorLoginPassword: 'dbatoolsIsAwe$some'
  }
  tags: {
    role: 'Azure SQL'
    owner: 'Beardy McBeardFace'
    budget: 'Ben Weissman personal account'
    bicep: 'true'
    BenIsAwesome: 'Always'
    WhichConference: 'GlobalAzure'
  }
}

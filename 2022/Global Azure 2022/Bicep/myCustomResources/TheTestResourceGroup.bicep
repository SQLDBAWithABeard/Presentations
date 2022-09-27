targetScope = 'subscription'

var tags = {
  Role: 'demo'
  Bicep: true 
}
var resourceGroupName = 'demo-rg'

module testResourceGroup 'br:bearddemoacr.azurecr.io/bicep/resourcegroup:0.0.1' = {
  name: 'test-rg-deployment'
  params: {
    location: 'eastus'
    name: resourceGroupName
    tags: tags
  }
}

// I am adding a comment for the pipeline  

module storage 'br:bearddemoacr.azurecr.io/bicep/storage/storagev2:0.0.2' = {
  scope: az.resourceGroup(resourceGroupName)
  name: 'ateststorage-deployment'
  params: {
    isHnsEnabled: false
    name: 'ateststorage01234567'
    networkAclsBypass: 'None'
    rgVirtualNetworksSubnets: [
      
    ]
    skuName: 'Standard_LRS'
  }
  dependsOn:[
  testResourceGroup
  ]
}

targetScope = 'subscription'
@minLength(1)
@maxLength(90)
@description('The name of the Resource Group')
param rgname string = 'beardy-VMs'
param rglocation string = 'eastus'

@maxLength(64)
@description('the name of the VM')
param vmname string = 'BeardyVM'

@description('the number of Vms to create')
param vmCount int = 2

@minLength(2)
@maxLength(64)
@description('The name of the Virtual Network')
param virtualNetwork string = 'beardvnet'

@minLength(1)
@maxLength(90)
@description('The name of the Resource Group the vnet is in')
param virtualNetworkResourceGroupName string = 'beardedresourcegroup'

@minLength(1)
@maxLength(80)
@description('The name of the subnet')
param subnetName string = 'public'

@minLength(1)
@maxLength(80)
@description('The name of the public IP - Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore')
param publicIPName string = 'beardyvmpublicIP'

@description('The Admin user  name for the machine This property cannot be updated after the VM is created. Windows-only restriction: Cannot end in "." Disallowed values: "administrator", "admin", "user", "user1", "test", "user2", "test1", "user3", "admin1", "1", "123", "a", "actuser", "adm", "admin2", "aspnet", "backup", "console", "david", "guest", "john", "owner", "root", "server", "sql", "support", "support_388945a0", "sys", "test2", "test3", "user4", "user5".')
param adminUsername string = 'jeremy'
@secure()
@description('The password of the admin account - min 3 max 123 - Complexity requirements: 3 out of 4 conditions below need to be fulfilled Has lower characters Has upper characters Has a digit Has a special character Disallowed values: "abc@123", "P@$$w0rd", "P@ssw0rd", "P@ssword123", "Pa$$word", "pass@word1", "Password!", "Password1", "Password22", "iloveyou!" ')
param adminPassword string

@description('the image sku')
param sku string = '2022-datacenter'

@description('the size of the VM')
param vmSize string = 'Standard_A4_v2'

@description('The name of the NSG')
param networkSecurityGroup string = 'gandalf'

module  resourceGroup '../ResourceGroup.bicep' = {
  name: '${rgname}-deploy'
  params: {
    location: rglocation
    name: rgname
  }
}

module publicIPAddress '../Network/PublicIPAddress.bicep' = [for PublicIP in range(0,vmCount): {
  scope: az.resourceGroup(rgname)
  name: '${vmname}-PublicIP-${PublicIP}-deploy'
  params: {
    name: '${publicIPName}-${PublicIP}'
  }
  dependsOn:[
    resourceGroup
  ]
}]

module NetworkInterface '../Network/NetworkInterfacePublicIpNSG.bicep' = [for nic in range(0,vmCount):  {
  scope: az.resourceGroup(rgname)
  name: 'NIC-${nic}-deploy'
  params: {
    name: 'NIC-${nic}'
    subnetName: subnetName
    virtualNetwork: virtualNetwork
    virtualNetworkResourceGroupName: virtualNetworkResourceGroupName
    publicIpAddressName: '${publicIPName}-${nic}'
    networkSecurityGroup: networkSecurityGroup
    networkSecurityGroupResourceGroup: virtualNetworkResourceGroupName
  }
  dependsOn:[
    publicIPAddress
  ]
}]

module VirtualMachine '../Compute/WindowsVirtualMachineWithDataDisks.bicep' = [for vm in range(0,vmCount): {
  scope: az.resourceGroup(rgname)
  name: '${vmname}-${vm}-VM-deploy'
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    bootDiagnosticsenabled: false
    name: '${vmname}-${vm}'
    nicNames: [
      'NIC-${vm}'
    ]
    sku: sku
    vmSize: vmSize
  }
  dependsOn:[
    publicIPAddress
    NetworkInterface
  ]
}]

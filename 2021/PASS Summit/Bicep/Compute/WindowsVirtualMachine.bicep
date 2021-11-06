targetScope = 'resourceGroup'

@maxLength(64)
@description('the name of the reosurce')
param name string
@description('The location - uses the resource group location by default')
param location string = ''
@description('The tags')
param tags object = {}
@allowed([
  'Basic_A0'
  'Basic_A1'
  'Basic_A2'
  'Basic_A3'
  'Basic_A4'
  'Standard_A0'
  'Standard_A1'
  'Standard_A10'
  'Standard_A11'
  'Standard_A1_v2'
  'Standard_A2'
  'Standard_A2_v2'
  'Standard_A2m_v2'
  'Standard_A3'
  'Standard_A4'
  'Standard_A4_v2'
  'Standard_A4m_v2'
  'Standard_A5'
  'Standard_A6'
  'Standard_A7'
  'Standard_A8'
  'Standard_A8_v2'
  'Standard_A8m_v2'
  'Standard_A9'
  'Standard_B1ms'
  'Standard_B1s'
  'Standard_B2ms'
  'Standard_B2s'
  'Standard_B4ms'
  'Standard_B8ms'
  'Standard_D1'
  'Standard_D11'
  'Standard_D11_v2'
  'Standard_D12'
  'Standard_D12_v2'
  'Standard_D13'
  'Standard_D13_v2'
  'Standard_D14'
  'Standard_D14_v2'
  'Standard_D15_v2'
  'Standard_D16_v3'
  'Standard_D16s_v3'
  'Standard_D1_v2'
  'Standard_D2'
  'Standard_D2_v2'
  'Standard_D2_v3'
  'Standard_D2s_v3'
  'Standard_D3'
  'Standard_D32_v3'
  'Standard_D32s_v3'
  'Standard_D3_v2'
  'Standard_D4'
  'Standard_D4_v2'
  'Standard_D4_v3'
  'Standard_D4s_v3'
  'Standard_D5_v2'
  'Standard_D64_v3'
  'Standard_D64s_v3'
  'Standard_D8_v3'
  'Standard_D8s_v3'
  'Standard_DS1'
  'Standard_DS11'
  'Standard_DS11_v2'
  'Standard_DS12'
  'Standard_DS12_v2'
  'Standard_DS13'
  'Standard_DS13-2_v2'
  'Standard_DS13-4_v2'
  'Standard_DS13_v2'
  'Standard_DS14'
  'Standard_DS14-4_v2'
  'Standard_DS14-8_v2'
  'Standard_DS14_v2'
  'Standard_DS15_v2'
  'Standard_DS1_v2'
  'Standard_DS2'
  'Standard_DS2_v2'
  'Standard_DS3'
  'Standard_DS3_v2'
  'Standard_DS4'
  'Standard_DS4_v2'
  'Standard_DS5_v2'
  'Standard_E16_v3'
  'Standard_E16s_v3'
  'Standard_E2_v3'
  'Standard_E2s_v3'
  'Standard_E32-16_v3'
  'Standard_E32-8s_v3'
  'Standard_E32_v3'
  'Standard_E32s_v3'
  'Standard_E4_v3'
  'Standard_E4s_v3'
  'Standard_E64-16s_v3'
  'Standard_E64-32s_v3'
  'Standard_E64_v3'
  'Standard_E64s_v3'
  'Standard_E8_v3'
  'Standard_E8s_v3'
  'Standard_F1'
  'Standard_F16'
  'Standard_F16s'
  'Standard_F16s_v2'
  'Standard_F1s'
  'Standard_F2'
  'Standard_F2s'
  'Standard_F2s_v2'
  'Standard_F32s_v2'
  'Standard_F4'
  'Standard_F4s'
  'Standard_F4s_v2'
  'Standard_F64s_v2'
  'Standard_F72s_v2'
  'Standard_F8'
  'Standard_F8s'
  'Standard_F8s_v2'
  'Standard_G1'
  'Standard_G2'
  'Standard_G3'
  'Standard_G4'
  'Standard_G5'
  'Standard_GS1'
  'Standard_GS2'
  'Standard_GS3'
  'Standard_GS4'
  'Standard_GS4-4'
  'Standard_GS4-8'
  'Standard_GS5'
  'Standard_GS5-16'
  'Standard_GS5-8'
  'Standard_H16'
  'Standard_H16m'
  'Standard_H16mr'
  'Standard_H16r'
  'Standard_H8'
  'Standard_H8m'
  'Standard_L16s'
  'Standard_L32s'
  'Standard_L4s'
  'Standard_L8s'
  'Standard_M128-32ms'
  'Standard_M128-64ms'
  'Standard_M128ms'
  'Standard_M128s'
  'Standard_M64-16ms'
  'Standard_M64-32ms'
  'Standard_M64ms'
  'Standard_M64s'
  'Standard_NC12'
  'Standard_NC12s_v2'
  'Standard_NC12s_v3'
  'Standard_NC24'
  'Standard_NC24r'
  'Standard_NC24rs_v2'
  'Standard_NC24rs_v3'
  'Standard_NC24s_v2'
  'Standard_NC24s_v3'
  'Standard_NC6'
  'Standard_NC6s_v2'
  'Standard_NC6s_v3'
  'Standard_ND12s'
  'Standard_ND24rs'
  'Standard_ND24s'
  'Standard_ND6s'
  'Standard_NV12'
  'Standard_NV24'
  'Standard_NV6'
])
@description('the size of the VM')
param vmSize string
@maxLength(15)
@description('The host name')
param computerName string = name
@description('The Admin user  name for the machine This property cannot be updated after the VM is created. Windows-only restriction: Cannot end in "." Disallowed values: "administrator", "admin", "user", "user1", "test", "user2", "test1", "user3", "admin1", "1", "123", "a", "actuser", "adm", "admin2", "aspnet", "backup", "console", "david", "guest", "john", "owner", "root", "server", "sql", "support", "support_388945a0", "sys", "test2", "test3", "user4", "user5".')
param adminUsername string
@secure()
@minLength(3)
@maxLength(123)
@description('The password of the admin account - Complexity requirements: 3 out of 4 conditions below need to be fulfilled Has lower characters Has upper characters Has a digit Has a special character Disallowed values: "abc@123", "P@$$w0rd", "P@ssw0rd", "P@ssword123", "Pa$$word", "pass@word1", "Password!", "Password1", "Password22", "iloveyou!" ')
param adminPassword string
@description('The image publisher')
param publisher string = 'MicrosoftWindowsServer'
@description('The image offer')
param offer string = 'WindowsServer'
@description('the image sku')
param sku string
@description('Specifies the version of the platform image or marketplace image used to create the virtual machine. The allowed formats are Major.Minor.Build or latest. Major, Minor, and Build are decimal numbers. Specify latest to use the latest version of an image available at deploy time. Even if you use latest, the VM image will not automatically update after deploy time even if a new version becomes available')
param version string = 'latest'
@description('The OS disk name')
param osDiskName string = 'osdisk'
@allowed([
  'None'
  'ReadOnly'
  'ReadWrite'
])
@description('Specifies the caching requirements. Possible values are: None ReadOnly ReadWrite Default: None for Standard storage. ReadOnly for Premium storage')
param osDiskCaching string = 'ReadWrite'
@allowed([
  'Attach'
  'FromImage'
])
@description('Specifies how the virtual machine should be created. Possible values are: Attach  This value is used when you are using a specialized disk to create the virtual machine. FromImage  This value is used when you are using an image to create the virtual machine. If you are using a platform image, you also use the imageReference element described above. If you are using a marketplace image, you also use the plan element previously described.')
param osDiskCreateOption string = 'FromImage'
@description('The names of the NICs to attach to the Virtual Machine ')
param nicNames array
@description('Whether boot diagnostics should be enabled')
param bootDiagnosticsenabled bool
@description('boot dignostics storage account name')
param bootDiagnosticsstorageAccountName string

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: name
  location: !empty(location) ? location : resourceGroup().location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: computerName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: publisher
        offer: offer
        sku: sku
        version: version
      }
      osDisk: {
        name: osDiskName
        caching: osDiskCaching
        createOption: osDiskCreateOption
      }
    }
    networkProfile: {
      networkInterfaces: [for nicName in nicNames: {
        id: resourceId('Microsoft.Network/networkInterfaces', nicName)
      }]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: bootDiagnosticsenabled
        storageUri: bootDiagnosticsenabled == true ? 'https://${bootDiagnosticsstorageAccountName}.blob.${environment().suffixes.storage}' : ''
      }
    }
  }
}

output vmID string = windowsVM.id
output vmObject object = windowsVM.properties

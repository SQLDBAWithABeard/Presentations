@description('The name of the key vault to store the secret in')
param keyVault string
@description('The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies.')
param objectid string
@allowed([
  'all'
  'backup'
  'create'
  'decrypt'
  'delete'
  'encrypt'
  'get'
  'import'
  'list'
  'purge'
  'recover'
  'release'
  'restore'
  'sign'
  'unwrapKey'
  'update'
  'verify'
  'wrapKey'
])
@description('Permissions to keys')
param keyPermissions array = []
@allowed([
  'all'
  'backup'
  'delete'
  'get'
  'list'
  'purge'
  'recover'
  'restore'
  'set'
])
@description('Permissions to secrets')
param secretPermissions array = []
@allowed([
  'all'
  'backup'
  'create'
  'delete'
  'deleteissuers'
  'get'
  'getissuers'
  'import'
  'list'
  'listissuers'
  'managecontacts'
  'manageissuers'
  'purge'
  'recover'
  'restore'
  'setissuers'
  'update'
])
@description('Permissions to certificates')
param certificatePermissions array = []
@allowed([
  'all'
  'backup'
  'delete'
  'deletesas'
  'get'
  'getsas'
  'list'
  'listsas'
  'purge'
  'recover'
  'regeneratekey'
  'restore'
  'set'
  'setsas'
  'update'
])
@description('Permissions to storage accounts')
param storagePermissions array = []

resource keyvaultpermissions 'Microsoft.KeyVault/vaults/accessPolicies@2021-04-01-preview' = {
  name: '${keyVault}/add'
  properties: {
    accessPolicies: [
      {
        objectId: objectid
        permissions: {
          keys: keyPermissions
          secrets: secretPermissions
          certificates: certificatePermissions
          storage: storagePermissions
        }
        tenantId: subscription().tenantId
      }
    ]
  }
}

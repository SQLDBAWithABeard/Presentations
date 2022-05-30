@minLength(1)
@maxLength(127)
@description('The name of the secret - between 1 and 127 alphanumeric characters and hyphens')
param name string
@description('The tags for the resource')
param tags object = {}
@description('The content type of the secret.')
param contentType string
@secure()
param value string
@description('Determines whether the object is enabled. default true')
param enabled bool = true
@description('Expiry date in seconds since 1970-01-01T00:00:00Z. No default')
param expiry int = 0
@description('Not before date in seconds since 1970-01-01T00:00:00Z. No default')
param notBefore int = 0

resource keyvaultsecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: name
  tags: tags
  properties: {
    contentType: contentType
    value: value
    attributes: {
      enabled: enabled
      exp: expiry == 0 ? null : expiry
      nbf: notBefore == 0 ? null : notBefore
    }
  }
}

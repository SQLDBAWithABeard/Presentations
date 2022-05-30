@minLength(4)
@maxLength(63)
@description('The name of the Log Analytics Workspace - Alphanumerics and hyphens. Start and end with alphanumeric.')
param name string
@description('The location for the Log Analystics - defaults to Resource Group Location')
param location string = ''
@description('The workspace data retention in days. Allowed values are per pricing plan. See pricing tiers documentation for details.')
param retentionDays int
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
@description('The sku Name for the workspace defaults to pay as you go')
param skuName string = 'PerGB2018'

@description('The tags that should be added to the resource')
param tags object = {}

resource loganalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: name
  tags: tags
  location: location == '' ? resourceGroup().location : location
  properties: {
    sku: {
      name: skuName
    }
    retentionInDays: retentionDays
  }
}

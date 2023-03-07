@minLength(1)
@maxLength(63)
@description('The name of the SQL server - Lowercase letters, numbers, and hyphens.Cant start or end with hyphen.')
param sqlServerName string

@minLength(1)
@maxLength(128)
@description('Name of the database - Cant use: <>*%&:\\/? or control characters Cant end with period or space')
param name string

@allowed([
  ''
  'dev'
  'test'
  'prod'
])
@description('The environment that is being deployed')
param environment string = ''

var dbName = environment == '' ? name : '${name}-${environment}'

@description('The location for the SQL Server')
param location string

@description('The name of the workspace')
param workspaceName string = ''

@description('The resource group the workspace is in defautls to deployment resource group')
param workspaceResourceGroup string = ''

var workspaceId = workspaceResourceGroup == '' ? resourceId('Microsoft.OperationalInsights/workspaces', workspaceName) : resourceId(workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName) 


resource sqldatabase 'Microsoft.Sql/servers/databases@2021-05-01-preview' = {
  name: '${sqlServerName}/${dbName}'
  location: location
}

output dbname string = sqldatabase.name

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(environment == 'prod') {
  name: name
  scope: sqldatabase
  properties: {
    logs:  [
      {
        category: 'SQLInsights'
        enabled:  true
      }
      {
        category: 'AutomaticTuning'
        enabled:  true
      }
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled:  true
      }
      {
        category: 'QueryStoreWaitStatistics'
        enabled:  true
      }
      {
        category: 'Errors'
        enabled:  true
      }
      {
        category: 'DatabaseWaitStatistics'
        enabled:  true
      }
      {
        category: 'Timeouts'
        enabled:  true
      }
      {
        category: 'Blocks'
        enabled:  true
      }
      {
        category: 'Deadlocks'
        enabled:  true
      }
    ]
    metrics: [
      {
        category: 'Basic'
        enabled:  true
      }
      {
        category: 'InstanceAndAppAdvanced'
        enabled:  true
      }
      {
        category: 'WorkloadManagement'
        enabled:  true
      }
    ]
    workspaceId: workspaceId
  }
}

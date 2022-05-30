@description('The name of the diagnostic setting')
param name string

@description('A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type constructed as follows: {normalized service identity}_{normalized category name}. Possible values are: Dedicated and null (null is default.)')
param logAnalyticsDestinationType string = ''

//      {
//  category: 'string'
//  categoryGroup: 'string'
//  enabled: bool
//  retentionPolicy: {
//    days: int
//    enabled: bool
//  }
//}
@description('An array of log categories objects like above ')
param logs array = []

// {
//   category: 'string'
//   enabled: bool
//   retentionPolicy: {
//     days: int
//     enabled: bool
//   }
//   timeGrain: 'string'
// }

@description('An array of metrics categories objects like above ')
param metrics array = []
@description('The name of the workspace')
param workspaceName string

@description('The resource group the workspace is in defautls to deployment resource group')
param workspaceResourceGroup string = ''

var workspaceId = workspaceResourceGroup == '' ? resourceId('Microsoft.OperationalInsights/workspaces', workspaceName) : resourceId(workspaceResourceGroup, 'Microsoft.OperationalInsights/workspaces', workspaceName) 

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: name
  properties: {
    logAnalyticsDestinationType: logAnalyticsDestinationType == '' ? null : logAnalyticsDestinationType
    logs: logs
    metrics: metrics
    workspaceId: workspaceId
  }
}

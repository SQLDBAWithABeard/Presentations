targetScope = 'resourceGroup'

param topLevel string
param projectKey string
param productkey string
param product string
param environment string
param isAML bool
var name = isAML ? '${topLevel}-${projectKey}-${productkey}-${environment}-aml-ai' : '${topLevel}-${projectKey}-${productkey}-${environment}-ai'
param bucode string
param costcenter string
param creator string

var tags = {
  important: 'Controlled by bicep'
  creator: creator
  environment: environment
  costcenter: costcenter
  bucode: bucode
  env: environment
  projectKey: projectKey
  billing: '${projectKey}-${product}'
  application: product
}
param applicationType string // Type of application being monitored. - web or other
param kind string // freeform - web, ios,other,store,java, etc
param samplingPercentage int // Percentage of the data produced by the application being monitored that is being sampled for Application Insights telemetry.
param disableIpMasking bool = false
param logAnalyticsWorkspaceName string = '${topLevel}-${projectKey}-${product}-${environment}-log'
param logAnalyticsWorkspaceResourceGroupName string = 'default'
var logAnalyticsResourceGroupName = logAnalyticsWorkspaceResourceGroupName == 'default' ? resourceGroup().name : logAnalyticsWorkspaceResourceGroupName
param publicNetworkAccessForIngestion string = 'Enabled' // The network access type for accessing Application Insights ingestion. - Enabled or Disabled
param publicNetworkAccessForQuery string = 'Enabled' // The network access type for accessing Application Insights query. - Enabled or Disabled
param ingestionMode string // Indicates the flow of the ingestion. - ApplicationInsights, ApplicationInsightsWithDiagnosticSettings, LogAnalytics

resource appinsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: name
  location: resourceGroup().location
  tags: tags
  kind: kind
  properties: {
    Application_Type: applicationType
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    SamplingPercentage: samplingPercentage
    DisableIpMasking: disableIpMasking
    WorkspaceResourceId: resourceId(logAnalyticsResourceGroupName, 'Microsoft.OperationalInsights/workspaces', logAnalyticsWorkspaceName)
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    IngestionMode: ingestionMode
  }
}

output appinsightsid string = appinsights.id
output appinsightsname string = appinsights.name

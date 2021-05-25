param sqlMiName string = 'ben-starker'
param dataControllerName string = 'beard-direct-dc'
param customLocation string = 'beardarclocation'
param location string = resourceGroup().location
param admin string = 'benadmin'
param subscription string

@secure()
param password string
param namespace string = 'arcdirect'
param serviceType string = 'NodePort'
param vCoresMax int = 4
param memoryMax string = '8Gi'
param dataStorageSize string = '5Gi'
param dataStorageClassName string = 'bens-local-storage'
param logsStorageSize string = '5Gi'
param logsStorageClassName string = 'bens-local-storage'
param dataLogsStorageSize string = '5Gi'
param dataLogsStorageClassName string = 'bens-local-storage'
param backupsStorageSize string = '5Gi'
param backupsStorageClassName string = 'bens-local-storage'
param replicas int = 1
param resourceTags object = {
  important:    'WARNING - This resource is controlled by IaaC using bicep'
  creator: 'Rob'
  project: 'Demo SQL Mi'
}

resource benverbindung 'Microsoft.AzureArcData/sqlManagedInstances@2021-03-02-preview' = {
  name: sqlMiName
  location: location
  extendedLocation: {
    type: 'CustomLocation'
    name: resourceId('microsoft.extendedlocation/customlocations',customLocation)
  }
  tags: resourceTags
  properties: {
    admin: admin
    basicLoginInformation: {
      username: admin
      password: password
    }
    k8sRaw: {
      spec: {
        dev: false
        services: {
          primary: {
            type: serviceType
          }
        }
        replicas: replicas
        scheduling: {
          default: {
            resources: {
              requests: {
                vcores: vCoresMax
                memory: memoryMax
              }
            }
          }
        }
        storage: {
          data: {
            volumes: [
              {
                className: dataStorageClassName
                size: dataStorageSize
              }
            ]
          }
          logs: {
            volumes: [
              {
                className: logsStorageClassName
                size: logsStorageSize
              }
            ]
          }
          datalogs: {
            volumes: [
              {
                className: dataLogsStorageClassName
                size: dataLogsStorageSize
              }
            ]
          }
          backups: {
            volumes: [
              {
                className: backupsStorageClassName
                size: backupsStorageSize
              }
            ]
          }
        }
        settings: {
          azure: {
            subscription: subscription
            resourceGroup: 'beardarc'
            location: location
          }
        }
      }
      metadata: {
        namespace: namespace
      }
      status: {}
    }
    dataControllerId: resourceId('Microsoft.AzureArcData/dataControllers',dataControllerName)
  }
}

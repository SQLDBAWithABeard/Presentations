# This is the variables file. This is used to define and set variables for creating resources

/* 
This variable is the one that will define the values for each environment - for a test

Each variable has a value for each environment. This is the value that you change when you want to update 
a resource. This is then mapped to a local variable in main.tf where it is used.

Each variable is defined with a description below
*/
variable "environment_config" {
  type = map

  default = {
    dev = {
      resourcegroup_name                             = "-dev"
      location                                       = "West Europe"
      sqlserver_name                                 = "-dev"
      sqlserver_admin                                = "sysadmin"
      elasticpool_name                               = ""
      elasticpool_max_size_gb                        = "100"
      elasticpool_sku_name                           = "GP_Gen5"
      elasticpool_sku_capacity                       = 4
      elasticpool_sku_tier                           = "GeneralPurpose"
      elasticpool_sku_family                         = "Gen5"
      elasticpool_per_database_settings_max_capacity = 4
      elasticpool_per_database_settings_min_capacity = 0
      sqlserver_database_Beard1_Name                   = "database1"
      sqlserver_database_Beard2_Name                   = "database2"
      sqlserver_database_Beard3_Name                   = "database3"
      sqlserver_database_Audit_Name                    = "databaseAudit"
      sqlaudit_storage_account_name                  = "devsqlauditstore"
      sqlaudit_retention_days                        = 7
      sqlserver_Azure_AD_Name                        = ""
      sqlserver_Azure_AD_Object_ID                   = ""
      sql_security_alert_policy_state                = "Enabled"
      sql_security_alert_policy_disabled_alerts      = ["Sql_Injection", "Data_Exfiltration"]
      sql_security_alert_policy_email_account_admins = true
      sql_security_alert_policy_email_addresses      = [""]
      sql_security_alert_policy_retention_days       = 7
      virtual_network_name                           = "databasenetwork"
      address_space                                  = ["10.0.0.0/16"]   
      dns_servers                                    = ["10.0.0.4", "10.0.0.5"]
      #subnets_virtual_network_name                   = aname
      address_prefixes                               = ["10.0.1.0/24"]
      service_endpoints                              = ["Microsoft.Sql"]
      sql_server_private_endpoint_name               = "databaseendpoint"
      sql_server_private_service_name                = "databaseprivatelink"
      sql_server_private_service_is_manual           = false
      sql_server_private_service_subresources        = ["sqlServer"]
      log_analytics_workspace_name = ""
      log_analytics_workspace_resource_group_name = ""
      beardip = ""
    }
    test = {
      resourcegroup_name                             = "-uat"
      location                                       = "West Europe"
      sqlserver_name                                 = "-uat"
      sqlserver_admin                                = "sysadmin"
      elasticpool_name                               = ""
      elasticpool_max_size_gb                        = "50"
      elasticpool_sku_name                           = "GP_Gen5"
      elasticpool_sku_capacity                       = 4
      elasticpool_sku_tier                           = "GeneralPurpose"
      elasticpool_sku_family                         = "Gen5"
      elasticpool_per_database_settings_max_capacity = 4
      elasticpool_per_database_settings_min_capacity = 0
      sqlserver_database_Beard1_Name                   = "uatdatabase1"
      sqlserver_database_Beard2_Name                   = "uatdatabase2"
      sqlserver_database_Beard3_Name                   = "uatdatabase3"
      sqlserver_database_Audit_Name                    = "uatbeardsqlAudit"
      sqlaudit_storage_account_name                  = "uatsqlauditstore"
      sqlaudit_retention_days                        = 7
      sqlserver_Azure_AD_Name                        = ""
      sqlserver_Azure_AD_Object_ID                   = ""
      sql_security_alert_policy_state                = "Disabled"
      sql_security_alert_policy_disabled_alerts      = ["Sql_Injection", "Data_Exfiltration"]
      sql_security_alert_policy_email_account_admins = true
      sql_security_alert_policy_email_addresses      = [""]
      sql_security_alert_policy_retention_days       = 15
      virtual_network_name                           = "uatbeardsqlnetwork"
      address_space                                  = ["10.0.0.0/16"] 
      dns_servers                                     = ["10.0.0.4", "10.0.0.5"]
      # subnets_virtual_network_name                   = aname
      address_prefixes                               = ["10.0.1.0/24"]
      service_endpoints                              = ["Microsoft.Sql"]
      sql_server_private_endpoint_name               = "uatbeardsqlendpoint"
      sql_server_private_service_name                = "uatbeardsqlprivatelink"
      sql_server_private_service_is_manual           = false
      sql_server_private_service_subresources        = ["sqlServer"]
      log_analytics_workspace_name = ""
      log_analytics_workspace_resource_group_name = ""
      beardip = ""
    }
    prod = {
      resourcegroup_name                             = ""
      location                                       = "West Europe"
      sqlserver_name                                 = ""
      sqlserver_admin                                = "sysadmin"
      elasticpool_name                               = ""
      elasticpool_max_size_gb                        = "50"
      elasticpool_sku_name                           = "GP_Gen5"
      elasticpool_sku_capacity                       = 4
      elasticpool_sku_tier                           = "GeneralPurpose"
      elasticpool_sku_family                         = "Gen5"
      elasticpool_per_database_settings_max_capacity = 4
      elasticpool_per_database_settings_min_capacity = 0
      sqlserver_database_Beard1_Name                 = "Beard-App-1"
      sqlserver_database_Beard2_Name                 = "Beard-App-2"
      sqlserver_database_Beard3_Name                 = "Beard-Reporting-3"
      sqlserver_database_Audit_Name                  = "Beard-Audit"
      sqlaudit_storage_account_name                  = "prodsqlauditstore"
      sqlaudit_retention_days                        = 30
      sqlserver_Azure_AD_Name                        = ""
      sqlserver_Azure_AD_Object_ID                   = "uatdatabase"
      sql_security_alert_policy_state                = "Disabled"
      sql_security_alert_policy_disabled_alerts      = []
      sql_security_alert_policy_email_account_admins = true
      sql_security_alert_policy_email_addresses      = [""]
      sql_security_alert_policy_retention_days       = 30
      virtual_network_name                           = "beardsqlnetwork"
      address_space                                  = ["10.0.0.0/16"]
      dns_servers                                    = ["10.0.0.4", "10.0.0.5"]
     # subnets_virtual_network_name                   = aname
      address_prefixes                               = ["10.0.1.0/24"]
      service_endpoints                              = ["Microsoft.Sql"]
      sql_server_private_endpoint_name               = "beardsqlendpoint"
      sql_server_private_service_name                = "beardsqlprivatelink"
      sql_server_private_service_is_manual           = false
      sql_server_private_service_subresources        = ["sqlServer"]
      log_analytics_workspace_name = "beardsewelllogs"
      log_analytics_workspace_resource_group_name = ""
      beardip = ""
    }
  }
}

# This will set the tags on the resources - Maximum Tag length is 256 characters

variable "environment_tags" {
  type = map

  default = {
    dev = {
      ReadMe      = "DO NOT change in the Portal. These resources are controlled by Terraform in the repo located here https://dev.azure.com/dbawithabeard/Terraform/_git/ElasticPool Any changes that you make in the portal will break the CI/CD process or be overwritten"
      environment = "Beard Dev"
      costcenter  = "Beard Cost Centre"
      project     = "Azure SQL ElasticPool"
    }
    test = {
      ReadMe      = "DO NOT change in the Portal. These resources are controlled by Terraform in the repo located here https://dev.azure.com/dbawithabeard/Terraform/_git/ElasticPool Any changes that you make in the portal will break the CI/CD process or be overwritten"
      environment = "Beard UAT"
      costcenter  = "Beard Cost Centre"
      project     = "Azure SQL ElasticPool"
    }
    prod = {
      ReadMe      = "DO NOT change in the Portal. These resources are controlled by Terraform in the repo located here https://dev.azure.com/dbawithabeard/Terraform/_git/ElasticPool Any changes that you make in the portal will break the CI/CD process or be overwritten"
      environment = "Beard Prod"
      costcenter  = "Beard Cost Centre"
      project     = "Azure SQL ElasticPool"
    }
  }
}

variable "resourcegroup_name" {
  type        = string
  description = "The resource group name"
  default     = ""
}

variable "location" {
  type        = string
  description = "The Azure Region in which the resources in this example should exist"
  default     = "West Europe"
}

variable "tags" {
  type        = map
  description = "Any tags which should be assigned to the resources in this plan"

  default = {
    environment = "Unknown"
    costcenter  = "Unknown"
    project     = "Unknown"
  }
}

variable "sqlserver_name" {
  type        = string
  description = "The name of the sql server"
  default     = ""
}

variable "sqlserver_admin" {
  type        = string
  description = "The name of the sql server admin account"
  default     = "sysadmin"
}
/*
variable "sqlserver_admin_password" {
  type        = string
  description = "The sql server admin account password"
  default     = "dbatools.IO"
}

*/
variable "elasticpool_name" {
  type        = string
  description = "The name of the elastic pool to be used by the sqlserver"
  default     = ""
}

variable "elasticpool_max_size_gb" {
  description = "The max data size of the elastic pool in gigabytes."
  default     = "50"
}

variable "elasticpool_sku_name" {
  description = "The name of the sku for the elastic pool - Specifies the SKU Name for this Elasticpool. The name of the SKU, will be either vCore based tier + family pattern (e.g. GP_Gen4, BC_Gen5) or the DTU based BasicPool, StandardPool, or PremiumPool pattern"
  default     = "GP_Gen5"
}

variable "elasticpool_sku_capacity" {
  description = "The scale up/out capacity, representing server's compute units."
  default     = 4
}

variable "elasticpool_sku_tier" {
  description = "The tier of the particular SKU. Possible values are GeneralPurpose, BusinessCritical, Basic, Standard, or Premium. For more information see the documentation for your Elasticpool configuration"
  default     = "GeneralPurpose"
}

variable "elasticpool_sku_family" {
  description = "The family of hardware Gen4 or Gen5."
  default     = "Gen5"
}

variable "elasticpool_per_database_settings_max_capacity" {
  description = "The maximum capacity any one database can consume (i.e. compute units)."
  default     = 4
}

variable "elasticpool_per_database_settings_min_capacity" {
  description = "The minimum capacity any one database can consume (i.e. compute units)."
  default     = 0
}

variable "sqlserver_database_Beard1_Name" {
  description = "The name of the Azure SQL database on - needs to be unique, lowercase between 3 and 24 characters including the prefix"
  default     = null
}
variable "sqlserver_database_Beard2_Name" {
  description = "The name of the Azure SQL database on - needs to be unique, lowercase between 3 and 24 characters including the prefix"
  default     = null
}
variable "sqlserver_database_Beard3_Name" {
  description = "The name of the Azure SQL database on - needs to be unique, lowercase between 3 and 24 characters including the prefix"
  default     = null
}
variable "sqlserver_database_Audit_Name" {
  description = "The name of the Azure SQL database on - needs to be unique, lowercase between 3 and 24 characters including the prefix"
  default     = null
}

variable "sqlserver_Azure_AD_Name" {
  description = "The login username of the Azure AD Administrator of this SQL Server."
  default     = null
}

variable "sqlserver_Azure_AD_Object_ID" {
  description = "The object id of the Azure AD Administrator of this SQL Server."
  default     = null
}

variable "sqlaudit_storage_account_name" {
  description = "The name of the storage account to hold the SQL Server audit records"
  default     = null
}
variable "sqlaudit_retention_days" {
  description = "The number of days for the audit retention"
  default     = null
}

variable "sql_security_alert_policy_state" {
  description = "Specifies the state of the policy, whether it is enabled or disabled or a policy has not been applied yet on the specific database server. Allowed values are: Disabled, Enabled, New"
  default     = "Disabled"
}

variable "sql_security_alert_policy_disabled_alerts" {
  description = "Specifies an array of alerts that are disabled. Allowed values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action."
  default     = null
}
variable "sql_security_alert_policy_email_account_admins" {
  description = "Boolean flag which specifies if the alert is sent to the account administrators or not. Defaults to false"
  default     = true
}
variable "sql_security_alert_policy_email_addresses" {
  description = "Specifies an array of e-mail addresses to which the alert is sent."
  default     = null
}
variable "sql_security_alert_policy_retention_days" {
  description = "Specifies the number of days to keep in the Threat Detection audit logs"
  default     = null
}


# Azure Subscription Id
variable "azure-subscription-id" {
  type        = string
  description = "Azure Subscription Id"
}
# Azure Client Id/appId
variable "azure-client-id" {
  type        = string
  description = "Azure Client Id/appId"
}
# Azure Client Id/appId
variable "azure-client-secret" {
  type        = string
  description = "Azure Client Id/appId"
}
# Azure Tenant Id
variable "azure-tenant-id" {
  type        = string
  description = "Azure Tenant Id"
}

variable "resource_group_name" {
  description = "The terraform state resource group name"
  type        = string
}

variable "storage_account_name" {
  description = "The terraform state storage account name"
  type        = string
}

variable "virtual_network_name" {
  description =  "The name of the virtual network. Changing this forces a new resource to be created."
  default = null
}
variable "address_space" {
  description = "The address space that is used the virtual network. You can supply more than one address space. Changing this forces a new resource to be created"
  default = null
}
variable "dns_servers" {
  description = "List of IP addresses of DNS servers"
  default = null
}

/*
variable "subnets_virtual_network_name" {
  description = "the virtual network name is a variable in case we do not have perms or are not required to create it The name of the virtual network to which to attach the subnet. Changing this forces a new resource to be created."
  default = null
}
*/
variable "address_prefixes" {
  description = "The address prefixes to use for the subnet."
  default = null
}
variable "service_endpoints" {
  description = "The list of Service endpoints to associate with the subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage and Microsoft.Web."
  default = null
}

variable "sql_server_private_endpoint_name" {
  description = "Specifies the Name of the Private Endpoint. Changing this forces a new resource to be created."
default = null
}

variable "sql_server_private_service_name" {
  description = "Specifies the Name of the Private Service Connection. Changing this forces a new resource to be created."
  default = null
}
variable "sql_server_private_service_is_manual" {
  description = "Does the Private Endpoint require Manual Approval from the remote resource owner? Changing this forces a new resource to be created"
  default = null
}
variable "sql_server_private_service_subresources" {
  description = "A list of subresource names which the Private Endpoint is able to connect to. subresource_names corresponds to group_id. Changing this forces a new resource to be created. dfs,dfs_secondary ,Data Lake File System Gen2	dfs	dfs_secondary,sqlServer	,blob,blob_secondary,file,file_secondary,queue,queue_secondary,table,table_secondary,web,web_secondary"
  default = null
}
variable "log_analytics_workspace_name" {
  description = "Name of the log analytics workspace"
  type        = string
  default     = null
}
variable "log_analytics_workspace_resource_group_name" {
  description = "Name of the log analytics workspace Resource Group"
  type        = string
  default     = null
}
variable "beardip" {
  description = "Client IP"
  type        = string
  default     = null
}
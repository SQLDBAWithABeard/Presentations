# Set up the Azure Provider  
provider "azurerm" { 
  version = "~> 2.13" 
  features {} 
  subscription_id = var.azure-subscription-id 
  client_id       = var.azure-client-id 
  client_secret   = var.azure-client-secret 
  tenant_id       = var.azure-tenant-id 
} 
 
# Values for the azure backend - the rest of the values are defined in the ENVNAME.backend-config.tfvars file 
terraform { 
  backend "azurerm" { 
    resource_group_name  = var.resource_group_name 
    storage_account_name = var.storage_account_name 
    container_name       = "terraform" 
    key                  = "elasticpool.tfstate" 
  } 
} 
 
/* 
To ensure that all of the environments are created in exactly the same manner we will use the same configuration  
but we will want to have different values per environment. This is done with terraform workspaces. 
 
The variables.tf file is where the values for any configuration are set. The variable environment_config has a set of 
values for each environment which is mapped to a local variable in the block below. The local variable is then used within 
the required resource. 
 
Each variable in the environment_config also has a variable {} entry in the variables.tf file with a description so that you  
can see what it is that it does. The only values that should ever be in here are values that will be the same across all 
environments adn to be honest even then I would place them in the variables.tf file because you never know! 
 
*/ 
 
# Define the local variables block 
locals { 
  stack                                          = var.environment_config[terraform.workspace] 
  tags                                           = var.environment_tags[terraform.workspace] 
  env_name                                       = terraform.workspace 
  resourcegroup_name                             = local.stack["resourcegroup_name"] 
  location                                       = local.stack["location"] 
  sqlserver_name                                 = local.stack["sqlserver_name"] 
  sqlserver_admin                                = local.stack["sqlserver_admin"] 
 # sqlserver_admin_password                       = local.stack["sqlserver_admin_password"] 
  elasticpool_name                               = local.stack["elasticpool_name"] 
  elasticpool_max_size_gb                        = local.stack["elasticpool_max_size_gb"] 
  elasticpool_sku_name                           = local.stack["elasticpool_sku_name"] 
  elasticpool_sku_capacity                       = local.stack["elasticpool_sku_capacity"] 
  elasticpool_sku_tier                           = local.stack["elasticpool_sku_tier"] 
  elasticpool_sku_family                         = local.stack["elasticpool_sku_family"] 
  elasticpool_per_database_settings_max_capacity = local.stack["elasticpool_per_database_settings_max_capacity"] 
  elasticpool_per_database_settings_min_capacity = local.stack["elasticpool_per_database_settings_min_capacity"] 
  sqlserver_database_Beard1_Name                   = local.stack["sqlserver_database_Beard1_Name"] 
  sqlserver_database_Beard2_Name                   = local.stack["sqlserver_database_Beard2_Name"] 
  sqlserver_database_Beard3_Name                   = local.stack["sqlserver_database_Beard3_Name"] 
  sqlserver_database_Audit_Name                    = local.stack["sqlserver_database_Audit_Name"] 
  sqlaudit_storage_account_name                  = local.stack["sqlaudit_storage_account_name"] 
  sqlaudit_retention_days                        = local.stack["sqlaudit_retention_days"] 
  sqlserver_Azure_AD_Name                        = local.stack["sqlserver_Azure_AD_Name"] 
  sqlserver_Azure_AD_Object_ID                   = local.stack["sqlserver_Azure_AD_Object_ID"] 
  sql_security_alert_policy_state                = local.stack["sql_security_alert_policy_state"] 
  sql_security_alert_policy_disabled_alerts      = local.stack["sql_security_alert_policy_disabled_alerts"] 
  sql_security_alert_policy_email_account_admins = local.stack["sql_security_alert_policy_email_account_admins"] 
  sql_security_alert_policy_email_addresses      = local.stack["sql_security_alert_policy_email_addresses"] 
  sql_security_alert_policy_retention_days       = local.stack["sql_security_alert_policy_retention_days"] 
  virtual_network_name                           = local.stack["virtual_network_name"] 
  address_space                                  = local.stack["address_space"] 
  dns_servers                                    = local.stack["dns_servers"] 
  #subnets_virtual_network_name                   = local.stack["subnets_virtual_network_name"] 
  address_prefixes                               = local.stack["address_prefixes"] 
  service_endpoints                              = local.stack["service_endpoints"] 
  sql_server_private_endpoint_name               = local.stack["sql_server_private_endpoint_name"] 
  sql_server_private_service_name                = local.stack["sql_server_private_service_name"] 
  sql_server_private_service_is_manual           = local.stack["sql_server_private_service_is_manual"] 
  sql_server_private_service_subresources        = local.stack["sql_server_private_service_subresources"] 
  log_analytics_workspace_name                          = local.stack["log_analytics_workspace_name"] 
  log_analytics_workspace_resource_group_name           = local.stack["log_analytics_workspace_resource_group_name"] 
  beardip                                        = local.stack["beardip"] 
} 
 
## Ge the secrets from KeyVault 
 
data "azurerm_key_vault" "beardkeyvault" { 
  name                = "" 
  resource_group_name = "" 
} 
 
data "azurerm_key_vault_secret" "SqlServerAdminPassword" { 
name = "SqlServerAdminPassword" 
key_vault_id = data.azurerm_key_vault.beardkeyvault.id 
} 
 
# the resource group for the SQL Server and Elastic Pool 
resource "azurerm_resource_group" "rg" { 
  name     = local.resourcegroup_name 
  location = local.location 
  tags     = local.tags 
} 
 
# The PaaS SQL Server 
resource "azurerm_mssql_server" "sqlserver" { 
  name                         = local.sqlserver_name 
  resource_group_name          = azurerm_resource_group.rg.name 
  location                     = azurerm_resource_group.rg.location 
  version                      = "12.0" 
  administrator_login          = local.sqlserver_admin 
  administrator_login_password = data.azurerm_key_vault_secret.SqlServerAdminPassword.value 
  public_network_access_enabled = true 
 
  azuread_administrator { 
    login_username = local.sqlserver_Azure_AD_Name 
    object_id      = local.sqlserver_Azure_AD_Object_ID  
  } 
 
  identity { 
    type = "SystemAssigned" 
  } 
 
 
  tags = local.tags 
} 
 
resource "azurerm_sql_firewall_rule" "Beard-IP" { 
  name                = "Allow the Beard" 
  resource_group_name = azurerm_resource_group.rg.name 
  server_name         = azurerm_mssql_server.sqlserver.name 
  start_ip_address    = local.beardip 
  end_ip_address      = local.beardip 
} 
 
#The Elastic Pool 
resource "azurerm_mssql_elasticpool" "elasticpool" { 
  name                = local.elasticpool_name 
  resource_group_name = azurerm_resource_group.rg.name 
  location            = azurerm_resource_group.rg.location 
  server_name         = azurerm_mssql_server.sqlserver.name 
  license_type        = "LicenseIncluded" 
  max_size_gb         = local.elasticpool_max_size_gb 
  tags                = local.tags 
  sku { 
    name     = local.elasticpool_sku_name 
    tier     = local.elasticpool_sku_tier 
    capacity = local.elasticpool_sku_capacity 
    family   = local.elasticpool_sku_family 
  } 
 
  per_database_settings { 
    min_capacity = local.elasticpool_per_database_settings_min_capacity 
    max_capacity = local.elasticpool_per_database_settings_max_capacity 
  } 
} 
 
# A set of databases 
resource "azurerm_sql_database" "Beard-1" { 
  name                = local.sqlserver_database_Beard1_Name 
  resource_group_name = azurerm_resource_group.rg.name 
  location            = azurerm_resource_group.rg.location 
  server_name         = azurerm_mssql_server.sqlserver.name 
  elastic_pool_name   = azurerm_mssql_elasticpool.elasticpool.name 
  tags                = local.tags 
} 
 
resource "azurerm_mssql_database_extended_auditing_policy" "Beard-1-auditing" { 
  database_id                             = azurerm_sql_database.Beard-1.id 
  storage_endpoint                        = azurerm_storage_account.sqlaudit.primary_blob_endpoint 
  storage_account_access_key              = azurerm_storage_account.sqlaudit.primary_access_key 
  storage_account_access_key_is_secondary = false 
  retention_in_days                       = local.sqlaudit_retention_days 
} 
 
resource "azurerm_sql_database" "Beard-2" { 
  name                = local.sqlserver_database_Beard2_Name 
  resource_group_name = azurerm_resource_group.rg.name 
  location            = azurerm_resource_group.rg.location 
  server_name         = azurerm_mssql_server.sqlserver.name 
  elastic_pool_name   = azurerm_mssql_elasticpool.elasticpool.name 
  tags                = local.tags 
} 
 
resource "azurerm_sql_database" "Beard-3" { 
  name                = local.sqlserver_database_Beard3_Name 
  resource_group_name = azurerm_resource_group.rg.name 
  location            = azurerm_resource_group.rg.location 
  server_name         = azurerm_mssql_server.sqlserver.name 
  elastic_pool_name   = azurerm_mssql_elasticpool.elasticpool.name 
  tags                = local.tags 
} 
 
resource "azurerm_sql_database" "Audit" { 
  name                = local.sqlserver_database_Audit_Name 
  resource_group_name = azurerm_resource_group.rg.name 
  location            = azurerm_resource_group.rg.location 
  server_name         = azurerm_mssql_server.sqlserver.name 
  elastic_pool_name   = azurerm_mssql_elasticpool.elasticpool.name 
  tags                = local.tags 
} 
 
resource "azurerm_mssql_database_extended_auditing_policy" "Audit-auditing" { 
  database_id                             = azurerm_sql_database.Audit.id 
  storage_endpoint                        = azurerm_storage_account.sqlaudit.primary_blob_endpoint 
  storage_account_access_key              = azurerm_storage_account.sqlaudit.primary_access_key 
  storage_account_access_key_is_secondary = false 
  retention_in_days                       = local.sqlaudit_retention_days 
} 
 
# A Storage account for storing the auditing of the SQL Server 
resource "azurerm_storage_account" "sqlaudit" { 
  name                     = local.sqlaudit_storage_account_name 
  resource_group_name      = azurerm_resource_group.rg.name 
  location                 = azurerm_resource_group.rg.location 
  account_tier             = "Standard" 
  account_replication_type = "LRS" 
  tags                     = local.tags 
} 
 
# Security Alert Policy 
 
resource "azurerm_mssql_server_security_alert_policy" "sqlpolicy" { 
  resource_group_name        = azurerm_resource_group.rg.name 
  server_name                = azurerm_mssql_server.sqlserver.name 
  state                      = local.sql_security_alert_policy_state 
  storage_endpoint           = azurerm_storage_account.sqlaudit.primary_blob_endpoint 
  storage_account_access_key = azurerm_storage_account.sqlaudit.primary_access_key 
  disabled_alerts            = local.sql_security_alert_policy_disabled_alerts 
  email_account_admins       = local.sql_security_alert_policy_email_account_admins 
  email_addresses            = local.sql_security_alert_policy_email_addresses 
  retention_days             = local.sql_security_alert_policy_retention_days 
} 
 
# Virtual Network 
 
resource "azurerm_virtual_network" "sqlservernetwork" { 
  name                = local.virtual_network_name 
  location            = azurerm_resource_group.rg.location 
  resource_group_name = azurerm_resource_group.rg.name 
  address_space       = local.address_space 
  dns_servers         = local.dns_servers 
  tags                = local.tags 
} 
 
# We will keep the subnet separate 
# the virtual network name can be a variable in case we do not have perms  
# or are not required to create it 
resource "azurerm_subnet" "sqlserversubnet" { 
  name                 = "beardsqlsub" 
  resource_group_name  = azurerm_resource_group.rg.name 
  virtual_network_name = azurerm_virtual_network.sqlservernetwork.name 
  address_prefixes     = local.address_prefixes  
  service_endpoints    = local.service_endpoints 
  enforce_private_link_endpoint_network_policies = true 
} 
 
resource "azurerm_private_endpoint" "sql_server_private_endpoint" { 
  name                = local.sql_server_private_endpoint_name 
  location            = azurerm_resource_group.rg.location 
  resource_group_name = azurerm_resource_group.rg.name 
  subnet_id           = azurerm_subnet.sqlserversubnet.id 
 
  private_service_connection { 
 
    name                           = local.sql_server_private_service_name 
    is_manual_connection           = local.sql_server_private_service_is_manual 
    private_connection_resource_id = azurerm_mssql_server.sqlserver.id 
    subresource_names              = ["sqlServer"] 
  } 
 
  tags = local.tags 
} 
 
 
## Get the log analytics workspace id 
 
data "azurerm_log_analytics_workspace" "loganalytics" { 
    name                = local.log_analytics_workspace_name 
    resource_group_name = local.log_analytics_workspace_resource_group_name 
  } 
   
   
  resource "azurerm_monitor_diagnostic_setting" "elasticpool" { 
    name               = "SendToLogAnalytics" 
    target_resource_id = azurerm_mssql_elasticpool.elasticpool.id 
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.loganalytics.id 
   
    metric { 
      category = "Basic" 
    } 
   
    metric { 
      category = "InstanceAndAppAdvanced" 
    } 
  } 
 
  resource "azurerm_monitor_diagnostic_setting" "Auditdatabase" { 
    name               = "SendToLogAnalytics" 
    target_resource_id = azurerm_sql_database.Audit.id 
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.loganalytics.id 
   
    log { 
      category = "SQLInsights" 
    } 
    log { 
      category = "AutomaticTuning" 
    } 
    log { 
      category = "QueryStoreRuntimeStatistics" 
      } 
    log { 
      category = "QueryStoreWaitStatistics" 
      } 
    log { 
      category = "Errors" 
      } 
    log { 
      category = "DatabaseWaitStatistics" 
      } 
    log { 
      category = "Timeouts" 
      } 
    log { 
      category = "Blocks" 
      } 
    log { 
      category = "Deadlocks" 
      } 
   
    metric { 
      category = "Basic" 
    } 
    metric { 
      category = "InstanceAndAppAdvanced" 
    } 
    metric { 
      category = "WorkloadManagement" 
    } 
  } 
 
  resource "azurerm_monitor_diagnostic_setting" "Beard-1" { 
    name               = "SendToLogAnalytics" 
    target_resource_id = azurerm_sql_database.Beard-1.id 
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.loganalytics.id 
   
    log { 
      category = "SQLInsights" 
    } 
    log { 
      category = "AutomaticTuning" 
    } 
    log { 
      category = "QueryStoreRuntimeStatistics" 
      } 
    log { 
      category = "QueryStoreWaitStatistics" 
      } 
    log { 
      category = "Errors" 
      } 
    log { 
      category = "DatabaseWaitStatistics" 
      } 
    log { 
      category = "Timeouts" 
      } 
    log { 
      category = "Blocks" 
      } 
    log { 
      category = "Deadlocks" 
      } 
    metric { 
      category = "Basic" 
    } 
    metric { 
      category = "InstanceAndAppAdvanced" 
    } 
    metric { 
      category = "WorkloadManagement" 
    } 
  } 
 
  resource "azurerm_monitor_diagnostic_setting" "Beard-2" { 
    name               = "SendToLogAnalytics" 
    target_resource_id = azurerm_sql_database.Beard-2.id 
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.loganalytics.id 
   
    log { 
      category = "SQLInsights" 
    } 
    log { 
      category = "AutomaticTuning" 
    } 
    log { 
      category = "QueryStoreRuntimeStatistics" 
      } 
    log { 
      category = "QueryStoreWaitStatistics" 
      } 
    log { 
      category = "Errors" 
      } 
    log { 
      category = "DatabaseWaitStatistics" 
      } 
    log { 
      category = "Timeouts" 
      } 
    log { 
      category = "Blocks" 
      } 
    log { 
      category = "Deadlocks" 
      } 
   
    metric { 
      category = "Basic" 
    } 
    metric { 
      category = "InstanceAndAppAdvanced" 
    } 
    metric { 
      category = "WorkloadManagement" 
    } 
  } 
 
  resource "azurerm_monitor_diagnostic_setting" "Beard-3" { 
    name               = "SendToLogAnalytics" 
    target_resource_id = azurerm_sql_database.Beard-3.id 
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.loganalytics.id 
   
    log { 
      category = "SQLInsights" 
    } 
    log { 
      category = "AutomaticTuning" 
    } 
    log { 
      category = "QueryStoreRuntimeStatistics" 
      } 
    log { 
      category = "QueryStoreWaitStatistics" 
      } 
    log { 
      category = "Errors" 
      } 
    log { 
      category = "DatabaseWaitStatistics" 
      } 
    log { 
      category = "Timeouts" 
      } 
    log { 
      category = "Blocks" 
      } 
    log { 
      category = "Deadlocks" 
      } 
   
    metric { 
      category = "Basic" 
    } 
    metric { 
      category = "InstanceAndAppAdvanced" 
    } 
    metric { 
      category = "WorkloadManagement" 
    } 
  } 
 
 
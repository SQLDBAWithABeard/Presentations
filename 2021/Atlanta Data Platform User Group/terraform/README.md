# Elastic Pool Infrastructure as Code 

- [Elastic Pool Infrastructure as Code](#elastic-pool-infrastructure-as-code)
  - [Overview](#overview)
  - [Diagram](#diagram)
  - [Pre-Requisites](#pre-requisites)
    - [<u>Azure Key Vault</u>](#uazure-key-vaultu)
    - [<u>Storage Account</u>](#ustorage-accountu)
    - [<u>Service Principal (SPN) in Azure Active Directory</u>](#uservice-principal-spn-in-azure-active-directoryu)
    - [<u>3 environments in Azure DevOps</u>](#u3-environments-in-azure-devopsu)
    - [<u>Configuration Items</u>](#uconfiguration-itemsu)
  - [Creating the Pipeline](#creating-the-pipeline)
    - [Pipeline Variables](#pipeline-variables)
  - [Creating the Environment](#creating-the-environment)
    - [Securing the Environments](#securing-the-environments)
  - [Securing the Pipeline](#securing-the-pipeline)
  - [Configuration](#configuration)
    - [IMPORTANT NOTE](#important-note)
    - [What will the Terraform do if it runs ?](#what-will-the-terraform-do-if-it-runs-)
    - [Configuration Items](#configuration-items)

## Overview
This code repository holds the code to create the Azure SQL Elastic Pool Infrastructure with the following resources

| Name   | Resource Type |  
|------------|----------------:
|databaseendpoint.nic.1641944e-1d27-4bbd-b7e3-b54cbfcad0b3 |Microsoft.Network/networkInterfaces
|databaseendpoint                                          |Microsoft.Network/privateEndpoints
|databasenetwork                                           |Microsoft.Network/virtualNetworks
|-dev                                         |Microsoft.Sql/servers
|-dev/databaseAudit                          |Microsoft.Sql/servers/databases
|-dev/database1                         |Microsoft.Sql/servers/databases
|-dev/database2                         |Microsoft.Sql/servers/databases
|-dev/database3                         |Microsoft.Sql/servers/databases
|-dev/master                                  |Microsoft.Sql/servers/databases
|-dev/                       |Microsoft.Sql/servers/elasticpools
|devsqlauditstore                                             |Microsoft.Storage/storageAccounts

The infrastructure is created with Terraform using an Azure DevOps Pipeline which is included in the repository

## Diagram

![Image](Docs\Images\Elastic_Pool.png)

## Pre-Requisites

### <u>Azure Key Vault</u>  
to hold the secrets for the Terraform
  - Resource Group Name to be added as variable into [azuredevops/AzureTerraform.Yaml](azuredevops/AzureTerraform.Yaml)
  - Name to be added as variable into [azuredevops/AzureTerraform.Yaml](azuredevops/AzureTerraform.Yaml)
### <u>Storage Account</u> 
The state for the Terraform is stored in an Azure storage account  
  - Resource Group Name to be added as variable into [azuredevops/AzureTerraform.Yaml](azuredevops/AzureTerraform.Yaml)
  - Name to be added as variable into [azuredevops/AzureTerraform.Yaml](azuredevops/AzureTerraform.Yaml)
### <u>Service Principal (SPN) in Azure Active Directory</u>   
to run the Azure DevOps Pipeline with permissions
  - Access to the Azure Subscription to be able to create Resources
  - Access to retrieve the storage key for the Azure Storage Account for the Terraform state described above  
  - Access to the Azure Key Vault defined above to be able to set and remove Firewall entries (reasoning described below)
  - Access to the Azure Key Vault defined above to be able to retrieve secrets
### <u>3 environments in Azure DevOps</u>  
Dev, Test, Prod (details described below)

### <u>Configuration Items</u>  
- **Azure Client ID**
  To be added as variable for the Pipeline in the GUI  
- **Azure Subscription ID**  
  To be added as variable for the Pipeline in the GUI  
- **Azure Tenant ID**  
  To be added as variable for the Pipeline in the GUI 
- **Resource Location**  
The location of the resource group use az- account list-locations this must be the westeurope type name not the- "West Europe" 
- **The Terraform Resource Group Name**  
The Resource Group Name for the Terraform storage account
- **Terraform storage account**  
The name of the Terraform storage account
- **Key Vault Resource Group Name**  
The Resource Group Name for the Key Vault
- **The Key Vault Name**  
The Name of the Key Vault  
- **Configuration values for each environment**  
  The configuration for each resource in each environment needs to be added to   [Build/variables.tf](Build/variables.tf)

## Creating the Pipeline

To create the Pipeline, go to Pipelines --> Pipelines in the left menu in Azure DevOps

![Menu](/Docs/Images/menu.png)

Click on New Pipeline top right

![NewPipeline](/Docs/Images/NewPipeline.png)

Choose Azure Repos Git for your code location

![ChooseCode](/Docs/Images/ChooseCode.png)

Choose this repository and then Existing Azure Pipelines YAML File

![ConfigurePipeline](/Docs/Images/ConfigurePipeline.png)

Select the file /azuredevops/AzureTerraform.Yaml from the drop down (NOTE - the /azuredevops/destroypipeline.yml will create a pipeline to destroy the infrastructure too, useful for demos. You can follow the same process to create that pipeline also)

![SelectYAML](/Docs/Images/SelectYAML.png)

### Pipeline Variables

**Either** add the variables 

- azure-client-id
- azure-subscription-id
- azure-tenant-id

in the GUI

![Variables](/Docs/Images/Variables.png)

**or** add the variables to the top of the pipeline YAML file

![YAMLVariables](/Docs/Images/YAMLVariables.png)

**In both cases** add the required values for those variables

- azure-client-id is the Client ID for the SPN
- azure-subscription-id is the subscription id
- azure-tenant-id is the tenant id

You should also add the values for the other variables at the top of the Pipeline YAML file

- location: location of the resource group use az- account list-locations this must be the westeurope type name not the- "West Europe" 
- terraform_resource_group_name: The Resource Group Name for the Terraform storage account
- terraform_storage_account: The name of the Terraform storage account
- terraform_storage_key: This will be retrieved by the pipeline **do not add values**
- agent_ip_address: This will be retrieved by the pipeline **do not add values**
- key_vault_resource_group_name: The Resource Group Name for the Key Vault
- key_vault_name: The Name of the Key Vault

## Creating the Environment  

To create the environments, Pipelines --> Environments

![EnvironmentMenu](/Docs/Images/EnvironmentMenu.png)

Click New Environment and give it a name and a description

![New Environment](/Docs/Images/NewEnvironment.png)

Then choose the environment and click the three ellipses

![Three Ellipses](/Docs/Images/ThreeEllipses.png)


and choose Approvals and Checks, click the plus sign to add a check

![Add A Check](/Docs/Images/AddCheck.png)


### Securing the Environments

You can also choose the security button from the three ellipses and restrict access to the approval process for the Environments. This useful to ensure that, for example, the Release Management Team are in control of the Production Environment

## Securing the Pipeline

It is wise to control who has the ability to create and approve PRs for items in the Build Pipeline which can access secrets and create resources


## Configuration

The configuration of the environments is done using the [variables.tf](/Build/variables.tf) file.  

Altering the values for the configuration items and committing the change in code and pushing to the main branch will trigger a build.

**NOTE** - You can push a change to the code without triggering a build by starting the commit message with `***NO_CI***` <u>**Exactly**</u> like that, it is case sensitive

### IMPORTANT NOTE

<u>**IMPORTANT NOTE**</u> - Be aware that changing some configurations will result in resources being **destroyed** and new ones being created. You can find this information by looking at the Terraform reference for the resource. As an example :-

If you look at https://www.terraform.io/docs/providers/azurerm/r/sql_server.html you will see 

![Changing Resources](/Docs/Images/ChangingResources.png)

If you change the location or the administrator login then a new resource will be created, so be careful.

In general, changing names, locations, resource groups, collation, admin logins or something the resource is connected to like a storage account, subnet or NIC will do this and altering "scalable" configurations will not (although remember that there may still be an interruption to service while the resource is reconfigured)

### What will the Terraform do if it runs ?

**Useful Tip** To keep yourself doubly safe, in the pipeline YAML file, each task has an enabled property added. You can set the enabled property for the `Apply Terraform` task to false and then check the output of the `Plan Terraform` task to see what the change will do.

![Enabled False](/Docs/Images/EnabledFalse.png)

In the picture below, you can see that the Terraform will be performing a create. 

![Create Plan](/Docs/Images/CreatePlan.png)

This means that it is only going to be creating new resources. Below that you will see the resources and the configuration values that it will use to do the creation.

![Create Detail](/Docs/Images/CreateDetail.png)

The picture below shows a plan that will create and update in place. 

![Update Plan](/Docs/Images/UpdatePlan.png)

This means that there are new resources to be created and some resources have configuration that has changed.

![Update Detail](/Docs/Images/UpdateDetail.png)

The configuration that will change will be identified with a `~` You can see in the picture below that the `max_size_gb` will be updated from 50 to 100

The picture below shows that no changes have been found between **the plan in the tfstate file** and the code. It is **not** checking the resources that are in Azure

![No Change Plan](/Docs/Images/NoChangePlan.png)


**NOTE** A Terraform plan does not validate that a change **will** work only display the changes that you have requested between the code and the state in the tfstate file. **The tfstate file only knows about changes that are made by Terraform**, so if people change the resource in the portal and then later try to run the terraform it can fail or destroy new items for example.

It is also possible to provide a change that the Terraform sees as ok but Azure does not. This is often naming conventions or configuration values restrictions for resources not being followed or a pre-requisite not existing.

### Configuration Items

You can find the restrictions for naming resources at  
https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules

- resourcegroup_name    
  The name of the resource group that will be created                         
- location                                       
- sqlserver_name                                 
- sqlserver_admin                                
- elasticpool_name                               
- elasticpool_max_size_gb                        
- elasticpool_sku_name                           
- elasticpool_sku_capacity                       
- elasticpool_sku_tier                           
- elasticpool_sku_family                         
- elasticpool_per_database_settings_max_capacity 
- elasticpool_per_database_settings_min_capacity 
- sqlserver_database_Beard1_Name                   
- sqlserver_database_Beard2_Name                   
- sqlserver_database_Beard3_Name                   
- sqlserver_database_Audit_Name                    
- sqlaudit_storage_account_name                  
- sqlaudit_retention_days                        
- sqlserver_Azure_AD_Name                        
- sqlserver_Azure_AD_Object_ID                   
- sql_security_alert_policy_state                
- sql_security_alert_policy_disabled_alerts      
- sql_security_alert_policy_email_account_admins 
- sql_security_alert_policy_email_addresses      
- sql_security_alert_policy_retention_days       
- virtual_network_name                           
- address_space                                  
- dns_servers                                    
- #subnets_virtual_network_name                  
- address_prefixes                               
- service_endpoints                              
- sql_server_private_endpoint_name               
- sql_server_private_service_name                
- sql_server_private_service_is_manual           
- sql_server_private_service_subresources        
- log_analytics_workspace_name                   
- log_analytics_workspace_resource_group_name    
/*
This file is used to define the values for the
dev workspace state file resource group and azure subscription
Any values surrounded with __ are replaced in the pipeline 
with the values of the pipeline variable WITH THE SAME NAME
*/
# tfstate vars
resource_group_name  = "__terraform_resource_group_name__"
storage_account_name = "__terraform_storage_account__"

# Azure Subscription Id
azure-subscription-id = "__azure-subscription-id__"
# Azure Client Id/appId
azure-client-id = "__azure-client-id__"
# Azure Client Secret/password
azure-client-secret = "__azure-client-secret__"
# Azure Tenant Id
azure-tenant-id = "__azure-tenant-id__"
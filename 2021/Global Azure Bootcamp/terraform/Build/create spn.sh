az login
az account set 
az account list --output table
az ad sp create-for-rbac --role="Contributor"  --scopes="/subscriptions/" --name "Azure-DevOps"
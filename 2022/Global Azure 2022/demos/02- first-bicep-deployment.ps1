if(-not $env:Path.Contains('C:\users\mrrob\.azure\bin')){
    Write-PSFMessage "Arggh - set the path to have the bicep" -Level Output
    $env:Path = $env:Path + ';C:\users\mrrob\.azure\bin'
}
Set-Location demos

code ..\Bicep\myCustomResources\01myBeard.bicep

Connect-AzAccount
# Create a Resource Group

New-AzResourceGroup -Name AzureBeard -Location eastus -Tag @{  Demo = 'true';Conference = 'GlobalAzure';BenIsAwesome = 'Always'}

# What happens if we deploy the Bicep file?
New-AzResourceGroupDeployment -ResourceGroupName AzureBeard -TemplateFile ..\Bicep\myCustomResources\01myBeard.bicep -WhatIf

# Deploy the Bicep file
New-AzResourceGroupDeployment -ResourceGroupName AzureBeard -TemplateFile ..\Bicep\myCustomResources\01myBeard.bicep

# Create a Resource Group
az account set --subscription 'Microsoft Azure Sponsorship'
az group create --name AzureBeards --location eastus --tags Demo='true' Conference='GlobalAzure' BenIsAwesome='Always'

# Deploy the Bicep file
az deployment group create --resource-group AzureBeards --template-file ..\Bicep\myCustomResources\01myBeard.bicep

# Now go and look in the deployments and activity log

# Deploy the Bicep file
az deployment group create --resource-group AzureBeards --template-file ..\Bicep\myCustomResources\01myBeards.bicep

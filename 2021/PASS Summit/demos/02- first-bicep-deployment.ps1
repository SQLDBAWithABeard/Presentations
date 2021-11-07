if(-not $env:Path.Contains('C:\users\mrrob\.azure\bin')){
    Write-PSFMessage "Arggh - set the path to have the bicep" -Level Output
    $env:Path = $env:Path + ';C:\users\mrrob\.azure\bin'
}
Set-Location demos

code ..\Bicep\myCustomResources\01myBeard.bicep

Connect-AzAccount
# Create a Resource Group

New-AzResourceGroup -Name PassBeard -Location uksouth -Tag @{  Demo = 'true';Conference = 'PassSummit';BenIsAwesome = 'Always'}

# What happens if we deploy the Bicep file?
New-AzResourceGroupDeployment -ResourceGroupName PassBeard -TemplateFile ..\Bicep\myCustomResources\01myBeard.bicep -WhatIf

# Deploy the Bicep file
New-AzResourceGroupDeployment -ResourceGroupName PassBeard -TemplateFile ..\Bicep\myCustomResources\01myBeard.bicep

# Create a Resource Group
az group create --name PassBeards --location uksouth --tags Demo='true' Conference='PassSummit' BenIsAwesome='Always'

# Deploy the Bicep file
az deployment group create --resource-group PassBeards --template-file ..\Bicep\myCustomResources\01myBeard.bicep

# Now go and look in the deployments and activity log

# Deploy the Bicep file
az deployment group create --resource-group PassBeards --template-file ..\Bicep\myCustomResources\01myBeards.bicep

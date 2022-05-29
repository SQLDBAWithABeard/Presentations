#region just incase
if (-not $env:Path.Contains('C:\users\mrrob\.azure\bin')) {
    Write-PSFMessage "Arggh - set the path to have the bicep" -Level Output
    $env:Path = $env:Path + ';C:\users\mrrob\.azure\bin'
}
Set-Location demos
#endregion

code '..\Bicep\Data\sqlserver.bicep'

#region create random password
# I use this function from Joel Bennett to create random passwords
. ..\Functions\New-Password.ps1
$administratorLoginPassword = New-Password S24
$administratorLoginPassword
$administratorLoginPassword | ConvertFrom-SecureString -AsPlainText
#endregion

#region What happens if we deploy the Bicep file?
$deploymentConfig = @{
    ResourceGroupName          = 'AzureBeard'
    TemplateFile               = '..\Bicep\Data\sqlserver.bicep'
    nameFromTemplate           = 'beardsqlserver1' # Note that we need to change the parameter name here
    location                   = 'eastus'
    administratorLogin         = 'jeremy'
    administratorLoginPassword = $administratorLoginPassword
    WhatIf                     = $true
}
New-AzResourceGroupDeployment @deploymentConfig
#endregion

#region Deploy the Bicep file
$deploymentConfig = @{
    ResourceGroupName          = 'AzureBeard'
    TemplateFile               = '..\Bicep\Data\sqlserver.bicep'
    nameFromTemplate           = 'beardsqlserver1'
    location                   = 'eastus'
    administratorLogin         = 'jeremy'
    administratorLoginPassword = $administratorLoginPassword
}
New-AzResourceGroupDeployment @deploymentConfig
#endregion

#region Deploy the Bicep file but make a nice deployment name
$deploymentname = 'Deploy_sqlserver_{0}' -f [Guid]::NewGuid().Guid
$deploymentConfig = @{
    ResourceGroupName          = 'AzureBeard'
    TemplateFile               = '..\Bicep\Data\sqlserver.bicep'
    name                       = $deploymentname
    nameFromTemplate           = 'beardsqlserver1'
    location                   = 'eastus'
    administratorLogin         = 'jeremy'
    administratorLoginPassword = $administratorLoginPassword
}
New-AzResourceGroupDeployment @deploymentConfig
#endregion

#region Deploy the Bicep file and change the admin name
$deploymentname = 'Deploy_sqlserver_{0}' -f [Guid]::NewGuid().Guid
$deploymentConfig = @{
    ResourceGroupName          = 'AzureBeard'
    TemplateFile               = '..\Bicep\Data\sqlserver.bicep'
    name                       = $deploymentname
    nameFromTemplate           = 'beardsqlserver1'
    location                   = 'eastus'
    administratorLogin         = 'benjiben'
    administratorLoginPassword = $administratorLoginPassword
}
New-AzResourceGroupDeployment @deploymentConfig

# Check the deployment error
#endregion
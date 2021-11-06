#region just incase
if (-not $env:Path.Contains('C:\users\mrrob\.azure\bin')) {
    Write-PSFMessage "Arggh - set the path to have the bicep" -Level Output
    $env:Path = $env:Path + ';C:\users\mrrob\.azure\bin'
}
Set-Location demos
#endregion

code '..\Bicep\myCustomResources\04sqlserveranddatabase.bicep'

#region create random password
# I use this function from Joel Bennett to create random passwords
. ..\Functions\New-Password.ps1
$administratorLoginPassword = New-Password S24
$administratorLoginPassword
$administratorLoginPassword | ConvertFrom-SecureString -AsPlainText
#endregion

#region Deploy the module Bicep file 
$deploymentname = 'Deploy_sqlserver_{0}' -f [Guid]::NewGuid().Guid
$deploymentConfig = @{
    ResourceGroupName          = 'PassBeard'
    TemplateFile               = '..\Bicep\myCustomResources\04sqlserveranddatabase.bicep'
    name                       = $deploymentname
    nameFromTemplate           = 'beardsqlserver1'
    location                   = 'uksouth'
    administratorLogin         = 'jeremy'
    administratorLoginPassword = $administratorLoginPassword
    databasename               = '1stdatabase'
}
New-AzResourceGroupDeployment @deploymentConfig
#endregion

#region Deploy the module Bicep file again
$deploymentname = 'Deploy_sqlserver_{0}' -f [Guid]::NewGuid().Guid
$deploymentConfig = @{
    ResourceGroupName          = 'PassBeard'
    TemplateFile               = '..\Bicep\myCustomResources\04sqlserveranddatabase.bicep'
    name                       = $deploymentname
    nameFromTemplate           = 'anotherbeardsqlserver1'
    location                   = 'uksouth'
    administratorLogin         = 'jeremy'
    administratorLoginPassword = $administratorLoginPassword
    databasename               = '1stdatabase-uat'
}
New-AzResourceGroupDeployment @deploymentConfig
#endregion

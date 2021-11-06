#region just incase
if (-not $env:Path.Contains('C:\users\mrrob\.azure\bin')) {
    Write-PSFMessage "Arggh - set the path to have the bicep" -Level Output
    $env:Path = $env:Path + ';C:\users\mrrob\.azure\bin'
}
Set-Location demos
#endregion

code '..\Bicep\myCustomResources\05sqlserveranddatabaseswithlooprange.bicep'

#region create random password
# I use this function from Joel Bennett to create random passwords
. ..\Functions\New-Password.ps1
$administratorLoginPassword = New-Password S24
$administratorLoginPassword
$administratorLoginPassword | ConvertFrom-SecureString -AsPlainText
#endregion

#region Deploy the module Bicep file 
$deploymentname = 'Deploy_sqlserver_{0}' -f [Guid]::NewGuid().Guid

$instanceName = 'beardsqlserver1'
$administratorLogin = 'jeremy'
$deploymentConfig = @{
    ResourceGroupName          = 'PassBeard'
    TemplateFile               = '..\Bicep\myCustomResources\05sqlserveranddatabaseswithlooprange.bicep'
    name                       = $deploymentname
    nameFromTemplate           = $instanceName
    location                   = 'uksouth'
    administratorLogin         = $administratorLogin
    administratorLoginPassword = $administratorLoginPassword
    databasename               = 'jezzasdb'
    numberOfDatabases          = 3
}
New-AzResourceGroupDeployment @deploymentConfig
#endregion

#region Check the databases
$sqlInstance = '{0}.database.windows.net' -f $instanceName

$firewallConfig = @{
    FirewallRuleName  = 'Robs IP' 
    StartIpAddress    = (whatsmyip) 
    EndIpAddress      = (whatsmyip)
    ServerName        = $instanceName
    ResourceGroupName = 'PassBeard' 
}
New-AzSqlServerFirewallRule @firewallConfig | Out-Null

[pscredential]$sqlCredential  = New-Object System.Management.Automation.PSCredential ($administratorLogin, $administratorLoginPassword)
$dbaConfig = @{
    SqlInstance   = $sqlInstance 
    SqlCredential = $sqlCredential 
    ClientName    = 'Robs-dbatools'
}
$azureSql = Connect-DbaInstance @dbaConfig

$azureSql

Get-DbaDatabase -SqlInstance $azureSql | Select SqlInstance , Name, IsAccessible

#endregion

#region add a couple of databases

$deploymentConfig = @{
    ResourceGroupName          = 'PassBeard'
    TemplateFile               = '..\Bicep\myCustomResources\05sqlserveranddatabaseswithlooprange.bicep'
    name                       = $deploymentname
    nameFromTemplate           = $instanceName
    location                   = 'uksouth'
    administratorLogin         = $administratorLogin
    administratorLoginPassword = $administratorLoginPassword
    databasename               = 'jezzasdb'
    numberOfDatabases          = 5
}
New-AzResourceGroupDeployment @deploymentConfig

$azureSql = Connect-DbaInstance @dbaConfig

Get-DbaDatabase -SqlInstance $azureSql | Select SqlInstance , Name, IsAccessible

#endregion

#region but if we go back to 3 what happens?

$deploymentConfig = @{
    ResourceGroupName          = 'PassBeard'
    TemplateFile               = '..\Bicep\myCustomResources\05sqlserveranddatabaseswithlooprange.bicep'
    name                       = $deploymentname
    nameFromTemplate           = $instanceName
    location                   = 'uksouth'
    administratorLogin         = $administratorLogin
    administratorLoginPassword = $administratorLoginPassword
    databasename               = 'jezzasdb'
    numberOfDatabases          = 3
}
New-AzResourceGroupDeployment @deploymentConfig

$azureSql = Connect-DbaInstance @dbaConfig

Get-DbaDatabase -SqlInstance $azureSql | Select SqlInstance , Name, IsAccessible

#endregion

#region deploy with an array of names

$deploymentConfig = @{
    ResourceGroupName          = 'PassBeard'
    TemplateFile               = '..\Bicep\myCustomResources\05sqlserveranddatabaseswithlooparray.bicep'
    name                       = $deploymentname
    nameFromTemplate           = $instanceName
    location                   = 'uksouth'
    administratorLogin         = $administratorLogin
    administratorLoginPassword = $administratorLoginPassword
    databaseNames              = 'bensdb', 'bensotherdb','someotherdb','yetanotherdb'
}
New-AzResourceGroupDeployment @deploymentConfig

$azureSql = Connect-DbaInstance @dbaConfig

Get-DbaDatabase -SqlInstance $azureSql | Select SqlInstance , Name, IsAccessible

#endregion
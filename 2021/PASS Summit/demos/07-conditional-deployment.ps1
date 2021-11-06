#region just incase
if (-not $env:Path.Contains('C:\users\mrrob\.azure\bin')) {
    Write-PSFMessage "Arggh - set the path to have the bicep" -Level Output
    $env:Path = $env:Path + ';C:\users\mrrob\.azure\bin'
}
Set-Location demos
#endregion

code '..\Bicep\myCustomResources\07adminRG.bicep'

#region deploy diagnostics
$deploymentname = 'Deploy_adminRg_{0}' -f [Guid]::NewGuid().Guid


$deploymentConfig = @{
    TemplateFile = '..\Bicep\myCustomResources\07adminRG.bicep'
    name         = $deploymentname
    location     = 'uksouth'
}
New-AzDeployment @deploymentConfig

# add Robs Ip to the KeyVault firewall

Add-AzKeyVaultNetworkRule -VaultName passbeard-kv -ResourceGroupName PassBeard-Admin -IpAddressRange (whatsmyip)
#endregion


#region Deploy the dev environment
#region create random password
# I use this function from Joel Bennett to create random passwords
. ..\Functions\New-Password.ps1
$administratorLoginPassword = New-Password S24 
$administratorLoginPassword | ConvertFrom-SecureString -AsPlainText
#endregion

code '..\Bicep\myCustomResources\07conditional.bicep'

$deploymentname = 'Deploy_beard_dev_env_{0}' -f [Guid]::NewGuid().Guid
$deploymentConfig = @{
    ResourceGroupName          = 'PassBeard'
    TemplateFile               = '..\Bicep\myCustomResources\07conditional.bicep'
    name                       = $deploymentname
    nameFromTemplate           = 'beardsql'
    location                   = 'uksouth'
    administratorLogin         = 'jeremy'
    administratorLoginPassword = $administratorLoginPassword
    databasename               = 'bensdb'
    environment                = 'dev'
}
New-AzResourceGroupDeployment @deploymentConfig

# now we have the password in the key vault

$devadminpwd = (Get-AzKeyVaultSecret -VaultName passbeard-kv -Name beardsql-dev-admin-pwd).SecretValue

## Add ip to the firewall

$sqlInstance = '{0}.database.windows.net' -f 'beardsql-dev'
$firewallConfig = @{
    FirewallRuleName  = 'Robs IP' 
    StartIpAddress    = (whatsmyip) 
    EndIpAddress      = (whatsmyip)
    ServerName        = 'beardsql-dev'
    ResourceGroupName = 'PassBeard' 
}
New-AzSqlServerFirewallRule @firewallConfig | Out-Null

[pscredential]$sqlCredential = New-Object System.Management.Automation.PSCredential ('jeremy', $devadminpwd )
$dbaConfig = @{
    SqlInstance   = $sqlInstance 
    SqlCredential = $sqlCredential 
    ClientName    = 'Robs-dbatools'
}

$azureSql = Connect-DbaInstance @dbaConfig

Get-DbaDatabase -SqlInstance $azureSql | Format-Table
#endregion

#region Deploy the test environment
    #region create random password
    # I use this function from Joel Bennett to create random passwords
    . ..\Functions\New-Password.ps1
    $administratorLoginPassword = New-Password S24 
    $administratorLoginPassword | ConvertFrom-SecureString -AsPlainText
    #endregion
$deploymentname = 'Deploy_beard_test_env_{0}' -f [Guid]::NewGuid().Guid
$deploymentConfig = @{
    ResourceGroupName          = 'PassBeard'
    TemplateFile               = '..\Bicep\myCustomResources\07conditional.bicep'
    name                       = $deploymentname
    nameFromTemplate           = 'beardsql'
    location                   = 'uksouth'
    administratorLogin         = 'jeremy'
    administratorLoginPassword = $administratorLoginPassword
    databasename               = 'bensdb'
    environment                = 'test'
}
New-AzResourceGroupDeployment @deploymentConfig  | Out-Null

# now we have the password in the key vault

$testadminpwd = (Get-AzKeyVaultSecret -VaultName passbeard-kv -Name beardsql-test-admin-pwd).SecretValue

## Add ip to the firewall

$sqlInstance = '{0}.database.windows.net' -f 'beardsql-test'
$firewallConfig = @{
    FirewallRuleName  = 'Robs IP' 
    StartIpAddress    = (whatsmyip) 
    EndIpAddress      = (whatsmyip)
    ServerName        = 'beardsql-test'
    ResourceGroupName = 'PassBeard' 
}
New-AzSqlServerFirewallRule @firewallConfig

[pscredential]$sqlCredential = New-Object System.Management.Automation.PSCredential ('jeremy', $testadminpwd )
$dbaConfig = @{
    SqlInstance   = $sqlInstance 
    SqlCredential = $sqlCredential 
    ClientName    = 'Robs-dbatools'
}
$azureSql = Connect-DbaInstance @dbaConfig
Get-DbaDatabase -SqlInstance $azureSql | Format-Table
#endregion

#region Deploy the prod environment
    #region create random password
    # I use this function from Joel Bennett to create random passwords
    . ..\Functions\New-Password.ps1
    $administratorLoginPassword = New-Password S24 
    $administratorLoginPassword | ConvertFrom-SecureString -AsPlainText
    #endregion
$deploymentname = 'Deploy_beard_prod_env_{0}' -f [Guid]::NewGuid().Guid
$deploymentConfig = @{
    ResourceGroupName          = 'PassBeard'
    TemplateFile               = '..\Bicep\myCustomResources\07conditional.bicep'
    name                       = $deploymentname
    nameFromTemplate           = 'beardsql'
    location                   = 'uksouth'
    administratorLogin         = 'jeremy'
    administratorLoginPassword = $administratorLoginPassword
    databasename               = 'bensdb'
    workspaceName              = 'beard-diag'
    workspaceResourceGroup     = 'PassBeard-Admin'
    environment                = 'prod'
}
New-AzResourceGroupDeployment @deploymentConfig

# now we have the password in the key vault

$prodadminpwd = (Get-AzKeyVaultSecret -VaultName passbeard-kv -Name beardsql-prod-admin-pwd).SecretValue

## Add ip to the firewall

$sqlInstance = '{0}.database.windows.net' -f 'beardsql-prod'
$firewallConfig = @{
    FirewallRuleName  = 'Robs IP' 
    StartIpAddress    = (whatsmyip) 
    EndIpAddress      = (whatsmyip)
    ServerName        = 'beardsql-prod'
    ResourceGroupName = 'PassBeard' 
}
New-AzSqlServerFirewallRule @firewallConfig  | Out-Null

[pscredential]$sqlCredential = New-Object System.Management.Automation.PSCredential ('jeremy', $prodadminpwd )
$dbaConfig = @{
    SqlInstance   = $sqlInstance 
    SqlCredential = $sqlCredential 
    ClientName    = 'Robs-dbatools'
}
$azureSql = Connect-DbaInstance @dbaConfig
Get-DbaDatabase -SqlInstance $azureSql | Format-Table
#endregion

#region Can we get some logs

Write-PSFMessage  "Starting up deadlock scripts" -Level Significant
Write-PSFMessage "Gimme a few seconds to load up some parallel processes" -Level Significant

$sql = @"
IF OBJECT_ID('bensdb-prod..table1') IS NULL
BEGIN
	CREATE TABLE table1 (column1 int);
	INSERT INTO table1 VALUES (1);
END
IF OBJECT_ID('bensdb-prod..table2') IS NULL
BEGIN
	CREATE TABLE table2 (column1 int);
	INSERT INTO table2 VALUES (1);
END
BEGIN TRAN
UPDATE table1
SET column1 = 0
DECLARE @waitString varchar(50) = 'WAITFOR DELAY ''00:00:'+ RIGHT('0' + CAST(ABS(CHECKSUM(NEWID())) % 10 AS varchar(2)),2) +''''
EXEC(@waitString)
UPDATE table2
SET column1 = 0
ROLLBACK
BEGIN TRAN
UPDATE table2
SET column1 = 0
SET @waitString = 'WAITFOR DELAY ''00:00:'+ RIGHT('0' + CAST(ABS(CHECKSUM(NEWID())) % 10 AS varchar(2)),2) +''''
EXEC(@waitString)
UPDATE table1
SET column1 = 0
ROLLBACK
"@

1..100 | ForEach-Object -Parallel {
    Invoke-DbaQuery -SqlInstance $Using:azureSql -Database bensdb-prod -Query $Using:sql
    Write-PSFMessage  "Script $_ is finished" -Level Significant
} 

# You should see deadlocks in metrics - getting them into teh logs normally takes a while for a new database
#endregion
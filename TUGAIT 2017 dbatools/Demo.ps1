<# Where the magic happens#>
Return ' Hey Beardy This is a Demo!! '
$SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL*'  -and $_.State -eq 'Running'}).Name
$singleServer = "sql2016"

<#
Get-Help Always start with get-help
#>


<#
    Test Latency
    You can use a custom query and define the number of retries
#>
Test-SqlNetworkLatency -SqlServer $SQLServers -Query "SELECT * FROM master.sys.databases" -Count 4

#Test connection to instances
Test-SqlConnection -SqlServer $OneSQLServer

$SQLServers | % {Test-SqlConnection -SqlServer $_}

<#
    Get UpTime
    Can be only SQL or only Windows
#>
Get-DbaUptime -SqlServer $servers -WindowsOnly



<#
    Get TCP port
    Use -Detailed to find all instances on the server
#>
Get-DbaTcpPort -SqlServer $servers | Format-Table


<# SP_configure difference between two servers and copy Windows to Linux

NEEDS COMMENTS -0 RMS
#>

## We have to compare the Configuration for 2 servers to make sure that the new server is the same as the old one
## We are going to show that (some) dbatools commands work with SQL on Linux :-)

## First we will use Connect-DbaSqlServer - the best way to create a validated SMO object
$linuxSQL = 'LinuxvNextCTP14'
$WinSQl1 = 'SQL2017CTP2'
$cred = Get-Credential -UserName SA -Message "Linux SQL Auth"
$linux = Connect-DbaSqlServer -SqlServer $linuxSQL  -Credential $cred -ConnectTimeout 60
$win = Connect-DbaSqlServer -SqlServer $WinSQl1

## Then we shall create a simple function to compare the two spconfigures with Get-DbaSpConfigure
Function Compare-WinLinuxConfigs
{
    #Get the configurations
$linuxSpConfigure = Get-DbaSpConfigure  -SqlServer $linuxSQL -SqlCredential $cred
$WinSPConfigure = Get-DbaSpConfigure -SqlServer $WinSQl1
#Compare them
$propcompare = foreach ($prop in $linuxSpConfigure) {
    [pscustomobject]@{
    Config = $prop.DisplayName
    'Linux setting' = $prop.RunningValue
    'Windows Setting' = $WinSPConfigure | Where DisplayName -eq $prop.DisplayName | Select -ExpandProperty RunningValue
    }
}
## Put them in Out-GridView
$propcompare | ogv
}

Compare-WinLinuxConfigs

## Set to a windows server as it is quicker
$linuxSQL = 'SQL2016N1'
$linux = Connect-DbaSqlServer -SqlServer $linuxSQL

## lets alter the default backup compression setting
$win.Configuration.Properties['DefaultBackupCompression'].ConfigValue = 1
$win.Configuration.Alter()

# and compare them
Compare-WinLinuxConfigs

# so know we need to make them the same
Copy-SqlSpConfigure -Source $WinSQl1 -Destination $linuxSQL -DestinationSqlCredential $cred -Configs DefaultBackupCompression

# and compare them
Compare-WinLinuxConfigs

## Now lets alter the linux server and compare

$linux.Configuration.Properties['DefaultBackupCompression'].ConfigValue = 0
$linux.Configuration.Alter()
Compare-WinLinuxConfigs

# They are different - Maybe we dont have the servers connected
# Maybe the new server is not built yet
# Maybe we need to have the configuration in a file for auditing
# Lets export it to file with Export-SqlSpConfigure

$linuxConfigPath = 'C:\Temp\Linuxconfig.sql'
Export-SqlSpConfigure -SqlServer $linuxSQL -SqlCredential $cred -Path $LinuxConfigPath
notepad $linuxConfigPath

# if we export the windows configuration
$WinConfigPath = 'C:\Temp\Winconfig.sql'
Export-SqlSpConfigure -SqlServer $WinSQl1 -Path $winConfigPath
notepad $winConfigPath

# We can use it to make the linux server the same - remember we changed the backup  compression
Import-SqlSpConfigure -Path $WinConfigPath -SqlServer $linuxSQL -SqlCredential $cred


Compare-WinLinuxConfigs

<# Test- Set Max Memory #>

# Lets Test our Max Memory
Test-DbaMaxMemory -SqlServer $SQLServers | ogv

## look at the Avaialbility Group Servers, Thats not right
## Lets make it correct

Test-DbaMaxMemory -SqlServer SQL2012Ser08AG1 ,SQL2012Ser08AG2, SQL2012Ser08AG3  | Where-Object { $_.SqlMaxMB -gt $_.TotalMB } | Set-DbaMaxMemory
Test-DbaMaxMemory -SqlServer SQL2012Ser08AG1 ,SQL2012Ser08AG2, SQL2012Ser08AG3 | ogv

## What if we have 2 instances?
Test-DbaMaxMemory -SqlServer $singleServer


<#
    Temdb

    By default only best practices rules not in use are showed. Use -Detailed to get also the ones already in use
#>
Test-SqlTempDbConfiguration -SqlServer $singleServer

Test-SqlTempDbConfiguration -SqlServer $singleServer -Detailed

<#
    Disclaimer: The function will not perform any actions that would shrink or delete data files.
    If a user desires this, they will need to reduce tempdb so that it is â€œsmallerâ€ than what the
    function will size it to before running the function.

    You can force the number of files
    You have to say the total size you want for tempdb
#>
Set-SqlTempDbConfiguration -SqlServer $singleServer -DataFileCount 4 -datafilesizemb 4096


<# DBCC CheckDb #>
# You can use the SQLServer Provider to read your Registered Servers or CMS
# cd 'SQLSERVER:\sqlregistration\database engine server group\BEARDNUC'
# $2016servers = (Get-ChildItem).Where{$_.Name -like '*SQL2016N*'}.Name

# When was the last good CheckDb - Cláudio please explain how to do it in T-SQL
# I'll do it like this!!
$2016Servers = $SQLServers.Where{$_ -like '*2016*'} #Note: the .Where method only works on PowerShell v4+
Get-DbaLastGoodCheckDb -SqlServer $2016servers | ogv

<# Find-DBAStoredProcedure #>



<# Test-DBAIdentity #>

# I want to add a row to a table and I ge this error

$Query = @"
INSERT INTO [HumanResources].[Shift]
([Name],[StartTime],[EndTime],[ModifiedDate])
VALUES
( 'The Beards Favourite Shift','10:00:00.0000000','11:00:00.0000000',GetDate())
"@

Invoke-SQLCmd2 -ServerInstance $singleServer -Database AdventureWorks2014 -Query $Query

## Arithmetic overflow error converting IDENTITY to data type tinyint.

## Claudio Please explain what is happening

## But we can quickly and easily see that

Test-DbaIdentityUsage -SqlInstance ROB-XPS -NoSystemDb -Threshold 70 | ogv

## You can look at a whole server
Test-DbaIdentityUsage -SqlInstance ROB-XPS, ROB-XPS\DAVE -NoSystemDb | ogv

## or a number of servers

Test-DbaIdentityUsage -SqlInstance $2016Servers -NoSystemDb | Ogv

=======

## 30 minutes
<# Find-DbaDatabaseGrowthEvent #>
Invoke-Sqlcmd2 -ServerInstance $singleServer -Query "IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'AutoGrowth')
BEGIN
	ALTER DATABASE [AutoGrowth] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE IF EXISTS [AutoGrowth]
END
CREATE DATABASE AutoGrowth;"


$queryConfigureDatabase = @"
DBCC SHRINKFILE (N'AutoGrowth' , 1)
DBCC SHRINKFILE (N'AutoGrowth_log' , 1)
ALTER DATABASE [AutoGrowth] MODIFY FILE ( NAME = N'AutoGrowth', FILEGROWTH = 1024KB )
ALTER DATABASE [AutoGrowth] MODIFY FILE ( NAME = N'AutoGrowth_log', FILEGROWTH = 1024KB )
"@
Invoke-Sqlcmd2 -ServerInstance $singleServer -Query $queryConfigureDatabase



<# Get-DbaDatabaseFreespace #>
Get-DbaDatabaseFreespace -SqlServer $singleServer -Database AutoGrowth | OGV


$queryForceAutoGrowthEvents = @"
DROP TABLE IF EXISTS ToGrow
CREATE TABLE ToGrow
(
    ID BIGINT PRIMARY KEY IDENTITY(1,1)
    ,SomeText VARCHAR(8000) DEFAULT(REPLICATE('A', 80000))
)
DECLARE @Iteration INT = 1
WHILE (@Iteration < 2000)
	BEGIN
		INSERT INTO ToGrow (SomeText)
		DEFAULT VALUES;

		SET @Iteration += 1;
	END
"@
Invoke-Sqlcmd2 -ServerInstance $singleServer -Query $queryForceAutoGrowthEvents -Database AutoGrowth


Find-DbaDatabaseGrowthEvent -SqlInstance $singleServer -Database AutoGrowth | OGV


<# Read-DBAtransactionlog #>
Read-DbaTransactionLog -SqlInstance $singleServer -Database AutoGrowth | OGV

<# Get-DbaDatabaseFreespace #>
Get-DbaDatabaseFreespace -SqlServer $singleServer -Database AutoGrowth | OGV



<# Orphaned File #>

## We are running out of space Rob
## Clean up the Orphaned Files

## I can find them like this

Find-DbaOrphanedFile -SqlServer SQL2016N2 | ogv

## How much space are they using up ?

((Find-DbaOrphanedFile -SqlInstance SQL2016N2 -RemoteOnly | Get-ChildItem | Select -ExpandProperty Length | Measure-Object -Sum)).Sum / 1MB

## Hmm Probably better remove them
Find-DbaOrphanedFile -SqlInstance SQL2016N2 -RemoteOnly | Remove-Item -Whatif

## Lets remove them!!
Find-DbaOrphanedFile -SqlInstance SQL2016N2 -RemoteOnly | Remove-Item

<# Start-Up Parameters #>

## Hey we are getting different results between our production server SQL2016N3 and our dev and Test N1 and N2
## Why is that????

Get-DbaStartupParameter -SqlServer SQL2016N3, SQL2016N1,SQL2016N2 | ogv

<## INDEXES ##>

Get-DbaHelpIndex -SqlServer sql2016N1 -Databases Viennadbareports -IncludeStats -IncludeDataTypes |ogv

<# Duplicate Indexes #>


## ADD DUPLICATE INDEXES - RMS
$CreateDuplicatedIndexes = @"
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ProdId' AND [object_id] = object_id('Sales.SalesOrderDetail'))
	DROP INDEX [Sales].[SalesOrderDetail].[IX_ProdId]

CREATE NONCLUSTERED INDEX [IX_ProdId] ON [Sales].[SalesOrderDetail]
(
	[ProductID] ASC
)

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SalesOrderDetail_ProductID__ICarrierTrackingNumber' AND [object_id] = object_id('Sales.SalesOrderDetail'))
	DROP INDEX [Sales].[SalesOrderDetail].[IX_SalesOrderDetail_ProductID__ICarrierTrackingNumber]

CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_ProductID__ICarrierTrackingNumber] ON [Sales].[SalesOrderDetail]
(
	[ProductID] ASC
)
INCLUDE
(
	[CarrierTrackingNumber]
)

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SalesOrderDetail_ProductID__FUnitPrice' AND object_id = object_id('Sales.SalesOrderDetail'))
	DROP INDEX [Sales].[SalesOrderDetail].[IX_SalesOrderDetail_ProductID__FUnitPrice]

CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_ProductID__FUnitPrice] ON [Sales].[SalesOrderDetail]
(
	[ProductID] ASC
)
INCLUDE
(
	[CarrierTrackingNumber]
)
WHERE ([UnitPrice] > 100)


IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SalesOrderDetail_ProductID__FUnitPrice1000' AND object_id = object_id('Sales.SalesOrderDetail'))
	DROP INDEX [Sales].[SalesOrderDetail].[IX_SalesOrderDetail_ProductID__FUnitPrice1000]

CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_ProductID__FUnitPrice1000] ON [Sales].[SalesOrderDetail]
(
	[ProductID] ASC
)
WHERE ([UnitPrice] > 1000)
"@
Invoke-Sqlcmd2 -ServerInstance ROB-XPS -Database AdventureWorks2014


## Rob - Can you find the duplicate indexes for me please

Find-SqlDuplicateIndex -SqlServer sql2016n1

Find-SqlDuplicateIndex -SqlServer sql2016n1 -IncludeOverlapping -FilePath  c:\temp\indexes.txt
notepad c:\temp\indexes.txt

## Cláudio to create overlapping indexes in AdventureWorks2014

Find-SqlDuplicateIndex -SqlServer ROB-XPS -IncludeOverLapping

<# Unused Indexes #>

## NEED A VIDEO for this as SQL will have just restarted

<# SPNs #>


<# Test-SQLPath #>

Test-SqlPath -SqlServer SQL2016N1 -Path Z:

Describe 'Testing Access to Backup Share' -Tag Server, Backup {
## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
$SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
## create the test cases array
$testCases= @()
$SQLServers.ForEach{$testCases += @{Name = $_}}
    It "<Name> has access to Backup Share Z:" -TestCases $testCases {
        Param($Name)
        Test-SqlPath -SqlServer $Name -Path Z: | Should Be $True
    }
}

<# SMO explore - Connect-DBASQLServer #>

## The best way to create an SMO object these days

$srv = Connect-DbaSqlServer -SqlServer SQL2017CTP2

$srv | Get-Member -MemberType Property

$srv.Version

$srv.Databases.Name

$srv.LoginMode

$srv.JobServer.Jobs

$srv.Databases | Get-Member -MemberType Methods

$srv.Databases['DBA-Admin'].Script()

$srv.Databases['DBA-Admin'].tables[0].script()

<# Remove-SQLDatabaseSafely #>

Remove-SQLDatabaseSafely -SqlServer ROB-XPS -Databases ProviderDemo -BackupFolder C:\MSSQL\Backup 

<# Backup history #>

Get-DbaLastBackup -sqlserver sql2016n1 | ogv

Get-DbaBackupHistory -SqlServer SQL2016N1 | ogv

Get-DbaBackupHistory -SqlServer SQL2016N1 -LastFull

Get-DbaBackupHistory -SqlServer SQL2016N1 -Last | ogv

Get-DbaBackupHistory -SqlServer SQL2016N1 -Databases VideoDemodbareports -Raw| ogv

<# Restore to a new server #>

Backup-DbaDatabase -SqlInstance sql2016n1 -Databases Viennadbareports -BackupDirectory \\SQL2016N2\SQLBackups | Restore-DbaDatabase -SqlServer sql2016n2 -DatabaseName Lisbondbareports

## But what if you use the same server it wont work
Backup-DbaDatabase -SqlInstance sql2016n1 -Databases Viennadbareports -BackupDirectory \\SQL2016N2\SQLBackups | Restore-DbaDatabase -SqlServer sql2016n1 -DatabaseName Lisbondbareports -DestinationFilePrefix Lisbon

<# Chrissy's blog post about a restore server #>



<# Copy-SQLJob #>

Copy-SqlJob -Source SQL ## write this Rob


<# Pester Tests #>

cd GIT:\dbatools-scripts
code-insiders .\TestConfig.json
code-insiders '.\Pester Test Backup Share - Server level.Tests.ps1'

$Config = (Get-Content TestConfig.JSON) -join "`n" | ConvertFrom-Json
Invoke-Pester

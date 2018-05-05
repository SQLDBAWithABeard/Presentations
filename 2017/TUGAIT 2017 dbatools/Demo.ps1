<# Where the magic happens#>
Return 'Hey Beardy This is a Demo!! '
$SQLServers = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL2016N1' -or $_.Name -Like '*SQL*2012*' -or $_.Name -Like '*SQL*2014*' -or $_.Name -Like '*SQL*2008*'  -or $_.Name -Like '*SQL*2005*'  -and $_.State -eq 'Running'}).Name
$singleServer = "Rob-XPS"

<#
Get-Help Always start with get-help

Get-Help  Test-SQLConnection -Full
#>
 
 #Test connection to instances
Test-SqlConnection -SqlServer $SingleServer

$SQLServers[0..3] | % {Test-SqlConnection -SqlServer $_}

<#
    Test Latency
    You can use a custom query and define the number of retries
#>
Test-SqlNetworkLatency -SqlServer $SQLServers -Query "SELECT * FROM master.sys.databases" -Count 4 | Format-Table

<#
    Get TCP port
    Use -Detailed to find all instances on the server
#>

Get-DbaTcpPort -SqlServer $sqlservers -Detailed -WarningAction SilentlyContinue| Format-Table -AutoSize



<# SP_configure difference between two servers and copy Windows to Linux

NEEDS COMMENTS -0 RMS
#>

## We have to compare the Configuration for 2 servers to make sure that the new server is the same as the old one
## We are going to show that (some) dbatools commands work with SQL on Linux :-)

## First we will use Connect-DbaSqlServer - the best way to create a validated SMO object
$WinSQL2 = 'LinuxvNextCTP14'
$WinSQl1 = 'SQL2017CTP2'
$cred = Get-Credential -UserName SA -Message "SQL Auth"
$win2 = Connect-DbaSqlServer -SqlServer $WinSQL2  -Credential $cred
$win = Connect-DbaSqlServer -SqlServer $WinSQl1

## Then we shall create a simple function to compare the two spconfigures with Get-DbaSpConfigure
Function Compare-SPConfigs
{
    #Get the configurations
$win2SpConfigure = Get-DbaSpConfigure  -SqlServer $WinSQL2 -SqlCredential $cred
$WinSPConfigure = Get-DbaSpConfigure -SqlServer $WinSQl1
#Compare them
$propcompare = foreach ($prop in $win2SpConfigure) {
    [pscustomobject]@{
    Config = $prop.DisplayName
    'Instance 2 setting' = $prop.RunningValue
    'Instance 1 Setting' = $WinSPConfigure | Where DisplayName -eq $prop.DisplayName | Select -ExpandProperty RunningValue
    }
}
## Put them in Out-GridView
$propcompare | ogv
}

Compare-SPConfigs

## lets alter the default backup compression setting

$win.Configuration.Properties['DefaultBackupCompression'].ConfigValue = 0
$win.Configuration.Alter()

# and compare them
Compare-SPConfigs

# so know we need to make them the same
Copy-SqlSpConfigure -Source $WinSQl1 -Destination $WinSQL2 -DestinationSqlCredential $cred -Configs DefaultBackupCompression

# and compare them
Compare-SPConfigs

## Now lets alter the linux server and compare
$win2.Configuration.Properties['DefaultBackupCompression'].ConfigValue = 0
$win2.Configuration.Alter()
Compare-SPConfigs

# They are different - Maybe we dont have the servers connected
# Maybe the new server is not built yet
# Maybe we need to have the configuration in a file for auditing
# Lets export it to file with Export-SqlSpConfigure
$WinSQL2ConfigPath = 'C:\Temp\Linuxconfig.sql'
Export-SqlSpConfigure -SqlServer $WinSQL2 -SqlCredential $cred -Path $WinSQL2ConfigPath
notepad $WinSQL2ConfigPath

# if we export the windows configuration
$WinConfigPath = 'C:\Temp\Winconfig.sql'
Export-SqlSpConfigure -SqlServer $WinSQl1 -Path $winConfigPath
notepad $winConfigPath

# We can use it to make the linux server the same - remember we changed the backup  compression
Import-SqlSpConfigure -Path $WinConfigPath -SqlServer $WinSQL2 -SqlCredential $cred


Compare-SPConfigs

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

Test-SqlTempDbConfiguration -SqlServer $singleServer -Detailed | ft -AutoSize -Wrap

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
$2016Servers = $SQLServers.Where{$_ -like '*2016*' -or $_ -like '*2014*'} #Note: the .Where method only works on PowerShell v4+
Get-DbaLastGoodCheckDb -SqlServer $2016servers | ogv

<# Find-DBAStoredProcedure #>

Find-DbaStoredProcedure -SqlInstance $singleserver -database AdventureWorks2014 -Pattern 'Name' |ogv

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
Test-DbaIdentityUsage -SqlInstance ROB-XPS -NoSystemDb | ogv

## or a number of servers

Test-DbaIdentityUsage -SqlInstance $2016Servers -NoSystemDb | Ogv


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

$Files = Find-DbaOrphanedFile -SqlServer SQL2016N2
$Files 

(($Files |% { Get-ChildItem $_.RemoteFileName | Select -ExpandProperty Length} ) | Measure-Object -Sum).Sum / 1Mb

$Files.RemoteFileName  | Remove-Item -Force


<# Start-Up Parameters #>

## Get-DbaStartupParameter -SqlInstance  SQL2016N1,SQL2016N2,SQL2016N3 

<## INDEXES ##>

Get-DbaHelpIndex -SqlServer sql2016N1 -Databases Viennadbareports -IncludeStats -IncludeDataTypes |ogv

<# Duplicate Indexes #>

## ADD DUPLICATE INDEXES - RMS
$query= @"
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
Invoke-Sqlcmd2 -ServerInstance ROB-XPS -Database AdventureWorks2014 -query $query


## Rob - Can you find the duplicate indexes for me please

Find-SqlDuplicateIndex -SqlServer ROB-XPS

Find-SqlDuplicateIndex -SqlServer ROB-XPS -IncludeOverlapping -FilePath  c:\temp\indexes.txt
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

$srv.Databases

$srv.LoginMode

$srv.JobServer.Jobs

$srv.Databases | Get-Member -MemberType Methods

$srv.Databases['DBA-Admin'].Script()

$srv.Databases['DBA-Admin'].tables[0].script()


<# Backup history #>

Get-DbaBackupHistory -SqlServer SQL2016N1 | ogv

Get-DbaBackupHistory -SqlServer SQL2016N1 -LastFull

Get-DbaBackupHistory -SqlServer SQL2016N1 -Last | ogv

Get-DbaBackupHistory -SqlServer SQL2016N1 -Databases VideoDemodbareports -Raw| ogv

<# Restore to a new server #>
Backup-DbaDatabase -SqlInstance sql2016n1 -Databases Viennadbareports -BackupDirectory \\SQL2016N2\SQLBackups | Restore-DbaDatabase -SqlServer sql2016n2 -DatabaseName Lisbondbareports

## But what if you use the same server it wont work
Backup-DbaDatabase -SqlInstance sql2016n1 -Databases Viennadbareports -BackupDirectory \\SQL2016N2\SQLBackups | Restore-DbaDatabase -SqlServer sql2016n1 -DatabaseName Lisbondbareports -DestinationFilePrefix Lisbon

<# Chrissy's blog post about a restore server #>


<# remove-SQLDatabaseSafely #>


<# Copy-SQLJob #>



$Config = (Get-Content TestConfig.JSON) -join "`n" | ConvertFrom-Json
Invoke-Pester


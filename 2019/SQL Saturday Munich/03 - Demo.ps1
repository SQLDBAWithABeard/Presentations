#region Setup Variables
. .\vars.ps1
$ErrorActionPreference = 'SilentlyContinue'
#endregion

#region Reset Admin

Start-Process https://www.youtube.com/watch?v=FRhg0ZTQ3vI

Get-DbaLogin -SqlInstance $sql1 |Format-Table

Reset-DbaAdmin -SqlInstance $SQL1 -Login TheBeard

Get-DbaLogin -SqlInstance $sql1 |Format-Table

$query = @"
CREATE TABLE PlaceForTheStolenThings
    (
	StolenThingsID int NOT NULL, 
	UserName nvarchar(30) NULL, 
	Email nvarchar(50) NULL,
	IsAdmin bit NULL,
	UserPassword nvarchar(150) NULL, 
	ADGroupMembership nvarchar(MAX) NULL
    CONSTRAINT StolenThings PRIMARY KEY (StolenThingsID)
    )
    GO

    BEGIN TRAN
    INSERT INTO PlaceForTheStolenThings VALUES
    (1,'TheBoss','Boss@TheBeard.Local', 1,'WhyDoesItHaveToBeLikeThis','Domain Admin,Bosses Secret Group')
"@

$query | clip
#endregion

#region Wotcha doing ?

# Does resetting admin command mean any admin can create their own sysadmin account?
## Yes it does
## So why not source control your logins like Claudio Silva does http://redglue.eu/have-you-backed-up-your-sql-logins-today/?
Export-DbaLogin -SqlInstance $sql1

## You can do it to a file and then source control it

Export-DbaLogin -SqlInstance $sql1 -FilePath c:\temp\sql1_users.sql

Find-DbaCommand -Pattern permissions

Invoke-Item c:\temp\sql1_users.sql

## Maybe you like sp_WhoIsActive?

"SELECT * FROM PlaceForTheStolenThings
GO 50" | clip

## easy to install
Install-DbaWhoIsActive -SqlInstance $sql1 -Database tempdb

Invoke-DbaWhoIsActive -SqlInstance $sql1 -Database tempdb

## What about Glenn Berry's Diagnostic Queries ?

# Diagnostic query!

Start-Process https://www.sqlskills.com/blogs/glenn/category/dmv-queries/

Explorer "$Home\Documents\Glenn Berry Diagnostic Queries"
$sql0| Invoke-DbaDiagnosticQuery -UseSelectionHelper | Export-DbaDiagnosticQuery -Path "$Home\Documents\Glenn Berry Diagnostic Queries"


#endregion

#region Clones and snapshots

## Maybe we want to test query performance without requiring all the space needed for the data in the database

$invokeDbaDatabaseCloneSplat = @{
    SqlInstance = $sql0
    CloneDatabase = 'NorthWind_CLONE'
    UpdateStatistics = $true
    Database = 'NorthWind'
}
Invoke-DbaDbClone @invokeDbaDatabaseCloneSplat

## Now run in SSMS

<#

    SELECT c.CategoryName,
  (select sum(val)
   from (SELECT TOP 5 od2.UnitPrice*od2.Quantity as val
         FROM [Order Details] od2, Products p2
         WHERE od2.ProductID = p2.ProductID
         AND c.CategoryID = p2.CategoryID
         ORDER BY 1 DESC
        ) t
  ) AS "5 top orders in 1997"
FROM [Order Details] od, Products p, Categories c, Orders o 
WHERE od.ProductID = p. ProductID
AND p.CategoryID = c.CategoryID
AND od.OrderID = o.OrderID
AND YEAR(o.OrderDate) = 1997
GROUP BY c.CategoryName, c.CategoryId
#>

## We can also get the execution plan
Get-DbaExecutionPlan -SqlInstance $sql0 -Database NorthWind_CLONE

# create a snapshot
New-DbaDbSnapshot -SqlInstance localhost -Database Beard1 -Name NorthWind_snap

Get-DbaDbSnapshot -SqlInstance localhost

Get-DbaProcess -SqlInstance localhost -Database Beard1  | Stop-DbaProcess
Get-DbaProcess -SqlInstance localhost -Database NorthWind_snap| Stop-DbaProcess

# restore from snapshot
Restore-DbaDbSnapshot -SqlInstance localhost -Database Beard1 -Snapshot NorthWind_snap

Remove-DbaDbSnapshot -SqlInstance localhost -Snapshot NorthWind_snap # or -Database AdventureWorks2014

#endregion


#region Find the thing

$SQLInstances | Find-DbaStoredProcedure -Pattern employee | Out-GridView

# Maybe you want to find all the hardcoded email addresses :-) in 21664 stored procedures

$SQLInstances | Find-DbaStoredProcedure -Pattern '\w+@\w+\.\w+' 

## Hmm

($sql0 | Find-DbaStoredProcedure -Pattern '\w+@\w+\.\w+').StoredProcedure.TextHeader

# We can find triggers

$SQLInstances  | Find-DbaTrigger -Pattern ddl -SqlCredential $cred

# We can find views

$SQLInstances | Find-DbaView -Pattern email -SqlCredential $cred

# We can find indexes

Find-DbaUnusedIndex -SqlInstance $sql0 -Database pubs 

Find-DbaDisabledIndex -SqlInstance $sql0

Find-DbaDuplicateIndex -SqlInstance $sql0 | Out-GridView

## Whilst we are here lets look at our indexes

Get-DbaHelpIndex -SqlInstance $sql0 -Database pubs | Out-GridView

$getDbaHelpIndexSplat = @{
    Database = 'AdventureWorks2014'
    ObjectName = '[Sales].[SalesOrderDetail]'
    IncludeStats = $true
    IncludeDataTypes = $true
    SqlInstance = $sql0
}
Get-DbaHelpIndex @getDbaHelpIndexSplat | Out-GridView

# find user owned objects for when an employee is leaving

Find-DbaUserObject -SqlInstance $SQL0 -Pattern sqladmin

## We can find when a database grew

Find-DbaDbGrowthEvent -SqlInstance $sql1 | Format-Table

#endregion

#region Query Store

# You can get your Query Store options 
Get-DbaDbQueryStoreOption -SqlInstance $sql0 -Database pubs 

# You can also set them 

Set-DbaDbQueryStoreOption -SqlInstance $sql0 -Database pubs -MaxSize 200 
Set-DbaDbQueryStoreOption -SqlInstance $sql0 -Database pubs -MaxSize 200 -State ReadWrite
#endregion

#region Query

# Quickly find slow query executions within a database

Get-DbaQueryExecutionTime -SqlInstance $sql0 -Database NorthWind  -MinExecMs 0 -MinExecs 1 | Out-GridView

#endregion

#region sp_Configure

$linux = Connect-DbaInstance -SqlInstance $sql0

Function Compare-DbaSPConfig {

    Param(
        $SourceInstance,
        $DestinationInstance,
        $SourceSqlCredential,
        $DestinationSqlCredential
    )
    $SourceSpConfigure = Get-DbaSpConfigure  -SqlInstance $SourceInstance -SqlCredential $SourceSQLCredential
    $DestSPConfigure = Get-DbaSpConfigure -Sqlinstance $DestinationInstance -SqlCredential $DestinationSqlCredential

    $propcompare = foreach ($prop in $SourceSpConfigure) {
        [pscustomobject]@{
            Config            = $prop.DisplayName
            'Source_setting'   = $prop.RunningValue
            'Destination_Setting' = $DestSPConfigure | Where DisplayName -eq $prop.DisplayName | Select -ExpandProperty RunningValue
        }
    } 

    $propcompare  | Out-GridView -Title "Comparing Sp_configure Settings Source - $SourceInstance With Destination $DestinationInstance"
}

Compare-DbaSPConfig -SourceInstance $sql0 -SourceSqlCredential $cred -DestinationInstance $sql0 -DestinationSqlCredential $cred

Copy-DbaSpConfigure -Source $sql0 -Destination $sql1 -ConfigName DefaultBackupCompression

Compare-DbaSPConfig -SourceInstance $sql0 -DestinationInstance $sql1  -SourceSqlCredential $cred -DestinationSqlCredential $cred

$linux.Configuration.Properties['DefaultBackupCompression'].ConfigValue = 1
$linux.Configuration.Alter()

Compare-DbaSPConfig -SourceInstance $sql0 -DestinationInstance $sql1  -SourceSqlCredential $cred -DestinationSqlCredential $cred


$linuxConfigPath = 'C:\Temp\Linuxconfig.sql'
Export-DbaSpConfigure -SqlInstance $sql0 -FilePath $LinuxConfigPath
code-insiders $linuxConfigPath

$WinConfigPath = 'C:\Temp\Winconfig.sql'
Export-DbaSpConfigure -SqlServer localhost -FilePath $winConfigPath
code-insiders  $winConfigPath

Import-DbaSpConfigure -Path $WinConfigPath -SqlServer $sql1 

Compare-DbaSPConfig -SourceInstance localhost -DestinationInstance $sql1  -SourceSqlCredential $cred -DestinationSqlCredential $cred

#endregion





$ErrorActionPreference = 'Continue'





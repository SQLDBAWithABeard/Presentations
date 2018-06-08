#region Setup Variables
. .\vars.ps1
#endregion

#region Reset Admin

Get-DbaLogin -SqlInstance $sql1 |Format-Table

Reset-DbaAdmin -SqlInstance $SQL1 -Login TheBeard 

Get-DbaLogin -SqlInstance $sql1 |Format-Table

## connect in SSMS and run 

<#
    USE tempdb
    GO

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

#>
#endregion

#region Wotcha doing ?

# Does resetting admin command mean any admin can create their own sysadmin account?
## Yes it does
## So why not source control your logins like Claudio Silva does http://redglue.eu/have-you-backed-up-your-sql-logins-today/?
Export-DbaLogin -SqlInstance $sql1

## You can do it to a file and then source control it

Export-DbaLogin -SqlInstance $sql1 -FilePath c:\temp\sql1_users.sql

## But maybe you want to see what is going on

Get-DbaProcess -SqlInstance $sql1

Get-DbaProcess -SqlInstance $sql1 |Out-GridView

# or the open transactions

Get-DbaOpenTransaction -SqlInstance $sql1

## Oh

## Email from manager

$newBurntToastNotificationSplat = @{
    Text = 'FROM THE BOSS - Keep this CONFIDENTIAL', 'I NEED to know immediately what the user account TheBeard did on SQL1 DROP EVERYTHING and DO IT NOW','Angry Manager'
    AppLogo = 'C:\Users\enterpriseadmin.THEBEARD\Desktop\angryboss.jpg'
}
New-BurntToastNotification @newBurntToastNotificationSplat

## Hmm Better get onto this quick

Get-DbaProcess -SqlInstance $sql1 -Login TheBeard | Out-GridView

Read-DbaTraceFile -SqlInstance $sql1 -Login TheBeard | Out-GridView

Get-DbaSchemaChangeHistory -SqlInstance $sql1 -Database tempdb

## Maybe you like sp_WhoIsActive?

## easy to install
Install-DbaWhoIsActive -SqlInstance $sql1 -Database tempdb

## easy to use
Invoke-DbaWhoisActive -SqlInstance $sql1 | Out-GridView

## Thats it Get him off my instance

Get-DbaProcess -SqlInstance $sql1 -Login TheBeard | Stop-DbaProcess -confirm:$false

Get-DbaProcess -SqlInstance $sql1 -Login TheBeard

## In fact I don't want his login there

Get-DbaLogin -SqlInstance $sql1 -Login TheBeard | Remove-DbaLogin -Confirm:$false

## Much better :-)

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
    CloneDatabase = 'AdventureWorks2014_CLONE'
    UpdateStatistics = $true
    Database = 'AdventureWorks2014'
}
Invoke-DbaDatabaseClone @invokeDbaDatabaseCloneSplat

## Now run in SSMS

<#

    USE [AdventureWorks2014];
    GO
 
    SELECT *
    FROM [Sales].[SalesOrderHeader] [h]
    JOIN [Sales].[SalesOrderDetail] [d] ON [h].[SalesOrderID] = [d].[SalesOrderID]
    ORDER BY [SalesOrderDetailID];
    GO
 
    USE [AdventureWorks2014_CLONE];
    GO
 
    SELECT *
    FROM [Sales].[SalesOrderHeader] [h]
    JOIN [Sales].[SalesOrderDetail] [d] ON [h].[SalesOrderID] = [d].[SalesOrderID]
    ORDER BY [SalesOrderDetailID];
    GO
#>

## We can also get the execution plan
Get-DbaExecutionPlan -SqlInstance $sql0 -Database AdventureWorks2014_CLONE

# create a snapshot
New-DbaDatabaseSnapshot -SqlInstance $sql0 -Database AdventureWorks2012 -Name AD2012_snap

Get-DbaDatabaseSnapshot -SqlInstance $sql0

Get-DbaProcess -SqlInstance $sql0 -Database AdventureWorks2012 | Stop-DbaProcess
Get-DbaProcess -SqlInstance $sql0 -Database AD2012_snap| Stop-DbaProcess

# restore from snapshot
Restore-DbaFromDatabaseSnapshot -SqlInstance $sql0 -Database AdventureWorks2012 -Snapshot AD2012_snap

Remove-DbaDatabaseSnapshot -SqlInstance $sql0 -Snapshot AD2012_snap # or -Database AdventureWorks2014

#endregion

#region SPNs

Get-DbaSpn -ComputerName $sql0

setspn.exe -D "MSSQLSvc/SQL0.TheBeard.Local:1433" "TheBeard\EnterpriseAdmin"

Test-DbaSpn -ComputerName $sql0

Get-DbaSpn -ComputerName $sql0

(Test-DbaSpn -ComputerName $sql0).Where{$_.IsSet -eq $false} | Set-DbaSpn -WhatIf
(Test-DbaSpn -ComputerName $sql0).Where{$_.IsSet -eq $false} | Set-DbaSpn

Get-DbaSpn -ComputerName $sql0
#endregion

#region Find the thing

$containers | Find-DbaStoredProcedure -Pattern employee  -SqlCredential $cred | Out-GridView

# Maybe you want to find all the hardcoded email addresses :-) in 21664 stored procedures

$sql0 | Find-DbaStoredProcedure -Pattern '\w+@\w+\.\w+' 

## Hmm

($sql0 | Find-DbaStoredProcedure -Pattern '\w+@\w+\.\w+').StoredProcedure.TextHeader

# We can find triggers

$containers | Find-DbaTrigger -Pattern ddl -SqlCredential $cred

# We can find views

$containers | Find-DbaView -Pattern email -SqlCredential $cred

# We can find indexes

Find-DbaUnusedIndex -SqlInstance $sql0 -Database AdventureWorks2014 

Find-DbaDisabledIndex -SqlInstance $sql0

Find-DbaDuplicateIndex -SqlInstance $sql0 | Out-GridView

## Whilst we are here lets look at our indexes

Get-DbaHelpIndex -SqlInstance $sql0 -Database AdventureWorks2014 | Out-GridView

$getDbaHelpIndexSplat = @{
    Database = 'AdventureWorks2014'
    ObjectName = '[Sales].[SalesOrderDetail]'
    IncludeStats = $true
    IncludeDataTypes = $true
    SqlInstance = $sql0
}
Get-DbaHelpIndex @getDbaHelpIndexSplat | Out-GridView

# find user owned objects for when an employee is leaving

Find-DbaUserObject -SqlInstance $SQL0 -Pattern TheBeard\EnterpriseAdmin

## We can find when a database grew

Find-DbaDbGrowthEvent -SqlInstance $sql0 | Format-Table

#endregion

#region Extended Events

# Convert Traces to XE (h/t Jonathan Kehayias)
Get-DbaTrace -SqlInstance $sql0 | ConvertTo-DbaXESession -Name 'Default Trace' | Start-DbaXESession

# need to open in a seperate window as it doesnt respect CTRL C to cancel :-)
Start powershell {Get-DbaXESession -SqlInstance sql0 -Session AlwaysOn_health | Watch-DbaXEventSession}

Switch-SqlAvailabilityGroup -Path SQLSERVER:\SQL\SQL1\DEFAULT\AvailabilityGroups\SQLClusterAG

Get-DbaXESession -SqlInstance $sql0 -Session AlwaysOn_health | Read-DbaXEFile | Out-GridView

# Easily import Extended events sessions :-) # Pick login and deadlocal 
Get-DbaXESessionTemplate | Out-GridView -PassThru | Import-DbaXESessionTemplate -SqlInstance $sql0 | Start-DbaXESession

#region deadlock maker

Write-Host -Foreground Green "Starting up deadlock scripts"
Write-Host -Foreground Green "Gimme a few seconds to load up some parallel processes"

$sql = "
IF OBJECT_ID('tempdb..table1') IS NULL
BEGIN
	CREATE TABLE table1 (column1 int);
	INSERT INTO table1 VALUES (1);
END

IF OBJECT_ID('tempdb..table2') IS NULL
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
"
$dbs = @()
 1..5 | ForEach-Object {
     $dbs += "tempdb"
 }

$dbs | Invoke-Parallel -ImportVariables -ScriptBlock {
   sqlcmd -S $sql0 -Q $sql -d $psitem
}

#endregion

Get-DbaXESession -SqlInstance $SQL0 -Session 'Deadlock Graphs' | Read-DbaXEventFile | Out-GridView

## or maybe you want to replay some captured workload

(Get-DbaTable -SqlInstance $sql0 -Database tempdb).Name

Get-ChildItem creating_tables.xel | Read-DbaXEFile | Invoke-DbaXeReplay -SqlInstance $sql0

(Get-DbaTable -SqlInstance $sql0 -Database tempdb).Name
#endregion

#region Query Store

# You can get your Query Store options 
Get-DbaDbQueryStoreOptions -SqlInstance $sql0 -Database AdventureWorks2014

# You can also set them 

Set-DbaDbQueryStoreOptions -SqlInstance $sql0 -Database AdventureWorks2014 -MaxSize 200
#endregion

#region Query

# Quickly find slow query executions within a database

Get-DbaQueryExecutionTime -SqlInstance $sql0 -Database AdventureWorks2014  -MinExecMs 0 -MinExecs 1 | Out-GridView

#endregion

#region sp_Configure

$linux = Connect-DbaInstance -SqlServer $linuxSQL -Credential $cred

Function Compare-SPConfigs {

    Param(
        $SourceInstance,
        $DestinationInstance,
        $SourceCred,
        $DestinationCred
    )
    $SourceSpConfigure = Get-DbaSpConfigure  -SqlServer $SourceInstance -SqlCredential $SourceCred
    $DestSPConfigure = Get-DbaSpConfigure -SqlServer $DestinationInstance -SqlCredential $DestinationCred

    $propcompare = foreach ($prop in $SourceSpConfigure) {
        [pscustomobject]@{
            Config            = $prop.DisplayName
            'Source setting'   = $prop.RunningValue
            'Destination Setting' = $DestSPConfigure | Where DisplayName -eq $prop.DisplayName | Select -ExpandProperty RunningValue
        }
    } 

    $propcompare | Out-GridView -Title "Comparing Sp_configure Settings Source - $SourceInstance With Destination $DestinationInstance"
}

Compare-SPConfigs -SourceInstance $sql0 -DestinationInstance $linuxSQL -DestinationCred $cred

Copy-DbaSpConfigure -Source $sql0 -Destination $linuxSQL -DestinationSqlCredential $cred -ConfigName DefaultBackupCompression

Compare-SPConfigs -SourceInstance $sql0 -DestinationInstance $linuxSQL -DestinationCred $cred

$linux.Configuration.Properties['DefaultBackupCompression'].ConfigValue = 0
$linux.Configuration.Alter()

Compare-SPConfigs -SourceInstance $sql0 -DestinationInstance $linuxSQL -DestinationCred $cred

$linuxConfigPath = 'C:\Temp\Linuxconfig.sql'
Export-SqlSpConfigure -SqlServer $linuxSQL -SqlCredential $cred -Path $LinuxConfigPath
Open-EditorFile $linuxConfigPath

$WinConfigPath = 'C:\Temp\Winconfig.sql'
Export-SqlSpConfigure -SqlServer $sql0 -Path $winConfigPath
Open-EditorFile $winConfigPath

Import-DbaSpConfigure -Path $WinConfigPath -SqlServer $linuxSQL -SqlCredential $cred

Compare-SPConfigs -SourceInstance $sql0 -DestinationInstance $linuxSQL -DestinationCred $cred

#endregion

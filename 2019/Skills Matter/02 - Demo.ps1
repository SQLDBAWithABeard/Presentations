#region Setup Variables
. .\vars.ps1
#endregion
Remove-Module PsReadLine

$PSDefaultParameterValues = @{
    '*dba*:SqlCredential' = $cred
}

#region Searching and using commands

Return 'Oi Beardy, You may be an MVP but this is a demo, don''t run the whole thing, fool!!'

## Lets look at the commands
Get-Command -Module dbatools 

## How many commands?
(Get-Command -Module dbatools).Count


## How do we find commands?
Find-DbaCommand -Tag Backup
Find-DbaCommand -Tag Restore
Find-DbaCommand -Tag Migration
Find-DbaCommand -Tag Agent
Find-DbaCommand -Pattern User 
Find-DbaCommand -Pattern linked

## How do we use commands?

## ALWAYS ALWAYS use Get-Help on Windows

# Get-Help Test-DbaLinkedServerConnection -Full

'https://docs.dbatools.io/#Test-DbaLinkedServerConnection'

## Here a neat trick on Windows

Find-DbaCommand -Pattern linked | Out-GridView -PassThru | Get-Help -Full 

## Lets Check a connection to a SQL Instance

Connect-DbaInstance -SqlInstance $Sql0 

## and if it fails

Connect-DbaInstance -SqlInstance sql0

## All SqlInstance commands can take a single or multiple instances as an input to SqlInstance in a number of ways

$Sql0
$sql1 

## Get the Databases on the instances

Get-DbaDatabase -SqlInstance $sql0,$Sql1 | Format-Table

$sql0,$sql1 | Get-DbaDatabase  | Format-Table

## Getting databases without a full backup

Get-DbaDatabase -SqlInstance $sql0 -NoFullBackup | Format-Table

## Getting databases without a full backup in the last 14 days

Get-DbaDatabase -SqlInstance $sql0 -NoFullBackupSince (Get-Date).AddDays(-14) | Format-Table

## So when was the last backup ? # Also outputs the multiple recovery forks for pubs

Get-DbaLastBackup -SqlInstance $sql0 | Format-Table

## Probably a good idea to back up the database quick smart!

$backupPath = '/var/opt/mssql/backups/'

Get-DbaDatabase -SqlInstance $Sql0 -ExcludeUser -ExcludeDatabase tempdb |  Backup-DbaDatabase -Path $backupPath/system 
Get-DbaDatabase -SqlInstance $Sql0 -ExcludeSystem |  Backup-DbaDatabase -Path $backupPath/user 

## check the files exist

$localbackupPath = '/home/rob/Documents/docker/volumes/dbatools/backups'

dir $localbackupPath -Recurse

## and

Get-DbaLastBackup -SqlInstance $sql0 | Format-Table

## You can backup and obviously, youy can restore as well

Restore-DbaDatabase -SqlInstance $sql1 -Path $backupPath/user -WithReplace -NoRecovery 

## Check the databases on sql1 - Imagine if that was in your disaster recovery runbook

Get-DbaDatabase -SqlInstance $sql1 -ExcludeSystem | Format-Table

## Lets drop those databases

(Get-DbaDatabase -SqlInstance $sql1 -ExcludeSystem).Drop()

## and check

Get-DbaDatabase -SqlInstance $sql1 -ExcludeSystem

## now how about this - You are performing an upgrade from sql0 to sql1 and need to copy the databases over

$CopyParams = @{
    Source = $Sql0 
    SourceSqlCredential = $cred 
    Destination = $sql1 
    DestinationSqlCredential = $cred
    BackupRestore = $true
    SharedPath = $backupPath 
    AllDatabases = $true
}

Copy-DbaDatabase @CopyParams

Get-DbaDatabase -SqlInstance $sql1 |Format-Table

## There are a lot of copy commands

Get-Command -Module dbatools Copy*

## They all work in the same sort of way

## Look at agent jobs on SQL0

Get-DbaAgentJob -SqlInstance $Sql0 | Format-Table

## and sql1

Get-DbaAgentJob -SqlInstance $Sql1 | Format-Table

## copy them 

$CopyParams = @{
    Source = $Sql0 
    SourceSqlCredential = $cred 
    Destination = $sql1 
    DestinationSqlCredential = $cred
}

Copy-DbaAgentJob @CopyParams 

## and check

Get-DbaAgentJob -SqlInstance $Sql1 | Format-Table

#endregion

#region Some Gets

# Get db file information AND write it to table
Get-DbaDbFile -SqlInstance $sql0 | Out-GridView
Get-DbaDbFile -SqlInstance $sql0  | Write-DbaDataTable -SqlInstance $sql0 -Database tempdb -Table DiskSpaceExample -AutoCreateTable
Invoke-DbaQuery -SqlInstance $sql0 -Database tempdb -Query 'SELECT * FROM dbo.DiskSpaceExample' | Out-GridView


#endregion

#region Reset Admin - Windows only

https://www.youtube.com/watch?v=FRhg0ZTQ3vI

Get-DbaLogin -SqlInstance $sql1 |Format-Table

Reset-DbaAdmin -SqlInstance $SQL1 -Login TheBeard 

Get-DbaLogin -SqlInstance $sql1 |Format-Table

#endregion

#region Wotcha doing ?

# Does resetting admin command mean any admin can create their own sysadmin account?
## Yes it does
## So why not source control your logins like Claudio Silva does http://redglue.eu/have-you-backed-up-your-sql-logins-today/?

## You can do it to a file and then source control it

Export-DbaLogin -SqlInstance $sql1 -FilePath sql1_users.sql

code sql1_users.sql

## But maybe you want to see what is going on
## Open ADS and run sqlquery1 against sql1

Get-DbaProcess -SqlInstance $sql1 |Out-GridView

# or the open transactions

Get-DbaOpenTransaction -SqlInstance $sql1

Get-DbaProcess -SqlInstance $sql1 -Login sqladmin | Out-GridView

Read-DbaTraceFile -SqlInstance $sql0 -Login sqladmin | Out-GridView


## What about Glenn Berry's Diagnostic Queries ?

# Diagnostic query!

Start-Process https://www.sqlskills.com/blogs/glenn/category/dmv-queries/


$sql0| Invoke-DbaDiagnosticQuery -UseSelectionHelper | Export-DbaDiagnosticQuery -Path "$Home\Documents\Glenn Berry Diagnostic Queries"


#endregion

#region Find the thing

# Hey can you find me the stored procedure for authors
# Sure which database? 
# I dont know!!

Find-DbaStoredProcedure -SqlInstance $sql0 -Pattern author  | Out-GridView

## and views

Find-DbaView -SqlInstance $sql1 -Pattern product  | Out-GridView


## Whilst we are here lets look at our indexes

Get-DbaHelpIndex -SqlInstance $sql0 -Database  NorthWind| Out-GridView


#region Setup Variables
. .\vars.ps1
#endregion

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

## ALWAYS ALWAYS use Get-Help

Get-Help Test-DbaLinkedServerConnection -Full

## Here a neat trick

Find-DbaCommand -Pattern linked | Out-GridView -PassThru | Get-Help -Full 

## Lets look at the linked servers on sql0

Get-DbaLinkedServer -SqlInstance $sql0 | Format-Table

## I wonder if they are all workign correctly

Test-DbaLinkedServerConnection -SqlInstance $sql0 

## Lets have a look at the linked servers on sql1

Get-DbaLinkedServer -SqlInstance $sql1

## Ah - There is an Availability Group here
## I probably want to make sure that each instance has the same linked servers
## but they have sql auth and passwords - where are the passwords kept ?

(Get-DbaLinkedServer -sqlinstance $sql0)[0] | Select-Object SQLInstance, Name, RemoteServer, RemoteUser

## I can script out the T-SQL for the linked server
(Get-DbaLinkedServer -sqlinstance $sql0)[0] | Export-DbaScript 

## But I cant use the password :-(
Get-ChildItem *sql0-LinkedServer-Export* | Open-EditorFile

## Its ok, with dbatools I can just copy them over anyway :-) Dont need to know the password

Copy-DbaLinkedServer -Source $sql0 -Destination $sql1

## Now lets look at sql1 linked servers again

Get-DbaLinkedServer -SqlInstance $sql1 | Format-Table

## Lets test them to show we have the Password passed over as well

Test-DbaLinkedServerConnection -SqlInstance $sql1

#endregion

#region Look at Builds
$builds = @()
$SQLInstances.ForEach{
    $builds += Get-DbaSqlBuildReference -SqlInstance $PSitem 
}

$containers.ForEach{
    $Builds += Get-DbaSqlBuildReference -SqlInstance $PSitem -SqlCredential $cred
}

$Builds | Format-Table

Get-DbaSqlBuildReference -Build 10.0.6000,10.50.6000 |Format-Table

#endregion

#region Backups, restores and Agent Jobs

#region Backup
## Backup the entire instance - Imagine this is our KeepSafe backup store or our regular backup store
## Or you are a consultant who comes in and sees that the databases have never been properly backed up

Explorer $NetworkShare
Get-DbaDatabase -SqlInstance $sql0 -ExcludeAllSystemDb -ExcludeDatabase WideWorldImporters | Backup-DbaDatabase -BackupDirectory $NetworkShare

#endregion

#region DISASTER
## OH NO A DISASTER HAS BEFALLEN US!
## SQL0 has broken
## Folks in Suits are rushing around and shouting
## We MUST get the databases back quickly to keep the business running
## Where is our Disaster recovery plan?
## I just need one script - I can even just type it out in one line :-)
## NOTE - I am only showing the backups 
## but you have seen we can do linked servers and we can do prety much anything on the instance with the Copy-Dba* commands :-)

## Check databases on sql1
Get-DbaDatabase -SqlInstance $sql1 | Format-Table

## restore databases from backup folder
Restore-DbaDatabase -SqlInstance $sql1 -Path $NetworkShare -WithReplace

## Check databases on sql1
Get-DbaDatabase -SqlInstance $sql1 | Format-Table

## Happy suits :-)
## Now go and fix the broken server!!!
#endregion

#region test backups
## Thats all very well and good but that requires valid backup files
## How often do you test your backups?
##
##
##
## remember that a backup is just a file until you know that you can restore it and that it has a valid DBCC CHECKDB
##
##
## Now it is so easy to do this
## Watch

explorer '\\sql0.TheBeard.Local\F$\Data'
Test-DbaLastBackup -SqlInstance $sql0 -ExcludeDatabase WideWorldImporters  | Out-GridView
#endregion

#region agent jobs

## Look at the agent jobs

Get-DbaAgentJob -SqlInstance $SQL0
Get-DbaAgentJobCategory -SqlInstance $SQL0
Get-DbaAgentJobStep -SqlInstance $SQL0 -Job 'DatabaseBackup - USER_DATABASES - FULL'

## It even has intellisense
Get-DbaAgentJobStep -SqlInstance $SQL0 -Jo

Get-DbaAgentJobStep -SqlInstance $SQL0 -Job 'DatabaseBackup - USER_DATABASES - FULL' | Select *

Get-DbaAgentJobOutputFile -SqlInstance $SQL0 -Job 'DatabaseBackup - USER_DATABASES - FULL'
Open-EditorFile (Get-DbaAgentJobOutputFile -SqlInstance $SQL0 -Job 'DatabaseBackup - USER_DATABASES - FULL' ).RemoteOutputFileName

## DAH Ola uses tokens in his path names :-)
Get-ChildItem \\SQL0\F$\Backups\DatabaseBackup* | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Open-EditorFile

Get-DbaAgentLog -SqlInstance $SQL0

Get-DbaAgentJobHistory -SqlInstance $SQL0

Get-DbaAgentJobHistory -SqlInstance $SQL0 -Job 'DatabaseBackup - USER_DATABASES - FULL' | Out-GridView
#endregion

#region Ola Hallengren

## Who uses Ola's scripts?
## The best scripts for Backups and Index maintenance https://ola.hallengren.com 
## Always recommended - easy for novices - One script - install - schedule
## Easy for experts who require granular access and control as well :-)

## How easy it is to install them with dbatools ?

Get-DbaAgentJob -SqlInstance $LinuxSQL -SqlCredential $cred

## Install

Install-DbaMaintenanceSolution -SqlInstance $LinuxSQL -SqlCredential $cred -Database 'DBA-Admin' -CleanupTime 74 -LogToTable -InstallJobs -Verbose -Solution All

Get-DbaAgentJob -SqlInstance $LinuxSQL -SqlCredential $cred

## Run the job
(Get-DbaAgentJob -SqlInstance $LinuxSQL -SqlCredential $cred -Job 'DatabaseBackup - USER_DATABASES - FULL').start()
Get-DbaAgentJob -SqlInstance $LinuxSQL -SqlCredential $cred | Format-Table

## Check the history
Get-DbaAgentJobHistory -SqlInstance $LinuxSQL -SqlCredential $cred -Job 'DatabaseBackup - USER_DATABASES - FULL'

## Check the backup history
## Answer the question - When was this database backed up

Get-DbaBackupHistory -SqlInstance $LinuxSQL -SqlCredential $cred  # other params -Since -Last -LastFull -LastDiff -LastLog -LastLsn 

## Answer the question - When was this database LAST backed up
Get-DbaLastBackup -SqlInstance $LinuxSQL -SqlCredential $cred | Format-Table

## Yes - That is working on SQL on Linux beause it is just the same as SQL on Windows from a SQL point of view

## What about checking the last time a database was restored?

Get-DbaRestoreHistory -SqlInstance $sql1 

## Test access to a path from SQL Service account
## These days user accounts are often denied access to the backup shares as a security measure
## But we still need to know if the SQL account can get to the folder otherwise we have no backups
## Also useful for testing access for other requirements for SQL Server

Test-DbaSqlPath -SqlInstance $SQL0 -Path $NetworkShare

## or explore a filepath from the SQL Service account
## By default it is the data path

Get-DbaFile -SqlInstance $LinuxSQL -SqlCredential $cred 

## but you can explore other paths too
Get-DbaFile -SqlInstance $LinuxSQL -SqlCredential $cred -Path '/var/opt/mssql/data/BeardLinuxSQL/LinuxDb9/FULL/'

## Oh and dbatools can restore from a Ola Hallengren directory too

## show the databases
Get-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred -ExcludeAllSystemDb -ExcludeDatabase 'DBA-Admin' |Format-Table

## Remove them
Get-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred -ExcludeAllSystemDb -ExcludeDatabase 'DBA-Admin' | Remove-DbaDatabase -Confirm:$false

## show the databases - There are none
Get-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred -ExcludeAllSystemDb -ExcludeDatabase 'DBA-Admin'

## Restore from Ola directory
Restore-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred -Path '/var/opt/mssql/data/BeardLinuxSQL' -AllowContinue

## show the databases
Get-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred -ExcludeAllSystemDb | Format-Table

#endregion
#endregion

#region Some Gets

# See protocols
Get-DbaServerProtocol -ComputerName $sql0

# Get the registry root
Get-DbaSqlRegistryRoot -ComputerName $sql0

#endregion
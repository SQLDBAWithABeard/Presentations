#region Setup Variables
. .\vars.ps1
#endregion
Pop-Location
#region Searching and using commands

Return 'Oi Beardy, You may be an MVP but this is a demo, don''t run the whole thing, fool!!'

## Lets look at the commands
Get-Command -Module dbatools 

## How many commands?
(Get-Command -Module dbatools -CommandType Function ).Count

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

## Lets build an Availability Group between the two containers

Get-DbaDatabase -SqlInstance $sql0 | Format-Table

$path = '/var/opt/mssql/backups/'

Test-DbaPath -SqlInstance $sql0 -Path $path

Get-DbaFile -SqlInstance $sql0 -Path $path

# look its on windows
ls C:\MSSQL\BACKUP\KEEP

$restoreDbaDatabaseSplat = @{
    SqlInstance = $sql0
    DatabaseName = 'AdventureWorks'
    UseDestinationDefaultDirectories = $true
    Path = '/var/opt/mssql/backups/AdventureWorks2016_EXT.bak'
}
Restore-DbaDatabase @restoreDbaDatabaseSplat 

Get-DbaDatabase -SqlInstance $sql0 -Database AdventureWorks
Get-DbaDbRestoreHistory -SqlInstance $sql0 -Database AdventureWorks

# lets have a look at some Logins and Agent Jobs

Get-DbaLogin -SqlInstance $sql0, $sql1 | Format-Table 

Get-DbaAgentJob -SqlInstance $sql0,$sql1 | Format-Table 

## Ah - Lets pretend thatt there is an Availability Group here
## I probably want to make sure that each instance has the same logins and Jobs

Copy-DbaAgentJob -Source $sql0 -Destination $sql1 

Get-DbaAgentJob -SqlInstance $sql0,$sql1 | Format-Table 

# and it can be run again and again :-) as it will skip jobs tha talready exist on the destination

Copy-DbaAgentJob -Source $sql0 -Destination $sql1 

# However, if you want to, you can set it to drop and recreate

Copy-DbaAgentJob -Source $sql0 -Destination $sql1 -Force -Verbose

# or you can set it to be disabled on the destination
Copy-DbaAgentJob -Source $sql0 -Destination $sql1 -DisableOnDestination -Force

Get-DbaAgentJob -SqlInstance $sql0,$sql1 | Select Name, IsEnabled

#logins are the same - take a look at the output and see what it is doing

Copy-DbaLogin -Source $sql0 -Destination $sql1 -Verbose

# thats one way to copy things across to other instances
# you can also create T-SQL scripts

Get-DbaLogin -SqlInstance $sql0 | Export-DbaScript -Path C:\temp


## I can script out the T-SQL for the linked server
(Get-DbaLinkedServer -sqlinstance $sql0)[0] | Export-DbaScript -Path C:\temp\sql0-LinkedServer-Export-11012018081839.sql

## But I cant use the password :-(
code-insiders.cmd C:\temp\sql0-LinkedServer-Export-11012018081839.sql

## Its ok, with dbatools I can just copy them over anyway on windows :-) Dont need to know the password

<#
Copy-DbaLinkedServer -Source $sql0 -Destination $sql1 -Verbose

## Now lets look at sql1 linked servers again

Get-DbaLinkedServer -SqlInstance $sql1 | Format-Table

## Lets test them to show we have the Password passed over as well

Test-DbaLinkedServerConnection -SqlInstance $sql1
#>

#endregion

#region Look at Builds
$builds = @()
$SQLInstances.ForEach{
    $builds += Get-DbaBuildReference -SqlInstance $PSitem 
}

$containers.ForEach{
    $Builds += Get-DbaBuildReference -SqlInstance $PSitem -SqlCredential $cred
}

$localinstances.ForEach{
    $Builds += Get-DbaBuildReference -SqlInstance $PSitem 
}

$Builds | Format-Table

Get-DbaBuildReference -Build 10.00.6556, 10.50.6000 |Format-Table

Get-DbaBuildReference -Build 7.00.961, 8.00.2039 , 9.00.5254|Format-Table

#endregion

#region Backups, restores and Agent Jobs

#region Backup
## Backup the entire instance - Imagine this is our KeepSafe backup store or our regular backup store
## Or you are a consultant who comes in and sees that the databases have never been properly backed up

Explorer C:\MSSQL\BACKUP\KEEP
Get-DbaDatabase -SqlInstance $sql0 -ExcludeAllSystemDb -ExcludeDatabase WideWorldImporters, ValidationResults | Backup-DbaDatabase -BackupDirectory $NetworkShare -Type FULL -CopyOnly

## Whats our Backup ThroughPut ?
Measure-DbaBackupThroughput -SqlInstance $sql0 |ft

## You can add it (and anything returned from PowerShell) to a table with Write-DbaDataTable
Measure-DbaBackupThroughput -SqlInstance $sql0 |Write-DbaDataTable -SqlInstance $sql0 -Database tempdb -Table throughput -AutoCreateTable

## Query the table
Invoke-DbaQuery -SqlInstance $SQL0 -Database tempdb -Query "SELECT * FROM throughput" 

# EVERYTHING is an object

$throughput = Invoke-DbaQuery -SqlInstance $SQL0 -Database tempdb -Query "SELECT * FROM throughput" 
$throughput
$throughput | ConvertTo-Csv
$throughput | ConvertTo-Xml 
$throughput | ConvertTo-Json

# There is no Excel on this machine (Like your Servers)
# If you use Doug Finkes ImportExcel module
# Install-Module ImportExcel

$throughput | Export-Excel -Path C:\temp\Excel\Throughput.xlsx
Explorer C:\temp\Excel

## Add some formatting

$excel = $throughput | Export-Excel -Path C:\temp\Excel\ThroughputAutoSize.xlsx -WorksheetName "Backup Throughput" -AutoSize -FreezeTopRow -AutoFilter 

## Add some conditional formatting
$excel = $throughput | Export-Excel -Path C:\temp\Excel\ThroughputConditional.xlsx -WorksheetName "Backup Throughput" -AutoSize -FreezeTopRow -AutoFilter -PassThru
Add-ConditionalFormatting -WorkSheet $excel.Workbook.Worksheets[1] -Address "e2:e1048576" -ForeGroundColor "RED" -RuleType LessThanOrEqual -ConditionValue 4999999
Add-ConditionalFormatting -WorkSheet $excel.Workbook.Worksheets[1] -Address "e2:e1048576" -ForeGroundColor "Green" -RuleType GreaterThan -ConditionValue 5000000
Add-ConditionalFormatting -WorkSheet $excel.Workbook.Worksheets[1] -Address "i2:i1048576" -BackgroundColor "Green" -RuleType GreaterThan -ConditionValue 5000000
Add-ConditionalFormatting -WorkSheet $excel.Workbook.Worksheets[1] -Address "i2:i1048576" -BackgroundColor "YELLOW" -RuleType Between -ConditionValue 3000000 -ConditionValue2 4999999
Add-ConditionalFormatting -WorkSheet $excel.Workbook.Worksheets[1] -Address "i2:i1048576" -BackgroundColor "RED" -RuleType Between -ConditionValue 0 -ConditionValue2 3000000
Close-ExcelPackage $excel 

## You can do that with ANY object - Into a database with Write-DbaDataTable - Into an Excel Sheet with ImportExcel

#endregion

#region UH-OH
## Email from manager

$newBurntToastNotificationSplat = @{
    Text    = 'P1 -ALERT - ALERT
BeardWidget is Broken. FIX IT NOW', 'Angry Manager'
    AppLogo = 'C:\Users\enterpriseadmin.THEBEARD\Desktop\angryboss.jpg'
}
New-BurntToastNotification @newBurntToastNotificationSplat 
#endregion

## Hmm Better get onto this quick

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
Get-DbaDatabase -SqlInstance $sql1 | Select Name, Status, IsAccessible, RecoveryModel

#region check space
## Check that we have enough space on the destination (obviously we couldnt do it this way if we SQL0 was broken)

$Databases = (Get-DbaDatabase -SqlInstance $SQL0 -ExcludeAllSystemDb -ExcludeDatabase WideWorldImporters, ValidationResults -Status Normal).Name
$measurement = $Databases.ForEach{
    Measure-DbaDiskSpaceRequirement -Source $SQL0 -Destination $sql1 -Database $PSItem
}

## How much space do we need ?
($measurement.DifferenceSize | Measure-Object -Property Megabyte -Sum).Sum
($measurement.DifferenceSize | Measure-Object -Property GigaByte -Sum).Sum

## Check the space on teh server
Get-DbaDiskSpace -ComputerName $sql1

## Or - Read the backup header and get the size
$fileName = (Get-ChildItem C:\MSSQL\BACKUP\keep\AdventureWorks* | Sort-Object LastWriteTime -Descending | Select -First 1).Name
$Path = $NetworkShare + $fileName

Read-DbaBackupHeader -Path $path -SqlInstance $sql1

(Read-DbaBackupHeader -Path $path -SqlInstance $sql1).BackupSize

## Or compare the requirements for a source and a destination - The difference size

Measure-DbaDiskSpaceRequirement -Source $SQL0 -Destination $sql1 -Database AdventureWorks
#endregion

## But back to the disaster!
## restore databases from backup folder
Restore-DbaDatabase -SqlInstance $sql1 -Path $NetworkShare -WithReplace

## Check databases on sql1
Get-DbaDatabase -SqlInstance $sql1 | Format-Table

# Back them up

Get-DbaDatabase -SqlInstance $sql1 -ExcludeAllSystemDb -ExcludeDatabase WideWorldImporters, ValidationResults | Backup-DbaDatabase -BackupDirectory $NetworkShare

#region Send an Email
$newBurntToastNotificationSplat = @{
    Text    = "FIXED - P1 Alert Over
Be Calm - The Beard has fixed it."
    AppLogo = 'C:\Users\enterpriseadmin.THEBEARD\Desktop\SarkyDBA.jpg'
}
New-BurntToastNotification @newBurntToastNotificationSplat

#endregion

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
## Now it is so easy to do this if you have a proper network share as your backuppath

Start-Process https://youtu.be/50xEuEZr6as

## Now I am going to test the last backups for SQL1 on SQL1
# Test-DbaLastBackup -SqlInstance $sql1 -ExcludeDatabase WideWorldImporters, ValidationResults | Out-GridView
#endregion

#region agent jobs

## Look at the agent jobs

Get-DbaAgentJob -SqlInstance $SQL0

Get-DbaAgentJobCategory -SqlInstance $SQL0

Get-DbaAgentSchedule -SqlInstance $sql0

Get-DbaAgentJobStep -SqlInstance $SQL0 -Job 'DatabaseBackup - USER_DATABASES - FULL'

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

## Lets look at the agent jobs on my linux instance
Get-DbaAgentJob -SqlInstance $LinuxSQL -SqlCredential $cred

## No OLA there lets Install

$installDbaMaintenanceSolutionSplat = @{
    CleanupTime   = 74
    InstallJobs   = $true
    Solution      = 'All'
    SqlInstance   = $LinuxSQL
    LogToTable    = $true
    Database      = 'DBA-Admin'
    SqlCredential = $cred
    Verbose       = $true
}
Install-DbaMaintenanceSolution @installDbaMaintenanceSolutionSplat 

Get-DbaAgentJob -SqlInstance $LinuxSQL -SqlCredential $cred

#region If you need to create some dummy backups (Rob - Today you don't)
## Run the job
(Get-DbaAgentJob -SqlInstance $LinuxSQL -SqlCredential $cred -Job 'DatabaseBackup - USER_DATABASES - FULL').start()
Get-DbaAgentJob -SqlInstance $LinuxSQL -SqlCredential $cred | Format-Table

$scriptBlock = {
    $x = 0
    while ($x -lt 5) {
        (Get-DbaAgentJob -SqlInstance $Using:LinuxSQL -SqlCredential $Using:cred -Job 'DatabaseBackup - USER_DATABASES - DIFF').start()
        $y = 0
        while ($y -lt 5) {
            (Get-DbaAgentJob -SqlInstance $Using:LinuxSQL -SqlCredential $Using:cred -Job 'DatabaseBackup - USER_DATABASES - LOG').start()
            $y ++  
            Start-Sleep -Seconds 2
        }
        Start-Sleep -Seconds 2
        $x ++
    }
}

Start-Job -Name DoSomeBackupsPlease -ScriptBlock $scriptBlock 

#endregion

## Check the history
Get-DbaAgentJobHistory -SqlInstance $LinuxSQL -SqlCredential $cred -Job 'DatabaseBackup - USER_DATABASES - FULL'

## Check the backup history
## Answer the question - When was this database backed up

Get-DbaBackupHistory -SqlInstance $LinuxSQL -SqlCredential $cred  # other params -Since -Last -LastFull -LastDiff -LastLog -LastLsn 

## Answer the question - When was this database LAST backed up
Get-DbaLastBackup -SqlInstance $LinuxSQL -SqlCredential $cred | Format-Table

## What about checking the last time a database was restored?

Get-DbaRestoreHistory -SqlInstance $sql1 

## Test access to a path from SQL Service account
## These days user accounts are often denied access to the backup shares as a security measure
## But we still need to know if the SQL account can get to the folder otherwise we have no backups
## Also useful for testing access for other requirements for SQL Server

Test-DbaPath -SqlInstance $SQL0 -Path $NetworkShare

## or explore a filepath from the SQL Service account
## By default it is the data path

Get-DbaFile -SqlInstance $LinuxSQL -SqlCredential $cred 

## but you can explore other paths too
Get-DbaFile -SqlInstance $LinuxSQL -SqlCredential $cred -Path '/var/opt/mssql/data/BeardLinuxSQL/LinuxDb7/'
Get-DbaFile -SqlInstance $LinuxSQL -SqlCredential $cred -Path '/var/opt/mssql/data/BeardLinuxSQL/LinuxDb7/FULL/'
Get-DbaFile -SqlInstance $LinuxSQL -SqlCredential $cred -Path '/var/opt/mssql/data/BeardLinuxSQL/LinuxDb7/DIFF/'
Get-DbaFile -SqlInstance $LinuxSQL -SqlCredential $cred -Path '/var/opt/mssql/data/BeardLinuxSQL/LinuxDb7/LOG/'

## and create a directory

New-DbaDirectory -SqlInstance $sql0 -Path 'F:/Seattle/'

## Oh and dbatools can restore from a Ola Hallengren directory too

## Check the job is not running
Get-DbaAgentJob -SqlInstance $LinuxSQL -SqlCredential $cred | Format-Table
Get-Job -Name DoSomeBackupsPlease -IncludeChildJob | Select JobStateInfo 

## show the databases
Get-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred -ExcludeAllSystemDb  |Format-Table

## Remove them - DON'T DO THIS ON PRODUCTION!!!!
Get-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred -ExcludeAllSystemDb | Remove-DbaDatabase -Confirm:$false

## show the databases - There are none
Get-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred -ExcludeAllSystemDb 

## Restore from Ola directory
Restore-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred -Path '/var/opt/mssql/data/BeardLinuxSQL' -AllowContinue -Verbose

## show the databases
Get-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred -ExcludeAllSystemDb | Format-Table

#endregion
#endregion

#region Some Gets

# See protocols
Get-DbaServerProtocol -ComputerName $sql0

# Get the registry root
Get-DbaRegistryRoot -ComputerName $sql0

# Get the SQL ErrorLog
Get-DbaErrorLog -SqlInstance $SQL1 | Out-GridView

# Get the Operating System
Get-DbaOperatingSystem -ComputerName $sql0 

# Get db file information AND write it to table
Get-DbaDbFile -SqlInstance $sql0 | Out-GridView
Get-DbaDbFile -SqlInstance $sql0  | Write-DbaDataTable -SqlInstance $sql0 -Database tempdb -Table DiskSpaceExample -AutoCreateTable
Invoke-DbaQuery -ServerInstance $sql0 -Database tempdb -Query 'SELECT * FROM dbo.DiskSpaceExample' | Out-GridView

# Get and change service account
Get-DbaService -ComputerName $sql0 | Out-GridView
Get-DbaService -ComputerName $sql0 | Select-Object * | Out-GridView
## Get-DbaService -Instance $sql0 -Type Agent | Update-DbaServiceAccount  -Username 'Local system' -WhatIf


#endregion








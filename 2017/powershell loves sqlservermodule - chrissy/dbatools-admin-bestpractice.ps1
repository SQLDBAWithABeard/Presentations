# IF THIS SCRIPT IS RUN ON LOCAL SQL INSTANCES, YOU MUST RUN ISE OR POWERSHELL AS ADMIN
# Otherwise, a bunch of commands won't work.

## Welcome to PowerShell :-)
Return "This is a demo Beardy!"

# Paths that auto-load modules
$env:PSModulePath -Split ";"

# This is the [development] aka beta branch
Import-Module C:\github\dbatools -Force

# Set some vars
$new = "localhost\DAVE"
$old = $instance = "localhost"
$allservers = 'ROB-XPS','ROB-XPS\DAVE' ,'SQL2005Ser2003','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3','SQLVnextN1','SQLvNextN2'

# Get-DbaSpConfigure - @sirsql
$oldprops = Get-DbaSpConfigure -SqlServer $old
$newprops = Get-DbaSpConfigure -SqlServer $new

$propcompare = foreach ($prop in $oldprops) {
    [pscustomobject]@{
    Config = $prop.DisplayName
    'SQL Server 2012' = $prop.RunningValue
    'SQL Server 2016' = $newprops | Where ConfigName -eq $prop.ConfigName | Select -ExpandProperty RunningValue
    }
} 

$propcompare | Out-GridView

# Copy-SqlSpConfigure
Copy-SqlSpConfigure -Source $old -Destination $new -Configs DefaultBackupCompression, IsSqlClrEnabled

# Get-DbaSpConfigure - @sirsql
Get-DbaSpConfigure -SqlServer $new | Where-Object { $_.ConfigName -in 'DefaultBackupCompression', 'IsSqlClrEnabled' } | 
Select-Object ConfigName, RunningValue, IsRunningDefaultValue | Format-Table -AutoSize


# Get-DbaLastBackup - by @powerdbaklaas
$allservers | Get-DbaLastBackup |ogv
$allservers | Get-DbaLastBackup | Where-Object LastFullBackup -eq $null | ogv
$allservers | Get-DbaLastBackup | Where-Object { $_.SinceLog -gt '00:15:00' -and $_.RecoveryModel -ne 'Simple' -and $_.Database -ne 'model' } | Select Server, Database, SinceFull, DatabaseCreated | Out-GridView

# LastGoodCheckDb - by @jagoop
$checkdbs = Get-DbaLastGoodCheckDb -SqlServer $instance
$checkdbs
$checkdbs | Where LastGoodCheckDb -eq $null
$checkdbs | Where LastGoodCheckDb -lt (Get-Date).AddDays(-1)

# Disk Space - by a bunch of us
Get-DbaDiskSpace -SqlInstance $instance
$diskspace = Get-DbaDiskSpace -SqlInstance $allservers -Detailed
$diskspace | Where PercentFree -lt 20

# Test last backup
Get-Help Test-DbaLastBackup -Online
Import-Module SqlServer
Invoke-Item (Get-Item SQLSERVER:\SQL\LOCALHOST\DEFAULT).DefaultFile

Test-DbaLastBackup -SqlServer $instance | Out-GridView
Test-DbaLastBackup -SqlServer $instance -Destination $new -VerifyOnly | Out-GridView

# Test-VirtualLog file - Expand-SqlTLogResponsibly down below
$allservers | Test-DbaVirtualLogFile
$bigvlfs = $allservers | Test-DbaVirtualLogFile | Where-Object {$_.Count -ge 50} | Sort-Object Count -Descending
$bigvlfs

# Virtual Log files - if time allots - 2 commands left before beard
# Expand-SqlTLogResponsibly by @ClaudioESSilva
$database = ($bigvlfs | Select -Last 1).Database
Expand-SqlTLogResponsibly -SqlServer $instance -Databases $database -TargetLogSizeMB 16 -IncrementSizeMB 1 -ShrinkLogFile -ShrinkSizeMB 1 
Test-DbaVirtualLogFile -SqlServer $instance -Databases $database

# Awesome!
Reset-SqlAdmin -SqlServer $instance -Login sqladmin

# Remove dat orphan - by @sqlstad
Find-DbaOrphanedFile -SqlServer $instance
((Find-DbaOrphanedFile -SqlServer $instance -LocalOnly | Get-ChildItem | Select -ExpandProperty Length | Measure-Object -Sum)).Sum / 1MB
Find-DbaOrphanedFile -SqlServer $instance -LocalOnly | Remove-Item

# One of my favs! - by @sqldbawithbeard
Get-Help Remove-SqlDatabaseSafely -Online
Remove-SqlDatabaseSafely -SqlServer $instance -Databases AdventureWorks2008R2 -BackupFolder \\workstation\migration

# Test/Repair Windows/SQL Server name
Test-DbaServerName -SqlServer $allservers
Repair-DbaServerName -SqlServer $allservers

# Get and Set SqlTempDbConfiguration - by @mike_fal
Get-Help Test-SqlTempDbConfiguration -Online
Test-SqlTempDbConfiguration -SqlServer $instance
Set-SqlTempDbConfiguration -SqlServer $instance -DataFileSizeMb 2048

# Test-DbaPowerPlan
Invoke-Item C:\github\TrainingMaterial\Videos\Test-DbaPowerPlan.mp4

# Get/Set SQL max memory
Test-DbaMaxMemory -SqlServer $allservers 
Test-DbaMaxMemory -SqlServer $allservers | Set-DbaMaxMemory
Test-DbaMaxMemory -SqlServer $allservers | Where-Object { $_.SqlMaxMB -gt $_.TotalMB } | Set-DbaMaxMemory
Set-DbaMaxMemory -SqlServer $instance -MaxMb 2048

# sp_whoisactive
Show-SqlWhoisActive -SqlServer $instance -ShowOwnSpid -ShowSystemSpids

# Find-DbaStoredProcdure
$allservers | Find-DbaStoredProcedure -Pattern dbatools
$allservers | Find-DbaStoredProcedure -Pattern '\w+@\w+\.\w+'

# Test-DbaSpns
$allservers | Test-DbaSpn | Out-GridView -PassThru | Set-DbaSpn -Whatif

# Now
Test-DbaFullRecoveryModel -SqlServer $instance
Test-DbaFullRecoveryModel -SqlServer $instance | Where { $_.ConfiguredRecoveryModel -ne $_.ActualRecoveryModel }

# backup header
Read-DbaBackupHeader -SqlServer $instance -Path C:\migration\SQL2012\WSS_Content\FULL\SQL2012_WSS_Content_FULL_20161218_113644.bak
Read-DbaBackupHeader -SqlServer $instance -Path C:\migration\SQL2012\WSS_Content\FULL\SQL2012_WSS_Content_FULL_20161218_113644.bak | 
SELECT ServerName, DatabaseName, UserName, BackupFinishDate, SqlVersion, BackupSizeMB

Read-DbaBackupHeader -SqlServer $instance -Path C:\migration\SQL2012\WSS_Content\FULL\SQL2012_WSS_Content_FULL_20161218_113644.bak -FileList  | Out-GridView

# Backup History!
Get-DbaBackupHistory -SqlServer $instance
Get-DbaBackupHistory -SqlServer $instance | Out-GridView
Get-DbaBackupHistory -SqlServer $instance -Databases AdventureWorks2012 | Format-Table -AutoSize

# Restore History!
Get-DbaRestoreHistory -SqlServer $instance | Out-GridView

# DbaStartupParameter
Get-DbaStartupParameter -SqlServer $instance
Get-DbaStartupParameter -SqlServer $new

# Resolve things
Resolve-DbaNetworkName -ComputerName $instance
Resolve-DbaNetworkName -ComputerName $env:computername

# Test Db compat
Test-DbaDatabaseCompatibility -SqlServer $instance -Detailed | Format-Table -AutoSize

# Test Db collation
Test-DbaDatabaseCollation -SqlServer $instance -Detailed | Format-Table -AutoSize
 
# Get Db Free Space AND write it to disk
Get-DbaDatabaseFreespace -SqlServer $instance
Get-DbaDatabaseFreespace -SqlServer $instance -IncludeSystemDBs | Out-DbaDataTable | Write-DbaDataTable -SqlServer $instance -Table tempdb.dbo.DiskSpaceExample
Get-DbaDatabaseFreespace -SqlServer $instance -IncludeSystemDBs | Out-DbaDataTable | Write-DbaDataTable -SqlServer $instance -Table tempdb.dbo.DiskSpaceExample -AutoCreateTable

# Run a lil query
Ssms.exe "C:\temp\tempdbquery.sql"

# Copy-SqlDatabase
Get-Command *Orphan*
Copy-SqlDatabase -Source $old -Destination $new -DetachAttach -Reattach -Databases WSS_Logging -Force
Repair-SqlOrphanUser -SqlServer $new
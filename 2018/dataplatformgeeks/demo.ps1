# Set some vars
$new = 'ROB-XPS\BOLTON'
$old = $instance = 'ROB-XPS\SQL2016'
$allservers = $old, $new
$SQLHost = 'Rob-XPS'

# Alternatively, use Registered Servers? 
Get-DbaRegisteredServer -SqlInstance $instance | Out-GridView

# Quick overview of commands
Start-Process https://dbatools.io/commands

# You've probably heard about how easy migrations can be with dbatools. Here's an example 
$startDbaMigrationSplat = @{
    Source = $old
    Destination = $new
    BackupRestore = $true
    NetworkShare = 'C:\temp'
    NoSysDbUserObjects = $true
    NoLogins = $true
    NoCredentials = $true
    NoBackupDevices = $true
    NoEndPoints = $true
}

Start-DbaMigration @startDbaMigrationSplat -Force | Select * | Out-GridView

# Use Ola Hallengren's backup script? We can restore an *ENTIRE INSTANCE* with just one line
Get-ChildItem -Directory 'C:\MSSQL\BACKUP\ROB-XPS$BOLTON' | Restore-DbaDatabase -SqlInstance $new 

# Nowadays, we don't just backup databases. Now, we're backing up logins
Export-DbaLogin -SqlInstance $instance -Path C:\temp\logins.sql
Open-EditorFile C:\temp\logins.sql

# And Agent Jobs
Get-DbaAgentJob -SqlInstance $old | Export-DbaScript -Path C:\temp\jobs.sql
Open-EditorFile C:\temp\jobs.sql

# Complaint: Already have a library of Profiler templates
# Answer: Convert them instantly to Sessions (h/t Jonathan Kehayias)
Get-DbaTrace -SqlInstance $old| ConvertTo-DbaXESession | Start-DbaXESession

# Easily import
Get-DbaXESessionTemplate | Out-GridView -PassThru ## | Import-DbaXESessionTemplate -SqlInstance $allservers | Start-DbaXESession

# Testing your backups is crazy easy! 
Start-Process https://dbatools.io/Test-DbaLastBackup
Test-DbaLastBackup -SqlInstance $old | Out-GridView

# But what if you want to test your backups on a different server?
Test-DbaLastBackup -SqlInstance $old -Destination $new | Out-GridView

# Know how snapshots used to be a PITA? Now they're super easy
New-DbaDbSnapshot -SqlInstance $new -Database DBA-Admin -Name DBAAdmin_snapshot
Get-DbaDbSnapshot -SqlInstance $new
Get-DbaProcess -SqlInstance $new -Database DBAAdmin_snapshot | Stop-DbaProcess
Restore-DbaFromDatabaseSnapshot -SqlInstance $new -Database db1 -Snapshot DBAAdmin_snapshot
Remove-DbaDbSnapshot -SqlInstance $new -Snapshot DBAAdmin_snapshot # or -Database db1

# We evaluated 37,545 SQL Server stored procedures on 9 servers in 8.67 seconds!
$old | Find-DbaStoredProcedure -Pattern backup 

# Have an employee who is leaving? Find all of their objects.
$allservers | Find-DbaUserObject -Pattern ROB-XPS\mrrob | Out-GridView
 
# Find detached databases, by example
Detach-DbaDatabase -SqlInstance $instance -Database DBAutomationTarget
Find-DbaOrphanedFile -SqlInstance $instance | Out-GridView

# View and change service account
Get-DbaService -ComputerName $SQLHost | Out-GridView
Get-DbaService -ComputerName $SQLHost | Select * | Out-GridView
Get-DbaService -Instance SQL2016 -Type Agent | Update-DbaServiceAccount -Username 'Local system'

# Check out how complete our sp_configure command is
Get-DbaSpConfigure -SqlInstance $new | Out-GridView
Get-DbaSpConfigure -SqlInstance $new -ConfigName XPCmdShellEnabled

# Easily update configuration values
Set-DbaSpConfigure -SqlInstance $new -ConfigName XPCmdShellEnabled -Value $true

# XEs Read and watch
Get-DbaXESession -SqlInstance $new -Session system_health | Read-DbaXEFile

# Reset-DbaAdmin
Reset-DbaAdmin -SqlInstance $instance -Login sqladmin -Verbose
Get-DbaDatabase -SqlInstance $instance -SqlCredential (Get-Credential sqladmin)

# sp_whoisactive
Install-DbaWhoIsActive -SqlInstance $instance -Database master
Invoke-DbaWhoIsActive -SqlInstance $instance -ShowOwnSpid -ShowSystemSpids

# Diagnostic query!
$instance | Invoke-DbaDiagnosticQuery -UseSelectionHelper | Export-DbaDiagnosticQuery -Path $home
Invoke-Item $home

# Ola, yall
$instance | Install-DbaMaintenanceSolution -ReplaceExisting -BackupLocation C:\temp -InstallJobs

# Get db space AND write it to table
Get-DbaDbFile -SqlInstance $instance | Out-GridView
Get-DbaDbFile -SqlInstance $instance -IncludeSystemDB | Write-DbaDataTable -SqlInstance $instance -Database tempdb -Table DiskSpaceExample -AutoCreateTable
Invoke-DbaSqlcmd -ServerInstance $instance -Database tempdb -Query 'SELECT * FROM dbo.DiskSpaceExample' | Out-GridView

# History
Get-Command -Module dbatools *history*

# More histories
Get-DbaAgentJobHistory -SqlInstance $instance | Out-GridView
Get-DbaBackupHistory -SqlInstance $new | Out-GridView

# Test/Set SQL max memory
$allservers | Get-DbaMaxMemory
$allservers | Test-DbaMaxMemory | Format-Table
$allservers | Test-DbaMaxMemory | Where-Object { $_.SqlMaxMB -gt $_.TotalMB } | Set-DbaMaxMemory -WhatIf
Set-DbaMaxMemory -SqlInstance $instance -MaxMb 1023

# Reads trace files - default trace by default
Read-DbaTraceFile -SqlInstance $instance | Out-GridView

# don't have remoting access? Explore the filesystem. Uses master.sys.xp_dirtree
Get-DbaFile -SqlInstance $instance
Get-DbaFile -SqlInstance $instance -Depth 3 -Path 'C:\Program Files\Microsoft SQL Server' | Out-GridView
New-DbaDirectory -SqlInstance $instance  -Path 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\test'

# Out-GridView madness <3
Get-DbaDatabase -SqlInstance $old | Out-GridView -PassThru | Copy-DbaDatabase -Destination $new -BackupRestore -NetworkShare \\workstation\c$\temp -Force

# We've even got our own config system!
Get-DbatoolsConfig | Out-GridView

# Check out our logs directory, so Enterprise :D
Invoke-Item (Get-DbatoolsConfig -FullName path.dbatoolslogpath).Value

# Want to see what's in our logs?
Get-DbatoolsLog | Out-GridView

# Need to send us diagnostic information? Use this support package generator
New-DbatoolsSupportPackage









<#PSScriptInfo

.VERSION 1.0

.GUID 730f1621-25a7-4503-886d-625695f1dd06

.AUTHOR Rob Sewell

.DESCRIPTION Function to run a series of Pester tests for SQL Defaults against a server or array of servers
      
.COMPANYNAME 

.COPYRIGHT 

.TAGS SQL, Pester, Defaults, SQL Server

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#>
<#
    .Synopsis
    Function to run a series of Pester tests for SQL Defaults against a server or array of servers
    .DESCRIPTION
    Runs a number of Pester tests to check default values for many options against a server or array of servers
    .EXAMPLE
    Test-SQLDefault -Servers 'SQLServer1' -SQLAdmins 'THEBEARD\Rob'`
      -BackupDirectory 'C:\MSSQL\Backup' -DataDirectory 'C:\MSSQL\Data\'`
      -LogDirectory 'C:\MSSQL\Logs\' -MaxMemMb '4096' -Collation 'Latin1_General_CI_AS'`
      -TempFiles 4 -OlaSysFullFrequency 'Daily' -OlaSysFullStartTime '21:00:00'`
      -OlaUserFullSchedule 'Weekly' -OlaUserFullFrequency 1 `## 1 for Sunday
      -OlaUserFullStartTime '22:00:00' -OlaUserDiffSchedule 'Weekly'`
      -OlaUserDiffFrequency 126` ## 126 for every day except Sunday
      -OlaUserDiffStartTime '22:00:00' -OlaUserLogSubDayInterval 15`
      -OlaUserLoginterval 'Minute' -HasSPBlitz $true -HasSPBlitzCache $True
      -HasSPBlitzIndex $True -HasSPAskBrent $true -HASSPBlitzTrace  $true`
      -HasSPWhoisActive $true -LogWhoIsActiveToTable $true -LogSPBlitzToTable $true`
      -LogSPBlitzToTableEnabled $true -LogSPBlitzToTableScheduled $true`
      -LogSPBlitzToTableSchedule 'Weekly' -LogSPBlitzToTableFrequency 2 ` # 2 means Monday 
      -LogSPBlitzToTableStartTime  '03:00:00'


    This will run Pester tests against SQLServer1 instance and check using all the variables
    .EXAMPLE
      $Parms = @{
      Servers = 'SQLServer1','SQLServer2','SQLServer2\Instance1','SQLServer3';
      SQLAdmins = 'THEBEARD\Rob','THEBEARD\SQLAdmins';
      BackupDirectory = 'C:\MSSQL\Backup';
      DataDirectory = 'C:\MSSQL\Data\';
      LogDirectory = 'C:\MSSQL\Logs\';
      MaxMemMb = '4096';
      Collation = 'Latin1_General_CI_AS';
      TempFiles = 4 ;
      OlaSysFullFrequency = 'Daily';
      OlaSysFullStartTime = '21:00:00';
      OlaUserFullSchedule = 'Weekly';
      OlaUserFullFrequency = 1 ;## 1 for Sunday
      OlaUserFullStartTime = '22:00:00';
      OlaUserDiffSchedule = 'Weekly';
      OlaUserDiffFrequency = 126; ## 126 for every day except Sunday
      OlaUserDiffStartTime = '22:00:00';
      OlaUserLogSubDayInterval = 15;
      OlaUserLoginterval = 'Minute';
      HasSPBlitz = $true;
      HasSPBlitzCache = $True; 
      HasSPBlitzIndex = $True;
      HasSPAskBrent = $true;
      HASSPBlitzTrace =  $true;
      HasSPWhoisActive = $true;
      LogWhoIsActiveToTable = $true;
      LogSPBlitzToTable = $true;
      LogSPBlitzToTableEnabled = $true;
      LogSPBlitzToTableScheduled = $true;
      LogSPBlitzToTableSchedule = 'Weekly'; 
      LogSPBlitzToTableFrequency = 2 ; # 2 means Monday 
      LogSPBlitzToTableStartTime  = '03:00:00'}
      
      Test-SQLDefault @Parms

    This example uses splatting to hold the parameters and will run the tests against SQLServer1, SQLServer2, SQLServer2\Instance1 and SQLServer3
    .NOTES
    AUTHOR : Rob Sewell http://sqldbawithabeard.com
    Initial 12/05/2016
#>
function Test-SQLDefault {
[CmdletBinding()]
param(
# Server Name or ServerName\InstanceName or an array of server names and/or servername\instancenames
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [array]$Servers ,
# Expected SQL Admin Account or an array of accounts
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [array]$SQLAdmins ,
# Default Backup Directory - Needs to match exactly including trailing slash if applicable
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$BackupDirectory ,
# Default Data Directory - Needs to match exactly including trailing slash if applicable
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$DataDirectory ,
# Default Log Directory - Needs to match exactly including trailing slash if applicable
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$LogDirectory ,
# Maximum Memory
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [int32]$MaxMemMb ,
# Collation
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$Collation,
# Maximum Memory
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [int32]$TempFiles,
# The frequency of the Ola Hallengrens System backups - Weekly, Daily
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$OlaSysFullFrequency ,
# The start time of the Ola Hallengrens System backups - '21:00:00'
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$OlaSysFullStartTime ,
# The frequency of the Ola Hallengrens User Full backups - Weekly, Daily
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$OlaUserFullSchedule ,
# The frequency of the Ola Hallengrens User Full backups 
# See https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.agent.jobschedule.frequencyinterval.aspx
# for full options
# 1 for Sunday 127 for every day
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$OlaUserFullFrequency ,
# The start time of the Ola Hallengrens User Full backups - '21:00:00'
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$OlaUserFullStartTime ,
# The frequency of the Ola Hallengrens User Differential backups - Weekly, Daily
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$OlaUserDiffSchedule ,
# The frequency of the Ola Hallengrens User Differential backups 
# See https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.agent.jobschedule.frequencyinterval.aspx
# for full options
# 1 for Sunday 127 for every day
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$OlaUserDiffFrequency , ## 126 for every day except Sunday
# The start time of the Ola Hallengrens User Differential backups - '21:00:00'
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$OlaUserDiffStartTime ,
# The interval between the Ola Hallengrens Log Backups
# If 15 minutes this will be 15 if 3 hours this will be 3
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [int32]$OlaUserLogSubDayInterval ,
# The unit of time for the Ola Hallengrens Log Backups interval
# If 15 minutes this will be Minute if 3 hours this will be Hour
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$OlaUserLoginterval ,
# Boolean value for existence of sp_Blitz
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [boolean]$HasSPBlitz,
# Boolean value for existence of sp_BlitzCache
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [boolean]$HasSPBlitzCache,
# Boolean value for existence of sp_BlitzIndex
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [boolean]$HasSPBlitzIndex,
# Boolean value for existence of sp_AskBrent
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [boolean]$HasSPAskBrent,
# Boolean value for existence of sp_BlitzTrace
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [boolean]$HASSPBlitzTrace,
# Boolean value for existence of sp_WhoIsActive
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [boolean]$HasSPWhoisActive,
# Boolean value for existence of Agent Job to Log sp_WhoIsActive to table
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [boolean]$LogWhoIsActiveToTable,
# Boolean value for existence of Agent Job to log sp_Blitz to table
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [boolean]$LogSPBlitzToTable,
# Boolean value for Agent Job to log sp_Blitz to table enabled
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [boolean]$LogSPBlitzToTableEnabled,
# Boolean value for Agent Job to log sp_Blitz to table scheduled
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [boolean]$LogSPBlitzToTableScheduled,
# The frequency of the Agent Job to log sp_Blitz to table - Weekly, Daily
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$LogSPBlitzToTableSchedule,
# The frequency of the Agent Job to log sp_Blitz to table  
# See https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.agent.jobschedule.frequencyinterval.aspx
# for full options
# 1 for Sunday 127 for every day
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$LogSPBlitzToTableFrequency,
# The start time of the Agent Job to log sp_Blitz to table  - '21:00:00'
    [Parameter(Mandatory = $true, 
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true, 
    Position = 0)]
    [string]$LogSPBlitzToTableStartTime  
)
foreach($Server in $Servers)
    {
        $skip = $true
    if($Server.Contains('\'))
    {
    $ServerName = $Server.Split('\')[0]
    $Instance = $Server.Split('\')[1]
    }
    else
    {
    $Servername = $Server
    $Instance = 'MSSQLSERVER'
    } 
    ## Check for connectivity
      if((Test-Connection $ServerName -count 1 -Quiet) -eq $false){
       Write-Error "Could not connect to $ServerName"
       $_
       continue
        }
       if ([bool](Test-WSMan -ComputerName $ServerName -ErrorAction SilentlyContinue))
       {
           $skip = $true
       }
       else
       {Write-Error "PSRemoting is not enabled on $ServerName Please enable and retry"
       continue}
    Describe "$Server" {
        $kip = $true
        BeforeAll {
            $Scriptblock = {
            [pscustomobject]$Return = @{}
            $srv = ''
            $Server = $Server
            $SQLAdmins = $SQLAdmins
            [void][reflection.assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo');
            $srv = New-Object Microsoft.SQLServer.Management.SMO.Server $Server
            $Return.SQLRegKey = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$Instance" -ErrorAction SilentlyContinue)
            $Return.DBAAdminDb = $Srv.Databases.Name.Contains('DBA-Admin')
            $Logins = $srv.Logins.Where{$_.IsSystemObject -eq $false}.Name
            $Return.SQLAdmins = @(Compare-Object $Logins $SQLAdmins -SyncWindow 0).Length - $Logins.count -eq $SQLAdmins.Count
            $SysAdmins = $Srv.Roles['sysadmin'].EnumMemberNames()
            $Return.SQLAdmin = @(Compare-Object $SysAdmins $SQLAdmins -SyncWindow 0).Length - $SysAdmins.count -eq $SQLAdmins.Count
            $Return.BackupDirectory = $srv.BackupDirectory
            $Return.DataDirectory = $srv.DefaultFile
            $Return.LogDirectory  = $srv.DefaultLog
            $Return.MaxMemMb = $srv.Configuration.MaxServerMemory.RunValue
            $Return.TempFiles = $srv.Databases['tempdb'].FileGroups['PRIMARY'].Files.Count
            $Return.Collation = $srv.Collation
            $Return.DatabasesStatus = $srv.Databases.Where{$_.Status -ne 'Normal'}.count
            $Return.AgentJobs = $srv.JobServer.Jobs.Count
            $OlaDbs = 'CommandExecute','DatabaseBackup','DatabaseIntegrityCheck','IndexOptimize'
            $Sps = $srv.Databases['DBA-Admin'].StoredProcedures.Where{$_.Schema -eq 'dbo'}.Name 
            $Return.OlaProcs = $sps.count - @(Compare-Object $sps $oladbs -SyncWindow 0).Length -eq 4
            $Return.RestoreProc = $Sps -contains 'RestoreCommand'
            $Return.OlaSysFullEnabled = $srv.JobServer.jobs['DatabaseBackup - SYSTEM_DATABASES - FULL'].IsEnabled
            $Return.OlaSysFullScheduled = $srv.JobServer.jobs['DatabaseBackup - SYSTEM_DATABASES - FULL'].HasSchedule
            $Return.OlaSysFullFrequency = $srv.JobServer.jobs['DatabaseBackup - SYSTEM_DATABASES - FULL'].JobSchedules.FrequencyTypes
            $Return.OlaSysFullStartTime = $srv.JobServer.jobs['DatabaseBackup - SYSTEM_DATABASES - FULL'].JobSchedules.ActiveStartTimeOfDay
            $Return.OlaUserFullEnabled = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - FULL'].IsEnabled
            $Return.OlaUserFullScheduled = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - FULL'].HasSchedule
            $Return.OlaUserFullSchedule = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - FULL'].JobSchedules.FrequencyTypes
            $Return.OlaUserFullFrequency = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - FULL'].JobSchedules.FrequencyInterval
            $Return.OlaUserFullStartTime = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - FULL'].JobSchedules.ActiveStartTimeOfDay 
            $Return.OlaUserDiffEnabled = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - DIFF'].IsEnabled 
            $Return.OlaUserDiffScheduled = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - DIFF'].HasSchedule
            $Return.OlaUserDiffSchedule = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - DIFF'].JobSchedules.FrequencyTypes
            $Return.OlaUserDiffFrequency = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - DIFF'].JobSchedules.FrequencyInterval
            $Return.OlaUserDiffStartTime = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - DIFF'].JobSchedules.ActiveStartTimeOfDay
            $Return.OlaUserLogEnabled = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - Log'].IsEnabled 
            $Return.OlaUserLogScheduled = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - Log'].HasSchedule
            $Return.OlaUserLogSchedule = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - Log'].JobSchedules.FrequencyTypes
            $Return.OlaUserLogFrequency = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - Log'].JobSchedules.FrequencyInterval
            $Return.OlaUserLogSubDayInterval = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - Log'].JobSchedules.FrequencySubDayInterval
            $Return.OlaUserLoginterval = $srv.JobServer.jobs['DatabaseBackup - USER_DATABASES - Log'].JobSchedules.FrequencySubDayTypes
            $Return.HasSPBlitz = $Srv.Databases['master'].StoredProcedures.Name -contains 'sp_blitz'
            $Return.HasSPBlitzCache = $Srv.Databases['master'].StoredProcedures.Name -contains 'sp_blitzCache'
            $Return.HasSPBlitzIndex = $Srv.Databases['master'].StoredProcedures.Name -contains 'sp_blitzIndex'
            $Return.HasSPAskBrent = $Srv.Databases['master'].StoredProcedures.Name -contains 'sp_AskBrent'
            $Return.HASSPBlitzTrace = $Srv.Databases['master'].StoredProcedures.Name -contains 'sp_BlitzTrace'
            $Return.HasSPWhoisActive = $Srv.Databases['master'].StoredProcedures.Name -contains 'sp_WhoIsActive'
            $Return.LogWhoIsActiveToTable = $srv.JobServer.jobs.name.Contains('Log SP_WhoisActive to Table')
            $Return.LogSPBlitzToTable = $srv.JobServer.jobs.name.Contains('Log SP_Blitz to table')
            $Return.LogSPBlitzToTableEnabled = $srv.JobServer.jobs['Log SP_Blitz to table'].IsEnabled
            $Return.LogSPBlitzToTableScheduled = $srv.JobServer.jobs['log SP_Blitz to table'].HasSchedule
            $Return.LogSPBlitzToTableSchedule = $srv.JobServer.jobs['Log SP_Blitz to table'].JobSchedules.FrequencyTypes
            $Return.LogSPBlitzToTableFrequency = $srv.JobServer.jobs['Log SP_Blitz to table'].JobSchedules.FrequencyInterval
            $Return.LogSPBlitzToTableStartTime = $srv.JobServer.jobs['Log SP_Blitz to table'].JobSchedules.ActiveStartTimeOfDay
            $Return.Alerts20SeverityPlusExist = $srv.JobServer.Alerts.Where{$_.Severity -ge 20}.Count
            $Return.Alerts20SeverityPlusEnabled = $srv.JobServer.Alerts.Where{$_.Severity -ge 20 -and $_.IsEnabled -eq $true}.Count
            $Return.Alerts82345Exist = ($srv.JobServer.Alerts |Where {$_.Messageid -eq 823 -or $_.Messageid -eq 824 -or $_.Messageid -eq 825}).Count
            $Return.Alerts82345Enabled = ($srv.JobServer.Alerts |Where {$_.Messageid -eq 823 -or $_.Messageid -eq 824 -or $_.Messageid -eq 825 -and $_.IsEnabled -eq $true}).Count
            $Return.SysDatabasesFullBackupToday = $srv.Databases.Where{$_.IsSystemObject -eq $true -and $_.Name -ne 'tempdb' -and $_.LastBackupDate -lt (Get-Date).AddDays(-1)}.Count
          Return $Return
           }
           try {
           # $Return = Invoke-Command -ScriptBlock $Scriptblock -ComputerName $ServerName -ErrorAction Stop
           $skip =$true
        }
           catch {
               $Skip = $true
           }
            
            }
       Context 'Server' {
        It 'Should Exist and respond to ping'-Skip:$true {
            $connect = Test-Connection $ServerName -count 1 -Quiet 
            $Connect|Should Be $true
        }
        if($connect -eq $false){break}
       It 'Should have SQL Server Installed'-Skip:$true {  
            $Return.SQLRegKey | Should Not Be NullOrEmpty
        }
        } # End Context 
       Context 'Services'{
        BeforeAll {
        If($Instance -eq 'MSSQLSERVER')
        {
        $SQLService = $Instance
        $AgentService = 'SQLSERVERAGENT'
        }
        else
        {
        $SQLService = "MSSQL$" + $Instance
        $AgentService = "SQLAgent$" + $Instance
        }
        $MSSQLService = (Get-CimInstance -ClassName Win32_Service -Filter "Name = '$SQLService'" )
        $SQLAgentService = (Get-CimInstance -ClassName Win32_Service -Filter "Name = '$AgentService'")
        }
        It 'SQL DB Engine should be running'-Skip:$true {
            $MSSQLService.State | Should -Be 'Running'
        }
        It 'SQL Db Engine should be Automatic Start'-Skip:$true {
            $MSSQLService.StartMode |Should -Be 'Auto'
        }
        It 'SQL Agent should be running'-Skip:$true {
            $SQLAgentService.State | Should -Be 'Running'
        }
        It 'SQL Agent should be Automatic Start'-Skip:$true {
            $SQLAgentService.StartMode |should be 'Auto'
        }
        } # End Context 
      <# Context 'FireWall' {   
        It 'Should have a Firewall connection for SQL Browser'-Skip:$true {
            $Scriptblock =-Skip:$true {Get-NetFirewallRule -Name 'SQL Browser Service - Allow'} 
            $State = Invoke-Command -ComputerName $ServerName -ScriptBlock $Scriptblock 
            $State | Should -Be $true
        }
        It 'Firewall connection for SQL Browser should be enabled' {
            $Scriptblock = {(Get-NetFirewallRule -Name 'SQL Browser Service - Allow').Enabled} 
            $State = Invoke-Command -ComputerName $ServerName -ScriptBlock $Scriptblock 
            $State | Should -Be $true
        }
        It 'SQL Browser Firewall Action Should Be Allow' {
            $Scriptblock = {(Get-NetFirewallRule -Name 'SQL Browser Service - Allow').Action} 
            $State = Invoke-Command -ComputerName $ServerName -ScriptBlock $Scriptblock 
            $State.value | Should -Be 'Allow'
        }
        It 'SQL Browser Firewall Application should be the SQLBrowser.exe' {
            $Scriptblock = {(Get-NetFirewallRule -Name 'SQL Browser Service - Allow'|Get-NetFirewallApplicationFilter).Program} 
            $State = Invoke-Command -ComputerName $ServerName -ScriptBlock $Scriptblock 
            $State | Should -Be 'C:\Program Files (x86)\Microsoft SQL Server\90\Shared\sqlbrowser.exe'
        }
        It 'Should have a Firewall connection for SQL DB Engine' {
            $Scriptblock = {Get-NetFirewallRule -Name 'SQL Database Engine - Allow'} 
            $State = Invoke-Command -ComputerName $ServerName -ScriptBlock $Scriptblock 
            $State | Should -Be $true
        }
        It 'Firewall connection for SQL DB Engine should be enabled' {
            $Scriptblock = {(Get-NetFirewallRule -Name 'SQL Database Engine - Allow').Enabled} 
            $State = Invoke-Command -ComputerName $ServerName -ScriptBlock $Scriptblock 
            $State | Should -Be $true
        }
        It 'DB EngineFirewall Action Should Be Allow' {
            $Scriptblock = {(Get-NetFirewallRule -Name 'SQL Database Engine - Allow').Action} 
            $State = Invoke-Command -ComputerName $ServerName -ScriptBlock $Scriptblock 
            $State.value | Should -Be 'Allow'
        }
        It 'DB EngineFirewall Application should be the SQLBrowaser.exe' {
            $Scriptblock = {(Get-NetFirewallRule -Name 'SQL Database Engine - Allow'|Get-NetFirewallApplicationFilter).Program} 
            $State = Invoke-Command -ComputerName $ServerName -ScriptBlock $Scriptblock 
            $State | Should -Be 'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Binn\sqlservr.exe'
        }
    } # End Context Firewall

    #>
       Context 'Databases' {
            It 'Should have a DBA-Admin Database'-Skip:$true {
            $Return.DbaAdminDB |Should Be $true
            }
            It 'Databases should have a normal Status - No Restoring, Recovery Pending etc'-Skip:$true {
            $Return.DatabasesStatus |Should Be 0
            }
            It 'System Databases Shol dhave been backed up within the last 24 hours'-Skip:$true {
            $Return.SysDatabasesFullBackupToday | Should -Be 0
            }
        } # End Context 
        Context 'Users' {
        It "Should have $SQLAdmins as a login"-Skip:$true {
                    $Return.SQLAdmins | Should -Be $True
        }
        It "$SQLAdmins Should -Be sysadmin"-Skip:$true {
                    $Return.SQLAdmin|Should Be $true
        }
        } # End Context 
        Context 'Defaults'{
        It "Should have a default Backup Directory of $BackupDirectory"-Skip:$true {
            $Return.BackupDirectory |Should Be $BackupDirectory
        }
        It "Should have a default Data Directory of $DataDirectory"-Skip:$true {
            $Return.DataDirectory |Should Be $DataDirectory
        }
        It "Should have a default Log Directory of $LogDirectory "-Skip:$true {
            $Return.LogDirectory |Should Be $LogDirectory 
        }
        It "Should have a Max Memory Setting of $MaxMemMb"-Skip:$true {
            $Return.MaxMemMb |Should Be $MaxMemMb
        }
        It "Should have a Collation of $Collation" -Skip:$true {
            $Return.Collation |Should Be $Collation
        }
        it "Should have $tempFiles tempdb files" -Skip:$skip {
            $Return.tempFiles| Should -Be $tempFiles
        }
        It 'Should have Alerts for Severity 20 and above' -Skip:$skip {
        $Return.Alerts20SeverityPlusExist | Should -Be 6
        }
        It 'Severity 20 and above Alerts should be enabled' -Skip:$skip {
        $Return.Alerts20SeverityPlusEnabled | Should -Be 6
        }
        It 'Should have alerts for 823,824 and 825' -Skip:$skip {
        $Return.Alerts82345Exist |Should Be 3
        }
        } # End Context 
        Context 'Agent Jobs' {
        It 'Should have Agent Jobs' -Skip:$true {
            $Return.AgentJobs |Should BeGreaterthan 0
        }
        It 'Should have Ola Hallengrens maintenance Solution' -Skip:$true {
          $Return.OlaProcs | Should -Be $True
        }
        It 'Should have Restore Proc for Ola Hallengrens Maintenance Solution' -Skip:$true {
            $Return.RestoreProc | Should -Be $True
            }
        It 'The Full System Database Backup should be enabled' -Skip:$true {
            $Return.OlaSysFullEnabled | Should -Be $True
        }
        It 'The Full System Database Backup should be scheduled' -Skip:$true {
            $Return.OlaSysFullScheduled | Should -Be $True
        }
        It "The Full System Database Backup should be scheduled $OlaSysFullFrequency" -Skip:$true {
            $Return.OlaSysFullFrequency.value| Should -Be $OlaSysFullFrequency 
        }
        It "The Full System Database Backup should be scheduled at $OlaSysFullStartTime" -Skip:$true {
            $Return.OlaSysFullStartTime| Should -Be $OlaSysFullStartTime
        }
        It 'The Full User Database Backup should be enabled' -Skip:$true {     
            $Return.OlaUserFullEnabled| Should -Be $True
        }
        It 'The Full User Database Backup should be scheduled' -Skip:$true {
            $Return.OlaUserFullScheduled | Should -Be $True
        }
        It "The Full User Database Backup should be scheduled Weekly $OlaUserFullSchedule" -Skip:$true {
            $Return.OlaUserFullSchedule.value | Should -Be $OlaUserFullSchedule
        }
        It "The Full user Database Backup should be scheduled Weekly on a $OlaUserFullFrequency" -Skip:$true {
            $Return.OlaUserFullFrequency| Should -Be $OlaUserFullFrequency
        }
        It "The Full User Database Backup should be scheduled at $OlaUserFullStartTime" -Skip:$true {
            $return.OlaUserFullStartTime| Should -Be $OlaUserFullStartTime
        }
        It 'The Diff User Database Backup should be enabled' -Skip:$true {
            $Return.OlaUserDiffEnabled| Should -Be $True
        }
        It 'The Diff User Database Backup should be scheduled' -Skip:$true {
            $Return.OlaUserDiffScheduled| Should -Be $True
        }
        It "The Diff User Database Backup should be scheduled Daily Except Sunday = $OlaUserDiffSchedule" -Skip:$true {
            $Return.OlaUserDiffSchedule.Value| Should Be $OlaUserDiffSchedule
        }
        It "The Diff User Database Backup should be scheduled Daily Except Sunday = $OlaUserDiffFrequency" -Skip:$true {
            $Return.OlaUserDiffFrequency| Should -Be $OlaUserDiffFrequency
        }
        It "The Diff User Database Backup should be scheduled at $OlaUserDiffStartTime" -Skip:$true {
            $Return.OlaUserDiffStartTime| Should -Be $OlaUserDiffStartTime 
        }
        It 'The Log User Database Backup should be enabled' -Skip:$true {
            $Return.OlaUserLogEnabled| Should -Be $true
        }
        It 'The Log User Database Backup should be scheduled' -Skip:$true {
            $Return.OlaUserLogScheduled| Should -Be $True
        }
        It 'The Log User Database Backup should be scheduled Daily' -Skip:$true {
            $Return.OlaUserLogSchedule.Value  | Should -Be 'Daily'
        }
        It 'The Log User Database Backup should be scheduled Daily' -Skip:$true {
            $Return.OlaUserLogFrequency| Should -Be 1
        }
        It "The Log User Database Backup should be scheduled for every $OlaUserLogSubDayInterval" -Skip:$true {
            $Return.OlaUserLogSubDayInterval| Should -Be $OlaUserLogSubDayInterval
            }
        It "The Log User Database Backup should be scheduled for every $OlaUserLoginterval" -Skip:$true {
            $Return.OlaUserLoginterval.Value| Should -Be $OlaUserLoginterval 
        }
        It "Should have the Log SP_WhoisActive to Table Agent Job $LogWhoIsActiveToTable" -Skip:$true {
            $Return.LogWhoIsActiveToTable| Should -Be $LogWhoIsActiveToTable 
        }
        It "Should have the Log SP_Blitz to Table Agent Job $LogSPBlitzToTable" -Skip:$true {
            $Return.LogSPBlitzToTable| Should -Be $LogSPBlitzToTable 
        }
        It "Log SP_Blitz to Table Agent Job Should Be Enabled" -Skip:$true {
            $Return.LogSPBlitzToTableEnabled| Should -Be $LogSPBlitzToTableEnabled
        }
        It "Log SP_Blitz to Table Agent Job Should Be Scheduled" -Skip:$true {
            $Return.LogSPBlitzToTableScheduled| Should -Be $LogSPBlitzToTableScheduled
        }
        It "Log SP_Blitz to Table Agent Job Should Be Scheduled $LogSPBlitzToTableSchedule" -Skip:$true {
            $Return.LogSPBlitzToTableSchedule.Value| Should -Be $LogSPBlitzToTableSchedule
        }
        It "Log SP_Blitz to Table Agent Job Should Be Scheduled Weekly on a $LogSPBlitzToTableFrequency" -Skip:$true {
            $Return.LogSPBlitzToTableFrequency| Should -Be $LogSPBlitzToTableFrequency
        }
        It "Log SP_WhoisActive to Table Agent Job Should Be Scheduled at $LogSPBlitzToTableStartTime" -Skip:$true {
            $Return.LogSPBlitzToTableStartTime| Should -Be $LogSPBlitzToTableStartTime
        }  
        } # End Context Agent Jobs
        Context 'DBA Scripts' {
        It "Should Have sp_Blitz $HasSPBlitz"-Skip:$true {
          $Return.HasSPBlitz |Should -Be $HasSPBlitz
          }    
        It "Should Have sp_BlitzCache $HasSPBlitzCache" -Skip:$true {
        $Return.HasSPBlitzCache | Should -Be $HasSPBlitzCache
        }     
        It "Should Have sp_BlitzIndex $HasSPBlitzIndex" -Skip:$true {
        $Return.HasSPBlitzIndex | Should -Be $HasSPBlitzIndex
        }
        It "Should Have sp_AskBrent $HasSPAskBrent" -Skip:$true {
        $Return.HasSPAskBrent | Should -Be $HasSPAskBrent
        }
        It "Should Have sp_BlitzTrace $HASSPBlitzTrace" -Skip:$true {
        $Return.HASSPBlitzTrace | Should -Be $HASSPBlitzTrace
        }
        It "Should Have sp_WhoIsActive $HasSPWhoisActive" -Skip:$true {
        $Return.HasSPWhoisActive | Should -Be $HasSPWhoisActive
        } 
        }
} # End Describe $Server
}
}


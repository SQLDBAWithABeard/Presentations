<# Where the magic happens#>


<#
Get-Help Always start with get-help
#>


<# Latency - test-SQLConnection - Uptime - tcpport #>


<# SP_configure difference between two servers and copy Windows to Linux 

NEEDS COMMENTS -0 RMS
#>

Return ' Hey BEardy This is a Demo!! '


$linuxSQL = 'LinuxvvNext'
$WinSQl1 = 'SQLvNextN1'
$cred = Get-Credential -UserName SA -Message "Linux SQL Auth"
$linux = Connect-DbaSqlServer -SqlServer $linuxSQL  -Credential $cred
$win1 = Connect-DbaSqlServer -SqlServer $WinSQl1

Function Compare-WinLinuxConfigs
{
$linuxSpConfigure = Get-DbaSpConfigure  -SqlServer $linuxSQL -SqlCredential $cred
$WinSPConfigure = Get-DbaSpConfigure -SqlServer $WinSQl1

$propcompare = foreach ($prop in $linuxSpConfigure) {
    [pscustomobject]@{
    Config = $prop.DisplayName
    'Linux setting' = $prop.RunningValue
    'Windows Setting' = $WinSPConfigure | Where DisplayName -eq $prop.DisplayName | Select -ExpandProperty RunningValue
    }
} 

$propcompare | ogv
}

Compare-WinLinuxConfigs

$win.Configuration.Properties['DefaultBackupCompression'].ConfigValue = 1
$win.Configuration.Alter()

Compare-WinLinuxConfigs

Copy-SqlSpConfigure -Source $WinSQl1 -Destination $linuxSQL -DestinationSqlCredential $cred -Configs DefaultBackupCompression

Compare-WinLinuxConfigs

$linux.Configuration.Properties['DefaultBackupCompression'].ConfigValue = 0
$linux.Configuration.Alter()

Compare-WinLinuxConfigs

$linuxConfigPath = 'C:\Temp\Linuxconfig.sql'
Export-SqlSpConfigure -SqlServer $linuxSQL -SqlCredential $cred -Path $LinuxConfigPath
notepad $linuxConfigPath

$WinConfigPath = 'C:\Temp\Winconfig.sql'
Export-SqlSpConfigure -SqlServer $WinSQl1 -Path $winConfigPath
notepad $winConfigPath

Import-SqlSpConfigure -Path $WinConfigPath -SqlServer $linuxSQL -SqlCredential $cred


Compare-WinLinuxConfigs

<# Test- Set Max Memory #>


<# Test Set Tempdb #>


<# DBCC CheckDb #>
cd 'SQLSERVER:\sqlregistration\database engine server group\BEARDNUC'
$allservers = (Get-ChildItem).Where{$_.Name -like '*SQL2016N*'}.Name
Get-DbaLastGoodCheckDb -SqlServer $allservers -Detailed | ogv

<# Find-DBAStoredProcedure #>


<# Test-DBAIdentity #>


<# Get-DBAFreeSpace #>


<# Find-DatabaseAutoGrowthEvent #>


<# Read-DBAtransactionlog #>


<# Orphaned File #>


<# Start-Up Parameters #>

<## INDEXES ##>

Get-DbaHelpIndex -SqlServer sql2016N1 -Databases Viennadbareports -IncludeStats -IncludeDataTypes |ogv

<# Duplicate Indexes #>

## ADD DUPLCIATE INDEXES - RMS

Find-SqlDuplicateIndex -SqlServer sql2016n1

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


<# Chrissy's blog post about a restore server #>


<# remove-SQLDatabaseSafely #>


<# Copy-SQLJob #>


<# Pester Tests #>
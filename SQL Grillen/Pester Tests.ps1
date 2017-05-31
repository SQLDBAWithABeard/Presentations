<#
## Needs Both SQL Instances

cd presentations:\
try
{
    Start-Process powershell.exe -ArgumentList '-noprofile -command Get-Service MS*DAVE*,SQLAgent*DAVE,SQLSERVERAGENT,MSSQLSERVER,SQLAgent*SQL2016,MSSQL*SQL2016 | Start-Service' -Verb runas
}
catch
{
    Write-Warning "FAILED to start SQL"
}

Get-VM SQL2017CTP2 | Start-VM

import-module sqlserver
Import-module Pester
Import-Module dbatools

## Run Log Backups
$SQLServers = 'ROB-XPS','ROB-XPS\DAVE','ROB-XPS\SQL2016'
(Get-SQLAgentJob -ServerInstance $SQLServers | Where-Object {$_.Name -like 'Database*Log'}).Start()

#>
    Describe "SQL State" {
        $SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE','ROB-XPS\SQL2016'
        foreach($Server in $SQLServers)
        {
            Context "Checking SQL $Server" {
            if ($Server.Contains('\')) {
                $ServerName = $Server.Split('\')[0]
                $Instance = $Server.Split('\')[1]
            }
            else {
                $Servername = $Server
                $Instance = 'MSSQLSERVER'
            } 
            If ($Instance -eq 'MSSQLSERVER') {
                $SQLService = $Instance
                $AgentService = 'SQLSERVERAGENT'
            }
            else {
                $SQLService = "MSSQL$" + $Instance
                $AgentService = "SQLAgent$" + $Instance
            }
            $DBEngine = Get-service -ComputerName $Servername -Name $SQLService
                 It "$Server  DBEngine should be running" {
                      $DBEngine.Status | Should Be 'Running'
                  }
                 It "$Server DBEngine Should Not be Auto Start" {
                  $DBEngine.StartType | Should be 'Manual'
                 }
            $Agent = Get-service -ComputerName $Servername -Name $AgentService
                    It "$Server Agent should be running" {
                        $Agent.Status | Should Be 'Running'
                 }
                 It "$Server Agent Should Not be Auto Start" {
                  $Agent.StartType | Should be 'Manual'
                 }
            }
        }
    
    }


Describe "Testing for Presentation" {
    Context "Rob-XPS" {
        It "Shoudl have Code Insiders Open" {
             (Get-Process 'Code - Insiders'  -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        It "Should have PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Not Be 0
        }
       It "Should have One PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Be 1
        }

        It "Should have the correct PowerPoint Presentation Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'Green is Good - Red is Bad - PowerPoint'
        }
        It "Mail Should be closed" {
            (Get-Process HxMail -ErrorAction SilentlyContinue).COunt | Should Be 0
        }
        It "Tweetium should be closed" {
            (Get-Process WWAHost -ErrorAction SilentlyContinue).Count | Should Be 0
        }
        It "Slack should be closed" {
            (Get-Process slack* -ErrorAction SilentlyContinue).Count | Should BE 0
        }
        It "Prompt should be Presentations" {
            (Get-Location).Path | Should Be 'Presentations:\'
        }
        It "Should be running as rob-xps\mrrob" {
            whoami | Should Be 'rob-xps\mrrob'
        }
        It "Hyper-V Should Be Running" {
            (Get-Service vmcompute).Status | Should Be 'Running'
        }
        It "SQL2017CTP2 Should Be Running" {
            (Get-VM SQL2017CTP2 -ErrorAction SilentlyContinue).State | Should Be 'Running'
        }
        It "Should Have PowerBi Open" {
            Get-Process PBIDesktop  -ErrorAction SilentlyContinue| Should Not BeNullOrEmpty
        }
        It "Should have one PowerBi Open" {
            (Get-Process PBIDesktop -ErrorAction SilentlyContinue).Count | Should Be 1
        }
        It "Should have the RIGHT PowerBi Open!" {
            (Get-Process PBIDesktop -ErrorAction SilentlyContinue).MainWindowTitle | Should Be "Test Ola Report - Power BI Desktop"
        }
    }
}

Describe "Testing for Demo"{
    Context "All" {
        It "Should have DNS Servers for correct interface" {
            (Get-DnsClientServerAddress -InterfaceAlias 'Ethernet 2' -ErrorAction SilentlyContinue).Serveraddresses | Should Be @()
        }
        It "Should have correct gateway for alias"{
            (Get-NetIPConfiguration -InterfaceAlias 'Ethernet 2' -ErrorAction SilentlyContinue).Ipv4DefaultGateway.NextHop | Should Be '192.168.1.1'
        }
        It "Should have version 4.0.3 Pester Module installed" {
            (Get-Module Pester).Version | Should Be 4.0.3
        }
        It "Should have version 0.8.957 dbatools Module installed" {
            (Get-Module dbatools).Version | Should Be 0.8.957
        }
        It "Should have version 21.0.17099 sqlserver Module installed" {
            (Get-Module sqlserver)[0].Version | Should Be 21.0.17099
        }
        It "Code shoudl be running elevated"{
            (whoami /all | select-string S-1-16-12288) -ne $null | Should Be $True
        }
        It "Should have the Local Admin Cred for SQL2017CTP2" {
            Test-Path C:\backup\sql2017ctp2Rob.xml | Should Be $true
        }
        It "Should have the SA Cred for SQL2017CTP2" {
            Test-Path C:\backup\sacred.xml | Should Be $true
        }
        It "Should have the dbatools-scripts-local folder" {
            Test-Path C:\Users\mrrob\OneDrive\Documents\GitHub\dbatools-scripts-local\ | Should Be $true
            Test-Path GIT:\dbatools-scripts-local\ | Should Be $true
        }
        It "Should have the config file for the pester tests" {
            Test-Path C:\Users\mrrob\OneDrive\Documents\GitHub\dbatools-scripts-local\TestConfig.json | Should Be $true
        }
    }
    Context "Demo 1" {
        $cred = Import-Clixml C:\backup\sql2017ctp2Rob.xml
        It "The Server SQL2017CTP2 retunrs a ping" {
            (Test-Connection SQL2017CTP2 -Count 1 -Quiet -ErrorAction SilentlyContinue ) | Should Be $true
        }
        It "Default SQL Instance exists" {
            (Test-SqlConnection -SqlServer ROB-XPS).ConnectSuccess -eq $true | Should Be $true
        }
        It "SQL2016 SQL Instance exists" {
            (Test-SqlConnection -SqlServer ROB-XPS\SQL2016).ConnectSuccess -eq $true | Should Be $true
        }
        It "DAVE SQL Instance exists" {
            (Test-SqlConnection -SqlServer ROB-XPS\DAVE).ConnectSuccess -eq $true | Should Be $true
        }
        It "Hyper-V is enabled" {
            (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V).State | Should Be 'Enabled'
        }
        It "IIS should be disabled" {
            (Get-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole).State | Should Be 'Disabled'
        }
        It "SMBv1 should be removed from SQL2017CTP2" {
            (Get-WindowsFeature -ComputerName sql2017ctp2 -Credential $cred -Name FS-SMB1).InstallState | Should Be 'Removed'
        }
        It ".NET 4.6 should be installed" {
            (Get-WindowsFeature -ComputerName sql2017ctp2 -Credential $cred -Name Net-Framework-45-Core).InstallState | SHould Be 'Installed'
        }
        It "ROB-XPS Operating System Version" {
            (Get-WmiObject -ComputerName ROB-XPS -Class Win32_OperatingSystem).Version | Should Be '10.0.15063'
        }
        It "The Backup Folder exists" {
            Test-Path C:\MSSQL\BACKUP | Should Be $true
        }
        It "The Backup Share exists and is accessible by Default SQL Server" {
            Test-SqlPath -SqlServer ROB-XPS -Path C:\MSSQL\BACKUP | Should Be $true
        }
        It "The Backup Share exists and is accessible by DAVE SQL Server" {
            Test-SqlPath -SqlServer ROB-XPS\DAVE -Path C:\MSSQL\BACKUP | Should Be $true
        }
        It "The Backup Share exists and is accessible by SQL2016 SQL Server" {
            Test-SqlPath -SqlServer ROB-XPS\SQL2016 -Path C:\MSSQL\BACKUP | Should Be $true
        }
        It "Should have the jenkins file" {
            Test-Path 'C:\Program Files (x86)\Jenkins\jenkins.exe' | should be $true
        }
        It "Octopus Deploy Packages Should have at least two files" {
            (Get-ChildItem C:\Octopus\Packages\TheBeard).Count | Should BeGreaterThan 1
        }
        It "Jenkins Exe should be of this version" {
            (Get-ChildItem "C:\Program Files (x86)\Jenkins\jenkins.exe").VersionInfo.FileVersion | Should Be '1.1.0.0'
        }
        It "File should have been created on this date" {
            (Get-ChildItem C:\MSSQL\BACKUP\ROB-XPS\WideWorldImporters\FULL\ROB-XPS_WideWorldImporters_FULL_20170528_145031.bak).CreationTime | Should Be '05/28/2017 14:50:31'
        }
        It "Newest Backup File should be less than 30 minutes old" {
            $File = Get-ChildItem C:\MSSQL\BACKUP\ROB-XPS\thebeardsdatabase\LOG | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            $File.LastWriteTime| Should BeGreaterThan (Get-Date).AddMinutes(-30)
        }
        It "Should have 5 Network Adapters" {
            (Get-NetAdapter).Count | Should be 5
        }
        It "Should have correct DNS Servers" {
            (Get-DnsClientServerAddress -InterfaceAlias 'FreedomeVPNConnection').Serveraddresses | Should Be @('198.18.0.45')
        }
        (Get-DnsClientServerAddress -InterfaceAlias 'vEthernet (Beard Internal)').Serveraddresses.ForEach{
            It "DNS Server $($_) should respond to ping" {
                (Test-Connection $_ -Count 1 -Quiet -ErrorAction SilentlyContinue ) | Should Be $true
            }
        }
        It "Should have the Correct Gateway" {
            (Get-NetIPConfiguration -InterfaceAlias 'WIFI').Ipv4DefaultGateway.NextHop | Should Be '192.168.1.1'
        }
        It "Gateway should respond to ping" {
            (Test-Connection (Get-NetIPConfiguration -InterfaceAlias 'WIFI').Ipv4DefaultGateway.NextHop -Count 1 -Quiet -ErrorAction SilentlyContinue ) | Should Be $true
        }
        BeforeAll {
            $Programmes = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*
        }
        It "Should have Google Chrome" {
            $Programmes.Where{'Google Chrome'} | Should Not BeNullOrEmpty
        }
        It "Should have SSMS 2016" {
            $Programmes.Where{$_.displayname -eq 'SQL Server 2016 Management Studio'} | Should Not BeNullOrEmpty
        }
        It "Should have SSMS 17.1" {
            $Programmes.Where{$_.displayname -eq 'Microsoft SQL Server Management Studio - 17.1'} | Should Not BeNullOrEmpty
        }
        It "SSMS 17 RC should be version 14.0.17028.0" {
            $Programmes.Where{$_.displayname -eq 'Microsoft SQL Server Management Studio - 17.1'}.DisplayVersion | Should Be 14.0.17119.0
        }
    }
    ."GIT:\Presentations\SQL Grillen\Test-SQLSDefaults.ps1"
    $Parms = @{
        Servers                    = 'ROB-XPS' , 'ROB-XPS\SQL2016', 'ROB-XPS\DAVE';
        SQLAdmins                  = 'THEBEARD\Rob', 'THEBEARD\SQLAdmins';
        BackupDirectory            = 'C:\MSSQL\Backup';
        DataDirectory              = 'C:\MSSQL\Data\';
        LogDirectory               = 'C:\MSSQL\Logs\';
        MaxMemMb                   = '4096';
        Collation                  = 'Latin1_General_CI_AS';
        TempFiles                  = 4 ;
        OlaSysFullFrequency        = 'Daily';
        OlaSysFullStartTime        = '00:00:00';
        OlaUserFullSchedule        = 'Weekly';
        OlaUserFullFrequency       = 1 ; ## 1 for Sunday
        OlaUserFullStartTime       = '00:00:00';
        OlaUserDiffSchedule        = 'Daily';
        OlaUserDiffFrequency       = 1; ## 126 for every day except Sunday
        OlaUserDiffStartTime       = '00:00:00';
        OlaUserLogSubDayInterval   = 4;
        OlaUserLoginterval         = 'Hour';
        HasSPBlitz                 = $true;
        HasSPBlitzCache            = $True; 
        HasSPBlitzIndex            = $True;
        HasSPAskBrent              = $true;
        HASSPBlitzTrace            = $true;
        HasSPWhoisActive           = $true;
        LogWhoIsActiveToTable      = $true;
        LogSPBlitzToTable          = $true;
        LogSPBlitzToTableEnabled   = $true;
        LogSPBlitzToTableScheduled = $true;
        LogSPBlitzToTableSchedule  = 'Weekly'; 
        LogSPBlitzToTableFrequency = 2 ; # 2 means Monday 
        LogSPBlitzToTableStartTime = '03:00:00'
    }
      
    Test-SQLDefault @Parms

    Context "Demo 5" {
        It "Should have the correct folders" {
            Test-Path C:\temp\Reports | Should Be $true
            Test-Path C:\temp\ReportsIndividual | Should Be $true 
        }
        It "Shold Not have any XML files in the report folder" {
            (Get-ChildItem C:\temp\ReportsIndividual\*xml).Count | Should Be 0 
        }
        It "Shold Not have any HTML files in the report folder" {
            (Get-ChildItem C:\temp\ReportsIndividual\*html).Count | Should Be 0 
        }

    }
}
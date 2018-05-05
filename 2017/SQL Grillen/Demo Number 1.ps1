## Pester Demo

## RUN THEN Talk


#Requires -RunAsAdministrator
#Requires -Module dbatools
#Requires -Module sqlserver

Describe "Do things Exist" {
    BeforeAll {
        $cred = Import-Clixml C:\backup\sql2017ctp2Rob.xml
    }
    Context "Servers" {
        It "The Server retunrs a ping - This will fail - Wrong Server Name" {
            (Test-Connection SQL2016N31 -Count 1 -Quiet -ErrorAction SilentlyContinue ) | Should Be $true
        }
        It "The Server SQL2017CTP2 retunrs a ping" {
            (Test-Connection SQL2017CTP2 -Count 1 -Quiet -ErrorAction SilentlyContinue ) | Should Be $true
        }
    }
    Context "SQL Servers" {
        It "Default SQL Instance exists" {
            (Test-SqlConnection -SqlServer ROB-XPS).ConnectSuccess -eq $true | Should Be $true
        }
        It "SQL2016 SQL Instance exists" {
            (Test-SqlConnection -SqlServer ROB-XPS\SQL2016).ConnectSuccess -eq $true | Should Be $true
        }
        It "DAVE SQL Instance exists" {
            (Test-SqlConnection -SqlServer ROB-XPS\DAVE).ConnectSuccess -eq $true | Should Be $true
        }
        $srv = New-Object Microsoft.SqlServer.Management.Smo.Server ROB-XPS
        $Errorlog = $srv.ErrorLogPath + '\ERRORLOG'
        It "Error Log contains SQL Server is Ready - Contains works with Files" {
            
            $Errorlog | Should Contain "SQL Server is now ready for client connections"
        }

        It "Error Log shows CHECKDB finished without errors notice the .* any number of any character" {
            $Errorlog | Should Contain "CHECKDB for database.*finished without errors"
            ## WHat is this doing ?
        }
        It "Logins contain THEBEARD\Rob" {
            $srv.logins.Name -contains 'THEBEARD\Rob' |Should Be $true
        }
        It "$($srv.Name) has an operator - using BeNullOrEmpty and NOT" {
            $srv.JobServer.Operators | Should Not BeNullOrEmpty
        }
    }
    Context "Windows Features" {
        It "Hyper-V is enabled" {
         (Get-WindowsOptionalFeature -Online).Where{$_.FeatureName -eq 'Microsoft-Hyper-V'}.State | Should Be 'Enabled'
        }
        It "IIS should be disabled" {
         (Get-WindowsOptionalFeature -Online).Where{$_.FeatureName -eq 'IIS-WebServerRole'}.State | Should Be 'Disabled'
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
    }
    Context "Shares and Files" {
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
        It "File should have been created on this date"{
            (Get-ChildItem C:\MSSQL\BACKUP\ROB-XPS\WideWorldImporters\FULL\ROB-XPS_WideWorldImporters_FULL_20170528_145031.bak).CreationTime | Should Be '05/28/2017 14:50:31'
        }
        It "Newest Backup File should be less than 30 minutes old"{
            $File = Get-ChildItem C:\MSSQL\BACKUP\ROB-XPS\thebeardsdatabase\LOG | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            $File.LastWriteTime| Should BeGreaterThan (Get-Date).AddMinutes(-30)
        }
    }
    Context "Networks" {
        It "Should have 4 Network Adapters" {
            (Get-NetAdapter).Count | Should be 4
        }
        It "Should have correct DNS Servers" {
            (Get-DnsClientServerAddress -InterfaceAlias 'FreedomeVPNConnection').Serveraddresses | Should Be @('198.18.2.157')
        }
        It "Should have the Correct Gateway"{
            (Get-NetIPConfiguration -InterfaceAlias 'WIFI').Ipv4DefaultGateway.NextHop | Should Be '192.168.43.1'
        }
    }
    Context "Programmes"{
        BeforeAll{
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
}



## Pester Demo

## Just a failsafe ;-)
# Return "This is a demo Beardy!"


## Does it exist ?

Describe "Do things Exist" {
    Context "Servers" {
        It "The Server retunrs a ping" {
            (Test-Connection SQL2016N31 -Count 1 -Quiet -ErrorAction SilentlyContinue ) | Should Be $true
        }
        It "The Server retunrs a ping" {
            (Test-Connection SQL2016N1 -Count 1 -Quiet -ErrorAction SilentlyContinue ) | Should Be $true
        }
        It "SQL2005Ser2003 Operating System Version" {
            (Get-WmiObject -ComputerName SQL2005Ser2003 -Class Win32_OperatingSystem).Version | Should Be '5.2.3790'
        }
        It "SQL2012Ser08AG1 Operating System" {
            (Get-WmiObject -ComputerName SQL2012Ser08AG1 -Class Win32_OperatingSystem).Version  | Should Be '6.1.7601'
        }
        It "SQL2016N1 Operating System"{
            (Get-CimInstance -ComputerName SQL2016N1 -ClassName win32_operatingsystem).Version | Should Be '10.0.14393'
        }
    }
    Context "Shares and Files" {
        It "The Backup Share exists and is accessible" {
            Test-Path \\SQL2016N2\SQLBackups | Should Be $true
        }
        It "Should have the htm file" {
            Test-Path \\sql2016n1\C$\inetpub\wwwroot\iisstart.htm | should be $true
        }
        It "wwwroot folder should have only 2 files" {
            (Get-ChildItem \\sql2016n1\C$\inetpub\wwwroot\).Count | Should Be 2
        }
        It "Exe should be of this version" {
            (Get-ChildItem "\\SQL2016N1\C$\Program Files (x86)\Microsoft SQL Server\130\Tools\Binn\SQLPS.exe").VersionInfo.FileVersion | Should Be '13.0.1601.5 ((SQL16_RTM).160429-2226)'
        }
        It "File should have been created on this date"{
            (Get-ChildItem \\sql2016n1\C$\inetpub\wwwroot\iisstart.htm).CreationTime | Should Be '04/17/2017 09:10:32'
        }
        It "File should not have been modified since this date"{
            (Get-ChildItem \\sql2016n1\C$\inetpub\wwwroot\iisstart.htm).LastWriteTime| Should BeGreaterThan '04/17/2017 09:10:30'
        }
    }
    Context "Networks" {
        It "Should have 6 Network Adapters" {
            (Get-NetAdapter).COunt | Should be 6
        }
        It "Should have correct DNS Servers" {
            (Get-DnsClientServerAddress -InterfaceAlias 'Ethernet 3').Serveraddresses | Should Be @('10.0.0.2','10.0.0.1')
        }
        (Get-DnsClientServerAddress -InterfaceAlias 'Ethernet 3').Serveraddresses.ForEach{
            It "DNS Server $($_) should respond to ping" {
                (Test-Connection $_ -Count 1 -Quiet -ErrorAction SilentlyContinue ) | Should Be $true
            }
        }
        It "Should have the Correct Gateway"{
            (Get-NetIPConfiguration -InterfaceAlias 'Ethernet 3').Ipv4DefaultGateway.NextHop | Should Be '10.0.0.1'
        }
        It "Gateway should respond to ping" {
            (Test-Connection (Get-NetIPConfiguration -InterfaceAlias 'Ethernet 3').Ipv4DefaultGateway.NextHop -Count 1 -Quiet -ErrorAction SilentlyContinue ) | Should Be $true
        }
    }
    Context "IIS"{
        It 'Should have IIS Feature' {
            Get-WindowsFeature -ComputerName SQL2016N1 -Name Web-Server| Should Be $True
        }
        It 'Should have IIS Management Tools' {
            Get-WindowsFeature -ComputerName SQL2016N1 -Name Web-Mgmt-Tools| Should Be $True
        }
        It 'Should have IIS Console' {
            Get-WindowsFeature -ComputerName SQL2016N1 -Name Web-Mgmt-Console| Should Be $True
        } 
        It 'The Default Website Should be Started' {
            $Scriptblock = {(get-website -Name 'Default Web Site').state }
            $State = Invoke-Command -ComputerName SQL2016N1 -ScriptBlock $Scriptblock 
            $State | Should Be 'Started'
        }  
        It 'The Default App Pool should be started' {
            $State = Invoke-Command -ComputerName SQL2016N1 -ScriptBlock {(Get-WebAppPoolState -Name DefaultAppPool).Value}
            $State | Should Be 'Started'
        }
        It "The website protocols should be http" {
            $Protocols = Invoke-Command -ComputerName SQL2016N1 -ScriptBlock {(Get-WebSite -Name 'Default Web Site').enabledProtocols}
            $Protocols  | Should Be 'http'
        }
        It "The website path should be correct" {
            $Path = Invoke-Command -ComputerName SQL2016N1 -ScriptBlock {(Get-WebSite -Name 'Default Web Site').physicalPath}
            $Path | Should Be '%SystemDrive%\inetpub\wwwroot'
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
        It "Should have SSMS 17 RC" {
            $Programmes.Where{$_.displayname -eq 'Microsoft SQL Server Management Studio - 17.0 RC3'} | Should Not BeNullOrEmpty
        }
        It "SSMS 17 RC should be version 14.0.17028.0" {
            $Programmes.Where{$_.displayname -eq 'Microsoft SQL Server Management Studio - 17.0 RC3'}.DisplayVersion | Should Be 14.0.17028.0
        }
    }
}

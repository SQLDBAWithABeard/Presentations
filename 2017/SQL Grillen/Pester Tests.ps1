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
            (Get-DnsClientServerAddress -InterfaceAlias 'FreedomeVPNConnection' -ErrorAction SilentlyContinue).Serveraddresses | Should Be @('198.18.2.157')
        }
        It "Should have correct gateway for alias"{
            (Get-NetIPConfiguration -InterfaceAlias 'Wifi' -ErrorAction SilentlyContinue).Ipv4DefaultGateway.NextHop | Should Be '192.168.43.1'
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
       Invoke-Pester 'Presentations:\SQL Grillen\Demo Number 1.ps1'
    }
    Context "Demo 2" {
       Invoke-Pester 'Presentations:\SQL Grillen\Demo Number 2.ps1'
    }
    Context "Demo 5" {
       Invoke-Pester 'Presentations:\SQL Grillen\Demo Number 5.ps1'
    }
}
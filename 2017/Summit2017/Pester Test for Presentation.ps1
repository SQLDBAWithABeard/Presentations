<#
## Needs Both SQL Instances

cd presentations:\
try
{
    Start-Process powershell.exe -ArgumentList '-noprofile -command Get-Service MS*DAVE*,SQLAgent*DAVE | Start-Service' -Verb runas
}
catch
{
    Write-Warning "FAILED to start DAVE"
}
try
{
    Start-Process powershell.exe -ArgumentList '-noprofile -command Get-Service SQLSERVERAGENT,MSSQLSERVER|Start-Service' -Verb runas
}
catch
{
    Write-Warning "FAILED to start SQL"
}

try
{
    Start-Process powershell.exe -ArgumentList '-noprofile -command Get-Service MS*CTP2*,SQLAgent*CTP2 | Start-Service' -Verb runas
}
catch
{
    Write-Warning "FAILED to start SQL"
}

get-module dbatools | remove-module -ea silentlycontinue
import-module git:\dbatools\dbatools.psd1
#>

$sacred = Import-Clixml C:\MSSQL\sa.cred
Describe "Testing XPS" {
  Context "XPS" {
        It "DBEngine is running" {
            (Get-Service mssqlserver -ErrorAction SilentlyContinue).Status | Should Be Running
        }
        It "SQL Server Agent is running" {
            (Get-Service sqlserveragent -ErrorAction SilentlyContinue).Status | Should Be Running
        }
        It "DAVE DBEngine is running" {
            (Get-Service mssql*Dave -ErrorAction SilentlyContinue).Status | Should Be Running
        }
        It "DAVE Agent is running" {
            (Get-Service sqlagent*dave -ErrorAction SilentlyContinue).Status | Should Be Running
        }
    }
      
    Context "Hyper-V" {
        It "Hyper-V Should Be Running" {
            (Get-Service vmcompute).Status | Should Be 'Running'
        }
        It "$LinuxHyperVShould Be Running" {
            (Get-VM Bolton -ErrorAction SilentlyContinue).State | Should Be 'Running'
        }
    }
    It "Should have SQL Browser running" {
        (Get-Service SQLBrowser).Status | Should Be 'Running'
    }
    It "Should have Linux SQL running" {
        {Connect-DbaSqlServer -SqlInstance Bolton -Credential $sacred} | Should Not Throw
    }
} #end describe
Describe "Testing for Presentation" {
    Context "Rob-XPS" {
        It "Shoudl have Code Insiders Open" {
             (Get-Process 'Code - Insiders'  -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
        }
        It "Should have PowerPoint Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).Count | Should Be 1
        }
        It "Should have the correct PowerPoint Presentation Open" {
            (Get-Process POWERPNT  -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'precon - PowerPoint'
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
        It "Should have SSMS open" {
            (Get-Process ssms -ErrorAction SilentlyContinue).Count | Should Be 1
        }
    }
    Context "SQLSERVER:\" {
        It "Should have a 01 - Linux Server in registered servers" {
            Get-ChildItem 'SQLSERVER:\SQLRegistration\Database Engine Server Group\Rob-XPS\01 - Linux' | Should Not BeNullOrEmpty
        }
    }
}
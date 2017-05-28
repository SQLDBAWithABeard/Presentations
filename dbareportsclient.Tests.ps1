<#


cd presentations:\
try
{
    Start-Process powershell.exe -ArgumentList '-noprofile -command Get-Service MSSQLSERVER,SQLServerAgent,ReportServer | Start-Service' -Verb runas
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

if(Test-Path C:\Users\User\OneDrive\Documents\WindowsPowerShell\Modules\dbareports\dbareports-config.json)
{
    rm C:\Users\User\OneDrive\Documents\WindowsPowerShell\Modules\dbareports\dbareports-config.json
}

## Load the module

Import-Module GIT:\dbareports\dbareports.psd1

$srv = Connect-DBASQLServer Rob-XPS
if($srv.Databases['dbareportsMay2017'])
{
$srv.KillDatabase('dbareportsMay2017')
}
if ($srv.JobServer.jobs.WHere{$_.Name -like '*dbareports*'}.Name))
{
    $srv.JobServer.jobs.WHere{$_.Name -like '*dbareports*'}.drop()
}
#>

Describe "SQL and SSRS" {
    It "Should have SQL Server Service running" {
        (Get-Service MSSQLSERVER).Status | Should Be 'Running'
    }
    It "Should have SSRS Running" {
        (Get-Service ReportServer).Status | Should Be 'Running'
    }
    It "Should have SQL Server Agent Running" {
        (Get-Service SQLSERVERAGENT).Status | Should Be 'Running'
    }
}


Describe "Testing for Presentation" {
    Context "Rob-XPS" {
        <# It "Should have One PowerShell ISE Process" {
            (Get-Process powershell_ise -ErrorAction SilentlyContinue).Count | Should Be 1
        }#>
        It "Shoudl have Code Insiders Open" {
             (Get-Process 'Code - Insiders'  -ErrorAction SilentlyContinue) | Should Not BeNullOrEmpty
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
        It "Should be running as rob-xps\user" {
            whoami | Should Be 'rob-xps\user'
        }
    }
    Context "dbareports" {
        BeforeAll {
            $srv = Connect-DBASQLServer Rob-XPS
        }
        It "Should have the dbareports module" {
            Get-module dbareports | Should Not BeNullOrEmpty
        }   
        It "Should have the dbareports github version loaded" {
            (Get-module dbareports).ModuleBase | SHould Be C:\Users\User\OneDrive\Documents\Github\dbareports
        }
        It "Should not have a dbareports config file" {
            Test-Path C:\Users\User\OneDrive\Documents\WindowsPowerShell\Modules\dbareports\dbareports-config.json | SHould Be $false
        }
        It "Should not have the dbareportsMay2017 database" {
            ($Srv.Databases.Name -match 'dbareportsMay2017').Count | Should Be 0
        }
        It "Should have the DEMOdbareports database" {
            ($Srv.Databases.Name -match 'DEMOdbareports').Count | Should Be 1
        }
        It "Should not have any dbareport jobs" {
            $srv.jobserver.Jobs.Name -match 'dbareports' | Should BeNullOrEmpty
        }
        It "DEMOdbareports database users should contain dbareports" {
            $srv.Databases['DEMOdbareports'].Users.Name -contains 'dbareports'| should Be $true
        }
        It "dbareports user should be member of datareader role in DEMOdbareports" {
            $srv.Databases['DEMOdbareports'].Roles['db_datareader'].EnumMembers() -contains 'dbareports' | Should Be $true
        }
        It "Chrome should be open" {
            Get-Process 'Chrome' -ErrorAction SilentlyContinue | Should Not BeNullOrEmpty
        }
        It "Should have the SSRS reports open" {
            (Get-Process chrome).MainWindowTitle -contains  '00 - Quick View - SQL Server Reporting Services - Google Chrome' | SHould BE $true
        }
        It "Data adjust script should have been run" {
            $query = @"
Select SUM(AJS.FailedJObs) as Num
FROM dbo.InstanceList IL
JOIN info.AgentJobServer AJS
ON AJS.InstanceID = IL.InstanceID
WHERE
AJS.Date > DATEADD(Day,-1,GetDate())
"@
    (Invoke-Sqlcmd -ServerInstance ROB-XPS -Database DEMOdbareports -Query $query).Num | Should Be 11
        }
    }
}

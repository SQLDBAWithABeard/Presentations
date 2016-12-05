## Needs Both SQL Instances
cd presentations:\
try
{
    get-service MS*DAVE*|Start-Service
}
catch{Write-Warning "FAILED to start DAVE"
}
try
{
    Get-Service SQLSERVERAGENT,MSSQLSERVER|Start-Service
}
catch
{
    Write-Warning "FAILED to start SQL"
}

## Test before presentation
Describe "Testing for Presentation" {
    Context "Surface Book" {
        It "Should have One PowerShell ISE Process" {
            (Get-Process powershell_ise).Count | Should Be 1
        }
        It "Should have PowerPoint Open" {
            (Get-Process POWERPNT).Count | Should Be 1
        }
        It "Should have the correct PowerPoint Presentation Open" {
            (Get-Process POWERPNT).MainWindowTitle| Should Be 'Green is Good Red is Bad - Turning Your Checklists into Pester Tests.pptx - PowerPoint'
        }
        It "Mail Should be closed" {
            (Get-Process HxMail).COunt | Should Be 0
        }
        It "Tweetium should be closed" {
            (Get-Process WWAHost).Count | Should Be 0
        }
        It "Slack should be closed" {
            (Get-Process slack*).Count | Should BE 0
        }
        It "Skype should be closed" {
            (Get-Process skype*).Count | Should BE 0
        }
        It "Prompt should be Presentations" {
            (Get-Location).Path | Should Be 'Presentations:\'
        }
    }
    Context "Surface Book SQL" {
        BeforeAll {
             $srv = New-Object Microsoft.SQLServer.Management.SMO.Server .
        }
        It "DBEngine is running" {
            (Get-Service MSSQLSERVER).Status | Should Be Running
        }
        It "SQL Server Agent is running" {
            (Get-Service SQLSERVERAGENT).Status | Should Be Running
        }
        It "DAVE DBEngine is running" {
            (Get-Service mssql*Dave).Status | Should Be Running
        }
        It "DAVE Agent is running" {
            (Get-Service sqlagent*dave).Status | Should Be Running
        }
        It "Should not have any HTML files in Reports Folder" {
        (Get-ChildItem C:\temp\Reports\*.html).Count | Should Be 0
        }
        It "Should not have any XML files in Reports Folder" {
        (Get-ChildItem C:\temp\Reports\*.xml).Count | Should Be 0
        }
    }
}
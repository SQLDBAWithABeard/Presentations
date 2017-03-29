<#
$i = 0
while ($i -lt 5) {
New-Item "C:\temp\_DONT_CARE_ABOUT_THESE_$i.log" -ItemType File
$i ++
}

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
##>

## Test before presentation
Describe "Testing for Presentation" {
    Context "Rob-XPS" {
        It "Should have One PowerShell ISE Process" {
            (Get-Process powershell_ise -ErrorAction SilentlyContinue).Count | Should Be 1
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
    }
        Context "Rob-XPS SQL" {
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
    }
        Context "THEBEARD_Domain" {
            $NUCServers = '172.16.10.2'
            foreach($VM in $NUCServers)
                {
                It "$VM Should respond to ping" {
				(Test-Connection -ComputerName $VM -Count 1 -Quiet -ErrorAction SilentlyContinue) | Should be $True
				}
                }
    }
        
        }
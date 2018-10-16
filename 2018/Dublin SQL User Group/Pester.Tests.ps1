. .\vars.ps1

$null = Reset-DbcConfig

Describe "Testing for Demo" {
    Context "PowerShell"{
        $modules = 'dbachecks','dbatools','Pester','BurntToast'
        $modules.ForEach{
            It "Module $Psitem should be available" {
                Get-Module $Psitem -ListAvailable | Should -Not -BeNullOrEmpty
            }
        }
    }
    Context "SQL" {
        $SQLInstances.ForEach{
            It "$Psitem should be accepting SQL Connections" {
                (Test-DbaConnection -SqlInstance $PSItem ).ConnectSuccess | Should -BeTrue
            }
        }
        $Containers.ForEach{
            It "$Psitem should be accepting SQL Connections" {
                (Test-DbaConnection -SqlInstance $PSItem -SqlCredential $cred ).ConnectSuccess | Should -BeTrue
            }
        }
    }
}

$null = Set-DbcConfig -Name app.cluster -Value $SQL0
$null = Set-DbcConfig -Name app.sqlinstance -Value $SQLInstances
$null = Set-DbcConfig -Name skip.hadr.listener.pingcheck -Value $true
$null = Set-DbcConfig -Name agent.dbaoperatorname -Value 'The DBA Team'
$null = Set-DbcConfig -Name domain.name -Value 'TheBeard.Local'
$null = Set-DbcConfig -Name agent.failsafeoperator -Value 'The DBA Team'
$null = Set-DbcConfig -Name agent.databasemailprofile 'DBATeam'

Invoke-DbcCheck -Check HADR
Invoke-DbcCheck -Check Agent 

$null = Reset-DbcConfig

. .\vars.ps1

Reset-DbcConfig | Out-Null

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
 
Set-DbcConfig -Name app.cluster -Value $SQL0 | Out-Null
Set-DbcConfig -Name app.sqlinstance -Value $SQLInstances | Out-Null
Set-DbcConfig -Name skip.hadr.listener.pingcheck -Value $true | Out-Null
Set-DbcConfig -Name agent.dbaoperatorname -Value 'The DBA Team' | Out-Null
Set-DbcConfig -Name domain.name -Value 'TheBeard.Local' | Out-Null
Set-DbcConfig -Name agent.failsafeoperator -Value 'The DBA Team' | Out-Null
Set-DbcConfig -Name agent.databasemailprofile 'DBATeam' | Out-Null

Invoke-DbcCheck -Check HADR
Invoke-DbcCheck -Check Agent 

Reset-DbcConfig | Out-Null

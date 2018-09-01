. .\vars.ps1

Reset-DbcConfig

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

Set-DbcConfig -Name app.cluster -Value $SQL0
Set-DbcConfig -Name app.sqlinstance -Value $SQLInstances
Set-DbcConfig -Name skip.hadr.listener.pingcheck -Value $true
Set-DbcConfig -Name agent.dbaoperatorname -Value 'The DBA Team'
Set-DbcConfig -Name domain.name -Value 'TheBeard.Local'

Invoke-DbcCheck -Check HADR
Invoke-DbcCheck -Check Agent 

Reset-DbcConfig

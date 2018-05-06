$SQLInstances = 'sql0', 'sql1'
$containers = 'bearddockerhost,15789', 'bearddockerhost,15788', 'bearddockerhost,15787', 'bearddockerhost,15786', 'beardlinuxsql'
$cred = Import-Clixml $HOME\Documents\sa.cred
Describe "testing for Demo" {
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
    Context "Files and Folders" {
        $Share = '\\jumpbox\SQLBackups'
        It "Should have a SQLBackups folder" {
            Test-Path C:\SQLBackups | Should -BeTrue
        }
        It "Should have a SQL Backups Share" {
            Get-SmbShare -Name SQLBackups -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
        $SQLInstances.ForEach{
            $Share = '\\jumpbox.TheBeard.Local\SQLBackups'
            It "$Psitem Should be able to access the share" {
                Test-DbaSqlPath -SqlInstance $psitem -Path $Share | SHould -BeTrue
            }
        }
        It "should have all the backup files in the share keep folder" {
            (Get-ChildItem $Share\Keep).Count | Should -Be 8
        }
        It "shoudl not have a SQL Export file"{
            Get-ChildItem *sql0-LinkedServer-Export* | Should -BeNullOrEmpty
        }
    }
    Context "Linked servers" {
        $containers.ForEach{
            It "SQL0 should have a linked server for $Psitem" {
                Get-DbaLinkedServer -SqlInstance sql0 -LinkedServer $psitem | Should -Not -BeNullOrEmpty
            }
            It "SQL1 should not have a linked server for $PSitem" {
                Get-DbaLinkedServer -SqlInstance sql1 -LinkedServer $psitem | Should -BeNullOrEmpty
            }
        }
    }
}

Set-DbcConfig -Name app.cluster -Value sql0
Set-DbcConfig -Name skip.hadr.listener.pingcheck -Value $true
Set-DbcConfig -Name agent.dbaoperatorname -Value 'The DBA Team'

Invoke-DbcCheck -Check HADR
Invoke-DbcCheck -Check Agent 
. .\vars.ps1
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
    Context "Files and Folders" {

        It "Should have a SQLBackups folder" {
            Test-Path C:\SQLBackups | Should -BeTrue
        }
        It "Should have a SQL Backups Share" {
            Get-SmbShare -Name SQLBackups -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
        $SQLInstances.ForEach{
            It "$Psitem Should be able to access the share" {
                Test-DbaSqlPath -SqlInstance $psitem -Path $Share | SHould -BeTrue
            }
        }
        It "should have all the backup files in the share keep folder" {
            (Get-ChildItem $Share\Keep).Count | Should -Be 8
        }
        It "should not have a SQL Export file"{
            Get-ChildItem *sql0-LinkedServer-Export* | Should -BeNullOrEmpty
        }
        It "Should have the C:\SQLBackups\SQLBackupsForTesting folder" {
            Test-Path C:\SQLBackups\SQLBackupsForTesting | Should -BeTrue
        }
        it "C:\SQLBackups\SQLBackupsForTesting should be empty" {
            Get-ChildItem C:\SQLBackups\SQLBackupsForTesting | Should -BeNullOrEmpty
        }
        It "There should be a network share $NetworkShare" {
            Test-Path $NetworkShare | Should -BeTrue
        }
        It "Network Share $NetworkShare should be empty"{
            Get-ChildItem $NetworkShare | Should -BeNullOrEmpty
        }
        $SQLInstances.ForEach{
            It "$Psitem Should be able to access the share $NetworkShare" {
                Test-DbaSqlPath -SqlInstance $psitem -Path $NetworkShare| SHould -BeTrue
            }
        }
        It "Should not have the Finland folder on $sql0" {
            Test-Path -Path \\sql0.Thebeard.local\f$\Finland | Should -BeFalse
        }
        It "Have Glenn Berry Diagnostic Query Folder" {
            Test-Path "$Home\Documents\Glenn Berry Diagnostic Queries" | Should -BeTrue
        }
    }
    Context "Linked servers" {
        $containers.ForEach{
            It "$SQL0 should have a linked server for $Psitem" {
                Get-DbaLinkedServer -SqlInstance $SQL0 -LinkedServer $psitem | Should -Not -BeNullOrEmpty
            }
            It "$SQL1 should not have a linked server for $PSitem" {
                Get-DbaLinkedServer -SqlInstance $SQL1 -LinkedServer $psitem | Should -BeNullOrEmpty
            }
        }
    }
    Context "Databases" {
        It "$SQL0 should have the right number of databases" {
            (Get-DbaDatabase -SqlInstance $SQL0 -ExcludeAllSystemDb).Count | Should -Be 9
        }
        It "$SQL1 should have the right number of databases" {
            (Get-DbaDatabase -SqlInstance $SQL1 -ExcludeAllSystemDb).Count | Should -Be 1
        }
        It "Linux SQL should have the databases" {
            (Get-DbaDatabase -SqlInstance $LinuxSQL -SqlCredential $cred -ExcludeAllSystemDb).Count | Should -Be 22
        }
    }
    Context "Agent Jobs"{
        It "Linux SQL should have no ola jobs" {
            (Get-DbaAgentJob -SqlInstance $LinuxSQL -SqlCredential $cred).Count| Should -Be 0
        }
    }
    Context "Stored Procedures" {
        (Get-DbaDbStoredProcedure -SqlInstance $sql0 -Database AdventureWorks2014 -ExcludeSystemSp).Where{$_.Name -eq 'Steal_All_The_Emails'} | Should -Not -BeNullOrEmpty
    }
    Context "Indexes"{
        Find-DbaDisabledIndex -SqlInstance $sql0 | Should -Not -BeNullOrEmpty
    }
    Context "Users" {
        It "$SQL1 should not have TheBeard Login"{
            Get-DbaLogin -SqlInstance $SQL1 -Login TheBeard | Should -BeNullOrEmpty
        }
    }
    Context "Extended Event Sessions"{
        (Get-DbaXESession -SqlInstance $sql0).Count |Should -Be 3
    }
    Context "SP Configure" {
        It "$SQL0 should have Default backup compression set to 1" {
            (Get-DbaSpConfigure -SqlInstance $sql0 -Name DefaultBackupCompression).RunningValue | Should -Be 1
        }
        It "$LinuxSQL should have Default backup compression set to 0" {
            (Get-DbaSpConfigure -SqlInstance $LinuxSQL -SqlCredential $cred -Name DefaultBackupCompression).RunningValue | Should -Be 1
        }
    }
}

Set-DbcConfig -Name app.cluster -Value $SQL0
Set-DbcConfig -Name skip.hadr.listener.pingcheck -Value $true
Set-DbcConfig -Name agent.dbaoperatorname -Value 'The DBA Team'

Invoke-DbcCheck -Check HADR
Invoke-DbcCheck -Check Agent 
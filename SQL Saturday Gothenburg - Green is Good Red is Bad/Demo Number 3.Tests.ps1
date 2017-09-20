# Requires -Version 4
# Requires module dbatools
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
$BackupShare = 'C:\MSSQL\Backup'
$MaxVLFs = 50
$MaxLatency = New-TimeSpan -Seconds 1
$TargetJobOwner = 'sa'
Describe 'Testing Access to Backup Share' -Tag Instance, Backup {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    ## create the test cases array
    $testCases = @()
    $SQLServers.ForEach{$testCases += @{Name = $_}}
    It "<Name> has access to Backup Share $BackupShare" -TestCases $testCases {
        Param($Name)
        Test-DbaSqlPath -SqlServer $Name -Path $BackupShare | Should Be $True
    }
}

Describe "Testing Database Collation" -Tag Instance, Collation {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*SQL2016N*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $testCases = @()
    $SQLServers.ForEach{$testCases += @{Name = $_}}
    It "<Name> databases have the right collation" -TestCases $testCases {
        Param($Name)
        $Collation = Test-DbaDatabaseCollation -SqlServer $Name
        $Collation.IsEqual -contains $false | Should Be $false
    }

}

## Sometimes Test Cases dont work - Cant create a loop of test cases
Describe "Testing Last Known Good DBCC" -Tag Database, DBCC {

    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*SQL2016N*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    foreach ($Server in $SQLServers) {
        Context "Testing $Server" {
            $DBCCTests = Get-DbaLastGoodCheckDb -SqlServer $Server -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            foreach ($DBCCTest in $DBCCTests.Where{$_.Database -ne 'tempdb'}) {
                It "$($DBCCTest.Server) database $($DBCCTest.Database) had a successful CheckDB" {
                    $DBCCTest.Status | Should Be 'Ok'
                }
                It "$($DBCCTest.Server) database $($DBCCTest.Database) had a CheckDB run in the last 14 days" {
                    $DBCCTest.DaysSinceLastGoodCheckdb | Should BeLessThan 14
                    $DBCCTest.DaysSinceLastGoodCheckdb | Should Not BeNullOrEmpty
                }   
                It "$($DBCCTest.Server) database $($DBCCTest.Database) has Data Purity Enabled" {
                    $DBCCTest.DataPurityEnabled| Should Be $true
                }    
            }
        }
    }
}

## Test for Virtual Log Files

Describe 'Testing Virtual Log FIles' -Tag Database, VLF {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "Testing $_" {
            $Results = Test-DbaVirtualLogFile -SqlInstance $_ 
            $Results.ForEach{
                It "$($_.Database) Should have less than $MaxVLFs VLFs" {
                    $_.Count | Should BeLessThan $MaxVLFs
                }
            }
        }
    }

}

Describe 'Testing TempDB Configuration' -Tag TempDB, Instance {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "Testing $_" {
            It " Should pass the default TempDB Configuration" {
                (Test-DbaTempDbConfiguration -SqlInstance $_).IsBestPractice | Should Be $true
            }
        }
    }
}

Describe 'Testing SQL ServerName - HostName Configuration' -Tag ServerName, Instance {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "Testing $_" {
            It "SQL ServerName and Host name should match" {
                (Test-DbaServerName -SqlInstance $_).IsEqual | Should be $true
            }
        }
    }
}
Describe 'Testing Server PowerPlan Configuration' -Tag PowerPlan, Server {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "Testing $_" {
            $ServerName = $_.Split('\')[0]
            It "Server PowerPlan should be High Performance" {
                (Test-DbaPowerPlan -SqlServer $ServerName).IsBestPractice | Should be $true
            }
        }
    }
}
Describe 'Testing Optimise for AdHoc Workloads setting' -Tag AdHoc, Instance {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "Testing $_" {
            It "Should be Optimised for AdHocworkloads" {
                $Results = Test-DbaOptimizeForAdHoc -SqlInstance $_
                $Results.CurrentOptimizeAdHoc | Should be $Results.RecommendedOptimizeAdHoc
            }
        }
    }
}
Describe 'Testing Network Latency' -Tag Network, Latency, Instance {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "Testing $_" {
            It "Should Have a Latency less than $MaxLatency" {
                [timespan](Test-DbaNetworkLatency -SqlInstance $_).Average | Should BeLessThan $MaxLatency
            }
        }
    }
}
Describe 'Testing Max Memory' -Tag Memory, Instance {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "Testing $_" {
            It "Max Memry setting should be correct" {
                $Results = Test-DbaMaxMemory -SqlInstance $_
                $Results.SqlMaxMB | Should BeLessThan $Results.RecommendedMB
            }
        }
    }
}
Describe 'Testing Linked Servers' -Tag LinkedServer, Instance {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "Testing Linked Servers on  $_" {
            $Results = Test-DbaLinkedServerConnection -SqlInstance $_ 
            $Results.ForEach{
                It "Linked Server $($_.LinkedServerName) Should Be Connectable" {
                    $_.Connectivity | SHould be $True
                }
            }
        }
    }
}

Describe 'Testing Job Owners' -Tag JobOwner, Agent {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "Testing Job Owners on  $_" {
            $Results = Test-DbaJobOwner -SqlInstance $_ -Login $TargetJobOwner -Detailed
            # because 1 job does not have a foreach method!!
            if ($Results.Count -gt 1) {
                $Results.ForEach{
                    It "Job Owner for $($_.Job) Should be $TargetJobOwner" {
                        $_.CurrentOwner | Should Be $TargetJobOwner
                    }
                }
            }
            else{
                It "Job Owner for $($Results.Job) Should be $TargetJobOwner" {
                    $Results.CurrentOwner | Should Be $TargetJobOwner
                }
            }
        }
    }
}

Describe 'Testing FullRecovery Model' -Tag Backup, Database {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "Testing Full Recovery Model on  $_" {
            $Results = Test-DbaFullRecoveryModel -SqlInstance $_ 
            $Results.ForEach{
                It "$($_.Database) Should have had a Full backup if in Full Recovery Model" {
                    $_.ConfiguredRecoveryModel | Should Be $_.ActualRecoveryModel
                }
            }
        }
    }
}
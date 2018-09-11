# Requires -Version 4
# Requires module dbatools
$SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
$BackupShare = 'C:\MSSQL\Backup'
$MaxVLFs = 50
$MaxLatency = New-TimeSpan -Seconds 1
$MinDiskPercent = 10
$TargetJobOwner = 'sa'
$TargetDatabaseOwner = 'sa'

Describe 'Testing Access to Backup Share' -Tag Instance, Backup {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    ## create the test cases array
    $testCases = @()
    $SQLServers.ForEach{$testCases += @{Name = $_}}
    It "<Name> has access to Backup Share $BackupShare" -TestCases $testCases {
        Param($Name)
        Test-DbaPath -SqlServer $Name -Path $BackupShare | Should Be $True
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
        $Collation = Test-DbaDbCollation -SqlServer $Name
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
            $Results = Test-DbaDbVirtualLogFile -SqlInstance $_ 
            if ($Results.COunt -gt 1) {
                $Results.ForEach{
                    It "$($_.Database) Should have less than $MaxVLFs VLFs" {
                        $_.Count | Should BeLessThan $MaxVLFs
                    }
                }
            }
            else {
                $Results.Count | Should BeLessThan $MaxVLFs
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
                (Test-DbaTempdbConfig -SqlInstance $_).IsBestPractice | Should Be $true
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
                $Results.SqlMaxMB | Should BeLessThan ($Results.RecommendedMB + 379)
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
                    It "Job Owner for $($_.Job) Should Not be $TargetJobOwner" {
                        $_.CurrentOwner | Should Not Be $TargetJobOwner
                    }
                }
            }
            else {
                It "Job Owner for $($Results.Job) Should Not be $TargetJobOwner" {
                    $Results.CurrentOwner | Should Not Be $TargetJobOwner
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
            $Results = Test-DbaRecoveryModel -SqlInstance $_ -Detailed
            $Results.ForEach{
                It "$($_.Database) Should have had a Full backup if in Full Recovery Model" {
                    $_.ConfiguredRecoveryModel | Should Be $_.ActualRecoveryModel
                }
            }
        }
    }
}

Describe 'Testing Database Owner' -Tag Owner, Database {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "Testing Database Owners on  $_" {
            $Results = Test-DbaDbOwner -SqlInstance $_ -TargetLogin $TargetDatabaseOwner
            if ($Results.COunt -gt 1) {
                $Results.ForEach{
                    It "$($_.Database) Owner should Not be $TargetDatabaseOwner" {
                        $_.CurrentOwner | Should Not Be $_.TargetOwner
                    }
                }
            }
            else {
                It "$($Results.Database) Owner should Not be $TargetDatabaseOwner" {
                    $Results.CurrentOwner | Should Not Be $TargetDatabaseOwner
                }
            }
        }
    }
}

Describe 'Testing Database Compatability' -Tag Compatability {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "Testing Database Compatability on  $_" {
            $Results = Test-DbaDbCompatibility -SqlInstance $_ -Detailed
            
            if ($Results.COunt -gt 1) {
                $Results.ForEach{
                    It "$($_.Database) compatability should be the same as the server compatability" {
                        $_.DatabaseCompatibility | Should Be $_.ServerLevel
                    }
                }
            }
            else {
                It "$($_.Database) compatability should be the same as the server compatability" {
                    $_.DatabaseCompatibility | Should Be $_.ServerLevel
                }
            }
        }
    }
}
Describe 'Testing DiskSpace' -Tag DiskSpace, Server {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "Testing DiskSpace on  $_" {
            $Results = Get-DbaDiskSpace -SqlInstance $_ 
            if ($Results.COunt -gt 1) {
                $Results.ForEach{
                    It "Drive $($_.Name) - Label $($_.Label) Should have more than $MinDiskPercent % free" {
                        $_.PercentFree | SHould BeGreaterThan $MinDiskPercent
                    }
                }
            }
            else {
                It "Drive $($Results.Name) - Label $($Results.Label) Should have more than $MinDiskPercent % free" {
                    $Results.PercentFree | SHould BeGreaterThan $MinDiskPercent
                }
            }
        }
    }
}

Describe "Testing Instance Connectionn" -Tag Instance, Connection {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*SQL2016N*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "$_ Connection Tests" {
            BeforeAll {
                $Connection = Test-DbaConnection -SqlInstance $_ 
            }
            It "$_ Connects successfully" {
                $Connection.connectsuccess | Should BE $true
            }
            It "$_ AUth Scheme should be NTLM" {
                $connection.AuthScheme | SHould Be "NTLM"
            }
            It "$_ Is pingable" {
                $Connection.IsPingable | Should be $True
            }
            It "$_ Is PSRemotebale" {
                $Connection.PSRemotingAccessible | Should Be $True
            }
        }
    }

}

Describe "Testing Extended Event Sessions" -Tag  XEvents {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*SQL2016N*" -and $_.State -eq 'Running'}).Name
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    $SQLServers.ForEach{
        Context "$_ Extended Events Tests" {
            BeforeAll {
                $Xevents = Get-DbaXESession -SqlInstance $_ 
            }
            It "$_  Should have a Extended Event Session called system_health" {
                $Xevents.Name -contains 'system_health' | Should Be True
            }
            It "$_  System Health XEvent should be Running" {
                $Xevents.Where{$_.Name -eq 'system_health'}.Status | Should be 'Running'
            }
            It "$_  System Health XEvent Auto Start Should Be True" {
                $Xevents.Where{$_.Name -eq 'system_health'}.AutoStart | Should be $true
            }
            It "$_  Should have a Extended Event Session called AlwaysOn_health" {
                $Xevents.Name -contains 'AlwaysOn_health' | Should Be True
            }
            It "$_  Always On Health XEvent should Not be Running" {
                $Xevents.Where{$_.Name -eq 'AlwaysOn_health'}.Status | Should Not be 'Running'
            }
            It "$_  Always On Health XEvent Auto Start Should Be False" {
                $Xevents.Where{$_.Name -eq 'AlwaysOn_health'}.AutoStart | Should be $false
            }
            It "$_  Should have a Extended Event Session called telemetry_xevents" {
                $Xevents.Name -contains 'telemetry_xevents' | Should Be True
            }
            It "$_  Telemetry Events XEvent should be Running" {
                $Xevents.Where{$_.Name -eq 'telemetry_xevents'}.Status | Should be 'Running'
            }
            It "$_  Telemetry Events XEvent Auto Start Should Be True" {
                $Xevents.Where{$_.Name -eq 'telemetry_xevents'}.AutoStart | Should be $true
            }
        }
    }
}









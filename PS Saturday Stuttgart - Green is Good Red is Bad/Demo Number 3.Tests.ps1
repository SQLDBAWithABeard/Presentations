# Requires -Version 4
# Requires module dbatools

Describe 'Testing Access to Backup Share' -Tag Server, Backup {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
    $SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
    if (!$SQLServers) {Write-Warning "No Servers to Look at - Check the config.json"}
    ## create the test cases array
    $testCases = @()
    $SQLServers.ForEach{$testCases += @{Name = $_}}
    It "<Name> has access to Backup Share C:\MSSQL\Backup" -TestCases $testCases {
        Param($Name)
        Test-DbaSqlPath -SqlServer $Name -Path C:\MSSQL\Backup | Should Be $True
    }
}

Describe "Testing Database Collation" -Tag Server, Collation {
    ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
    ## $SQLServers = (Get-VM -ComputerName beardnuc -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*SQL2016N*" -and $_.State -eq 'Running'}).Name
    $SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
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
    $SQLServers = 'ROB-XPS', 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'
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
# Requires -Version 4
# Requires module dbatools

Describe 'Testing Access to Backup Share' -Tag Server, Backup {
## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
$SQLServers = (Get-VM -ComputerName beardnuc| Where-Object {$_.Name -like "*SQL2016*" -and $_.State -eq 'Running'}).Name
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
## create the test cases array
$testCases= @()
$SQLServers.ForEach{$testCases += @{Name = $_}}
    It "<Name> has access to Backup Share Z:" -TestCases $testCases {
        Param($Name)
        Test-SqlPath -SqlServer $Name -Path Z: | Should Be $True
    }
}

Describe "Testing Database Collation" -Tag Server,Collation{
## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
$SQLServers = (Get-VM -ComputerName beardnuc -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*SQL2016N*" -and $_.State -eq 'Running'}).Name
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
$testCases= @()
    $SQLServers.ForEach{$testCases += @{Name = $_}}
    It "<Name> databases have the right collation" -TestCases $testCases {
        Param($Name)
        $Collation = Test-DbaDatabaseCollation -SqlServer $Name
        $Collation.IsEqual -contains $false | Should Be $false
    }

}

## Sometimes Test Cases dont work - Cant create a loop of test cases
Describe "Testing Last Known Good DBCC" -Tag Database, DBCC{

 ## This is getting a list of server name from Hyper-V - You can chagne this to a list of SQL instances
$SQLServers = (Get-VM -ComputerName beardnuc -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*SQL2016N*" -and $_.State -eq 'Running'}).Name
if(!$SQLServers){Write-Warning "No Servers to Look at - Check the config.json"}
   foreach($Server in $SQLServers)
    {
        $DBCCTests = Get-DbaLastGoodCheckDb -SqlServer $Server -Detailed -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        foreach($DBCCTest in $DBCCTests)
        {
            It "$($DBCCTest.Server) database $($DBCCTest.Database) had a successful CheckDB"{
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
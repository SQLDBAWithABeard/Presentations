# Requires -Version 4
# Requires module dbatools
$SQLServers = 'ROB-XPS' ,'ROB-XPS\SQL2016','ROB-XPS\DAVE'

Describe 'Testing Access to Backup Share' -Tag Server, Backup {
if(!$SQLServers){Write-Warning "No Servers to Look at"}
## create the test cases array
$testCases= @()
$SQLServers.ForEach{$testCases += @{Name = $_}}
    It "<Name> has access to Backup Share" -TestCases $testCases {
        Param($Name)
        Test-SqlPath -SqlServer $Name -Path C:\MSSQL\BACKUP | Should Be $True
    }
}

Describe "Testing Database Collation" -Tag Server,Collation{
if(!$SQLServers){Write-Warning "No Servers to Look at"}
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

if(!$SQLServers){Write-Warning "No Servers to Look at"}
   foreach($Server in $SQLServers)
    {
        $DBCCTests = Get-DbaLastGoodCheckDb -SqlServer $Server -Exclude tempdb -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        foreach($DBCCTest in $DBCCTests)
        {
            It "$($DBCCTest.SQLInstance) database $($DBCCTest.Database) had a successful CheckDB"{
            $DBCCTest.Status | Should Be 'Ok'
            }
            It "$($DBCCTest.SQLInstance) database $($DBCCTest.Database) had a CheckDB run in the last 14 days" {
            $DBCCTest.DaysSinceLastGoodCheckdb | Should BeLessThan 14
            $DBCCTest.DaysSinceLastGoodCheckdb | Should Not BeNullOrEmpty
            }   
            It "$($DBCCTest.SQLInstance) database $($DBCCTest.Database) has Data Purity Enabled" {
            $DBCCTest.DataPurityEnabled| Should Be $true
            }    
        }
    }
}
## Test Cases and Tags

cd 'Presentations:\SQL Grillen'

## You can ask Pester to run all of the *.Tests.ps1 files in a folder
## With Invoke-Pester

## You can Tag your tests to only run certain tests
## Look in the Demo Number 3 Tests.ps1

cls 
Invoke-Pester -Tag Backup

cls
Invoke-Pester -tag Collation

cls
Invoke-Pester -Tag DBCC

cls
Invoke-Pester -Tag Server

cls
Invoke-Pester

## You can filter the information that you return to the screen - look at the timings
cls
Invoke-Pester -Show Fails

Invoke-Pester -Show Summary

## You can return an object - We LOVE objects
## You need the PassThru Parameter

$Tests = Invoke-Pester -Show Summary -PassThru

$Tests

$Tests | Get-Member

$results.TestResult |Select-Object -First 5

$results.TestResult.Where{$_.Passed -eq $true}.COunt

$results.TestResult.Where{$_.Passed -ne $true}.COunt

$Tests.TestResult |Select-Object Name, Passed, FailureMessage |  ft -AutoSize -Wrap

## I can take the results object and convert it JSON (This is for the Powerbi :-) )
$results.TestResult | ConvertTo-Json -Depth 10 | Out-File C:\temp\totalTestResults.json 
## Min and max memory settings

## Understand how to get the information with PowerShell
# (Get-DbaMaxMemory -SqlInstance ROB-XPS).SQLMaxMb
# (Get-DbaSpConfigure -SqlInstance ROB-XPS).Where{$_.ConfigName -eq 'MinServerMemory'}.RunningValue

## Test - Getting some information with PowerShell

## Write a PEster Test
# Install-Module pester -SkipPublisherCheck

$SQLInstances = 'Rob-XPS', 'Rob-XPS\DAVE', 'ROB-XPS\SQL2016', 'ROB-XPS\BOLTON'

$SQLInstances.ForEach{

    Describe "This is a series of tests for the SQL Server $($_)" {
        Context "Configuration - This is a scope for grouping our tests" {
            It "Max Memory Should Be  24Gb" {
                (Get-DbaMaxMemory -SqlInstance $_).SQLMaxMb | Should Be 24576
            }
            It "Minimum Memory SHould Be Less than 1Gb" {
                (Get-DbaSpConfigure -SqlInstance $_).Where{$_.ConfigName -eq 'MinServerMemory'}.RunningValue | Should BeLessThan 1024
            }
            It "Minimum Memory SHould Be Less than 1Gb AND Max Memory Should Be lesthan 24Gb" {
                (Get-DbaSpConfigure -SqlInstance $_).Where{$_.ConfigName -eq 'MinServerMemory'}.RunningValue | Should BeLessThan 1024
                (Get-DbaMaxMemory -SqlInstance $_).SQLMaxMb | Should Belessthan 24576
            }
        }

    }

}
# SMILE
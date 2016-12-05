Get-Service MSSQLSERVER,SQLSERVERAGENT | Start-Service 

## OK Over to YOU :-)

## Lets turn a checklist into a Pester Test

Describe "This is our Pester Test" {
    Context "The First things We will check" {
        It "Here is our first test" {
            $value | Should Be $value
            }
        }#End Context
    } # End Describe

<#

This is how I generated the word cloud

$srv|Get-Member -MemberType Property |Select-Object name                                                                                           
$srv|Get-Member -MemberType Property |Select-Object name                                                                                     
$srv.JobServer | Get-Member -MemberType Property |Select-Object name                                                                         
$srv.Databases | Get-Member -MemberType Property |Select-Object name                                                                         
$srv.Configuration | Get-Member -MemberType Property |Select-Object name 

#>
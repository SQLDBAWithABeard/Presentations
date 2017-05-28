## Use a configuration file

Get-Content GIT:\dbatools-scripts-local\TestConfig.json
code-insiders C:\Users\mrrob\OneDrive\Documents\GitHub\dbatools-scripts-local\dbatools-scripts-local\TestConfig.json
cls 
## Get SOme SQL Server Names

## We can get them from Hyper-V
## $SQLServers = (Get-VM -ComputerName $Config.CollationDatabase.HyperV -ErrorAction SilentlyContinue| Where-Object {$_.Name -like "*SQL*" -and $_.State -eq 'Running'}).Name
## From Registered Servers with dbatools
## $SQLServers = Get-SqlRegisteredServerName -SqlServer sqlserver2014a -Group HR, Accounting

## From CMS using SQLProvider
## cd 'SQLSERVER:\sqlregistration\Central Management Server Group\SERVER'
## $2016servers = (Get-ChildItem).Where{$_.Name -like '*2016*'}.Name

## Or from a list
$Global:SQLInstances = 'ROB-XPS' , 'ROB-XPS\DAVE', 'ROB-XPS\SQL2016'

## Now we read in the json config file into a variable
$Config = (Get-Content GIT:\dbatools-scripts-local\TestConfig.json) -join "`n" | ConvertFrom-Json

## and then we can run all of the tests in the folder with our config
invoke-Pester  Git:\dbatools-scripts-local 
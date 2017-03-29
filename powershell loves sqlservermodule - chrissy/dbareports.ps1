##
cd Git:\dbareports
##
Remove-Module dbareports
import-module .\dbareports 
##
cd Presentations:\
Get-Command -Module dbareports
## Lets Install the DBAReports solution
Install-DbaReports -SqlServer SQL2016N1 -Database Viennadbareports -InstallPath C:\temp\dbareports -verbose
## and add some servers
$Servers = 'SQL2005Ser2003','SQL2014Ser12R2','SQL2016N1','SQL2016N2'
Add-DbrServerToInventory -SqlInstance $Servers -Environment Production -Location InsideTheNUC 
## THese are the jobs created
Get-SqlAgentJob -ServerInstance SQL2016N1|Select Name,Category,IsEnabled,CurrentRunstatus,DateCreated|Format-Table -AutoSize
#lets start the jobs
(Get-SqlAgentJob -ServerInstance SQL2016N1 -Name 'dbareports - Agent Job Results').Start()
(Get-SqlAgentJob -ServerInstance SQL2016N1 -Name 'dbareports - Database Information').Start() 
(Get-SqlAgentJob -ServerInstance SQL2016N1 -Name 'dbareports - Disk Usage').Start() 
(Get-SqlAgentJob -ServerInstance SQL2016N1).Where{$_.Name -like 'dbareports *'}|Select Name,CurrentRunstatus,LastRunOutCome|Format-Table -AutoSize
## Lets have a look at the jobs whilst they run
Get-DbrAgentJob
## Lets have a look at the configuration
Get-DbrConfig
## Lets have a look at our instances
Get-DbrInstanceList|ft -AutoSize -Wrap
## Lets have a look at the information for a server and put it in a file
Get-DbrAllInfo -SQLInstance SQL2014Ser12R2 -Filepath c:\temp\
Get-ChildItem c:\temp\*sql2014* | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Invoke-Item
## We can also run some Pester Validation tests
Invoke-Pester 'GIT:\dbareports demo Estate Checks.ps1'

## Open the report server

Start-Process 'http://sql2016n1/reports'


## Lets see how it is done
psedit Git:\dbareports\functions\Install-DbaReports.ps1
psedit Git:\dbareports\functions\Add-DbrServerToInventory.ps1
psedit Git:\dbareports\functions\SharedFunctions.ps1

## The first thing to do is to install the latest SSMS release
Start-Process microsoft-edge:'https://www.google.co.uk/search?q=download+ssms+2016'
## You need to downlaod and install AND reboot
##
## then you can import the module
Import-Module sqlserver
## Lets look at the commands
Get-Command -Module sqlserver
## you can still import sqlps
Import-Module SQLPS
## ───────────────██████████░──────────────
## ─────────────███▒──────≈███░────────────
## ───────────▓██────────────▓██───────────
## ──────────██▒────≈─≈─≈──────██──────────
## ─────────██───────≈─────≈────██─────────
## ────────██────────────────≈≈──██────────
## ───────██─────────────────≈─≈──██───────
## ──────░█≈──────────────────░≈░──██──────
## ──────██────────────────────≈░░─▒█──────
## ─────██─────────────────────≈░░░─██─────
## ─────█▒─────────────────────≈≈░░≈─█▓────
## ────██───────────────────────≈░░░─██────
## ────█▒──≈────────────────────≈░░▒░─█▒───
## ───██──░─────────────────────░░▒▒░─██───
## ───██─≈≈─────────────────────≈░░▒▒≈▒█───
## ───█──≈≈─────────────────────≈░▒▒▒░─██──
## ──██────────────────────────≈≈░░▒░░─██──
## ──██─────────────────────────≈≈░─≈▓≈▒█──
## ──█▒──██────────────────────────▓██▒─█▒─
## ──█───████────────▒▒──█────────████▓─██─
## ─▓█───█─▒██≈──────█▒──█──────▓██──█▓─██─
## ─██───█───███▒────█───█▓──░████───█▒─██─
## ─██───▓▒──█████▓──█───▓▓░██████───█░─▓█─
## ─██────█───█▒─▓████────███░─▓█───██░─▒█─
## ─██────█▓───────▓█▒────██───────≈█▒░░▒█─
## ─█▓─────█▒──────██──────█──────░█▓▒▒░▒█─
## ─█▓─≈────██───≈██───────▒██░──██▓░▒▒░▒█─
## ─█▓───────██████─────────▒█████░≈▒▒▒░▒█─
## ─█▓─────────▒≈──────────≈──────░▒▒▒▒░▒█─
## ─██─────▒█─────────────≈≈░░░─░▒▒▒▒▒▒░▒█─
## ─██─────█████▓▒░────────≈≈░░▒▒▒▒▒▒▒▒░▒█─
## ─██────██──░▓███████▓▒───────≈░▒▒▒▒▒─▓█─
## ─██────██─▒░──────░▓██████▓▓▓▓▓░▒▒▒▒─██─
## ─▒█────██─▒▒░───────────▒▓██████░▒▒▒─██─
## ──█░───█▓≈▒▒▒──────────────────█▒▒▒▒─█▓─
## ──█▓───██─▒▒░≈─────────────░░░─█▒▒▒░░█──
## ──██───█▓≈▒▒▒≈────────────≈░▒▒░█▒▒▒─▓█──
## ──▓█───█▓▒▒▒░≈────────────▒▒░░░█░▒▒─██──
## ───█▒──█▓░▒▒░≈────────────▒▒▒▒▓█▒▒▒─█▒──
## ───██──█▓░▒▒░≈────────────≈░░─▓█▒▒─▓█───
## ───▒█──█▓─▒▒░─────────────────█▓▒░─██───
## ────█▓─██──≈──────────────▓▓███▒▒≈░█────
## ────▓█──███▒░─────────▒███████▒▒▒─██────
## ─────█▓──▓█████████████▓▒▒░░░▒▒▒≈░█─────
## ─────▒█──────░░▒▒▒░░░──░▒▒▒▒▒▒▒░─██─────
## ──────██─≈░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒░─▓█──────
## ───────█▓─░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒≈░█▓──────
## ───────≈█▒─░░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒≈─██───────
## ────────▓█▒─░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒≈─██≈≈≈─────
## ─────────██▒─░░▒▒▒▒▒▒▒▒▒▒▒░──██▓▒▒▒░────
## ──────────███──░▒▒▒▒▒▒▒▒▒──▒█████▓▓▒────
## ─────────▒░▓██▒──≈≈░░░≈──≈████████▓▓░───
## ─────────▒▓▓████▓▒────░▓██████████▓▓▒───
## ────────≈▒▓███████████████████████▓▓▒───
## ────────≈▒▓███████████████████████▓▓▒───
## ─────────▒▓██████████████████████▓▓▓▒───
## ─────────▒▓▓████████████████████▓▓▓▒░───
## ─────────≈▒▓▓█████████████████▓▓▓▒▒░────
## ──────────░▒▓▓▓████████████▓▓▓▓▒▒░≈─────
## ───────────░▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒░────────
## ──────────────░░▒░▒▒▒▒▒▒▒░░░≈───────────
##
cls
## there is a way but they wont run side by side
Remove-Module sqlserver
Import-Module sqlps
Get-Command -Module SQLPS -CommandType Cmdlet
## But the SQLPS module wont be updated so lets use the new one
Remove-Module SQLPS
Import-Module sqlserver
#lets start with the agent ones
get-help Get-SqlAgent -ShowWindow
Get-SQLAgent -ServerInstance .
## this is returning an object (we like objects) for a SQL Agent
##
## I always recommend that you do something like this to investigate new things
$a = Get-SqlAgent -ServerInstance .
$a |Get-Member
$A|select *
## You can do this for multiple servers
$A | Get-SqlAgentJob
## Now you can start doing things
(Get-SqlAgentJob -ServerInstance . ).Count
(Get-SqlAgentJob -ServerInstance . ).where{$_.LastRunOutcome -eq 'Succeeded'}.Count
(Get-SqlAgentJob -ServerInstance . ).where{$_.LastRunOutcome -eq 'Failed'}.Count
## You can also start and stop jobs
(Get-SqlAgentJob -ServerInstance . -Name 'DatabaseBackup - SYSTEM_DATABASES - FULL').Start()
Get-SqlAgentJob -ServerInstance . -Name 'DatabaseBackup - SYSTEM_DATABASES - FULL'
## There is also the history
Get-help get-SQLAgentJobHistory -showwindow
## Lets look at one job
Get-SqlAgentJobHistory -ServerInstance . -JobName 'DatabaseBackup - SYSTEM_DATABASES - FULL'
## OK that is the hostory for the amount of time since I purged the job history
## Theres a since Parameter
##  -Since <SinceType>
##  
##  A convenient abbreviation to avoid using the -StartRunDate parameter.
##   It can be specified with the -EndRunDate parameter.
##  
##  Do not specify a -StartRunDate parameter, if you want to use it.
##  
##  Accepted values are:
##   – Midnight (gets all the job history information generated after midnight)
##   – Yesterday (gets all the job history information generated in the last 24 hours)
##   – LastWeek (gets all the job history information generated in the last week)
##   – LastMonth (gets all the job history information generated in the last month)
##  
## Lets try since yesterday and output to gridview
Get-SqlAgentJobHistory -ServerInstance . -JobName 'DatabaseBackup - SYSTEM_DATABASES - FULL' -Since Yesterday |select RunDate,StepID,Server,JobName,StepName,Message|Out-GridView
## Pretty much what you would see in Agent Job History
## We can look at individual job steps
Get-Help Get-SqlAgentJobStep -ShowWindow
## I dont follow the examples completely
Get-SqlAgentJob -ServerInstance . -Name 'DatabaseBackup - SYSTEM_DATABASES - FULL' |Get-SqlAgentJobStep -Name 'DatabaseBackup - SYSTEM_DATABASES - FULL'|select *
## Or the schedule
Get-SqlAgentJob -ServerInstance . -Name 'DatabaseBackup - SYSTEM_DATABASES - FULL' |Get-SqlAgentJobSchedule|select *
## And the error log
##
## Again we have the since parameter
## You can move to the SQLServer PSDrive with cd SQLSERVER:\SQL\localhost\DEFAULT
## but also a timespan
$srv = New-Object Microsoft.SQLServer.Management.SMO.Server .
$srv | Get-SqlErrorLog -Timespan '00:30:00' |Format-Table -AutoSize -Wrap
## Lets look at the dbatools module
Start-Process microsoft-edge:'https://dbatools.io/sep2016/'
## So lots of new useful best practice commands
## It started as an amazing migration module
## You can migrate anything from an entire instance to a single login
## Lets Watch Chrissy migrate an instance
Start-Process microsoft-edge:'https://dbatools.io/videos'
## Remove-SQLDatabaseSafely is one of my commands
Start-Process microsoft-edge:'https://www.youtube.com/watch?v=2vusWhe-e1E'
## Some of the new commands
## Get the Restore History
Get-DbaRestoreHistory -SqlServer . -Detailed
## Get the TCP port
Get-DbaTcpPort -SqlServer .
## Detailed
Get-DbaTcpPort -SqlServer . -Detailed
## Compatability Levels
Test-DbaDatabaseCompatibility -SqlServer . -Detailed|ft -AutoSize
## Collation
Test-DbaDatabaseCollation -SqlServer . -Detailed | ft -AutoSize
## Which authorisation are we using?
Test-DbaConnectionAuthScheme -SqlServer . -Detailed
## Max memory
Get-SqlMaxMemory -SqlServer . 
## Get SP_WhoIsActive Results
(Get-SqlAgentJob -ServerInstance . ).where{$_.Name -like '*DatabaseIntegrityCheck*'}.start()
Show-SqlWhoIsActive -SqlServer . -Database DBA-Admin
## Need Database FreeSpace
Get-DbaDatabaseFreespace -SqlServer . 
## What databases are on my server?
Show-SqlDatabaseList -SqlServer .
## Is my TempDB set up using "best practices"
Test-SqlTempDbConfiguration -SqlServer .
## Database owners ok?
Test-DbaDatabaseOwner -SqlServer . -TargetLogin ROB-SURFACEBOOK\mrrob -Detailed | ft -AutoSize
## Agent Job Owners
Test-DbaJobOwner -SqlServer . -Detailed -TargetLogin sa |ft -AutoSize
## Power Plan ok?
Test-dbaPowerPlan -ComputerName . -Detailed
## There are so many commands and options start here
Start-Process microsoft-edge:'https://dbatools.io/functions/'
## Lets install dba reports
##
cd Git:\dbareports
##
import-module .\dbareports 
##
cd Presentations:\
Get-Command -Module dbareports
## Lets Install the DBAReports solution
Install-DbaReports -SqlServer SQL2016N1 -Database CardiffDemodbareports -InstallPath C:\temp\dbareports -JObSuffix 'Cardiff'
## and add some servers
$Servers = 'SQL2005Ser2003','SQL2008Ser2008','SQL2012Ser08AG3','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2','SQL2016N1','SQL2016N2'
Add-DbrServerToInventory -SqlInstance $Servers -Environment Production -Location InsideTheNUC 
## THese are the jobs created
Get-SqlAgentJob -ServerInstance SQL2016N1|Select Name,Category,IsEnabled,CurrentRunstatus,DateCreated|Format-Table -AutoSize
#lets start the jobs
(Get-SqlAgentJob -ServerInstance SQL2016N1 -Name 'dbareports - Agent Job Results*Cardiff*').Start()
(Get-SqlAgentJob -ServerInstance SQL2016N1 -Name 'dbareports - Database Information*Cardiff*').Start() 
(Get-SqlAgentJob -ServerInstance SQL2016N1 -Name 'dbareports - Disk Usage*Cardiff*').Start() 
(Get-SqlAgentJob -ServerInstance SQL2016N1).Where{$_.Name -like 'dbareports *'}|Select Name,CurrentRunstatus,LastRunOutCome|Format-Table -AutoSize
## Lets have a look at the jobs whilst they run
Get-DbrAgentJob
## Lets have a look at the configuration
Get-DbrConfig
## Lets have a look at our instances
Get-DbrInstanceList|ft -AutoSize -Wrap
## Lets have a look at the information for a server
Get-DbrAllInfo -SQLInstance SQL2014Ser12R2 -Filepath c:\temp\
## We can also run some Pester Validation tests
Invoke-Pester 'C:\Users\mrrob\OneDrive\Documents\GitHub\dbareports demo Estate Checks.ps1'
## Lets look at the SSRS Reports
ii 'C:\Users\mrrob\Desktop\Installing SSRS Reports for dbareports.webm'
## and the best bit the Cortana Integration
ii 'C:\Users\mrrob\Desktop\PowerBi Reports and Cortana for dbareports.mkv'














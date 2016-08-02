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
## So what new cmdlets are there?
Start-Process microsoft-edge:'https://blogs.technet.microsoft.com/dataplatforminsider/2016/06/30/sql-powershell-july-2016-update/'
#lets start with the agent ones
get-help Get-SqlAgent -ShowWindow
Get-SQLAgent -ServerInstance .
## this is returning an object (we like objects) for a SQL Agent
##
## I always recommend that you do something like this to investigate new things
$a = Get-SqlAgent -ServerInstance .
$a |Get-Member
$A|select *
## You can do this for muliple servers
$Servers = 'ROB-SURFACEBOOK','ROB-SURFACEBOOK\DAVE'
$B = Get-SqlAgent -ServerInstance $Servers
$B | Select Name,ServiceAccount,ServiceStartMode
## You can also pass these into other commands using pipe
$B | Get-SqlAgentJob
## Now you can start doing things
(Get-SqlAgentJob -ServerInstance . ).Count
(Get-SqlAgentJob -ServerInstance .|Where-Object {$_.LastRunOutcome -eq 'Succeeded'}).Count
(Get-SqlAgentJob -ServerInstance . |Where-Object {$_.LastRunOutcome -eq 'Failed'}).Count
(Get-SqlAgentJob -ServerInstance . |Where-Object{$_.IsEnabled -eq $false}).Count
(Get-SqlAgentJob -ServerInstance . |Where-Object{$_.LastRunOutcome -eq 'Unknown'}).Count
## Thats old Powershell version code ).Where{} is better
## Lets also add the counts to an object
[pscustomobject]$Jobs= @{}
$Jobs.JobCount =     (Get-SqlAgentJob -ServerInstance . ).Count
$Jobs.successCount = (Get-SqlAgentJob -ServerInstance . ).where{$_.LastRunOutcome -eq 'Succeeded'}.Count
$Jobs.failedCount =  (Get-SqlAgentJob -ServerInstance . ).where{$_.LastRunOutcome -eq 'Failed'}.Count
$Jobs.JobsDisabled = (Get-SqlAgentJob -ServerInstance . ).where{$_.IsEnabled -eq $false}.Count
$Jobs.UnknownCount = (Get-SqlAgentJob -ServerInstance . ).where{$_.LastRunOutcome -eq 'Unknown'}.Count
$Jobs
## You can also start and stop jobs
(Get-SqlAgentJob -ServerInstance . -Name 'DatabaseBackup - SYSTEM_DATABASES - FULL').Start()
Get-SqlAgentJob -ServerInstance . -Name 'DatabaseBackup - SYSTEM_DATABASES - FULL'
## Or combine it into something like this
Get-Content 'Presentations:\New PowerShell Commands For SQL Server\Restore-LogShippingDatabase.ps1'
## There is also the history
Get-help get-SQLAgentJobHistory -showwindow
## Lets see the history
Get-SqlAgentJobHistory -ServerInstance .
## WOW!!!!!!!!!!!!!!!!
## Thats a bit much
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
cd SQLSERVER:\SQL\localhost\DEFAULT
Get-SqlErrorLog -Since Yesterday
## but also a timespan
Get-SqlErrorLog -Timespan '00:30:00' |Format-Table -AutoSize -Wrap
## and use Out-GridView to filter
Get-SqlErrorLog -Timespan '00:30:00' |Out-GridView
## you can also pass in an SMO object
$srv = New-Object Microsoft.SQLServer.Management.SMO.Server .
$srv|Get-SqlErrorLog -Timespan '00:10:00' 

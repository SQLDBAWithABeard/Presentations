## How do i get the sqlserver module for PowerShell?
## The first thing to do is to install the latest SSMS release

## Download it from http://sqlps.io/dl

## You need to download and install AND reboot
##
## Import the module

Import-Module sqlserver

## Lets look at the commands

Get-Command -Module sqlserver

## you can still use the SQL PS module - lets import sqlps

Import-Module SQLPS

## Dang ! there is a way but they wont run side by side

## Remove the sqlserver module 

Remove-Module sqlserver

## import the sqlps module

Import-Module sqlps

Get-Command -Module SQLPS -CommandType Cmdlet

## But the SQLPS module wont be updated so lets use the new one

## remove the sqlps module

Remove-Module SQLPS

## import the sqlserver module

Import-Module sqlserver

## lets start with the ones for SQL Agent

Get-Command *Agent* -Module SqlServer

## Always use Get-Help to find out how to use a command

Get-Help Get-SqlAgent -ShowWindow

## Lets get our SQL Server Agent for the local machine
## This is going to connect to my DEFAULT local instance
## If you are following along you can change this to 'SERVERNAME\INSTANCE' 
## if you need to connect to a different Instance

$SQLInstance = $ENV:COMPUTERNAME 

Get-SQLAgent -ServerInstance $SQLInstance

## this is returning an object (we like objects) for a SQL Agent
## I always recommend that you do something like this to investigate new things

## Set the results fo a command to a variable using a $

$a = Get-SqlAgent -ServerInstance $SQLInstance

## Have a look at the methods, properties and events

$a |Get-Member

## To see what this object has for its properties

$A|select *

## NOTE: Not case-sensitive - select * isnt bad here (but may return a lot of data as well - think performance)

## You can do this for multiple servers

$SQLServers = 'ROB-XPS','ROB-XPS\DAVE' ,'SQL2005Ser2003','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3','SQLVnextN1','SQLvNextN2'
 # My machine has two instances you can put as many as you like here

$SQLAgents = Get-SqlAgent -ServerInstance $SQLServers

$SQLAgents | Select-Object Name, ServiceAccount, ServiceStartMode

## because this is a demo I don't use aliases but at the command line you can (and should)
## NOTE: NEVER use aliases in your scripts - Think of the next gal or guy

## SQL Agent Jobs - Always use Get-Help to find out how to use a command

Get-Help Get-SqlAgentJob -ShowWindow

## You can pass your object along the pipeline to other commands 

$SQLAgents | Get-SqlAgentJob

## Now you can start being creative/specific about what you want

## Put all the jobs in a variable (NOTE: This is in RAM and avaiable throughout your session - PERFORMANCE)

$Jobs = $SQLAgents | Get-SqlAgentJob

## What can we do or see ?

$Jobs | Get-Member

## How many Jobs ?

$Jobs.Count

## How many Failed?

($Jobs | Where-Object {$_.LastRunOutcome -eq 'Failed'}).Count

## How Many disabled ?

$Jobs.Where{$_.IsEnabled -eq $false}.Count

## NOTE: The second command uses PowerShell V4 and above syntax which is quicker. 
## You may need the first commands syntax

## Everything is an object - lets create a custom one

[pscustomobject]$Results= @{}
$Results.NoOfJobs = $Jobs.Count
$Results.Success = $Jobs.where{$_.LastRunOutcome -eq 'Succeeded'}.Count
$Results.Failed =  $Jobs.where{$_.LastRunOutcome -eq 'Failed'}.Count
$Results.Disabled = $Jobs.where{$_.IsEnabled -eq $false}.Count
$Results.Unknown = $Jobs.where{$_.LastRunOutcome -eq 'Unknown'}.Count
$Results

## OK cool we can get properties (There are many more properties in a job)

## If we want to look at a single job

$JobName = 'DatabaseBackup - SYSTEM_DATABASES - FULL'
Get-SQLAgentJob -ServerInstance $SQLInstance -Name $JobName | Select *

## If we want to look at a single Job in our collection
## NOTE: This is how you access an item in a collection

$Jobs[3]

## Or search through it
$Jobs.Where{$_.Name -eq $JobName}

## There is also the Job history

Get-help Get-SqlAgentJobHistory -ShowWindow

## Lets look at one job

Get-SqlAgentJobHistory -ServerInstance $SQLInstance -JobName 'DatabaseBackup - SYSTEM_DATABASES - FULL'

## OK that is the history for the amount of time since I purged the job history
## That can get quite large!!!

## Theres a since Parameter
##  -Since <SinceType>
##  
##  A convenient abbreviation to avoid using the -StartRunDate parameter.
##   It can be specified with the -EndRunDate parameter.
##  
##  Do not specify a -StartRunDate parameter, if you want to use it.
##  
##  Accepted values are:
##   “ Midnight (gets all the job history information generated after midnight)
##   “ Yesterday (gets all the job history information generated in the last 24 hours)
##   “ LastWeek (gets all the job history information generated in the last week)
##   “ LastMonth (gets all the job history information generated in the last month)
##  
## Lets try since yesterday and output to gridview

Get-SqlAgentJobHistory -ServerInstance $SQLInstance  -Since Yesterday |
Select-Object RunDate, StepID, Server, JobName, StepName, Message | Out-GridView

## Pretty much what you would see in Agent Job History - Lets look in SSMS
## We can look at individual job steps

Get-Help Get-SqlAgentJobStep -ShowWindow

## I dont follow the examples completely

Get-SqlAgentJob -ServerInstance $SQLInstance -Name 'DatabaseBackup - SYSTEM_DATABASES - FULL' |
Get-SqlAgentJobStep -Name 'DatabaseBackup - SYSTEM_DATABASES - FULL'|Select-Object *

## Or the schedule

Get-SqlAgentJob -ServerInstance $SQLInstance -Name 'DatabaseBackup - SYSTEM_DATABASES - FULL' |
Get-SqlAgentJobSchedule | Select-Object *

##  the error log

Get-Help Get-SqlErrorLog -ShowWindow

## Again we have the since parameter
## You can CD to the SQLSERVER Drive

Set-Location SQLSERVER:\SQL\$SQLServer\DEFAULT
Get-SqlErrorLog -Since Yesterday

## you can also pass in an SMO object - I'll create one this time 
## NOTE: Snippet to do this https://sqldbawithabeard.com/2014/09/09/powershell-snippets-a-great-learning-tool/
## Here we will use Out-GridView to enable us to filter

$srv = New-Object Microsoft.SQLServer.Management.SMO.Server .
$srv | Get-SqlErrorLog -Since Yesterday | Out-GridView

## but there is also a timespan parameter

$srv | Get-SqlErrorLog -Timespan '03:00:00' | Format-Table -AutoSize -Wrap

## Logins

Get-Help Add-SqlLogin -ShowWindow

## Add a Login
## NOTE: This login is created disabled and without permissin to connect to the database engine

Add-SqlLogin -ServerInstance $SQLServer -LoginName TheBeardRules -LoginType SqlLogin

## Now you can use Get-SQLLogin to get the Logins

Get-Help Get-SqlLogin -ShowWindow

Get-SqlLogin -ServerInstance $SQLServer

## Or maybe the disabled ones (which will include the new one we just created)

Get-SqlLogin -ServerInstance $SQLInstance -Disabled

## There are many Availability Group commands

Get-Command -Module sqlserver -Name *SqlAvailability*

## and for Always encrypted

Get-Command -Module sqlserver -Name *encry*
Get-Command -Module sqlserver -Name *key*

## Enabling/Disabling Always on 

Get-Command -Module sqlserver -Name *always*

## Starting and Stopping Instance

Get-Command -Module sqlserver -Name *inst*

## LAB - Agent Jobs and exploring object properties

## Get an Agent Job into a variable and examine its properties using Get-Member

## Write a command to see if the job has a schedule without using Get-SQLAgentJobSchedule

## Write a command to get the name of the schedule without using Get-SQLAgentJobSchedule and one more piece of information about it

## Write a command to display the Command of the first Job Step without using Get-SQLAgentJobStep 

## LAB Error Log 

## Write a command to get the last 20 minutes of the SQL Error log entries and format as a table

## Set the command to get the last 20 minutes of the SQL Error log to a variable and use a Where method 
## to find errors

## Get the last 20 minutes of the error log and export to a CSV file in the C:\temp directory

## LAB SQL Logins

## Use the help to write a command to add a sql login which is enabled with permissions to connect to the 
## database engine and a default database

## What are the options for the LoginType Parameter for Add-SQLLogin


## LAB Agent Jobs - Answers

$AgentJob = Get-SQLAgentJob -ServerInstance 'COMPUTERNAME' -Name 'JOBNAME'

$AgentJob | Get-Member

Get-SQLAgentJob -ServerInstance 'COMPUTERNAME' -Name 'JOBNAME' | Select-Object Parent, Name, HasSchedule

## or

$AgentJob | Select-Object Parent, Name, HasSchedule

## Need to find the properties 

$AgentJob.JobSchedules | Get-Member

$AgentJob.JobSchedules | Select-Object Name, ANOTHERPROPERTY

$AgentJob.JobSteps[0].Command

## LAB Error Log Answers

Get-SqlErrorLog -ServerInstance $SQLServer -Timespan '00:20:00'

$Errorlog = Get-SqlErrorLog -ServerInstance $SQLServer -Timespan '00:20:00'

$Errorlog | Get-Member

$Errorlog.Where{$_.Message -like '*error*'} | Format-Table -AutoSize

Get-SqlErrorLog -ServerInstance $SQLServer -Timespan '00:20:00' | Export-Csv -Path C:\Temp

## LAB Logins Answers

Add-SqlLogin -ServerInstance $SQLServer -LoginName TheBeardRulesAgain -LoginType SqlLogin -Enable -GrantConnectSql -DefaultDatabase DBA-Admin

        -- AsymmetricKey 
        -- Certificate 
        -- SqlLogin 
        -- WindowsGroup 
        -- WindowsUser


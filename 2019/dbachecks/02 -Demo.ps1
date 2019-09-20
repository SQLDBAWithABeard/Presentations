Set-Location 'GIT:\Presentations\2019\dbachecks'
#region Start - intro
. .\vars.ps1

Get-Module dbachecks -ListAvailable

## It's very important to keep up to date using

## Update-Module dbachecks

Get-Command -Module dbachecks

## How many Checks ?

(Get-DbcCheck).Count

## How many Configurations
(Get-DbcConfig).Count

## Lets have a look at the checks and the associated configurations

Get-DbcCheck | Out-GridView

#endregion

#region instant view

## Lets run a quick check - I'm a DBA

Invoke-DbcCheck -SqlInstance $sql0 -Check AutoClose

# its so easy, there is even intellisense

Invoke-DbcCheck -SqlInstance $sql0 -Check 

## I am not limited to just one server/instance
## Maybe I want to check all my containers for Errors

Invoke-DbcCheck -SqlInstance $containers -Check ErrorLog

## Or that I have enough diskspace (we try to help where we can - This needs ComputerName :-) 

Invoke-DbcCheck -ComputerName $ENV:COMPUTERNAME -Check DiskCapacity 

## Lets look at a configuration

Get-DbcConfig -Name app.sqlinstance

# So we can set this so that we have a default set of instances we want to check

Set-DbcConfig -Name app.sqlinstance -Value $containers

# Now I dont need to specify the instances 

## or that I have run DBCC CheckDb in the last 7 days

Invoke-DbcCheck -Check LastGoodCheckDb 






# Ah thats not so good

# I wonder if I have Ola Hallengrens Maintenance Solution installed ?

Invoke-DbcCheck  -Check OlaInstalled

# Ah ok - quick diversion to the cool that is dbatools - just so you see how easy it is

Install-DbaMaintenanceSolution -SqlInstance $containers 

# How many seconds ? :-D

Invoke-DbcCheck -Check OlaInstalled

# Lets start those DBCC running
$getDbaAgentJobSplat = @{
    Job = 'DatabaseIntegrityCheck - USER_DATABASES','DatabaseIntegrityCheck - SYSTEM_DATABASES'
    SqlInstance = $containers
}
(Get-DbaAgentJob @getDbaAgentJobSplat).Start()

Invoke-DbcCheck  -Check LastGoodCheckDb


## The problem with the last lot of checks I ran was that I could not scroll up and 
## see all of the failures as it was just output to the screen
## There are a few ways around this

## Just show the fails

Invoke-DbcCheck -Check LastGoodCheckDb -Show Fails

Invoke-DbcCheck -SqlInstance $sql0,$sql1 -Check FutureFileGrowth -Show Failed

# How about my linked servers ?

Invoke-DbcCheck -Check LinkedServerConnection 

# Are my builds supported? and will they be supported in 6 months?

Invoke-DbcCheck -Check SupportedBuild

#

Invoke-DbcCheck -Check DatabaseStatus

#

Invoke-DbcCheck -Check PseudoSimple

# 

Invoke-DbcCheck -Check DatabaseExists

# great you've shown that the system databases exist
# I need to know if my production pubs and NorthWind Databases are ok
# This is the process to use for any configuration
# lets see what configuration we have for a the check

Get-DbcCheck -Pattern DatabaseExists | Format-List

Get-DbcConfig -Name database.exists

Set-DbcConfig -Name database.exists -Value 'pubs', 'Northwind' -Append

Get-DbcConfigValue -Name database.exists

Invoke-DbcCheck -Check DatabaseExists

Invoke-DbcCheck -Check ValidDatabaseOwner

Get-DbcCheck -Pattern ValidDatabaseOwner | Format-List

Get-DbcConfig -Name policy.validdbowner.name

Get-DbcConfig -Name policy.validdbowner.excludedb

Set-DbcConfig -Name policy.validdbowner.name -Value sqladmin

Invoke-DbcCheck -Check ValidDatabaseOwner

# ah pubs is owned by sa - We could add sa to the config for policy.validdbowner.name

Set-DbcConfig -Name policy.validdbowner.excludedb -Value pubs -Append

#endregion

#region
## Email from manager

$newBurntToastNotificationSplat = @{
    Text = 'Major System Problem - The Availability Group is Broken. -  DROP EVERYTHING and DO IT NOW','Angry Manager'
    AppLogo = 'C:\Users\enterpriseadmin.THEBEARD\Desktop\angryboss.jpg'
}
New-BurntToastNotification @newBurntToastNotificationSplat
#endregion

## Hmm Better get onto this quick
<#
#region Check that issue
Set-DbcConfig -Name app.cluster -Value $SQL0
Set-DbcConfig -Name domain.name -Value 'TheBeard.Local'
Set-DbcConfig -Name skip.hadr.listener.pingcheck -Value $true

Invoke-DbcCheck -Check HADR
#>
#endregion

#region
## 

$newBurntToastNotificationSplat = @{
    Text = "NO - It's NOT the Availability Group or SQL at ALL"
    AppLogo = 'C:\Users\enterpriseadmin.THEBEARD\Desktop\SarkyDBA.jpg'
}
New-BurntToastNotification @newBurntToastNotificationSplat
#endregion


## I can set the configuration values for any of the 152 items and then run my checks

#region Set config for Production

# The computername we will be testing
Set-DbcConfig -Name app.computername -Value $sql0,$SQl1                                                                                                                                                                                                          
# The Instances we want to test
Set-DbcConfig -Name app.sqlinstance -Value $sql0,$SQl1                                                                                                                                            
# The database owner we expect
Set-DbcConfig -Name policy.validdbowner.name -Value 'THEBEARD\EnterpriseAdmin'  
# the database owner we do NOT expect
Set-DbcConfig -Name policy.invaliddbowner.name -Value 'sa'      
# Should backups be compressed by default?
Set-DbcConfig -Name policy.backup.defaultbackupcompression -Value $true     
# Do we allow DAC connections?
Set-DbcConfig -Name policy.dacallowed -Value $true    
# What recovery model should we have?
Set-DbcConfig -Name policy.recoverymodel.type -value FULL     
# What should ourt database growth type be?
Set-DbcConfig -Name policy.database.filegrowthtype -Value kb   
# What authentication scheme are we expecting?                                                                                                            
Set-DbcConfig -Name policy.connection.authscheme -Value 'KERBEROS'
# Which Agent Operator should be defined?
Set-DbcConfig -Name agent.dbaoperatorname -Value 'The DBA Team'
# Which Agent Operator email should be defined?
Set-DbcConfig -Name agent.dbaoperatoremail -Value 'TheDBATeam@TheBeard.Local'
# What is the name of our mail profile that should be on the machine?
Set-DbcConfig -Name agent.databasemailprofile -Value 'DBATeam'
# Which failsafe operator shoudl be defined?
Set-DbcConfig -Name agent.failsafeoperator -Value 'The DBA Team'
# Where is the whoisactive stored procedure?
Set-DbcConfig -Name policy.whoisactive.database -Value DBAAdmin 
# What is the maximum time since I took a Full backup?
Set-DbcConfig -Name policy.backup.fullmaxdays -Value 7
# What is the maximum time since I took a DIFF backup (in hours) ?
Set-DbcConfig -Name policy.backup.diffmaxhours -Value 26
# What is the maximum time since I took a log backup (in minutes)?
Set-DbcConfig -Name policy.backup.logmaxminutes -Value 30 
# What is my domain name?
Set-DbcConfig -Name domain.name -Value 'TheBeard.Local'
# Where is my Ola database?
Set-DbcConfig -Name policy.ola.database -Value DBAAdmin
# Which database should not be checked for recovery model
Set-DbcConfig -Name policy.recoverymodel.excludedb -Value 'master','msdb','tempdb'
# Should I skip the check for temp files on c?
Set-DbcConfig -Name skip.tempdbfilesonc -Value $true
# Should I skip the check for temp files count?
Set-DbcConfig -Name skip.tempdbfilecount -Value $true
# Which Checks should be excluded?
Set-DbcConfig -Name command.invokedbccheck.excludecheck -Value LogShipping,ExtendedEvent, HADR, PseudoSimple,SPN, TestLastBackupVerifyOnly,IdentityUsage,FKCKTrusted, DiskAllocationUnit,AgentServiceAccount
# How many months before a build is unsupported do I want to fail the test?
Set-DbcConfig -Name policy.build.warningwindow -Value 6


#endregion

## Now we can look at our configuration
Get-Dbcconfig | ogv

## and run a check like this

Invoke-DbcCheck

## Now that I have set my configuration I can export it
## I could save it and source control it

Export-DbcConfig -Path C:\temp\Production.Json



## To output to Azure DevOps (or Jenkins or Octopus etc)

$invokeDbcCheckSplat = @{
    Check = 'Agent'
    OutputFormat = 'NUnitXml'
    Show = 'Summary'
    OutputFile = 'C:\temp\Agent_Check_Results.xml'
}
Invoke-DbcCheck @invokeDbcCheckSplat

code-insiders C:\temp\Agent_Check_Results.xml

# But best of all the viewing is the PowerBi

Invoke-DbcCheck -SqlInstance $sql0 , $sql1 -Check Agent -Show Summary -PassThru | Update-DbcPowerBiDataSource -Environment Prod-Agent

Start-DbcPowerBi

## This happens automatically The json is stored in C:\windows\Temp\dbachecks

Explorer C:\windows\Temp\dbachecks

# This takes a minute or 3 to run so run then talk Rob
Invoke-DbcCheck -SqlInstance $sql0, $sql3  -Check Database -Show Summary -PassThru | Update-DbcPowerBiDataSource -Environment Prod-Database
Invoke-DbcCheck -SqlInstance $sql0,$sql1,$sql2, $sql3  -Check Database -Show Summary -PassThru | Update-DbcPowerBiDataSource -Environment Prod-Other


## So now you can see the power :-)

## You can create configurations for all sorts of scenarios
## and then import them or have them avaialble for systems or people to use

## You can run different sets of checks, save the json with different names 
## and have the results in the same Power Bi

## region Can I fix the problem in the tests?
$TestResults = Invoke-DbcCheck -SqlInstance $containers -Check FutureFileGrowth -Show None -PassThru

$TestResults

$TestResults.TestResult.Where{$_.Passed -eq $false}

#endregion
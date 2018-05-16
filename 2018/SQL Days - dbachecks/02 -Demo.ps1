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

## Lets run a quick check - I'm a DBA

Invoke-DbcCheck -SqlInstance $sql0 -Check AutoClose

# its so easy, there is even intellisense

Invoke-DbcCheck -SqlInstance $sql0 -Check 

## I am not limited to just one server/instance
## Maybe I want to check all my containers for Errors

Invoke-DbcCheck -SqlInstance $containers -Check ErrorLog -SqlCredential $cred

## Or that I have enough diskspace (we try to help where we can - This needs ComputerName :-) 

Invoke-DbcCheck -SqlInstance $SQLInstances -Check DiskCapacity

## or that I have run DBCC CheckDb in the last 7 days

Invoke-DbcCheck -SqlInstance $SQLInstances -Check LastGoodCheckDb 

(Get-DbaAgentJob -SqlInstance $SQLInstances -Job 'DatabaseIntegrityCheck - USER_DATABASES','DatabaseIntegrityCheck - SYSTEM_DATABASES').Start()

## I get a call about a system that uses an Availbility group
## Maybe I want to check that its all ok
## Or maybe I have finished patching and need to know all is well
## I need to set the app.cluster configuration to one of the nodes 
## and I need to set the domain.name value

Set-DbcConfig -Name app.cluster -Value $SQL0
Set-DbcConfig -Name domain.name -Value 'TheBeard.Local'

## I also skip the ping check for the listener as we are in Azure
Set-DbcConfig -Name skip.hadr.listener.pingcheck -Value $true

Invoke-DbcCheck -Check HADR

## I can set the configuration values for any of the 141 items and then run my checks

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
Set-DbcConfig -Name agent.dbaoperatoremail -Value 'DBATeam@TheBeard.Local'
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
# What is my SQL Credential
Set-DbcConfig -Name app.sqlcredential -Value $null
# Should I skip the check for temp files on c?
Set-DbcConfig -Name skip.tempdbfilesonc -Value $true
# Should I skip the check for temp files count?
Set-DbcConfig -Name skip.tempdbfilecount -Value $true
# Which Checks should be excluded?
Set-DbcConfig -Name command.invokedbccheck.excludecheck -Value LogShipping,ExtendedEvent, HADR, PseudoSimple,SPN, TestLastBackupVerifyOnly,IdentityUsage
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

## I can add this configuration to an automated system and get that to run my checks

Start-Process "https://sewells-consulting.visualstudio.com/Deploy%20SQL%20Always%20On%20-%20Azure/_build/index?buildId=629&_a=summary&tab=ms.vss-test-web.test-result-details"

## The problem with the last lot of checks I ran was that I could not scroll up and 
## see all of the failures as it was just output to the screen
## There are a few ways around this

## Just show the fails

Invoke-DbcCheck -SqlInstance $SQLInstances -Check FutureFileGrowth -Show Fails

## Dont show the failed - not as easy to see

Invoke-DbcCheck -SqlInstance $SQLInstances -Check FutureFileGrowth -Show Failed

## You can also save the results to a variable 
## and show None (I would show None for automated systems - why waste the CPU cycles?)

$TestResults = Invoke-DbcCheck -SqlInstance $SQLInstances -Check FutureFileGrowth -Show None -PassThru

$TestResults

$TestResults.TestResult.Where{$_.Passed -eq $false}

## To output to VSTS (or Jenkins or Octopus etc)

$invokeDbcCheckSplat = @{
    Check = 'Agent'
    OutputFormat = 'NUnitXml'
    Show = 'Summary'
    SqlInstance = $SQLInstances
    OutputFile = 'C:\temp\Agent_Check_Results.xml'
}
Invoke-DbcCheck @invokeDbcCheckSplat

Open-EditorFile C:\temp\Agent_Check_Results.xml

# But best of all the viewing is the PowerBi

Invoke-DbcCheck -SqlInstance $SQLInstances -Check Agent -Show Summary -PassThru | Update-DbcPowerBiDataSource -Environment Prod-Agent

Start-DbcPowerBi

## This happens automatically The json is stored in C:\windows\Temp\dbachecks

Explorer C:\windows\Temp\dbachecks

Invoke-DbcCheck -SqlInstance $SQLInstances -Check Database -Show Summary -PassThru | Update-DbcPowerBiDataSource -Environment Prod-Database

Start-DbcPowerBi

## So now you can see the power :-)

## You can create configurations for all sorts of scenarios
## and then import them or have them avaialble for systems or people to use

## Check our "Development" Servers

#region Dev Config
Set-DbcConfig -Name app.sqlinstance -Value $containers 
# Set-DbcConfig -Name app.sqlcredential -Value $cred
Set-DbcConfig -Name policy.validdbowner.name -Value 'sa'   
Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
Set-DbcConfig -Name policy.invaliddbowner.name -Value 'THEBEARD\EnterpiseAdmin'
Set-DbcConfig -Name policy.connection.authscheme -Value 'SQL'
Set-DbcConfig -Name policy.backup.defaultbackupcompression -Value $false
Set-DbcConfig -Name policy.database.filegrowthtype -Value kb
Set-DbcConfig -Name policy.database.filegrowthvalue -Value 64
Set-DbcConfig -Name policy.dacallowed -Value $false 
Set-DbcConfig -Name policy.network.latencymaxms -Value 100
Set-DbcConfig -Name policy.recoverymodel.type -value Simple
Set-DbcConfig -Name policy.whoisactive.database -Value DBAAdmin 
Set-DbcConfig -Name domain.name -Value 'WORKGROUP'
Set-DbcConfig -Name policy.recoverymodel.excludedb -Value 'master','model','msdb','tempdb'

Set-DbcConfig -Name policy.build.warningwindow -Value 6

Set-DbcConfig -Name command.invokedbccheck.excludecheck -Value LogShipping,ExtendedEvent, HADR, SaReNamed, PseudoSimple,spn, DiskSpace, DatabaseCollation,Agent,Backup,UnusedIndex,LogfileCount,FileGroupBalanced,LogfileSize,MaintenanceSolution,ServerNameMatch,ServiceAccount,ErrorLog, ModelDatabaseGrowth,WhoIsActiveInstalled,MaxMemory,TempDbConfiguration,Adhocworkload,Domain, CompatabilityLevel,FutureFileGrowth

#endregion

Invoke-DbcCheck -AllChecks -SqlCredential $cred -Show Fails -PassThru | Update-DbcPowerBiDataSource -Environment DevelopmentContainers

Export-DbcConfig -Path C:\temp\development_config.json
Open-EditorFile C:\temp\development_config.json

Set-DbcConfig -Name app.sqlinstance -Value $SQLInstances
Set-DbcConfig -Name command.invokedbccheck.excludecheck -Value Agent,HADR,Database,Instance,LogShipping,Server

Export-DbcConfig c:\temp\AgentConfig.json

Invoke-DbcCheck -AllChecks -SqlCredential $cred -Show Fails -PassThru | Update-DbcPowerBiDataSource -Environment OlaChecks

Set-DbcConfig -Name app.sqlinstance -Value $SQLInstances
Set-DbcConfig -Name app.computername -Value $SQLInstances
Set-DbcConfig -Name command.invokedbccheck.excludecheck -Value Agent,HADR,Database,Instance,LogShipping,MaintenanceSolution,PowerPlan,SPN,InstanceConnection,PingComputer,Domain


Export-DbcConfig c:\temp\DiskSpace.json

Invoke-DbcCheck -AllChecks -SqlCredential $cred -Show Fails -PassThru | Update-DbcPowerBiDataSource -Environment DiskSpace

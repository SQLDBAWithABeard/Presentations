
## Lets have a look at the checks and the associated configurations

Get-DbcCheck | Out-GridView

## Lets run a quick check - I'm a DBA

Invoke-DbcCheck -SqlInstance $sql0 -Check AutoClose

# its so easy, there is even intellisense

Invoke-DbcCheck -SqlInstance $sql0 -Check Agent

# more than one and SQL Auth
Invoke-DbcCheck -SqlInstance $containers -Check AutoShrink -SqlCredential $cred

# We can check Windows information as well
Invoke-DbcCheck -ComputerName $SQLInstances -Check DiskCapacity

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
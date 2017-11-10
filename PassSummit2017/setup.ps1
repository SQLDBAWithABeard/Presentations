#Requires -Version 5
#Requires -module dbatools
$VerbosePreference = 'Continue'
Import-Module dbatools

$SQLInstances = 'ROB-XPS','ROB-XPS\DAVE','ROB-XPS\SQL2016'

## Start the SQL Services
foreach ($ServerInstance in $SQLInstances) {
    if ($ServerInstance.Contains('\')) {
        $ServerName, $Instance = $ServerInstance.Split('\')
    }
    else {
        $Servername = $Server
        $Instance = 'MSSQLSERVER'
    }
    If ($Instance -eq 'MSSQLSERVER') {
        $SQLService = $Instance
        $AgentService = 'SQLSERVERAGENT'
    }
    else {
        $SQLService = "MSSQL$" + $Instance
        $AgentService = "SQLAgent$" + $Instance
    }
    if ((Get-service -Name $SQLService).status -ne 'Running') {
        Write-Verbose "Starting $SQLService Service"
        Start-Service -Name $SQLService
    }
    if ((Get-service  -Name $AgentService).Status -ne 'Running') {
        Write-Verbose "Starting $AgentService Service"
        Start-Service -Name $AgentService
    }


}

#Start the Linux machine

if((Get-VM -Name Bolton).State -ne 'Running'){
    Start-VM -Name Bolton 
}

$VerbosePreference = 'SilentlyContinue'
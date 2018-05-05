#Requires -Version 5
#Requires -module dbatools
$VerbosePreference = 'Continue'

$LinuxHyperV = 'Bolton'
$SQLInstances = 'ROB-XPS\DAVE','ROB-XPS'
## Start Linux VM if not running
If ((Get-VM -Name $LinuxHyperV).State -ne 'Running') {
    Get-VM -Name $LinuxHyperV | Start-VM
    Write-Verbose "Starting VM"
}
else{
    Write-Verbose "Linux VM running"
}


## Start the SQL Services
foreach ($ServerInstance in $SQLInstances) {
    if ($ServerInstance.Contains('\')) {
        $ServerName, $Instance = $ServerInstance.Split('\')
        #$ServerName = $ServerInstance.Split('\')[0] # delete when above change is working
        #$Instance = $ServerInstance.Split('\')[1] # delete when above change is working
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
    else{
        Write-Verbose " $SQLService Service already Running"
    }
    if ((Get-service  -Name $AgentService).Status -ne 'Running') {
        Write-Verbose "Starting $AgentService Service"
        Start-Service -Name $AgentService
    }
    else{
        Write-Verbose "$AgentService Service already Running"
    }
}

if ((Get-service  -Name SQLBrowser).Status -ne 'Running') {
    Write-Verbose "Starting SQLBrowser Service"
    Start-Service -Name SQLBrowser
}
else{
    Write-Verbose "SQLBrowser Service already Running"
}


$VerbosePreference = 'SilentlyContinue'
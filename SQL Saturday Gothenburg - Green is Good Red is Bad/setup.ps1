#Requires -Version 5
#Requires -module dbatools
$VerbosePreference = 'Continue'
Import-Module 'C:\Program Files\WindowsPowerShell\Modules\Pester\4.0.3\Pester.psd1'
Import-Module 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\Hyper-V\2.0.0.0\Hyper-V.psd1' 
Import-Module 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\DnsServer\DnsServer.psd1' 
Import-Module 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\NetAdapter\NetAdapter.psd1' 
Import-Module 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\NetTCPIP\NetTCPIP.psd1' 
# Import-Module 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\DnsClient\DnsClient.psd1' 
Import-Module 'C:\Program Files\WindowsPowerShell\Modules\dbatools\0.9.25\dbatools.psd1'

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



$containers = "$ENV:ComputerName,15591", "$ENV:ComputerName,15592"
$SQLInstances = $containers
$sql0 = $containers[0]
$sql1 = $containers[1]
$cred = Import-Clixml 'dockercompose:\dbatools-2-instances-AG\sacred.xml'
$NetworkShare = '/var/opt/mssql/backups/'

. .\invoke-Parallel.ps1

$ShowKube = $false
$ShowAzure = $true
$ShowGit = $true
$ShowPath = $true
$ShowDate = $true
$ShowTime = $true
$ShowCountDown = $true
$CountDownMessage = "dbatools is awesome in $location"


$PSDefaultParameterValues += @{
    '*db*:SqlCredential' = $cred
    '*db*:DestinationSqlCredential' = $cred
    '*db*:SourceSqlCredential' = $cred
}
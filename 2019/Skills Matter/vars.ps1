$SQLInstances = 'localhost,15591', 'localhost,15591'
$sql0 = 'localhost,15591'
$sql1 = 'localhost,15592'
$cred = Import-Clixml /home/rob/Documents/Presentations/dbatools/sqladmin.cred

$containers = 'bearddockerhost,15789', 'bearddockerhost,15788', 'bearddockerhost,15787', 'bearddockerhost,15786'
$SQL2017Container = 'bearddockerhost,15789'

$LinuxSQL = 'beardlinuxsql'
$mirrors = 'sql0\mirror','sql1\mirror'

$filenames = ''#(Get-ChildItem C:\SQLBackups\Keep).Name
$Share = '\\jumpbox.TheBeard.Local\SQLBackups'
$NetworkShare = '\\bearddockerhost.TheBeard.Local\NetworkSQLBackups'
$location = 'London'

. .\invoke-Parallel.ps1

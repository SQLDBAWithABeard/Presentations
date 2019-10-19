$SQLInstances = 'localhost,15591', 'localhost,15592', 'localhost,15593', 'localhost,15594'
$sql0 = 'localhost,15591'
$sql1 = 'localhost,15592'
$sql2 = 'localhost,15593'
$sql3 = 'localhost,15594'
$localhost = 'localhost'

$cred = Import-Clixml C:\MSSQL\BACKUP\sqladmin.cred
$filenames = (Get-ChildItem C:\MSSQL\BACKUP\KEEP -File).Name

$location = 'Munich'

. .\invoke-Parallel.ps1

$ShowCountDown = $true
$CountDownEndDate = Get-Date -Year 2019 -Month 10 -Day 19 -Hour 16 -Minute 40
$CountDownMessage = 'dbatools loves Munich'

$BackupWin = 'C:\MSSQL\BACKUP\'
$BackupLinux = '/var/opt/mssql/backups/'

$PSDefaultParameterValues += @{
    '*dba*:SqlCredential' = $cred
    '*dba*:DestinationSqlCredential' = $cred
    '*dba*:SourceSqlCredential' = $cred
}

$verbosePreference = 'SilentlyContinue'
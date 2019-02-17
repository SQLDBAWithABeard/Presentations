if ($ENV:COMPUTERNAME -eq 'JumpBox') {
    $cred = Import-Clixml $HOME\Documents\sa.cred
    $SQLInstances = 'sql0', 'sql1'
    $containers = 'bearddockerhost,15789', 'bearddockerhost,15788', 'bearddockerhost,15787', 'bearddockerhost,15786'
    $SQL2017Container = 'bearddockerhost,15789'
    $sql0 = 'sql0'
    $sql1 = 'sql1'
    $filenames = (Get-ChildItem C:\SQLBackups\Keep).Name
    $LinuxSQL = 'beardlinuxsql'
    $Share = '\\jumpbox.TheBeard.Local\SQLBackups'
    $NetworkShare = '\\bearddockerhost.TheBeard.Local\NetworkSQLBackups'

}
elseif ($ENV:COMPUTERNAME -eq 'ROB-XPS') {
    $cred = Import-Clixml C:\MSSQL\BACKUP\sqladmin.cred     
    $containers = 'localhost,15591', 'localhost,15592', 'localhost,15593', 'localhost,15594'
    $sql0 = 'localhost,15591'
    $sql1 = 'localhost,15592'
    $sql2 = 'localhost,15593'
    $sql3 = 'localhost,15594'
}
if (-not ($PSDefaultParameterValues.'*-Dba*:SqlCredential')) {
    $PSDefaultParameterValues += @{
        '*-Dba*:SqlCredential' = $cred
    }
    $PSDefaultParameterValues += @{
        '*-Dbc*:SqlCredential' = $cred
    }
}
$location = 'Manchester'
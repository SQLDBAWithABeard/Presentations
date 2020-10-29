$SqlInstance = 'localhost'
$databases = (Get-DbaDatabase -SqlInstance $SqlInstance -ExcludeSystem).Name
$logins =  'akamman', 'alevy', 'beardapp1', 'beardapp2', 'beardapp3', 'beardapp4', 'beardapp5', 'beardapp6', 'beardapp7', 'beardapp8', 'clemaire', 'csilva', 'fatherjack', 'gsartori', 'jamrtin', 'Reporting1', 'Reporting2', 'Reporting3', 'Reporting4', 'smelton', 'SockFactoryApp_User', 'soneill', 'sqladmin', 'Support1', 'Support2', 'Support3', 'Support4', 'Support5', 'Support6', 'tboggiano', 'thebeard', 'wdurkin'

$pwd = 'Password0!'
$secpwd = ConvertTo-SecureString $pwd -AsPlainText -Force
foreach ($login in $logins) {
    New-DbaLogin -SqlInstance $SqlInstance -Login $login -SecurePassword $secpwd -Force
}

$roles = 'db_accessadmin', 'db_backupoperator', 'db_datareader', 'db_datawriter', 'db_ddladmin', 'db_denydatareader', 'db_denydatawriter', 'db_owner', 'db_securityadmin'

foreach ($login in $logins) {
    $DbNumber = Get-Random -Minimum 2 -Maximum $Databases.Count
    $Dbs = Get-Random $databases -Count $DbNumber
    foreach ($db in $dbs) {
        $rolenumber = Get-Random -Minimum 1 -Maximum $roles.Count
        $rolestoadd = Get-Random $roles -Count $rolenumber
        New-DbaDbUser -SqlInstance $SqlInstance -Database $db -Login $login 
        Add-DbaDbRoleMember -SqlInstance $SqlInstance -Database $db -Role $rolestoadd -User $login -Confirm:$false
    }
}

#clear up
foreach($db in $databases){
     Remove-DbaDbUser -SqlInstance $SqlInstance -database $db -User $logins
}

    Remove-DbaLogin -SqlInstance $SqlInstance -Login $logins -Confirm:$false

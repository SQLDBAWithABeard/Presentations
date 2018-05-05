$linuxSQL = 'LinuxvvNext'
$WinSQl1 = 'SQLvNextN1'
$cred = Get-Credential -UserName SA -Message "Linux SQL Auth"
$linux = Connect-DbaSqlServer -SqlServer $linuxSQL  -Credential $cred
$win1 = Connect-DbaSqlServer -SqlServer $WinSQl1

Function Compare-WinLinuxConfigs
{
$linuxSpConfigure = Get-DbaSpConfigure  -SqlServer $linuxSQL -SqlCredential $cred
$WinSPConfigure = Get-DbaSpConfigure -SqlServer $WinSQl1

$propcompare = foreach ($prop in $linuxSpConfigure) {
    [pscustomobject]@{
    Config = $prop.DisplayName
    'Linux setting' = $prop.RunningValue
    'Windows Setting' = $WinSPConfigure | Where DisplayName -eq $prop.DisplayName | Select -ExpandProperty RunningValue
    }
} 

$propcompare | ogv
}

Compare-WinLinuxConfigs

$win.Configuration.Properties['DefaultBackupCompression'].ConfigValue = 1
$win.Configuration.Alter()

Compare-WinLinuxConfigs

Copy-SqlSpConfigure -Source $WinSQl1 -Destination $linuxSQL -DestinationSqlCredential $cred -Configs DefaultBackupCompression

Compare-WinLinuxConfigs

$linux.Configuration.Properties['DefaultBackupCompression'].ConfigValue = 0
$linux.Configuration.Alter()

Compare-WinLinuxConfigs

$linuxConfigPath = 'C:\Temp\Linuxconfig.sql'
Export-SqlSpConfigure -SqlServer $linuxSQL -SqlCredential $cred -Path $LinuxConfigPath
notepad $linuxConfigPath

$WinConfigPath = 'C:\Temp\Winconfig.sql'
Export-SqlSpConfigure -SqlServer $WinSQl1 -Path $winConfigPath
notepad $winConfigPath

Import-SqlSpConfigure -Path $WinConfigPath -SqlServer $linuxSQL -SqlCredential $cred


Compare-WinLinuxConfigs
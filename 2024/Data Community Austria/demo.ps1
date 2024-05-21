docker compose -f docker-compose.yml up -d


$containers = $dbatools1, $dbatools2, $dbatools3, $dbatools4, $dbatools5, $dbatools6, $dbatools7, $dbatools8, $dbatools9, $dbatools10 = 'localhost,11001','localhost,11002','localhost,11003','localhost,11004','localhost,11005','localhost,11006','localhost,11007','localhost,11008','localhost,11009','localhost,11010'
[pscredential]$sqlcredential = New-Object System.Management.Automation.PSCredential (Get-Secret -Name sqladmin -Vault LocalStore -AsPlainText), (Get-Secret -Name sqladminpwd -Vault LocalStore)

Set-DbcConfig policy.connection.authscheme -Value 'Sql'
Set-DbcConfig skip.connection.remoting -Value $true
$Results = Invoke-DbcCheck -SQLInstance $containers -SqlCredential $sqlcredential -Check InstanceConnection, AutoClose,AutoShrink,DatabaseExists,XpCmdShellDisabled, ValidJobOwner,ValidDatabaseOwner -PassThru

$results | Convert-DbcResult -Label 'Run Number Three' | Write-DbcTable -SqlInstance Beard-Desktop -Database KittenFactory

Start-DbcPowerBi -FromDatabase
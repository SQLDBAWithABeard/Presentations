$Bolton = Connect-DbaSqlServer -SqlInstance 'Rob-XPS\Bolton'
$SQL2016 = Connect-DbaSqlServer -SqlInstance 'Rob-XPS\SQL2016'
$cred = Import-Clixml C:\MSSQL\sa.cred 
$LinuxBolton = Connect-DbaSqlServer -SqlInstance Bolton -Credential $cred
## Ensure all required objects in SQL2016

## Add logins
$Server = 'Rob-XPS\SQL2016'
$Password = 'DuffPassword01'
$i = 15
While ($i -gt 0)
{
    $User = 'UserForManchesterDemo_' + [string]$i
    $Pass = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Pass
    Add-SqlLogin -ServerInstance $Server -LoginName $User -LoginType SqlLogin -DefaultDatabase tempdb -Enable -GrantConnectSql -LoginPSCredential $Credential
    $i --
}

## Add Credential

$Script = @"
CREATE CREDENTIAL [ManchesterCredential] WITH IDENTITY = N'ROB-XPS\jenkins', SECRET = N'Password01'
"@
Invoke-Sqlcmd -ServerInstance $Server -Database master -Query $script 

## Add Audit

$script = @"
CREATE SERVER AUDIT [ManchesterDemoSQLAudit]
TO FILE 
(	FILEPATH = N'C:\MSSQL\MSSQL13.SQL2016\MSSQL'
	,MAXSIZE = 0 MB
	,MAX_ROLLOVER_FILES = 2147483647
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
)

"@
Invoke-Sqlcmd -ServerInstance $Server -Database master -Query $script 

## Add server audit specification

$Script = @"
CREATE SERVER AUDIT SPECIFICATION [ManchesterAuditSpecification]
FOR SERVER AUDIT [ManchesterDemoSQLAudit]
ADD (FAILED_LOGIN_GROUP),
ADD (AUDIT_CHANGE_GROUP),
ADD (BACKUP_RESTORE_GROUP),
ADD (DBCC_GROUP),
ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
ADD (SERVER_PERMISSION_CHANGE_GROUP)
"@
Invoke-Sqlcmd -ServerInstance $Server -Database master -Query $script 

# Create linked server

$script = @"
EXEC master.dbo.sp_addlinkedserver @server = N'MANCHESTERDAVE', @srvproduct=N'SQL Server'
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'MANCHESTERDAVE', @locallogin = NULL , @useself = N'False'
"@
Invoke-Sqlcmd -ServerInstance $Server -Database master -Query $script 

## Create Proxy

$Script = @"
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'ManchesterDemoProxy',@credential_name=N'ManchesterCredential', 
		@enabled=1
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'ManchesterDemoProxy', @subsystem_id=12
"@
Invoke-Sqlcmd -ServerInstance $Server -Database master -Query $script 


$Bolton = Connect-DbaSqlServer -SqlInstance 'Rob-XPS\Bolton'
## Remove all databases from Bolton

foreach($db in $Bolton.Databases.Where{$_.IsSystemObject -eq $false}){
    $db.Name
    $db.DropIfExists()
}

## Remove all logins from Bolton
$exclude = '#MS_PolicyEventProcessingLogin##','##MS_PolicyTsqlExecutionLogin##','NT AUTHORITY\SYSTEM','NT Service\MSSQL$BOLTON','NT SERVICE\SQLAgent$BOLTON','NT SERVICE\SQLTELEMETRY$BOLTON','NT SERVICE\SQLWriter','NT SERVICE\Winmgmt','ROB-XPS\mrrob','sa'
foreach ($login in $Bolton.Logins.Where{$_.Name -notin $exclude}) {
    $Login.Drop()
}

# Remove all jobs from Bolton
$Jobs =  (Get-DbaAgentJob -SqlInstance $Bolton.Name).Where{$_.Name -notlike '*syspolicy*'}
$Jobs.DropIfExists()

# Remove all Alerts from Bolton
$Alerts = Get-DbaAgentAlert -SqlInstance $Bolton.Name
$Alerts.DropIfExists()

## remove Operator form Bolton

$ops = Get-DbaAgentOperator -SqlInstance $BOLTON.Name
$ops.DropIfExists()

## Remove proxy from Bolton
$BOLTON.JobServer.ProxyAccounts['ManchesterDemoProxy'].DropIfExists()

## remove credntials
$creds = $BOLTON.Credentials
$creds | ForEach-Object {$_.DropIfExists()}

## remove audit

(Get-DbaServerAudit -SqlInstance $Bolton.Name).dropifexists()

## remove audit specification

(Get-DbaServerAuditSpecification -SqlInstance $Bolton.Name).dropifexists()

## Remove linked server from bolton

$links = $Bolton.LinkedServers.Where{$_.Name -like '*Manchester*'}
$Links | ForEach-Object {$_.DropIfExists($true)}

## Remove table from DBA-Admin

(Get-DbaTable -SqlInstance Rob-XPS\SQL2016 -Database DBA-Admin -Table ManchesterDemo).Drop() 
<# 
# CLEANUP

$Bolton = Connect-DbaSqlServer -SqlInstance 'Rob-XPS\Bolton'
$SQL2016 = Connect-DbaSqlServer -SqlInstance 'Rob-XPS\SQL2016'

# remove logins

foreach($login in $SQL2016.Logins.Where{$_.Name -like '*ManchesterDemo*'})
{
    $Login.Drop()
}

remove credntials
$sql2016.Credentials['ManchesterCredential'].DropIfExists()

remove audit

(Get-DbaServerAudit -SqlInstance $sql2016.Name).Where{$_.Name -like '*Manchester*'}.dropifexists()

remove audit specification

(Get-DbaServerAuditSpecification -SqlInstance $sql2016.Name).Where{$_.Name -like '*Manchester*'}.dropifexists()

remove linked server

$SQL2016.LinkedServers.Where{$_.Name -like '*Manchester*'}.DropIfExists($true)

remove proxy
$SQL2016.JobServer.ProxyAccounts['ManchesterDemoProxy'].DropIfExists()

#>

<#
.\Setup.exe /SAPWD=Password01  /ConfigurationFile=c:\temp\configurationfile.ini /IACCEPTSQLSERVERLICENSETERMS /QS
#>
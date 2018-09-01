## Create the tables with the sql files

$Testresults = Invoke-DbcCheck -PassThru

Get-DbcCheck | Write-DbaDataTable -SqlInstance $sql0 -Database ValidationResults -Schema dbachecks -Table Checks -Truncate -Confirm:$False -AutoCreateTable

$query = "
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.systemfull) + "' WHERE [Describe] = 'Ola - `$SysFullJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserFull) + "' WHERE [Describe] = 'Ola - `$UserFullJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserDiff) + "' WHERE [Describe] = 'Ola - `$UserDiffJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserLog) + "' WHERE [Describe] = 'Ola - `$UserLogJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.CommandLogCleanup) + "' WHERE [Describe] = 'Ola - `$CommandLogJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.SystemIntegrity) + "' WHERE [Describe] = 'Ola - `$SysIntegrityJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserIntegrity) + "' WHERE [Describe] = 'Ola - `$UserIntegrityJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.UserIndex) + "' WHERE [Describe] = 'Ola - `$UserIndexJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.OutputFileCleanup) + "' WHERE [Describe] = 'Ola - `$OutputFileJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.DeleteBackupHistory) + "' WHERE [Describe] = 'Ola - `$DeleteBackupJobName'
UPDATE [dbachecks].[Checks] SET [Describe] = 'Ola - " + (Get-DbcConfigValue -Name ola.jobname.PurgeBackupHistory) + "' WHERE [Describe] = 'Ola - `$PurgeBackupJobName'
"
Invoke-DbaSqlQuery -SqlInstance $SQL0 -Database ValidationResults -Query $query


$Testresults | Write-DbaDataTable -SqlInstance $Instance -Database $Database -Schema dbachecks -Table Prod_dbachecks_summary_stage -FireTriggers -Truncate -Confirm:$False
$Testresults.TestResult | Write-DbaDataTable -SqlInstance $Instance -Database $Database -Schema dbachecks -Table Prod_dbachecks_detail_stage -FireTriggers -Truncate -Confirm:$False
## Create the tables with the sql files

Invoke-DbaQuery -SqlInstance $sql0 -Database ValidationResults -File '.\create tables and triggers.sql'

## Get the latest checks and put them into the database
Get-DbcCheck | Write-DbaDataTable -SqlInstance $sql0 -Database ValidationResults -Schema dbachecks -Table Checks  -Confirm:$False -AutoCreateTable # if its not the first time add -Truncate

Invoke-DbaQuery -SqlInstance $sql0 -Database ValidationResults -Query "SELECT * FROM dbachecks.Checks"

#region Update the entries for the Ola Job Names to match the configurations
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


Invoke-DbaQuery -SqlInstance $SQL0 -Database ValidationResults -Query $query
#endregion

# Now you can set your checks to run every day and set the results to a variable

$TestResults = Invoke-DbcCheck -SqlInstance $containers -Check FutureFileGrowth -Show None -PassThru

#region Results to staging table
# Write the results to the staging table
$Testresults | Write-DbaDataTable -SqlInstance $sql0 -Database ValidationResults -Schema dbachecks -Table Prod_dbachecks_summary_stage -FireTriggers -Truncate -Confirm:$False
$Testresults.TestResult | Write-DbaDataTable -SqlInstance $sql0 -Database ValidationResults -Schema dbachecks -Table Prod_dbachecks_detail_stage -FireTriggers -Truncate -Confirm:$False

#endregion
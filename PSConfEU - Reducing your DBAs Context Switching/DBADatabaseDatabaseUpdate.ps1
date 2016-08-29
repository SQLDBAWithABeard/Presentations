#requires -Version 2 -Modules SQLPS
<#
    .SYNOPSIS
    This Script will check all of the instances in the InstanceList table and gather the Database properties

    .DESCRIPTION 

    This Script will check all of the instances in the InstanceList and gather the Database name and size and other properties to the Info.Databases table

    .NOTES 

    AUTHOR: Rob Sewell sqldbawithabeard.com 

    DATE: 22/05/2015 - Initial

    - 08/08/2015 - Added noncatactable and inactive to the instance query

#> 

# Load SMO extension

$null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')

 
$LogFile = '\DBADatabaseSQLDatabaseUpdate_' + $Date + '.log'  ## Enter logfile path 
$CentralDBAServer = ''  ## Enter path to server/instance holding hte DBADatabase
$CentralDatabaseName = 'DBADatabase' ## enter the name of the DBA Database
 

<#

    .Synopsis

    Write-Log writes a message to a specified log file with the current time stamp.

    .DESCRIPTION

    The Write-Log function is designed to add logging capability to other scripts.

    In addition to writing output and/or verbose you can write to a log file for

    later debugging.

 

    By default the function will create the path and file if it does not 

    exist. 

    .NOTES

    Created by: Jason Wasser @wasserja

    Modified: 4/3/2015 10:29:58 AM 

 

    Changelog:

    * Renamed LogPath parameter to Path to keep it standard - thanks to @JeffHicks

    * Revised the Force switch to work as it should - thanks to @JeffHicks

 

    To Do:

    * Add error handling if trying to create a log file in a inaccessible location.

    * Add ability to write $Message to $Verbose or $Error pipelines to eliminate

    duplicates.

 

    .EXAMPLE

    Write-Log -Message "Log message" 

    Writes the message to c:\Logs\PowerShellLog.log

    .EXAMPLE

    Write-Log -Message "Restarting Server" -Path c:\Logs\Scriptoutput.log

    Writes the content to the specified log file and creates the path and file specified. 

    .EXAMPLE

    Write-Log -Message "Does not exist" -Path c:\Logs\Script.log -Level Error

    Writes the message to the specified log file as an error message, and writes the message to the error pipeline.

#>

function Write-Log
{
  [CmdletBinding()]

  #[Alias('wl')]

  [OutputType([int])]

  Param

  (

    # The string to be written to the log.

    [Parameter(Mandatory = $true,

        ValueFromPipelineByPropertyName = $true,

    Position = 0)]

    [ValidateNotNullOrEmpty()]

    [Alias('LogContent')]

    [string]$Message,

 

    # The path to the log file.

    [Parameter(Mandatory = $false,

        ValueFromPipelineByPropertyName = $true,

    Position = 1)]

    [Alias('LogPath')]

    [string]$Path = 'C:\Logs\PowerShellLog.log',

 

    [Parameter(Mandatory = $false,

        ValueFromPipelineByPropertyName = $true,

    Position = 3)]

    [ValidateSet('Error','Warn','Info')]

    [string]$Level = 'Info',

 

    [Parameter(Mandatory = $false)]

    [switch]$NoClobber

  )

 

  Begin

  {

  }

  Process

  {

        

    if ((Test-Path $Path) -AND $NoClobber) 
    {
      Write-Warning -Message "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."

      Return
    }

 

    # If attempting to write to a log file in a folder/path that doesn't exist

    # to create the file include path.

    elseif (!(Test-Path $Path)) 
    {
      Write-Verbose -Message "Creating $Path."

      $NewLogFile = New-Item $Path -Force -ItemType File
    }

 

    else 
    {
      # Nothing to see here yet.
    }

 

    # Now do the logging and additional output based on $Level

    switch ($Level) {

      'Error' 
      {
        Write-Error $Message

        Write-Output -InputObject "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ERROR: $Message" | Out-File -FilePath $Path -Append
      }

      'Warn' 
      {
        Write-Warning -Message $Message

        Write-Output -InputObject "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') WARNING: $Message" | Out-File -FilePath $Path -Append
      }

      'Info' 
      {
        Write-Verbose -Message $Message

        Write-Output -InputObject "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') INFO: $Message" | Out-File -FilePath $Path -Append
      }

    }

  }

  End

  {

  }
}

function Catch-Block
{
  param ([string]$Additional)

  $ErrorMessage = " On $Connection " + $Additional + $_.Exception.Message + $_.Exception.InnerException.InnerException.message

  $Message = ' This message came from the Automated Powershell script updating the DBA Database with SQL Information'

  $Msg = $Additional + $ErrorMessage + ' ' + $Message

  Write-Log -Path $LogFile -Message $ErrorMessage -Level Error

  Write-EventLog -LogName Application -Source 'SQLAUTOSCRIPT' -EventId 1 -EntryType Error -Message $Msg
}

$Date = Get-Date -Format ddMMyyyy_HHmmss

# Create Log File
try
{
  New-Item -Path $LogFile -ItemType File
  $Msg = 'New File Created'
  Write-Log -Path $LogFile -Message $Msg
}

catch
{
  $ErrorMessage = $_.Exception.Message
  $FailedItem = $_.Exception.ItemName
  $Message = ' This message came from the Automated Powershell script updating the DBA Database with SQL Information'
  $Msg = $ErrorMessage + ' ' + $FailedItem + ' ' + $Message
  Write-EventLog -LogName Application -Source 'SQLAUTOSCRIPT' -EventId 1 -EntryType Error -Message $Msg
}

Write-Log -Path $LogFile -Message ' Script Started'

$Query = @"
SELECT [ServerName]
      ,[InstanceName]
      ,[Port]
  FROM [DBADatabase].[dbo].[InstanceList]
  Where Inactive = 0 
  AND NotContactable = 0
"@

try
{
  $AlltheServers = Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $CentralDatabaseName -Query $Query
  $ServerNames = $AlltheServers| Select-Object -Property ServerName, InstanceName, Port
}

catch
{
  Catch-Block ' Failed to gather Server and Instance names from the DBA Database'
}

foreach ($ServerName in $ServerNames)
{
  ## $ServerName
  $InstanceName = $ServerName|Select-Object -Property InstanceName -ExpandProperty InstanceName
  $Port = $ServerName| Select-Object -Property Port -ExpandProperty Port
  $ServerName = $ServerName|Select-Object -Property ServerName -ExpandProperty ServerName 
  $Connection = $ServerName + '\' + $InstanceName + ',' + $Port

  try
  {
    $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Connection
  }
  catch
  {
    Catch-Block " Failed to connect to $Connection"
  }

  if (!( $srv.version))
  {
    Catch-Block " Failed to Connect to $Connection"
    continue
  }

  foreach($db in $srv.databases|Where-Object -FilterScript {
      $_.IsSystemObject -eq $false 
  })

  {
    $Name = $db.Name
    $Parent = $db.Parent.Name
    $AutoClose = $db.AutoClose
    $AutoCreateStatisticsEnabled = $db.AutoCreateStatisticsEnabled
    $AutoShrink = $db.AutoShrink
    $AutoUpdateStatisticsEnabled = $db.AutoUpdateStatisticsEnabled
    $AvailabilityDatabaseSynchronizationState = $db.AvailabilityDatabaseSynchronizationState
    $AvailabilityGroupName = $db.AvailabilityGroupName
    $CaseSensitive = $db.CaseSensitive
    $Collation = $db.Collation
    $CompatibilityLevel = $db.CompatibilityLevel
    $CreateDate = $db.CreateDate
    $DataSpaceUsage = $db.DataSpaceUsage
    $EncryptionEnabled = $db.EncryptionEnabled
    $IndexSpaceUsage = $db.IndexSpaceUsage
    $IsAccessible = $db.IsAccessible
    $IsFullTextEnabled = $db.IsFullTextEnabled
    $IsMirroringEnabled = $db.IsMirroringEnabled
    $IsParameterizationForced = $db.IsParameterizationForced
    $IsReadCommittedSnapshotOn = $db.IsReadCommittedSnapshotOn
    $IsUpdateable = $db.IsUpdateable
    $LastBackupDate = $db.LastBackupDate
    $LastDifferentialBackupDate = $db.LastDifferentialBackupDate
    $LastLogBackupDate = $db.LastLogBackupDate
    $Owner = $db.Owner
    $PageVerify = $db.PageVerify
    $ReadOnly = $db.ReadOnly
    $RecoveryModel = $db.RecoveryModel
    $ReplicationOptions = $db.ReplicationOptions
    $Size = $db.Size
    $SnapshotIsolationState = $db.SnapshotIsolationState
    $SpaceAvailable = $db.SpaceAvailable
    $Status = $db.Status
    $TargetRecoveryTime = $db.TargetRecoveryTime  

    # Check if Entry already exists
    try
    {
      $Query = @"
SELECT  D.[DatabaseID]
    FROM [DBADatabase].[Info].[Databases] as D
  JOIN
[DBADatabase].[dbo].[InstanceList] as IL
ON
IL.[InstanceID] = D.InstanceID
   WHERE IL.ServerName = '$ServerName' 
 AND IL.[InstanceName] = '$InstanceName'
AND D.Name = '$Name'
"@

      # $Query
      $Exists = Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $CentralDatabaseName -Query $Query
    }

    catch
    {
      Catch-Block " Failed to gather Instance Name for Exists check $ServerName $InstanceName "
      Break
    }

    if($Exists)
    {
      $Query = @"
UPDATE [Info].[Databases]
   SET 
      [DateChecked] = GetDate()
      ,[AutoClose] = '$AutoClose'
      ,[AutoCreateStatisticsEnabled] = '$AutoCreateStatisticsEnabled'
      ,[AutoShrink] = '$AutoShrink'
      ,[AutoUpdateStatisticsEnabled] = '$AutoUpdateStatisticsEnabled'
      ,[AvailabilityDatabaseSynchronizationState] = '$AvailabilityDatabaseSynchronizationState'
      ,[AvailabilityGroupName] = '$AvailabilityGroupName'
      ,[CaseSensitive] = '$CaseSensitive'
      ,[Collation] = '$Collation'
      ,[CompatibilityLevel] = '$CompatibilityLevel'
      ,[CreateDate] = '$CreateDate'
      ,[DataSpaceUsageKB] = '$DataSpaceUsage'
      ,[EncryptionEnabled] = '$EncryptionEnabled'
      ,[IndexSpaceUsageKB] = '$IndexSpaceUsage'
      ,[IsAccessible] = '$IsAccessible'
      ,[IsFullTextEnabled] = '$IsFullTextEnabled'
      ,[IsMirroringEnabled] = '$IsMirroringEnabled'
      ,[IsParameterizationForced] = '$IsParameterizationForced'
      ,[IsReadCommittedSnapshotOn] = '$IsReadCommittedSnapshotOn'
      ,[IsUpdateable] = '$IsUpdateable'
      ,[LastBackupDate] = '$LastBackupDate'
      ,[LastDifferentialBackupDate] = '$LastDifferentialBackupDate'
      ,[LastLogBackupDate] = '$LastLogBackupDate'
      ,[Owner] = '$Owner'
      ,[PageVerify] = '$PageVerify'
      ,[ReadOnly] = '$ReadOnly'
      ,[RecoveryModel] = '$RecoveryModel'
      ,[ReplicationOptions] = '$ReplicationOptions'
      ,[SizeMB] = '$Size'
      ,[SnapshotIsolationState] = '$SnapshotIsolationState'
      ,[SpaceAvailableKB] = '$SpaceAvailable'
      ,[Status] = '$Status'
      ,[TargetRecoveryTime] = '$TargetRecoveryTime'

      WHERE [InstanceID] = (SELECT InstanceID from dbo.InstanceList WHERE ServerName = '$ServerName' AND InstanceName = '$InstanceName'
      AND [Name] = '$Name')
"@
    }

    else

    {
      $Query = @"
INSERT INTO [Info].[Databases]
           ([InstanceID]
           ,[Name]
           ,[DateAdded]
           ,[DateChecked]
           ,[AutoClose]
           ,[AutoCreateStatisticsEnabled]
           ,[AutoShrink]
           ,[AutoUpdateStatisticsEnabled]
           ,[AvailabilityDatabaseSynchronizationState]
           ,[AvailabilityGroupName]
           ,[CaseSensitive]
           ,[Collation]
           ,[CompatibilityLevel]
           ,[CreateDate]
           ,[DataSpaceUsageKB]
           ,[EncryptionEnabled]
           ,[IndexSpaceUsageKB]
           ,[IsAccessible]
           ,[IsFullTextEnabled]
           ,[IsMirroringEnabled]
           ,[IsParameterizationForced]
           ,[IsReadCommittedSnapshotOn]
           ,[IsUpdateable]
           ,[LastBackupDate]
           ,[LastDifferentialBackupDate]
           ,[LastLogBackupDate]
           ,[Owner]
           ,[PageVerify]
           ,[ReadOnly]
           ,[RecoveryModel]
           ,[ReplicationOptions]
           ,[SizeMB]
           ,[SnapshotIsolationState]
           ,[SpaceAvailableKB]
           ,[Status]
           ,[TargetRecoveryTime])
     VALUES
           ((SELECT InstanceID from dbo.InstanceList WHERE ServerName = '$ServerName' AND InstanceName = '$InstanceName')
           ,'$Name'
           ,GetDate()
           ,GetDate()
           ,'$AutoClose'
           ,'$AutoCreateStatisticsEnabled'
           ,'$AutoShrink'
           ,'$AutoUpdateStatisticsEnabled'
           ,'$AvailabilityDatabaseSynchronizationState'
           ,'$AvailabilityGroupName'
           ,'$CaseSensitive'
           ,'$Collation'
           ,'$CompatibilityLevel'
           ,'$CreateDate'
           ,'$DataSpaceUsage'
           ,'$EncryptionEnabled'
           ,'$IndexSpaceUsage'
           ,'$IsAccessible'
           ,'$IsFullTextEnabled'
           ,'$IsMirroringEnabled'
           ,'$IsParameterizationForced'
           ,'$IsReadCommittedSnapshotOn'
           ,'$IsUpdateable'
           ,'$LastBackupDate'
           ,'$LastDifferentialBackupDate'
           ,'$LastLogBackupDate'
           ,'$Owner'
           ,'$PageVerify'
           ,'$ReadOnly'
           ,'$RecoveryModel'
           ,'$ReplicationOptions'
           ,'$Size'
           ,'$SnapshotIsolationState'
           ,'$SpaceAvailable'
           ,'$Status'
           ,'$TargetRecoveryTime'
                 )
"@
    }

    try
    {
      # $Query
      Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $CentralDatabaseName -Query $Query -ErrorAction Stop
    }

    catch
    {
      Catch-Block " Failed to insert information for $Name on $Connection $Query"
    }
  }

  $Msg = " Info added for $Connection"
  Write-Log -Path $LogFile -Message $Msg
}

Write-Log -Path $LogFile -Message 'Script Finished'
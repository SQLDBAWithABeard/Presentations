#requires -Version 2 -Modules sqlps
<# 
    .SYNOPSIS  
    This Script will check all of the instances in the InstanceList and gather SQL Configuration Info and save to the Info.SQLInfo table

    .DESCRIPTION 
    This Script will check all of the instances in the InstanceList and gather SQL Configuration Info and save to the Info.SQLInfo table

    .PARAMETER 

    .EXAMPLE 



    .NOTES 
    AUTHOR: Rob Sewell sqldbawithabeard.com 
    DATE: 22/05/2015 - Initial
    21/07/2015 - Added Inactive column to gather instances query
#> 


# Load SMO extension
$null = [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')

$CentralDBAServer = 'sql2014ser12r2' ## Add the address of the instance that holds the DBADatabase
$CentralDatabaseName = 'DBADatabase'
$Date = Get-Date -Format ddMMyyyy_HHmmss
$LogFile = 'C:\temp\DBADatabaseServerUpdate_' + $Date + '.log' ## Set Path to Log File

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
"@

try
{
  $AlltheServers = Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database DBADatabase -Query $Query
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
    continue
  }
  if (!( $srv.version))
  {
    Catch-Block " Failed to Connect to $Connection"
    continue
  }
  if ($srv.IsHadrEnabled -eq $true)
  {
    $IsHADREnabled = $true
    $AGs = $srv.AvailabilityGroups|
    Select-Object -Property Name -ExpandProperty Name|
    Out-String
  }
  else
  {
    $IsHADREnabled = $false
  }
  $BAckupDirectory = $srv.BackupDirectory
  $BrowserAccount = $srv.BrowserServiceAccount
  $BrowserStartMode = $srv.BrowserStartMode
  $IsSQLClustered = $srv.IsClustered # is sqlclustered
  $ClusterName = $srv.ClusterName
  $ClusterQuorumstate = $srv.ClusterQuorumState
  $ClusterQuorumType = $srv.ClusterQuorumType
  $Collation = $srv.Collation
  $C2AuditMode = $srv.Configuration.C2AuditMode.ConfigValue
  $CostThresholdForParallelism = $srv.Configuration.CostThresholdForParallelism.ConfigValue
  $MaxDegreeOfParallelism = $srv.Configuration.MaxDegreeOfParallelism.ConfigValue
  $DBMailEnabled = $srv.Configuration.DatabaseMailEnabled.ConfigValue
  $DefaultBackupCComp = $srv.Configuration.DefaultBackupCompression.ConfigValue
  $FillFactor = $srv.Configuration.FillFactor.ConfigValue
  $MaxMem = $srv.Configuration.MaxServerMemory.ConfigValue
  $MinMem = $srv.Configuration.MinServerMemory.ConfigValue
  $RemoteDacEnabled = $srv.Configuration.RemoteDacConnectionsEnabled.ConfigValue
  $XPCmdShellEnabled = $srv.Configuration.XPCmdShellEnabled.ConfigValue
  $CommonCriteriaComplianceEnabled = $srv.Configuration.CommonCriteriaComplianceEnabled.ConfigValue
  $DefaultFile = $srv.DefaultFile
  $DefaultLog = $srv.DefaultLog
  $Edition = $srv.Edition
  $HADREndpointPort = ($srv.Endpoints|Where-Object -FilterScript {
      $_.EndpointType -eq 'DatabaseMirroring'
  }).Protocol.Tcp.ListenerPort 
  if(!$HADREndpointPort)
  {
    $HADREndpointPort = '0'
  }
  $ErrorLogPath = $srv.ErrorLogPath
  $InstallDataDirectory = $srv.InstallDataDirectory
  $InstallSharedDirectory = $srv.InstallSharedDirectory
  $IsCaseSensitive = $srv.IsCaseSensitive
  $IsFullTextInstalled = $srv.IsFullTextInstalled
  $LinkedServer = $srv.LinkedServers
  $LoginMode = $srv.LoginMode
  $MasterDBLogPath = $srv.MasterDBLogPath
  $MasterDBPath = $srv.MasterDBPath
  $NamedPipesEnabled = $srv.NamedPipesEnabled
  $ServicePack = $srv.ProductLevel
  $ServerType = $srv.ServerType
  $SQLServiceAccount = $srv.ServiceAccount
  $SQLService = $srv.ServiceName
  $SQLServiceStartMode = $srv.ServiceStartMode
  $VersionString = $srv.VersionString
  if($VersionString.split('.')[0] -eq 8)
  {
    $Version = 'SQL 2000'
  }
  if($VersionString.split('.')[0] -eq 9)
  {
    $Version = 'SQL 2005'
  }
  if($VersionString.split('.')[0] -eq 10 -and $VersionString.split('.')[1] -eq 0)
  {
    $Version = 'SQL 2008'
  }
  if($VersionString.split('.')[0] -eq 10 -and $VersionString.split('.')[1] -eq 50)
  {
    $Version = 'SQL 2008 R2'
  }
  if($VersionString.split('.')[0] -eq 11)
  {
    $Version = 'SQL 2012'
  }
  if($VersionString.split('.')[0] -eq 12)
  {
    $Version = 'SQL 2014'
  }
  $OptimizeAdhocWorkloads = $srv.Configuration.OptimizeAdhocWorkloads.ConfigValue

  try
  {
    $Exists = Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database DBADatabase -Query "SELECT [ServerName] ,[InstanceName]FROM [DBADatabase].[Info].[SQLInfo] WHERE ServerName = '$ServerName' AND [InstanceName] = '$InstanceName'"
  }
  catch
  {
    Catch-Block " Failed to gather Instance Name for Exists check $ServerName $InstanceName "
    Break
  }
  if ($Exists)
  {
    Write-Log -Path $LogFile -Message "Updating SQL Info for $ServerName $InstanceName"
    $Query = @"
USE [DBADatabase]
GO

UPDATE [Info].[SQLInfo]
   SET [DateChecked] = GetDate()
      ,[ServerName] = '$ServerName'
      ,[InstanceName] = '$InstanceName'
      ,[SQLVersionString] =  '$VersionString'
      ,[SQLVersion] = '$Version'
      ,[ServicePack] = '$ServicePack'
      ,[Edition] = '$Edition'
      ,[ServerType] = '$ServerType'
      ,[Collation] = '$Collation'
      ,[IsHADREnabled] = '$IsHADREnabled'
      ,[SQLServiceAccount] = '$SQLServiceAccount'
      ,[SQLService] = '$SQLService'
      ,[SQLServiceStartMode] = '$SQLServiceStartMode'
      ,[BAckupDirectory] = '$BAckupDirectory'
      ,[BrowserAccount] = '$BrowserAccount'
      ,[BrowserStartMode] = '$BrowserStartMode'
      ,[IsSQLClustered] = '$IsSQLClustered'
      ,[ClusterName] = '$ClusterName'
      ,[ClusterQuorumstate] = '$ClusterQuorumstate'
      ,[ClusterQuorumType] = '$ClusterQuorumType'
      ,[C2AuditMode] = '$C2AuditMode'
      ,[CostThresholdForParallelism] = '$CostThresholdForParallelism'
      ,[MaxDegreeOfParallelism] = '$MaxDegreeOfParallelism'
      ,[DBMailEnabled] = '$DBMailEnabled'
      ,[DefaultBackupCComp] = '$DefaultBackupCComp'
      ,[FillFactor] = '$FillFactor'
      ,[MaxMem] = '$MaxMem'
      ,[MinMem] = '$MinMem'
      ,[RemoteDacEnabled] = '$RemoteDacEnabled'
      ,[XPCmdShellEnabled] =  '$XPCmdShellEnabled'
      ,[CommonCriteriaComplianceEnabled] = '$CommonCriteriaComplianceEnabled'
      ,[DefaultFile] = '$DefaultFile'
      ,[DefaultLog] = '$DefaultLog'
      ,[HADREndpointPort] = $HADREndpointPort
      ,[ErrorLogPath] = '$ErrorLogPath'
      ,[InstallDataDirectory] = '$InstallDataDirectory'
      ,[InstallSharedDirectory] = '$InstallSharedDirectory'
      ,[IsCaseSensitive] = '$IsCaseSensitive'
      ,[IsFullTextInstalled] = '$IsFullTextInstalled'
      ,[LinkedServer] = '$LinkedServer'
      ,[LoginMode] = '$LoginMode'
      ,[MasterDBLogPath] = '$MasterDBLogPath'
      ,[MasterDBPath] = '$MasterDBPath'
      ,[NamedPipesEnabled] = '$NamedPipesEnabled'
      ,[OptimizeAdhocWorkloads] = '$OptimizeAdhocWorkloads' 
WHERE ServerName = '$ServerName' AND [InstanceName] = '$InstanceName'
GO
"@
  }
  else
  {
    Write-Log -Path $LogFile -Message "Inserting SQL Info for $ServerName $InstanceName"
    $Query = @"
USE [DBADatabase]
GO

INSERT INTO [Info].[SQLInfo]
           ([DateChecked]
            ,[DateAdded]
           ,[ServerName]
           ,[InstanceName]
           ,[SQLVersionString]
           ,[SQLVersion]
           ,[ServicePack]
           ,[Edition]
           ,[ServerType]
           ,[Collation]
           ,[IsHADREnabled]
           ,[SQLServiceAccount]
           ,[SQLService]
           ,[SQLServiceStartMode]
           ,[BAckupDirectory]
           ,[BrowserAccount]
           ,[BrowserStartMode]
           ,[IsSQLClustered]
           ,[ClusterName]
           ,[ClusterQuorumstate]
           ,[ClusterQuorumType]
           ,[C2AuditMode]
           ,[CostThresholdForParallelism]
           ,[MaxDegreeOfParallelism]
           ,[DBMailEnabled]
           ,[DefaultBackupCComp]
           ,[FillFactor]
           ,[MaxMem]
           ,[MinMem]
           ,[RemoteDacEnabled]
           ,[XPCmdShellEnabled]
           ,[CommonCriteriaComplianceEnabled]
           ,[DefaultFile]
           ,[DefaultLog]
           ,[HADREndpointPort]
           ,[ErrorLogPath]
           ,[InstallDataDirectory]
           ,[InstallSharedDirectory]
           ,[IsCaseSensitive]
           ,[IsFullTextInstalled]
           ,[LinkedServer]
           ,[LoginMode]
           ,[MasterDBLogPath]
           ,[MasterDBPath]
           ,[NamedPipesEnabled]
           ,[OptimizeAdhocWorkloads])
     VALUES
           (GetDate()
           ,GetDate()
           ,'$ServerName'
           ,'$InstanceName'
           ,'$VersionString'
           ,'$Version'
           ,'$ServicePack'
           ,'$Edition'
           ,'$ServerType'
           ,'$Collation'
           ,'$IsHADREnabled'
           ,'$SQLServiceAccount'
           ,'$SQLService'
           ,'$SQLServiceStartMode'
           ,'$BAckupDirectory'
           ,'$BrowserAccount'
           ,'$BrowserStartMode'
           ,'$IsSQLClustered'
           ,'$ClusterName'
           ,'$ClusterQuorumstate'
           ,'$ClusterQuorumType'
           ,'$C2AuditMode'
           ,'$CostThresholdForParallelism'
           ,'$MaxDegreeOfParallelism'
           ,'$DBMailEnabled'
           ,'$DefaultBackupCComp'
           ,'$FillFactor'
           ,'$MaxMem'
           ,'$MinMem'
           ,'$RemoteDacEnabled'
           ,'$XPCmdShellEnabled'
           ,'$CommonCriteriaComplianceEnabled'
           ,'$DefaultFile'
           ,'$DefaultLog'
           ,'$HADREndpointPort'
           ,'$ErrorLogPath'
           ,'$InstallDataDirectory'
           ,'$InstallSharedDirectory'
           ,'$IsCaseSensitive'
           ,'$IsFullTextInstalled'
           ,'$LinkedServer'
           ,'$LoginMode'
           ,'$MasterDBLogPath'
           ,'$MasterDBPath'
           ,'$NamedPipesEnabled'
           ,'$OptimizeAdhocWorkloads' )
GO
"@
  }
  #$query
  try
  {
    Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database DBADatabase -Query $Query -ErrorAction Stop
    Write-Log -Path $LogFile -Message "DBA Database updated for $ServerName $InstanceName"
  }
  catch
  {
    Catch-Block 'Failed to add info to DBA Database'
    Write-Log -Path $LogFile -Message "Query -- $Query"
  }
}

Write-Log -Path $LogFile -Message 'Script Finished'
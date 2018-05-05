<# 
.NOTES 
    Name: agent job results to DBA Database.ps1 
    Author: Rob Sewell http://sqldbawithabeard.com
    Requires: 
    Version History: 
                    Version 0.1 - Gathered code from Email agents job script and added write-log 
                    Version 1 - Added not contactable to the server list query
    
.SYNOPSIS 
    Adds data to the DBA database for agent job results in a server list 

.DESCRIPTION 
    Connects to a server list and iterates though reading the agent job results and adds data to the DBA Database - This is run as an agent job on 
#> 

# Load SMO extension
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo') | Out-Null;
$Date = Get-Date -Format ddMMyyyy_HHmmss

# Server List Details

Import-Module sqlps -DisableNameChecking

$CentralDBAServer = ''
$DBADatabase = 'DBADatabase'
$LogFile= '\DBADatabase_Agent_Job_Update_' + $Date +  '.log'

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
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('LogContent')]
        [string]$Message,

        # The path to the log file.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [Alias('LogPath')]
        [string]$Path='C:\Logs\PowerShellLog.log',

        [Parameter(Mandatory=$false,
                    ValueFromPipelineByPropertyName=$true,
                    Position=3)]
        [ValidateSet('Error','Warn','Info')]
        [string]$Level='Info',

        [Parameter(Mandatory=$false)]
        [switch]$NoClobber
    )

    Begin
    {
    }
    Process
    {
        
        if ((Test-Path $Path) -AND $NoClobber) {
            Write-Warning "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."
            Return
            }

        # If attempting to write to a log file in a folder/path that doesn't exist
        # to create the file include path.
        elseif (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            $NewLogFile = New-Item $Path -Force -ItemType File
            }

        else {
            # Nothing to see here yet.
            }

        # Now do the logging and additional output based on $Level
        switch ($Level) {
            'Error' {
                Write-Error $Message
                Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ERROR: $Message" | Out-File -FilePath $Path -Append
                }
            'Warn' {
                Write-Warning $Message
                Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') WARNING: $Message" | Out-File -FilePath $Path -Append
                }
            'Info' {
                Write-Verbose $Message
                Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') INFO: $Message" | Out-File -FilePath $Path -Append
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
$ErrorMessage = " On $Connection or $ServerName " + $Additional + $_.Exception.Message + $_.Exception.InnerException.InnerException.message
$Message = ' This message came from the Automated Powershell script updating the DBA Database with Agent Job Information'
$Msg = $Additional + $ErrorMessage + ' ' + $Message
Write-Log -Path $LogFile -Message $ErrorMessage -Level Error
Write-EventLog -LogName Application -Source 'SQLAUTOSCRIPT' -EventId 1 -EntryType Error -Message $Msg
}

# Create Log File

try{
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


Write-Log -Path $LogFile -Message 'Script Started'

 $Query = @"
 SELECT [ServerName]
      ,[InstanceName]
      ,[Port]
  FROM [DBADatabase].[dbo].[InstanceList]
  Where Inactive = 0 
  AND NotContactable = 0
"@

$CentralDBAServer = 'AOLI-SYSTEM-DBA,54703'
$DBADatabase = 'DBADatabase'

try{
$AlltheServers= Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $DBADatabase -Query $query
$ServerNames = $AlltheServers| Select-Object ServerName,InstanceName,Port
Write-Log -Path $LogFile -Message 'Collected ServerNames from DBA Database'
}
catch
{
Catch-Block ' Failed to gather Server and Instance names from the DBA Database'
}

foreach ($ServerName in $ServerNames)
{
 $InstanceName =  $ServerName|Select-Object InstanceName -ExpandProperty InstanceName
 $Port = $ServerName| Select-Object Port -ExpandProperty Port
$ServerName = $ServerName|Select-Object ServerName -ExpandProperty ServerName 
 $Connection = $ServerName + '\' + $InstanceName + ',' + $Port
Write-Log -Path $LogFile -Message "Gathering Information from $Connection"
 try
 {
 $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Connection
 }
catch
{
Catch-Block " Failed to connect to $Connection"
continue
}
 if (!( $srv.version)){
 Catch-Block " Failed to Connect to $Connection"
 continue
 }
 $edition = $srv.Edition
 if($Edition -eq 'Express')
 {
 Write-Log -Path $LogFile -Message "No Information gathered as this $Connection is Express"
 continue
 }


try{
$JobCount = $srv.JobServer.jobs.Count
$successCount = 0
$failedCount = 0
$UnknownCount = 0
$JobsDisabled =0
   # For each jobs on the server
      foreach($job in $srv.JobServer.Jobs)
      {
            $jobName = $job.Name;
            $jobEnabled = $job.IsEnabled;
            $jobLastRunOutcome = $job.LastRunOutcome;
            $Category = $Job.Category;
            $RunStatus = $Job.CurrentRunStatus;
            $Time = $job.LastRunDate ;
            if ($Time -eq '01/01/0001 00:00:00')
            {
            $Time = ''
            }

             $Description = $Job.Description;
            # Counts for Failed jobs

            if($jobEnabled -eq $False)
            {
            $JobsDisabled += 1
           }
            elseif($jobLastRunOutcome -eq 'Failed')
            {
             $failedCount += 1;
            }
            elseif ($jobLastRunOutcome -eq 'Succeeded')
            {
             $successCount += 1;
            }
             elseif ($jobLastRunOutcome -eq 'Unknown')
            {
             $UnknownCount += 1;
           }

if($Description -eq $null){$Description = ' '}
$Description = $Description.replace('''','''''')
if($jobName -eq $Null){$jobName = 'None'}
$JobName = $JobName.replace('''','''''')
$Query = @"
IF NOT EXISTS (
SELECT  [AgetnJobDetailID]
  FROM [DBADatabase].[Info].[AgentJobDetail]
  where jobname = '$jobName'
  and InstanceID = (SELECT [InstanceID]
  FROM [DBADatabase].[dbo].[InstanceList]
  WHERE [ServerName] = '$ServerName'
  AND [InstanceName] = '$InstanceName'
  AND [Port] = '$Port')
  and lastruntime = '$Time'
  )
INSERT INTO [Info].[AgentJobDetail]
           ([Date]
           ,[InstanceID]
           ,[Category]
           ,[JobName]
           ,[Description]
           ,[IsEnabled]
           ,[Status]
           ,[LastRunTime]
           ,[Outcome])
     VALUES
           (GetDate()
           ,(SELECT [InstanceID]
  FROM [DBADatabase].[dbo].[InstanceList]
  WHERE [ServerName] = '$ServerName'
  AND [InstanceName] = '$InstanceName'
  AND [Port] = '$Port')
           ,'$Category'
           ,'$jobName'
           ,'$Description'
           ,'$jobEnabled'
           ,'$RunStatus'
           ,'$Time'
           ,'$jobLastRunOutcome')
"@
# $Query
try{
Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $DBADatabase -Query $query -ErrorAction Stop
}
catch
{Catch-Block "Failed to add info for $Jobname on $Connection to DBA Database"
Write-Log -Path $LogFile -Message "Query -- $Query"}

}
$Query = @"
INSERT INTO [Info].[AgentJobServer]
           ([Date]
           ,[InstanceID]
           ,[NumberOfJobs]
           ,[SuccessfulJobs]
           ,[FailedJobs]
           ,[DisabledJobs]
		   ,[UnknownJobs])
     VALUES
           (GetDate()
           ,(SELECT [InstanceID]
  FROM [DBADatabase].[dbo].[InstanceList]
  WHERE [ServerName] = '$ServerName'
  AND [InstanceName] = '$InstanceName'
  AND [Port] = '$Port')
           ,'$JobCount'
           ,'$successCount'
           ,'$failedCount'
           ,'$JobsDisabled'
		   ,'$UnknownCount')
"@
## $Query
try{
Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $DBADatabase -Query $query -ErrorAction Stop
Write-Log -Path $LogFile -Message "DBA Database updated for $Connection"
}
catch
{
Catch-Block 'Failed to add info to DBA Database'
Write-Log -Path $LogFile -Message "Query -- $Query"
}

Write-Log -Path $LogFile -Message "Succeeded Gathering Information from $Connection and adding to DBA Database"
}
catch
{
Catch-Block "Failed to gather jobs from $Connection"
}
}
Write-Log -Path $LogFile -Message 'Script Finished'
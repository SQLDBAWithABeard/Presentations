## This will take a full backup of the logshipping databases and restore it onto the Destination Server and run the LogShipping Agent Jobs
## if the ls alert jobs are failing and you dont want to try and move the transaction log backups or have run a backup on the source server 
## and broken the log chain

## requires Powershell version 4 or above and at least the July 2016 release of SSMS to have been installed

function Restore-LogShippingDatabase
{
[CmdletBinding(SupportsShouldProcess = $true)]
param (
[Parameter(Mandatory = $true)]
[Alias("SourceServer","Server","SQLServer")] 
[string]$SourceInstance,
[Parameter(Mandatory = $true)]
[Alias("DestinationServer","DestServer")] 
[string]$DestinationInstance,
[Parameter(Mandatory = $true)]
[Alias("Database")] 
[string]$DBName ,
[Parameter(Mandatory = $true)]
[Alias("Share")] 
[string]$BackupShare
)
## This Powershell requires the July 2016 or later version of SSMS 2016 to have been installed 
$Date = Get-Date -Format 'dd-MM-yyyy-hh-mm-ss'
#Location of the log file
$LogFile = "c:\temp\LogShippingResolve_$Date.txt"

if(!(Test-Path $LogFile))
{
#create the log file if it doesnt exist 
If ($Pscmdlet.ShouldProcess($ENV:COMPUTERNAME, "Create $LogFile"))
    {
        New-Item $LogFile -ItemType File
    }
}
## This is the function that will write out to the screen the message and also to the log file
function Write-Message
    {
    param($Message)
    $Date =  Get-Date -Format 'dd-MM-yyyy HH:mm:ss'
    $msg = "$Date  : " + $Message 
    $msg | Out-File -FilePath $LogFile -Append
    Write-Output $msg
    }
## This is the function that will write out to the screen the errors and also to the log file
function Write-WarningMessage
    {
    param($Message)
     $Date =  Get-Date -Format 'dd-MM-yyyy HH:mm:ss'      
     $msg = "$Date : " + $Message 
     $msg | Out-File -FilePath $LogFile -Append   
     Write-Warning $msg
     $_ |Format-List -Force|Out-File -FilePath $LogFile -Append
     $_ |Format-List -Force
    }
## This is the function to run the agent Jobs
function Start-SQLAgentJob
    {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param($Instance,$Name,$Sleep = 10)
    $Job     = (get-sqlagentjob -ServerInstance $Instance).Where{$_.Name -like $Name}
    $JobName = $Job.Name
    If ($Pscmdlet.ShouldProcess($Instance, "Run $JobName"))
    {
        if($Job.CurrentRunStatus -eq 'Executing')
            {
            $Job.Stop()
            }
        (Get-SqlAgentJob -ServerInstance $Instance -Name $JobName).Start()
        Write-Message "Started $JobName on $Instance"
        Start-Sleep -Seconds 1
    }
    $Job = Get-SqlAgentJob -ServerInstance $Instance -Name $JobName
	$Status = $Job.CurrentRunStatus
	While ($Status -ne 'Idle')
	{
		Write-Output "$JobName on $Instance is $Status"
		$Job.Refresh()
		$Status = $Job.CurrentRunStatus
		Start-Sleep -Seconds $Sleep
	}
    }
## Load pre-reqs
try
{
    Import-Module sqlserver
    [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO'); 
    [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended'); 
}
catch
{
Write-WarningMessage -Message "Failed to load the required modules - please resolve - Script Aborting"
notepad $LogFile
break
}
# Backup the database on the source server
try
{
    $Backup = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Backup
    $Backup.Action = [Microsoft.SQLServer.Management.SMO.BackupActionType]::Database
    $Backup.BackupSetDescription = "Final Full Backup of $DBName Prior to Dropping"
    $Backup.Database = $DBName
    $Backup.Checksum = $True
    if ($SourceInstance.versionMajor -gt 9)
    {
            If($srv.Configuration.DefaultBackupCompression.RunValue = 1)
            {
                $Backup.CompressionOption = $true
            }
            else
            {
               $Backup.CompressionOption = $false 
            }
		}
    $BackupFileName = $BackupShare + '\' + $DbName + '_For_LogShipping_Jobs_' + [DateTime]::Now.ToString('yyyyMMdd_HHmmss') + '.bak'
    $DeviceType = [Microsoft.SqlServer.Management.Smo.DeviceType]::File
    $BackupDevice = New-Object -TypeName Microsoft.SQLServer.Management.Smo.BackupDeviceItem($BackupFileName, $DeviceType)
    $Backup.Devices.Add($BackupDevice)
    #Progress
    $percent = [Microsoft.SqlServer.Management.Smo.PercentCompleteEventHandler] {
     	Write-Progress -id 1 -activity "Backing up database $DBName on $SourceInstance to $BackupFileName" -percentcomplete $_.Percent -status ([System.String]::Format("Progress: {0} %", $_.Percent))
     }
    $Backup.add_PercentComplete($percent)
    $Backup.add_Complete($complete)
    If ($Pscmdlet.ShouldProcess($SourceInstance, "Back up $DBName"))
    {
        Write-Progress -id 1 -activity "Backing up database $DBName on $SourceInstance to $BackupFileName" -percentcomplete 0 -status ([System.String]::Format("Progress: {0} %", 0))
        $Backup.SqlBackup($SourceInstance)
        $Backup.Devices.Remove($BackupDevice)
        Write-Progress -id 1 -activity "Backing up database $DBName  on $SourceInstance to $BackupFileName" -status "Complete" -Completed
        Write-Message "Backup Completed for $DBName on $SourceInstance "
    }
}
catch
{
	Write-WarningMessage -Message "FAILED : To backup database $DBName on $SourceServer - Aborting"
    notepad $LogFile
	break
} # End Backup
# Restore the database on the destination server with no recovery
try
{
        $restore = New-Object 'Microsoft.SqlServer.Management.Smo.Restore'
        $restore.ReplaceDatabase = $true
        $percent = [Microsoft.SqlServer.Management.Smo.PercentCompleteEventHandler] {
        						Write-Progress -id 1 -activity "Restoring $dbname to $SQLServername" -percentcomplete $_.Percent -status ([System.String]::Format("Progress: {0} %", $_.Percent))
        					}
        $restore.add_PercentComplete($percent)
        $restore.PercentCompleteNotification = 1
        $restore.add_Complete($complete)
        $restore.ReplaceDatabase = $true
        $restore.Database = $dbname
        $restore.Action = [Microsoft.SqlServer.Management.Smo.RestoreActionType]::Files
        $restore.NoRecovery = $true
        $device = New-Object -TypeName Microsoft.SqlServer.Management.Smo.BackupDeviceItem
        $device.name = $BackupFileName
        $device.devicetype = 'File'
        $restore.Devices.Add($device)     
        If ($Pscmdlet.ShouldProcess($DestinationInstance, "Restore $DBName"))
        {
            Write-Progress -id 1 -activity "Restoring $dbname to $DestinationInstance" -percentcomplete 0 -status ([System.String]::Format("Progress: {0} %", 0))
            $restore.sqlrestore($DestinationInstance)
            Write-Progress -id 1 -activity "Restoring $dbname to $DestinationInstance" -status 'Complete' -Completed
            Write-Message "Restore Completed for $DBName on $DestinationInstance "
        }
}
catch
{
	Write-WarningMessage -Message "FAILED : To restore database $DBName on $DestinationInstance - Aborting"
    notepad $LogFile
	break
}
# Run the LS backup job
try
{
    Start-SQLAgentJob -Instance $SourceInstance -Name "LsBackup*$dbname" -Sleep 1
}
catch
{
    Write-WarningMessage -Message "FAILED : LSBackup Job failed on $DestinationInstance"
	break
}
if((Get-SqlAgentJob -ServerInstance $SourceInstance).Where{$_.Name -like "LsBackup*$dbname"}.LastRunOutcome -eq 'Succeeded')
{
Write-Message -Message "LSBackup Job Succeeded"
}
else
{
Write-WarningMessage -Message "FAILED : LSBackup Job Failed - Please check $SourceInstance"
notepad $Logfile
break
}

# run the LS copy job
try
{
    Start-SQLAgentJob -Instance $DestinationInstance -Name "Lscopy*$dbname" -Sleep 1
}
catch
{
    Write-WarningMessage -Message "FAILED : LSCopy Job failed on $DestinationInstance"
	break
}
if((Get-SqlAgentJob -ServerInstance $DestinationInstance).Where{$_.Name -like "Lscopy*$dbname"}.LastRunOutcome -eq 'Succeeded')
{
Write-Message -Message "LSCopy Job Succeeded"
}
else
{
Write-WarningMessage -Message "FAILED : LSCopy JOb Failed - Please check $SourceInstance"
notepad $Logfile
break
}
# run the LS restore job
try
{
    Start-SQLAgentJob -Instance $DestinationInstance -Name "Lsrestore*$dbname" -Sleep 1
}
catch
{
    Write-WarningMessage -Message "FAILED : LSRestore Job failed on $DestinationInstance"
	break
}
if((Get-SqlAgentJob -ServerInstance $DestinationInstance).Where{$_.Name -like "Lsrestore*$dbname"}.LastRunOutcome -eq 'Succeeded')
{
Write-Message -Message "LSrestore Job Succeeded"
}
else
{
Write-WarningMessage -Message "FAILED : LSrestore JOb Failed - Please check $SourceInstance"
notepad $Logfile
break
}
# run the LS Alert job
try
{    
    Start-SQLAgentJob -Instance $DestinationInstance -Name "Lsalert*" -Sleep 1
}
catch
{
    Write-WarningMessage -Message "FAILED : LSAlert Job failed on $DestinationInstance"
	break
}
if((Get-SqlAgentJob -ServerInstance $DestinationInstance).Where{$_.Name -like  "Lsalert*"}.LastRunOutcome -eq 'Succeeded')
{
Write-Message -Message "LSAlert Job Succeeded"
}
else
{
Write-WarningMessage -Message "FAILED : LSAlert Job Failed - Please check $SourceInstance"
notepad $Logfile
break
}
    If ($Pscmdlet.ShouldProcess($ENV:COMPUTERNAME, "Open LogFile $LogFile"))
    {
    Write-Message "Script Ended"
    notepad $LogFile
    }
}


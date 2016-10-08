 <# 
.SYNOPSIS  
     Daily Script to automate install and update of required SQL Server Estate 

.DESCRIPTION 
    This script is to run as a job on the admin server (XXXX) and will inspect the ScriptInstall database on the server for any update flags and take the appropriate action

.PARAMETER 

.EXAMPLE 

.NOTES 
    AUTHOR: Rob Sewell sqldbawithabeard.com 
    DATE: 1/05/2015 - Initial
			20/07/2015 - Altered Update-InstancesWithScript function to include query - added new scripts AlterOlaIndex

   $File = gci \\\LogFiles\autoserverupdate*|Sort-Object Lastwritetime -desc|select -first 1
   Get-Content -Path  -Tail 1 -Wait
#> 

$CentralDBAServer = 'ROB-SURFACEBOOK'
$CentralDBADatabase = 'ScriptInstall'
$DBAAdminDatabase = 'master' # This can be a DBA-Admin type database if required
$Date = Get-Date -Format ddMMyyyy_HHmmss
$LogFile = 'C:\MSSQL\Scriptlog\AutoScriptInstall__' + $Date + '.log' 

# To Load SQL Server Management Objects into PowerShell
   [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')  | out-null
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended')  | out-null

<# 
.SYNOPSIS 
Runs a T-SQL script. 
.DESCRIPTION 
Runs a T-SQL script. Invoke-Sqlcmd2 only returns message output, such as the output of PRINT statements when -verbose parameter is specified 
.INPUTS 
None 
    You cannot pipe objects to Invoke-Sqlcmd2 
.OUTPUTS 
   System.Data.DataTable 
.EXAMPLE 
Invoke-Sqlcmd2 -ServerInstance "MyComputer\MyInstance" -Query "SELECT login_time AS 'StartTime' FROM sysprocesses WHERE spid = 1" 
This example connects to a named instance of the Database Engine on a computer and runs a basic T-SQL query. 
StartTime 
----------- 
2010-08-12 21:21:03.593 
.EXAMPLE 
Invoke-Sqlcmd2 -ServerInstance "MyComputer\MyInstance" -InputFile "C:\MyFolder\tsqlscript.sql" | Out-File -filePath "C:\MyFolder\tsqlscript.rpt" 
This example reads a file containing T-SQL statements, runs the file, and writes the output to another file. 
.EXAMPLE 
Invoke-Sqlcmd2  -ServerInstance "MyComputer\MyInstance" -Query "PRINT 'hello world'" -Verbose 
This example uses the PowerShell -Verbose parameter to return the message output of the PRINT command. 
VERBOSE: hello world 
.NOTES 
Version History 
v1.0   - Chad Miller - Initial release 
v1.1   - Chad Miller - Fixed Issue with connection closing 
v1.2   - Chad Miller - Added inputfile, SQL auth support, connectiontimeout and output message handling. Updated help documentation 
v1.3   - Chad Miller - Added As parameter to control DataSet, DataTable or array of DataRow Output type 
#> 
function Invoke-Sqlcmd2 
{ 
    [CmdletBinding()] 
    param( 
    [Parameter(Position=0, Mandatory=$true)] [string]$ServerInstance, 
    [Parameter(Position=1, Mandatory=$false)] [string]$Database, 
    [Parameter(Position=2, Mandatory=$false)] [string]$Query, 
    [Parameter(Position=3, Mandatory=$false)] [string]$Username, 
    [Parameter(Position=4, Mandatory=$false)] [string]$Password, 
    [Parameter(Position=5, Mandatory=$false)] [Int32]$QueryTimeout=600, 
    [Parameter(Position=6, Mandatory=$false)] [Int32]$ConnectionTimeout=15, 
    [Parameter(Position=7, Mandatory=$false)] [string]$InputFile, 
    [Parameter(Position=8, Mandatory=$false)] [ValidateSet('DataSet', 'DataTable', 'DataRow')] [string]$As='DataRow' 
    ) 
 
    if ($InputFile) 
    { 
        $filePath = $(Resolve-Path $InputFile).path 
        $Query =  [System.IO.File]::ReadAllText("$filePath") 
    } 
 
    $conn=new-object System.Data.SqlClient.SQLConnection 
      
    if ($Username) 
    { $ConnectionString = 'Server={0};Database={1};User ID={2};Password={3};Trusted_Connection=False;Connect Timeout={4}' -f $ServerInstance,$Database,$Username,$Password,$ConnectionTimeout } 
    else 
    { $ConnectionString = 'Server={0};Database={1};Integrated Security=True;Connect Timeout={2}' -f $ServerInstance,$Database,$ConnectionTimeout } 
 
    $conn.ConnectionString=$ConnectionString 
     
    #Following EventHandler is used for PRINT and RAISERROR T-SQL statements. Executed when -Verbose parameter specified by caller 
    if ($PSBoundParameters.Verbose) 
    { 
        $conn.FireInfoMessageEventOnUserErrors=$true 
        $handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {Write-Verbose "$($_)"} 
        $conn.add_InfoMessage($handler) 
    } 
     
    $conn.Open() 
    $cmd=new-object system.Data.SqlClient.SqlCommand($Query,$conn) 
    $cmd.CommandTimeout=$QueryTimeout 
    $ds=New-Object system.Data.DataSet 
    $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd) 
    [void]$da.fill($ds) 
    $conn.Close() 
    switch ($As) 
    { 
        'DataSet'   { Write-Output ($ds) } 
        'DataTable' { Write-Output ($ds.Tables) } 
        'DataRow'   { Write-Output ($ds.Tables[0]) } 
    } 
 
} #Invoke-Sqlcmd2
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
$ErrorMessage = " On $Connection " + $Additional + $_.Exception.Message + $_.Exception.InnerException.InnerException.message
$Message = ' This message came from the Automated Powershell script to standardise DBA scripts across Estate'
$Msg = $Additional + $ErrorMessage + ' ' + $Message
Write-Log -Path $LogFile -Message $ErrorMessage -Level Error
}
function Remove-UpdateFlag
{
param(
[string]$ServerName,
[string]$InstanceName,
[string]$ScriptName
)
                try
                    {
            $RemoveUpdateFlag = @"
            UPDATE [dbo].[InstanceScriptLookup]
   SET 
      [NeedsUpdate] = 0
 WHERE 
 InstanceID = (SELECT InstanceID from dbo.InstanceList Where [ServerName] = '$ServerName' AND [InstanceName] = '$InstanceName')
 AND
 ScriptID = (SELECT ScriptID from [dbo].[ScriptList] WHERE [ScriptName] = '$ScriptName')
GO
"@
                     Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $CentralDBADatabase -Query $RemoveUpdateFlag
                     Write-Log -Path $LogFile -Message ' Update Flags Removed' -Level Info
                     }
                 catch
                     {
                     Catch-block 'Failed to remove Update Flags -- '
                     }
}
function Update-InstancesWithScript
{
param
(
$ScriptName
)

# Get Instances which need updating or installing
$Query = @"
SELECT
IL.ServerName
,IL.InstanceName
,IL.Port
,SL.ScriptName
,SL.ScriptLocation
,ISL.NeedsUpdate

FROM
[dbo].[InstanceScriptLookup] as ISL
JOIN
dbo.InstanceList as IL
ON
ISL.[InstanceID] = IL.InstanceID
JOIN
[dbo].[ScriptList] as SL
ON
SL.ScriptID = ISL.ScriptID
WHERE ISL.NeedsUpdate = 1
AND
SL.ScriptName = '$ScriptName'
"@

    try
    {
   # Write-Log -Path $LogFile -Message $Query -Level Info ## For logging purposes when testing
    $InstancesToUpdate = Invoke-Sqlcmd2 -ServerInstance $CentralDBAServer -Database $CentralDBADatabase -Query $Query
    Write-Log -Path $LogFile -Message ' Instances gathered' -Level Info
    }
    catch
    {
    $Add = " Failed to gather Instances from  $CentralDBAServer "
    Catch-block $Add
    }

    # Iterate through the required instances and run script
    if ($InstancesToUpdate -eq $NULL)
    {
 Write-Log -Path $LogFile -Message ' No Instances to Update' -Level Info
    }

    foreach ($Instance in $InstancesToUpdate)
        {
        $ServerName = $Instance.ServerName
        $InstanceName = $Instance.InstanceName
        $ScriptLocation = $Instance.ScriptLocation
        $ScriptName = $Instance.ScriptName
        $Connection = $ServerName + '\' + $InstanceName + ',' + $Instance.Port
        $srv = New-Object Microsoft.SQLServer.Management.SMO.Server $Connection

            # Run Install Script
            try
            {
            Invoke-Sqlcmd -ServerInstance $Connection -Database $DBAAdminDatabase -InputFile $ScriptLocation -DisableVariables -ErrorAction Stop
            Write-Log -Path $LogFile -Message "Installed or updated $ScriptName on $Connection"
            
                try
                    {
            Remove-UpdateFlag -ServerName $ServerName -InstanceName $InstanceName -ScriptName $ScriptName
                     }
                 catch
                     {
                     Catch-block 'Failed to Remove Update Flags  --'
                     }
                }
            catch
            {
            Catch-Block "Failed To Install or update $ScriptName -- "
            }
    }
    
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
$Msg = $ErrorMessage + ' ' + $FailedItem 
}

Write-Log -Path $LogFile -Message ' Script Started'
# Get the names of the scripts
$Query = @"
SELECT DISTINCT ScriptName
FROM
[dbo].[ScriptList] SL
JOIN [dbo].[InstanceScriptLookup] ISL
ON SL.ScriptID = ISL.ScriptID
WHERE ISL.NeedsUpdate = 1
"@

$Scripts = Invoke-Sqlcmd -ServerInstance $CentralDBAServer -Database $CentralDBADatabase -Query $Query

foreach($Script in $Scripts)
{
$ScriptName = $Script.ScriptName
Update-InstancesWithScript -ScriptName $ScriptName
}

Write-Log -Path $LogFile -Message  ' Script Finished'

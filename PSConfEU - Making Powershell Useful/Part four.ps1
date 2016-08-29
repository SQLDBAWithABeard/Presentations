#requires -Version 2
## Load some assemblies for TFS -- Search for the DLL to get the correct location
Add-Type -Path  'C:\Program Files\Common Files\microsoft shared\Team Foundation Server\15.0\Microsoft.TeamFoundation.Client.dll'
Add-Type -Path 'C:\Program Files\Common Files\microsoft shared\Team Foundation Server\15.0\Microsoft.TeamFoundation.VersionControl.Client.dll'
# Set up some variables ready for the script

$ServerPath = '$/Powershell Scripts/Functions' # Path to TFS Folder holding Functions
# Distinguish between ISE and CMD
if($PSISE) 
{
  $add = 'ISE'
}
else
{
  $add = 'CMD'
}

$WorkspaceName = 'PowershellFunctions' + $env:USERNAME + $env:COMPUTERNAME + $add # Setting a Workspace name that is
$LocalPath = 'C:\Users\' + $env:USERNAME + '\Documents\PowershellFunctions' + $add  
$tfsUri = '' # TFS Server URI http://TFSSERVER:8080/tfs/Collection or 'https://YOURNAMEHERE.visualstudio.com/DefaultCollection'

if(!(Test-Path $LocalPath))
{
  New-Item -Path $LocalPath -ItemType Directory
  Write-Output -InputObject "Created Directory $LocalPath"
}

$tfsCollection = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($tfsUri)
$vc = $tfsCollection.GetService([type] 'Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer')

if($vc.QueryWorkspaces($WorkspaceName,$null,$null))
{
  ## This is a horrible way but it works! The GetLastest method doesnt get the latest!!
  $workspace = $vc.QueryWorkspaces($WorkspaceName,$null,$null)
  $workspace.delete() # if workspace exists delete it and recreate
  Get-ChildItem $LocalPath |Remove-Item -Force -Recurse # remove existing files
  $workspaceComment = 'Powershell Functions from TFS for profile'
  $workspace = $vc.CreateWorkspace($WorkspaceName,'Rob Sewell',$workspaceComment)
  $workspace.Map($ServerPath, $LocalPath)
  $getstatus = $workspace.Get()
  Write-Output -InputObject "Workspace $WorkspaceName Dropped and Re-Created at $LocalPath"
}      
else
{
  $workspaceComment = 'Powershell Functions from TFS for profile'
  $workspace = $vc.CreateWorkspace($WorkspaceName,'Rob Sewell',$workspaceComment)
  $workspace.Map($ServerPath, $LocalPath)
  $getstatus = $workspace.Get()
  Write-Output -InputObject "Workspace $WorkspaceName Created at $LocalPath"
}

[void][reflection.assembly]::LoadWithPartialName( 'Microsoft.SqlServer.Management.Common' )
[void][reflection.assembly]::LoadWithPartialName( 'Microsoft.SqlServer.SmoEnum' )
[void][reflection.assembly]::LoadWithPartialName( 'Microsoft.SqlServer.Smo' )
[void][reflection.assembly]::LoadWithPartialName( 'Microsoft.SqlServer.SmoExtended ' )
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') 
$null = [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
## Add-PSSnapin Microsoft.TeamFoundation.Powershell
Write-Output -InputObject 'SQL Assemblies loaded'

# load all functions

Get-ChildItem -Path $LocalPath\*.ps1 | ForEach-Object -Process {
  .$_
} 

Write-Output -InputObject 'Custom Functions Loaded'

Remove-Variable -Name psTab, TheBeard, LocalPath, workspaceComment, workspace, add, getstatus, I, tfsCollection, tfsUri, vc, WorkspaceName
Write-Output -InputObject 'Custom PowerShell Environment Loaded' 
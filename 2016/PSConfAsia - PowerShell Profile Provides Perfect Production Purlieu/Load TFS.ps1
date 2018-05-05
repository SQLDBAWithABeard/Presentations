 Add-Type -Path  'D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.Client.dll'
 Add-Type -Path 'D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.VersionControl.Client.dll'
 
 # Set up some variables ready for the script

$ServerPath = '$/Powershell Scripts/Functions' # Path to TFS Folder holding Functions

$WorkspaceName = 'PowershellFunctions' + $env:USERNAME + $env:COMPUTERNAME + $add # Setting a Workspace name 
$LocalPath = 'C:\Users\' + $env:USERNAME + '\Documents\PowershellFunctions' + $add  
$tfsUri = 'https://YOURSITENAME.visualstudio.com/DefaultCollection'
# TFS Server URI http://TFSSERVER:8080/tfs/Collection

if(!(Test-Path $LocalPath))
{
  New-Item -Path $LocalPath -ItemType Directory
  Write-Output -InputObject "Created Directory $LocalPath"
}

$tfsCollection = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($tfsUri)
$vc = $tfsCollection.GetService([type] 'Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer')

if($vc.QueryWorkspaces($WorkspaceName,$null,$null))
{
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
  $workspace = $vc.CreateWorkspace($WorkspaceName,'USERNAME',$workspaceComment)
  $workspace.Map($ServerPath, $LocalPath)
  $getstatus = $workspace.Get()
  Write-Output -InputObject "Workspace $WorkspaceName Created at $LocalPath"
}
$getstatus
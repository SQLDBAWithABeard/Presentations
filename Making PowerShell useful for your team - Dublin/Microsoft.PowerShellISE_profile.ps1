#requires -Version 2


# Custom Profile from TFS loading all custom functions
## Set up OneDrive Powershell Folder as a PSDrive
if ($env:COMPUTERNAME -eq 'SHINYNEW')
{
  # load the assemblies needed for the task:
  Add-Type -Path  'C:\Program Files\Common Files\microsoft shared\Team Foundation Server\15.0\Microsoft.TeamFoundation.Client.dll'
Add-Type -Path 'C:\Program Files\Common Files\microsoft shared\Team Foundation Server\15.0\Microsoft.TeamFoundation.VersionControl.Client.dll'

  if (!(Get-PSDrive -Name OneDrivePS -ErrorAction SilentlyContinue))
  {
    New-PSDrive -Name OneDrivePS -PSProvider FileSystem -Root 'Scripts\Powershell Scripts' -Description 'Maps to the root of the Powershell Scripts folder'
  }
  if (!(Get-PSDrive -Name Functions -ErrorAction SilentlyContinue))
  {
    New-PSDrive -Name Functions -PSProvider FileSystem -Root '\Scripts\Powershell Scripts\Functions' -Description 'Maps to the root of the Powershell Scripts Functions folder'
  }
  if (!(Get-PSDrive -Name Git -ErrorAction SilentlyContinue))
  {
    New-PSDrive -Name Git -PSProvider FileSystem -Root '\GitHub' -Description 'Maps to the root of the Powershell Scripts Git folder'
  }
  if (!(Get-PSDrive -Name Presentations -ErrorAction SilentlyContinue))
  {
    New-PSDrive -Name Presentations -PSProvider FileSystem -Root '\Presentations' -Description 'Maps to the root of the Presentations folder'
  }
  Write-Output -InputObject 'Custom PSDrive loaded'
  if($PSISE) 
  {
    $add = 'ISE'
    function Run-Zoomit
    {
      Start-Process -FilePath \ZoomIt.exe
    }
    #Check for Subnmenus
    $psTab = $PSISE.CurrentPowerShellTab.addonsmenu
    if($psTab.Submenus)
    {
      #count them
      $I = $psTab.Submenus.Count - 1
      # loop through them and Remove the beard
      while($I -gt -1)
      {
        if($psTab.Submenus[$I].displayname.Contains('TheBeard'))
        {
          $null = $psTab.Submenus.remove($psTab.Submenus[$I])  
          $I --
        }    
      }
    }
    ## Add in shortcut for new file with pester
    $TheBeard = $psTab.Submenus.Add('TheBeard',$null,$null)
    $null = $TheBeard.Submenus.Add('New Git File',{
        New-GitPester
    },'Ctrl+Alt+Shift+N')
    $null = $TheBeard.Submenus.Add('Start Zoomit',{
        Run-Zoomit
    },'Ctrl+Alt+Shift+Z')
  }
  else
  {
    $add = 'CMD'
  }
}

if ($env:COMPUTERNAME -eq 'BEARD')
{
  Add-Type -Path  'D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.Client.dll'
  Add-Type -Path 'D:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.VersionControl.Client.dll'
  if (!(Get-PSDrive -Name OneDrivePS -ErrorAction SilentlyContinue))
  {
    New-PSDrive -Name OneDrivePS -PSProvider FileSystem -Root '\Scripts\Powershell Scripts' -Description 'Maps to the root of the Powershell Scripts folder'
  }
  if (!(Get-PSDrive -Name PSFunctions -ErrorAction SilentlyContinue))
  {
    New-PSDrive -Name PSFunctions -PSProvider FileSystem -Root '\Scripts\Powershell Scripts\Functions' -Description 'Maps to the root of the Powershell Scripts Functions folder'
  }
  Write-Output -InputObject 'Custom PSDrive loaded'
  if($PSISE) 
  {
    $add = 'ISE'
    function New-GitPester
    {
      Write-Output -InputObject 'WOW'
    }
    #Check for Subnmenus
    $psTab = $PSISE.CurrentPowerShellTab.addonsmenu
    if($psTab.Submenus)
    {
      #count them
      $I = $psTab.Submenus.Count - 1
      # loop through them and Remove the beard
      while($I -gt -1)
      {
        if($psTab.Submenus[$I].displayname.Contains('TheBeard'))
        {
          $null = $psTab.Submenus.remove($psTab.Submenus[$I])  
          $I --
        }    
      }
    }
    ## Add in shortcut for new file with pester
    $TheBeard = $psTab.Submenus.Add('TheBeard',$null,$null)
    $null = $TheBeard.Submenus.Add('New Git File',{
        New-GitPester
    },'Ctrl+Alt+Shift+N')
    $null = $TheBeard.Submenus.Add('Start Zoomit',{
        Run-Zoomit
    },'Ctrl+Alt+Shift+Z')
  }
  else
  {
    $add = 'CMD'
  }
}

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

[void][reflection.assembly]::LoadWithPartialName( 'Microsoft.SqlServer.Management.Common' )
[void][reflection.assembly]::LoadWithPartialName( 'Microsoft.SqlServer.SmoEnum' )
[void][reflection.assembly]::LoadWithPartialName( 'Microsoft.SqlServer.Smo' )
[void][reflection.assembly]::LoadWithPartialName( 'Microsoft.SqlServer.SmoExtended ' )
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo') 
$null = [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
Add-PSSnapin Microsoft.TeamFoundation.Powershell
Write-Output -InputObject 'SQL Assemblies loaded'

# load all functions

Get-ChildItem -Path $LocalPath\*.ps1 | ForEach-Object -Process {
  .$_
} 

Write-Output -InputObject 'Custom Functions Loaded'

if($PSISE) # Only add script browser to ISE
{
  if(Test-Path -Path 'C:\Program Files (x86)\Microsoft Corporation\Microsoft Script Browser')
  {
    if($PSISE.CurrentPowerShellTab.VerticalAddOnTools.Name -notcontains 'Script Browser')
    {
      #Script Browser Begin
      #Version: 1.3.2
      Add-Type -Path 'C:\Program Files (x86)\Microsoft Corporation\Microsoft Script Browser\System.Windows.Interactivity.dll'
      Add-Type -Path 'C:\Program Files (x86)\Microsoft Corporation\Microsoft Script Browser\ScriptBrowser.dll'
      Add-Type -Path 'C:\Program Files (x86)\Microsoft Corporation\Microsoft Script Browser\BestPractices.dll'
      $scriptBrowser = $PSISE.CurrentPowerShellTab.VerticalAddOnTools.Add('Script Browser', [ScriptExplorer.Views.MainView], $true)
      $scriptAnalyzer = $PSISE.CurrentPowerShellTab.VerticalAddOnTools.Add('Script Analyzer', [BestPractices.Views.BestPracticesView], $true)
      $PSISE.CurrentPowerShellTab.VisibleVerticalAddOnTools.SelectedAddOnTool = $scriptBrowser
      #Script Browser End
      Remove-Variable -Name scriptAnalyzer, scriptBrowser
    }
  }
}
Remove-Variable -Name psTab, TheBeard, LocalPath, workspaceComment, workspace, add, getstatus, I, tfsCollection, tfsUri, vc, WorkspaceName
Write-Output -InputObject 'Custom PowerShell Environment Loaded' 

# load poshgit variables
. $env:LOCALAPPDATA\GitHub\shell.ps1



Import-Module sqlserver
Write-Output 'The front row are particularly wonderful'
if(!(Get-PSDrive -Name 'Presentations' -ErrorAction SilentlyContinue ))
{
New-PSDrive -Name 'Presentations' -PSProvider FileSystem -Root 'C:\users\mrrob\OneDrive\Documents\Presentations' |Out-Null
}
if(!(Get-PSDrive -Name 'Functions' -ErrorAction SilentlyContinue))
{
New-PSDrive -Name 'Functions' -PSProvider FileSystem -Root 'C:\users\mrrob\OneDrive\Documents\Scripts\Powershell Scripts\Functions' |Out-Null
}
if(!(Get-PSDrive -Name 'Git' -ErrorAction SilentlyContinue ))
{
New-PSDrive -Name 'Git' -PSProvider FileSystem -Root C:\Users\mrrob\OneDrive\Documents\GitHub |Out-Null
}
if(!(Get-PSDrive -Name 'WIP'-ErrorAction SilentlyContinue ))
{
New-PSDrive -Name 'WIP' -PSProvider FileSystem -Root C:\Temp\WIP |Out-Null
}
#
## BUt it doesnt just have to Filepaths
#
if(!(Get-PSDrive -Name 'SQLDAVE' -ErrorAction SilentlyContinue))
{
New-PSDrive -Name 'SQLDAVE' –PSProvider SQLSERVER –Root 'SQLSERVER:\SQL\localhost\DAVE' |Out-Null
}
if(!(Get-PSDrive -Name 'JOBSERVER' -ErrorAction SilentlyContinue))
{
New-PSDrive -Name 'JOBSERVER' –PSProvider SQLSERVER –Root 'SQLSERVER:\SQL\localhost\Default\JobServer' |Out-Null
}

## from https://github.com/krispharper/Powershell-Scripts/blob/master/Microsoft.PowerShell_profile.ps1
function Shorten-Path([string] $path) {
   $loc = $path.Replace($env:home, '~')
   # remove prefix for UNC paths
   $loc = $loc -replace '^[^:]+::', ''
   # make path shorter like tabs in Vim,
   # handle paths starting with \\ and . correctly
   return ($loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2')
}
# Set up a simple prompt, adding the git prompt parts inside git repos
function prompt {
    $provider = ($pwd).Provider.Name

    # Only try to load posh-git functionality in filesystem providers
    if ($provider -eq "FileSystem") {
        $realLASTEXITCODE = $LASTEXITCODE

        # Reset color, which can be messed up by Enable-GitColors
        #$Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    }
    
    $green = [ConsoleColor]::Green
    $cyan = [ConsoleColor]::Cyan
    $darkCyan = [ConsoleColor]::DarkCyan
    $white = [ConsoleColor]::White
    $darkGray = [ConsoleColor]::DarkGray
    $hostName = [Net.Dns]::GetHostName()

    # If we're in a remote session, overwrite the generated prompt
    if ($PSSenderInfo) {
        $promptLength = $hostName.Length + 4
        (("`b" * $promptLength) + (" " * $promptLength) + ("`b" * $promptLength) + " ")
    }

    # Write the hostname, time, and a shortened version of the current path
    $path = (Shorten-Path ($pwd).Path) -replace "\\$"
    $path = $path -replace "\\", " $([char]0xE0B1) "
    Write-Host " $hostName " -n -f $white -b $green
    Write-Host "$([char]0xE0B0) " -n -f $green -b $darkGray
    Write-Host (Get-Date).ToString("HH:mm:ss ") -n -f $white -b $darkGray
    Write-Host "$([char]0xE0B0) " -n -f $darkGray -b $darkCyan
    Write-Host "$path " -n -f $white -b $darkCyan
    Write-Host $([char]0xE0B0) -n -f $darkCyan

    if ($provider -eq "FileSystem") {
        Write-VcsStatus

        $global:LASTEXITCODE = $realLASTEXITCODE
    }

    return " "
}

$DBAServer = 'ROB-SURFACEBOOK'
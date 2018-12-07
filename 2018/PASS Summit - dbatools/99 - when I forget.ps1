$root = 'C:\Git\Presentations\2018\PASS Summit - dbatools'
cd $root
. .\vars.ps1


$verbosePreference = 'Continue'
#region Create New PSDrive and prompt
if (-not (Get-PSDrive -Name $location -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $location -Root 'C:\Git\Presentations\2018\SQL South West' -PSProvider FileSystem | Out-Null
    Write-Verbose -Message "Created PSDrive"
}

function prompt {
    Write-Host ("dbatools its awesome  >") -NoNewLine -ForegroundColor Green
    return " "
}

Write-Verbose -Message "Created prompt"

$promptloc = $location + ':'
Set-Location $promptloc

$verbosePreference = 'SilentlyContinue'

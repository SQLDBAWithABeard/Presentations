. .\vars.ps1

$verbosePreference = 'Continue'
#region Create New PSDrive and prompt
if (-not (Get-PSDrive -Name SQLDays -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name SQLDays -Root 'C:\Git\Presentations\2018\SQL Days - dbachecks' -PSProvider FileSystem | Out-Null
    Write-Verbose -Message "Created PSDrive"
}

function prompt {
    Write-Host ("uśmiech >") -NoNewLine -ForegroundColor Magenta
    return " "
}

Write-Verbose -Message "Created prompt"

Set-Location SQLDays:





$verbosePreference = 'SilentlyContinue'
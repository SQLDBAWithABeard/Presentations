$root = 'C:\Users\mrrob\OneDrive\Documents\GitHub\Presentations\2019\SQL Saturday Munich'
cd $root
. .\vars.ps1

$verbosePreference = 'Continue'
#region Create New PSDrive and prompt
if (-not (Get-PSDrive -Name $location -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name $location -Root $root -PSProvider FileSystem | Out-Null
    Write-Verbose -Message "Created PSDrive"
}

docker-compose -f .\docker\docker-compose.yml up -d

Set-Location "$location`:\"

$verbosePreference = 'SilentlyContinue'
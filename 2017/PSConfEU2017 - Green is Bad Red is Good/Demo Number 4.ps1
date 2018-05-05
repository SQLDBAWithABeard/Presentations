## Use a configuration file

Get-Content GIT:\dbatools-scripts\TestConfig.json

cls
cd GIT:\dbatools-scripts
$Config = (Get-Content GIT:\dbatools-scripts\TestConfig.json) -join "`n" | ConvertFrom-Json
invoke-Pester 
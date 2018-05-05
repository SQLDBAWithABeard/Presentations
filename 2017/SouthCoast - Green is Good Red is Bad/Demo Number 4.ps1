## Use a configuration file

Get-Content GIT:\dbatools-scripts-stuttgart\TestConfig.json

cls
cd GIT:\dbatools-scripts-stuttgart
explorer C:\MSSQL\DATA\BOLTON
$Config = (Get-Content GIT:\dbatools-scripts-stuttgart\TestConfig.json) -join "`n" | ConvertFrom-Json
invoke-Pester 

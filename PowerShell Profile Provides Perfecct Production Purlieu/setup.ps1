
$ISEProfile = 'C:\Users\mrrob\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1'
$CMDProfile = 'C:\Users\mrrob\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'

try
{
$Date = Get-Date -Format ddMMyyy-HHmmss
Copy-Item $ISEprofile -Destination C:\Users\mrrob\Documents\ISEProfile_Copy_$Date.ps1 -Force -ErrorAction Stop
Copy-Item $CMDProfile -Destination C:\Users\mrrob\Documents\CMDProfile_Copy_$Date.ps1 -Force -ErrorAction Stop
}
catch
{
Write-Warning 'Failed to copy profile - aborting'
break
}

try{
Remove-Item $ISEProfile -Force -ErrorAction Stop
Remove-Item $CMDProfile -Force -ErrorAction Stop
}
catch
{
Write-Warning "Failed to remove Profile"
}
try{get-service MS*DAVE*|Start-Service}
catch{Write-Warning "FAILED to start DAVE"
}
try
{Get-Service SQLSERVERAGENT|Start-Service
Get-Service MSSQLSERVER|Start-Service}
catch
{Write-Warning "FAILED to start SQL"}
<#

. 'C:\Users\mrrob\OneDrive\Documents\Scripts\Powershell Scripts\Functions\Start-Demo.ps1'
Start-Demo -file 'C:\Users\mrrob\OneDrive\Documents\Presentations\PowerShell Profile Provides Perfecct Production Purlieu\One.ps1'

#>

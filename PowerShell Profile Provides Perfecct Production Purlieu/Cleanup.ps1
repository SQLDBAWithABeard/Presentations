$ISEProfile= (Get-ChildItem C:\Users\mrrob\Documents\ISEProfile_Copy_*ps1 |Sort-Object LastWriteTime -Descending|Select-Object -First 1).FullName
$CMDProfile= (Get-ChildItem C:\Users\mrrob\Documents\CMDProfile_Copy_*ps1 |Sort-Object LastWriteTime -Descending|Select-Object -First 1).FullName

try
{
Copy-Item $ISEProfile -Destination 'C:\Users\mrrob\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1' -Force -ErrorAction Stop
Copy-Item $CMDProfile -Destination 'C:\Users\mrrob\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1' -force    -ErrorAction Stop
}
catch
{
Write-Warning 'Failed to copy profiles'
}

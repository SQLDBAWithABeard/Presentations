## Now you can keep your scripts in control to stop those 'helpful' people

Show-DatabasesOnServer ROB-SURFACEBOOK

cd C:\users\mrrob\Documents\PowershellFunctionsISE

Add-TfsPendingChange -Edit -Item .\Show-DatabasesOnServer.ps1

psEdit .\Show-DatabasesOnServer.ps1

New-TfsChangeset -Item .\Show-DatabasesOnServer.ps1 -Comment 'A Demo Change'

Start-Process microsoft-edge:'https://dbawithabeard.visualstudio.com/defaultcollection/Powershell%20Scripts/Powershell%20Scripts%20Team/_versionControl?_a=history'

## Or we can change it in Visual Studio - or add the change with the Power Tools COntext menu
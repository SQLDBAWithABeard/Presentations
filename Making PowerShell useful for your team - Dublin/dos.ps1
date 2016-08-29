## When I started using Powershell I would google for a script
## and then copy and paste it into ISE
Start-Process microsoft-edge:'https://www.google.co.uk/search?q=powershell+list+files+and+folders'
##
## list files and folders in a directory
dir Presentations:\  | % { if ($_.PsIsContainer) { $_.FullName + "\" } else { $_.Name } }
##
## and when I needed to change something I would open the file and alter it
dir Functions:\ -r  | % { if ($_.PsIsContainer) { $_.FullName + "\" } else { $_.Name } }
##
## Here is one of those original files !!!!!
Get-Content 'C:\users\mrrob\onedrive\documents\presentations\Making PowerShell useful for your team - Dublin\tres.ps1'
##
## SMO default  files locations are here
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
$instancename = '.' 
$server = New-Object "Microsoft.SqlServer.Management.Smo.Server" $instanceName
write-host 'Default Backup Folder      ' $server.settings.BackupDirectory
## write-host 'Default Data File Folder      ' $server.settings.DefaultFile 
## write-host 'Default Log File Folder      ' $server.settings.DefaultLog 
## DON'T USE Write-Host !!
## Do Use $Srv|gm or $srv.databases |gm etc to see what there is
Set-Location OldScripts:\
## Then I realised that that was not viable (although I still see that method)
## and I started creating seperate scripts like this with a read-host for servername
##
Get-ChildItem -File Show*|Select-Object name 
##
## I would use this to perform tasks in this way 
## & '.\show me automatic start services.ps1'
& '.\show me sysadmin.ps1'
Set-Location OldScripts:\
& '.\Show Me Disk Space.ps1'
& '.\Show me Machine Info.ps1'
##
## Then I started to learn about functions and created some like this
##
Get-ChildItem psfunctions:\ -Name Show*
##
Show-DriveSizes -Server .
Show-DatabasesOnServer -Server .
Show-DatabasesOnServer -Server .\Dave
Show-Last24HoursSQLErrorLog -Server .\Dave
##
## I loaded these into my profile like this.
##
$LocalPath = (Get-PSDrive -Name PSFunctions).Root
Get-ChildItem -Path $LocalPath\*.ps1 | ForEach-Object -Process { .$_ } 
##
## This worked well until other people wanted to use the scripts
## 
## At first we would email them  (Really!!) 
## and then keep them on a share 
## but "clever" people made changes and broke everything
##
## One time -- show-drivesizes returned this for every server
##
Set-Location onedriveps:\
. .\Show-DriveSizesBroken.ps1
Show-DriveSizes -Server SomeServer
Show-DriveSizes -Server 'A Different Server'
notepad .\Show-DriveSizesBroken.ps1
##
## So this wasnt going to work
##
## So I ended up using two different methods to enable others to use the scripts
Set-Location onedriveps:\
## First I created little menus that called the scripts
##
##  1, 4 ,7
##
.\DBASewellBox.ps1
## and I also created a little GUI :-)
##
## which doesnt look as good at 4K resolution!
.\BoxOfTricks.ps1  
invoke-item Presentations:\PowershellBoxOftricks.png
##
## These both worked well but as others began to want to develop scripts we turned to TFS
##
## We started making use of TFS
##
## Now you can keep your scripts in control to stop those 'helpful' people
##
## VS Online is Free (and now known as Team Services)
## Five users free, unlimited private repos, developer tools, training and support
Start-Process microsoft-edge:'https://www.visualstudio.com/products/what-is-visual-studio-online-vs'
##
## You can install the TFS Cmdlets from the TFS Power Tools download (not by default)
## This is what you get
get-help tfs
## 
## So a handful of Cmdlets for you to use
## I tell people the best way to find out how to use a Cmdlet
## is to use Get-Help
Get-Help Get-SqlPsVote
## You can get your input to Microsoft for SQLPS and SSMS
## PS V5 Install-Module -Name TrelloVoteCount 
## https://www.powershellgallery.com/packages/TrelloVoteCount/1.0.0.7
Start-Process microsoft-edge:'https://sqlps.io/vote'
## PLease all say thankyou to @cl & @SQLvariant !
##
## But for TFS Cmdlets
Get-Help Update-TfsWorkspace -examples
##
## Lets See it in action
Show-DatabasesOnServer ROB-SURFACEBOOK
##
cd 'C:\Users\mrrob\OneDrive\Documents\Scripts\Powershell Scripts\Functions'
## Lets Check it out
Add-TfsPendingChange -Edit -Item .\Show-DatabasesOnServer.ps1
## and Edit it
notepad .\Show-DatabasesOnServer.ps1
## and then check it in
New-TfsChangeset -Item .\Show-DatabasesOnServer.ps1 -Comment 'A Demo Change at #SQLSatDublin by The Beard'
## \which we can see here if we are online
Start-Process microsoft-edge:'https://dbawithabeard.visualstudio.com/defaultcollection/Powershell%20Scripts/Powershell%20Scripts%20Team/_versionControl?_a=history'
##
## You can also work in VS or even @Code
##
## But I wanted to get the latest functions loaded with my profiles
##
## This is a good blog post about working with TFS objects with Powershell
## http://blog.majcica.com/2015/11/15/powershell-tips-and-tricks-retrieving-tfs-collections-and-projects/
## 
Get-Content 'C:\Users\mrrob\OneDrive\Documents\Presentations\Making PowerShell useful for your team - Dublin\Microsoft.PowerShellISE_profile.ps1' | Out-Host -Paging
##
## So now I can ensure that everyones profile is loaded from that template
## using GPO if I want so each team gets the correct functions for their function
##
## And anybody can contribute and update the scripts....... safely!
##
## You can also use GitHub - which is free but everyone will be able to see your code or
## from $9 per user per month but if you already use it in your organisation tehn it may be worthwhile
Start-Process microsoft-edge:'https://github.com/pricing'
##
## Lets make it easy to start testing our PowerShell scripts
##
##
Start-Process microsoft-edge:'https://blogs.msdn.microsoft.com/powershell/2015/02/24/powershell-script-analyzer-static-code-analysis-for-windows-powershell-scripts-modules/'
##
## Script Analyzer has a set of default rules
Invoke-ScriptAnalyzer -Path 'C:\Users\mrrob\OneDrive\Documents\Scripts\Powershell Scripts\show me all sql services and accounts.ps1'
##
## Lets make it even better Lets use Pester
##
## A quick introduction is here
Start-Process microsoft-edge:'https://mcpmag.com/articles/2016/05/19/test-powershell-modules-with-pester.aspx'
##
## You can call it using Invoke-Pester if you have a tests file
## Read Adams post for starters and Mike F Robbins and June Blender to go deeper
## and Irwin Strachan if you want to Validate your Active Directory
## https://pshirwin.wordpress.com/2016/04/08/active-directory-operations-test/
Invoke-Pester C:\users\mrrob\onedrive\Documents\GitHub\Functions\Set-OlaJobsSchedule.tests.ps1
##
## Yes that is running all of the PSScriptAnalyzer Tests I do that automatically like this
## Here is my New-GitPester Function
Get-Content 'C:\Users\mrrob\OneDrive\Documents\Scripts\Powershell Scripts\Functions\New-GitPester.ps1'
##
## So I have a Tests.template file (which means I dont have to remember if it is Tests.ps1 or tests.ps1 - It Does matter!) and also I can add to it or remove from it easily
Get-Content 'C:\Users\mrrob\OneDrive\Documents\Scripts\Powershell Scripts\tests.template.ps1' |Out-Host -Paging
## and I can alter it and all future scripts will automatically have a good set of starter tests
cd C:\users\mrrob\onedrive\Documents\GitHub\PrivateFunctions
.\Get-DriveSize.Tests.ps1
## Back to Powerpoint
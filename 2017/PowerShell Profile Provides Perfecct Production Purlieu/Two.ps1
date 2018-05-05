## Maybe put your Admin Credential in a variable eg
$AdminCred = Get-Credential -Message 'Add your Admin' -UserName 'THEBEARD\Rob'
## Then you can use like this Won't work if NUC not connected Rob so # 8
Enter-PSSession -ComputerName $SQLServer -Credential $AdminCred
##
## Or set some variables that you always use 
Exit-PSSession
##
$DevServers = (Invoke-Sqlcmd -ServerInstance $DBAServer -Query "SELECT [ServerName]FROM [DBADatabase].[dbo].[InstanceList] where Environment ='Dev'").ServerName
$DevServers
$TestServers = (Invoke-Sqlcmd -ServerInstance $DBAServer -Query "SELECT [ServerName]FROM [DBADatabase].[dbo].[InstanceList] where Environment ='Test'").ServerName
$TestServers
$LiveServers = (Invoke-Sqlcmd -ServerInstance $DBAServer -Query "SELECT [ServerName]FROM [DBADatabase].[dbo].[InstanceList] where Environment ='Prod'").ServerName
$LiveServers
##
## I am sure that you think of other things that will be useful for you
##
cls
## Store your Functions in TFS (or TSVS or VSO whatever it is called this week :-) )
## 
Show-DatabasesOnServer ROB-SURFACEBOOK
##
cd 'C:\Users\mrrob\OneDrive\Documents\Scripts\Powershell Scripts\Functions'
## Lets Check it out
Add-TfsPendingChange -Edit -Item .\Show-DatabasesOnServer.ps1
## and Edit it
notepad .\Show-DatabasesOnServer.ps1
## and then check it in
New-TfsChangeset -Item .\Show-DatabasesOnServer.ps1 -Comment 'A Demo Change at #PSConfAsia by The Beard'
## \which we can see here if we are online
Start-Process microsoft-edge:'https://dbawithabeard.visualstudio.com/defaultcollection/Powershell%20Scripts/Powershell%20Scripts%20Team/_versionControl?_a=history'
## This can be done like this
notepad 'C:\users\mrrob\OneDrive\Documents\Presentations\PowerShell Profile Provides Perfecct Production Purlieu\Load TFS.ps1'
cd c:\temp
## So now I can ensure that everyones profile is loaded from that template
## using GPO if I want so each team gets the correct functions for their function
##
## And anybody can contribute and update the scripts....... safely!

## Script Analyzer has a set of default rules
Invoke-ScriptAnalyzer -Path 'C:\Users\mrrob\OneDrive\Documents\Scripts\Powershell Scripts\show me all sql services and accounts.ps1'
##
notepad 'C:\Users\mrrob\OneDrive\Documents\Scripts\Powershell Scripts\show me all sql services and accounts.ps1'
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
## Back to Presentation

## Then I realised that that was not viable (although I still see that method)
## and I started creating seperate scripts like this with a read-host for servername

Set-Location OldScripts:\
Get-ChildItem -File|Select-Object name

## I would use this to perform tasks like so opening the 
& '.\show me automatic start services.ps1'
& '.\show me sysadmin.ps1'  ## if on surfacebook
& '.\Show Me Disk Space.ps1'
& '.\Show me Machine Info.ps1'

## Then I started to learn about functions and created some like this

Get-ChildItem psfunctions:\ -Name

Show-DriveSizes -Server .

## I loaded these into my profile

$LocalPath = (Get-PSDrive -Name PSFunctions).Root
Get-ChildItem -Path $LocalPath\*.ps1 | ForEach-Object -Process {
  .$_
} 


## This worked well until other people wanted to use the scripts

## At first we would email them  (Really!!) 
## and then keep them on a share 
## but "clever" people made changes and broke everything

## One time -- show-drives returned this for every server

Set-Location onedriveps:\
. .\Show-DriveSizesBroken.ps1
Show-DriveSizes -Server SomeServer
Show-DriveSizes -Server 'A Different Server'
psedit .\Show-DriveSizesBroken.ps1

## So this wasnt going to work


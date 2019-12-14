Set-Location 'Git:/Presentations/2019/PASS Summit/pwsh'

# Lets explore some PowerShell - 4 things you need Get-Command, Get-Help, Objects, Get-Member

$PSVersionTable

#region Help
# we need to find commands

Get-Command *-process*

# How do we use commands ?

Get-Help Get-Process

# more information

Get-Help Get-Process -Detailed

# online information

Get-Help Get-Process -Online

# You can even use aliases

# AT THE COMMAND LINE
# DO NOT Use aliases in any code you share :-(

gps

# DISCLAIMER - Do as I say not as I do ;-)

Get-Process

Get-Process -Name whoopsie

#endregion

#region grep sed (ish)
## Grep ish

# Get-Content somefile.txt | where { $_ -match "expression"}

Get-Content ./DATA.TXT | Where-Object {$Psitem -match 'Nothing'}

cat DATA.TXT |  Where {$_ -match 'Nothing'}
cat DATA.TXT |  ? {$_ -match 'Nothing'}



## SED ish

## cat somefile.txt | %{$_ -replace "expression","replace"}

Get-Content ./DATA.TXT |ForEach-Object {$Psitem -replace 'matters' , 'Is Important'} 
Get-Content ./DATA.TXT |ForEach-Object {$Psitem -replace 'matters' , 'Is Important'} | Where-Object {$Psitem -match 'Nothing'}

Get-Content ./DATA.TXT |ForEach-Object {$Psitem -replace 'matters' , 'Is Important'} | Where-Object {$Psitem -match 'Nothing'} | Set-Content DATA1.TXT 

#endregion

#region piping
# open a pwsh to the side and get ID

Get-Process pwsh

# back to the first window

Get-Process -Id 8476

# Piping commands - takes the output of one and passes it to the next
# Not text - the object

Get-Process -Id 8572 | Stop-Process

# You can explore objects by piping them to Get-Member

Get-Process pwsh | Get-Member

# The way that I do this is to set the command to the results of a variable
# Lets move over to some SQL

docker-compose -f ./linux-SQL2019-docker-compose.yml up -d 

$cred = Import-Clixml -LiteralPath /home/rob/Documents/docker/sqladmin.cred

$sqlinstance = 'localhost,15598'

$Databases = Get-DbaDatabase -SqlInstance $sqlinstance -SqlCredential $cred

$Databases | Get-Member

# You can see what type of object it is at the top

# Microsoft.SqlServer.Management.Smo.Database

Start-Process 'https://google.co.uk?q=Microsoft.SqlServer.Management.Smo.Database'

# although actually this shows that is an array of SMO.Database objects
$Databases.GetType()

# so maybe you want to examine just one of them

$Databases[5] | Format-Table

# This old publishing firm still has a database that needs looking after it seems!
# Lets examine the properties

$Databases[5] | Get-Member -MemberType Properties

# I can never remember the difference between State and Status
# this is how you can access properties and see the value

$Databases[5] | Select State , Status

# This is how we can filter in PowerShell

$databases | Where Name -like *orth*

# Remember I talked about piping ?

$databases | Where Name -like *orth* | Select Tables -ExpandProperty Tables

# Get the first one

$databases | Where Name -like *orth* | Select Tables -ExpandProperty Tables | Select -First 1 

# Now get the indexes
$databases | Where Name -like *orth* | Select Tables -ExpandProperty Tables | Select -First 1 | Select indexes -ExpandProperty indexes

# Set them to a variable

$indexes = $databases | Where Name -like *orth* | Select Tables -ExpandProperty Tables | Select -First 1 | Select indexes -ExpandProperty indexes

#endregion

#region more get membering
# Examine the object

$indexes | Get-Member

# That script method looks interesting

$indexes.Script()

# Let's put that in a file

$indexes.Script() | Out-File /tmp/indexes.sql

azuredatastudio /tmp/indexes.sql

#endregion

#region - writing code
# let Visual Studio Code help you

# when you start typing you get intellisense

Get-DbaDbBackupHistory -sqlinstance $sqlinstance -SqlCredential $cred



# if it doesnt turn up try CTRL SPACE

# when you need the syntax for looping or try catch



#

# Notice the squiggles ?

dir | % {$_ | Select FullName}

# its perfectly good code in that it runs but few know what it does
# lightbulb

dir | % {$_ | Select FullName}

# but also the problems panel below
#endregion

#region Writing code that will work cross-platform

# there are default variables that can help here

$IsCoreCLR

$IsLinux

$IsMacOS

$IsWindows

# So can add some logic to your code

if($IsCoreCLR){
    if($IsLinux){
        Write-Output "I am a penguin!"
    }
    if($IsMacOS){
        Write-Output "I am a fruit!"
    }
    if($IsWindows){
        Write-Output "I have the oddest version naming system"
    }
}else{
    Write-Output "Hey, Windows PowerShell still rocks thank you very much!"
}

# You want to write code that works across all OS's and versions?
# You can use PSScriptAnalyzer
# Thats what is making the squiggles

# Lets take this piece of code and run it

$CoolPeople = [System.Collections.Generic.Dictionary[string,string]]::new()

$CoolPeople.Add('Cool Person','Drew Furguielleieillieell - or something')

$CoolPeople

# it works fine

# here in pwsh, but will it work on a windows machine running
# We dont have a windows machine ( I know! lets pretend ok?)
# If we look in settings for our workspace and then open the PSScriptAnalyzerSettings file
# We can uncomment the 5.1 and 3.0 for use compatible syntax
# and change enable to true - Rob will forget this so shout it out please!

$CoolPeople = [System.Collections.Generic.Dictionary[string,string]]::new()

$CoolPeople.Add('Cool Person','Drew Furguielleieillieell - or something')

$CoolPeople

# So it shows us that this code wont work on PowerShell 3

# We can run Script Analyzer at the command line also

Invoke-ScriptAnalyzer -Path ./demo.ps1 -Settings ./PSScriptAnalyzerSettings.psd1

# this shows us the issues but also the lines that they occur

# and also how to resolve the issue

Invoke-ScriptAnalyzer -Path ./demo.ps1 -Settings ./PSScriptAnalyzerSettings.psd1
(Invoke-ScriptAnalyzer -Path ./demo.ps1 -Settings ./PSScriptAnalyzerSettings.psd1 | Where RuleName -eq 'PSUseCompatibleSyntax')[0].SuggestedCorrections.Description

# So that has helped us with some syntax
# we can also get (a bit of) help with command names

Import-Module -FullyQualifiedName /home/rob/.local/share/powershell/Modules/dbachecks/1.2.12/dbachecks.psd1
Get-FileHash -Path ./demo.ps1
$file = Split-Path -LeafBase /tmp/indexes.sql
Compress-Archive -Path /tmp/indexes.sql -DestinationPath /tmp/$file.zip -Force
gci /tmp

# it all works fine here but will it work on other versions?

# Go back to settings and set PSUseCompatibleCommands enable to true
# squiggly goodness :-)

# IT WON'T BE PERFECT

# But it will get you a long way


#endregion

<#
Instead of Import-Module -FullyQualifiedName @{...} we use Import-Module -Name ... -Version ...;
Instead of Get-FileHash, we’re going to need to use .NET directly and write a function;
Instead of Split-Path -LeafBase, we can use [System.IO.Path]::GetFileNameWithoutExtension();
Instead of Compress-Archive we’ll need to use more .NET methods in a function, and;
Instead of Out-File -NoNewline we can use New-Item -Value
#>
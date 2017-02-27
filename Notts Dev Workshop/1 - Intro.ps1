## Welcome to PowerShell :-)
Return "This is a demo Beardy!"
## Script Pane CTRL + I
## Console CTRL + D

## You can run commands and script blocks in either

dir

## Look at the version of powershell

$PSVersionTable

## Look at the module path - This is where PowerShell will look for cmdlets

$ENV:PSModulePath
$ENV:PSModulePath.Split(';')

## look at the loaded modules

Get-Module

## Look at the available modules

Get-Module -ListAvailable

## If we want to know what is in a module we can run

Get-Command -Module Hyper-V  # pick a module name from the available modules

## look at the loaded modules again and notice the one you named above has been added

Get-Module

# you can see it has been loaded already as this line runs quicker now

Get-Command -Module Hyper-V  

# Modules installed in Windows Server 2016 Technical Preview and Windows 10 
Start-Process "https://technet.microsoft.com/en-us/library/mt156917.aspx"

## Use the command Add-on to run a command Get-service

## Lets close the command add-on and work in  PowerShell!

## Find some commands

Get-Command Show-C*

## LIke the add-on but at the command line :-)

Show-Command Get-Service

## You can filter however you want

# by verb
Get-Command -Verb Get
Get-Command -Verb Add, Remove
#by noun
Get-Command -Noun Job
Get-Command -Noun Service
## Or put them together
Get-Command -Verb get, Set -Noun Service, Process
## the * is the wildcard
Get-Command -Name *SQL*
Get-Command -Name Get*SQL*
Get-Command -Name *SQL*key

## How would we find a command for the date ?



### USE TAB !!!!!!!!!!!!
## Place you cursor after each line and press TAB.

Get-Da
Get-Date -Y 
Get-Date -Year 2018 -M

## Aliases - FOR THE CLI only
## All the aliases
Get-Alias
##Alias for a command
Get-Alias -Definition *Process
## Whats the alias in that script
Get-Alias -name %

## How do we know how to use a command?

Get-Command *help*
Get-Help
Get-Help Get-ChildItem
Get-Help Get-ChildItem -Examples
Get-Help Get-ChildItem -Full
Get-Help Get-ChildItem -ShowWindow
Get-Help Get-ChildItem -Online

## and you can pipe from Get-Comand to Get-Help

Get-Command *Childi* | Get-Help

## The pipe takes the objects from the left hand side of the command and passes them to the right hand side

## example

New-Item c:\temp\NewText.txt -ItemType File -Force
Add-Content -Value "This is a test text file" -Path c:\temp\NewText.txt

Get-ChildItem c:\temp\*text.txt
Get-ChildItem c:\temp\*text.txt | Select FullName
Get-ChildItem c:\temp\*text.txt | Get-Content
Get-ChildItem c:\temp\*.txt| Out-GridView -PassThru | Invoke-Item

## Learning the syntax

## Use Snippets
## CTRL + J
## Foreach loop
## function


## You can add your own snippets Here are some I use

Start-Process 'https://github.com/SQLDBAWithABeard/Functions/blob/master/Snippets%20List.ps1'

## My snippet to create a snippet!!

$snippet1 = @{

 Title = 'New-Snippet'
 Description = 'Create a New Snippet'

 Text = @"
`$snippet = @{
 Title = `'Put Title Here`'
 Description = `'Description Here`'
 Text = @`"
 Code in Here 
`"@
}
New-IseSnippet @snippet
"@

}

New-IseSnippet @snippet1 –Force

## Exploring

# The best way to find out what you have and how to use it is to use Get-Member
# As I generally do this at the command line I use the alias gm

Get-Service | Gm

# However a better way is to se thte results to a variable

$A = Get-Service -ComputerName Rob-XPS

$A | Gm

# This way the variable is held in memory

$a

## Now we can access the properties

$a.ServiceName 

# Using a foreach the $_ refers to "This"

$a.Foreach{$_.ServiceName }

## Use a loop

foreach($beard in $a)
{
$beard.ServiceName 
}

## use the pipe

$A | ForEach-Object {$_.ServiceName }

## Use select

$A | Select-Object ServiceName 

## NEVER forget that PowerShell Loves Objects and You should too

$a | Out-file C:\temp\Services.txt
notepad C:\temp\Services.txt

$A | Out-GridView -PassThru | Out-file C:\temp\ServiceOGV.txt
notepad C:\temp\ServiceOGV.txt

$a | ConvertTo-Csv | Out-File c:\temp\servicesCSV.csv
notepad c:\temp\servicesCSV.csv

Send-MailMessage -Body $a -From mrrobsewell@outlook.com -SmtpServer SMPT.Beard.Local -To Servicedesk@Beard.local -Subject "Oh no. It all failed" -Priority High

$a | ConvertTo-Html | Out-File c:\temp\services.html
Start-Process c:\temp\services.html


## Create an excel sheet
$filename = 'C:\temp\Services.xlsx'
rm $filename -force -ErrorAction SilentlyContinue
$xl = new-object -comobject excel.application
$xl.Visible = $true # Set this to False when you run in production
$wb = $xl.Workbooks.Add() # Add a workbook
$ws = $wb.Worksheets.Item(1) # Add a worksheet
$ws.Name = 'Services'

$cells=$ws.Cells
$row = 2
$col = 2

$cells.item($row,$col)="Machine Name"
$cells.item($row,$col).font.size=16
$Cells.item($row,$col).Columnwidth = 10
$col++
$cells.item($row,$col)="Service Name"
$cells.item($row,$col).font.size=16
$Cells.item($row,$col).Columnwidth = 10
$col++
$cells.item($row,$col)="Status"
$cells.item($row,$col).font.size=16
$Cells.item($row,$col).Columnwidth = 10
$col++
$row ++
foreach($S in $a)
{
$col = 2
$cells.item($row,$col)= $S.MachineName
$col++
$cells.item($row,$col)=$S.ServiceName
$col++
$cells.item($row,$col)=$S.Status.ToString()
if($s.Status -eq 'Stopped')
{
$cells.item($row,$col).Interior.ColorIndex = 3 #Red
}
else
{
$cells.item($row,$col).Interior.ColorIndex = 4 #green
}
$row++
}
 
$wb.Saveas($filename)
$xl.quit()

Start-process $filename
## LAB

# Find some commands using wildcards

# Find the aliases for Get-ChildItem
# find the command that uses the alias pwd
# Find Help for a command
## The SQL Server Provider is just like Object Explorer in SSMS (Sort of)
##

## NOTE: Get the SSMS latest release from here https://sqlps.io/dl

Import-Module SqlServer

## PowerShell has PSDrives which enable you to navigate resources like directories

Get-PSDrive

## See the SQLSERVER Drive? Lets navigate to that

CD SQLSERVER:\
DIR;

## You can use the aliases you know in PowerShell like dir cd ls rm md etc
## But as you should never use aliases in scripts I am going to teach you using 
## the fully qualified names for the commands - just remember you can use the aliases

## What's inside SQLRegistration?

Set-Location SQLSERVER:\SQLRegistration
Get-ChildItem

Set-Location 'Database Engine Server Group'
Get-ChildItem

## Its my registered servers

Set-Location BEARDNUC
Get-ChildItem
Get-ChildItem | Select -Last 1 | Select *

$allservers = (Get-ChildItem).Where{$_.Name -ne 'SQL2008Ser2008' -and $_.name -ne 'LinuxvvNext' }.Name
$allservers

# Use the dbatools module from https://dbatools.io to get information
# Simply because it is so beautifula dn everyone should know about it

# How long has my estate been up?

Get-DbaUptime -SqlServer $allservers  | ogv

# Which port?

Get-DbaTcpPort -SqlServer $allservers | ogv

## My latency 

Test-SqlNetworkLatency  $allservers | ogv

## Free Space

Get-DbaDatabaseFreespace -SqlServer $allservers | ogv

## Which protocol

Get-DbaClientProtocol $allservers | Out-GridView 

## Last backup?

Get-DbaLastBackup  $allservers | Out-GridView

## Last Good CheckDB ?

Get-DbaLastGoodCheckDb -SqlServer $allservers -Detailed | ogv

## just to show that (some) work on Linux

$cred = Get-Credential

Get-DbaUptime -SqlServer linuxvvnext -SQLCredential $cred
Get-DbaTcpPort -SqlServer linuxvvnext -SQLCredential $cred
Test-SqlNetworkLatency -Sqlserver linuxvvnext -SQLCredential $cred
Get-DbaLastBackup -SqlServer linuxvvnext -Credential $cred | Format-Table -AutoSize
Get-DbaLastGoodCheckDb -SqlServer linuxvvnext -Credential $cred |Format-Table -AutoSize

## Check out the website for a WHOLE LOAD MORE COMMANDS :-)

## Lets Connect to SQL Server

Set-Location SQLSERVER:\SQL 
Get-ChildItem 

## Thats the local machine lets have look inside that 'folder'

$SQLServer = $env:COMPUTERNAME
Get-ChildItem .\$SQLServer

Set-Location SQLSERVER:\SQL\$SQLServer
Get-ChildItem 

## I have Two Instances

Get-ChildItem SQLSERVER:\SQL\ROB-XPS\DEFAULT
Get-ChildItem SQLSERVER:\SQL\ROB-XPS\DAVE

## NOTE: You can connect to remote servers too

Get-ChildItem SQLSERVER:\SQL\SQL2016N1

## NOTE: You can create SQL Authentication SQL SERVER PSDrives as well


New-PSDrive -Name  SQLServerWithSA -PSProvider SqlServer -Credential (Get-Credential -UserName SA -Message 'Enter SA Credentials') -Root "SQLSERVER:\SQL\$SQLSERVER\Default"

Set-Location SQLServerWithSA:\


## NOTE: We can take results and send them straight into a variable. 
## When we do that, PowerShell takes care of checking to see if a variable by 
## that name exists already, and assigns a data type to it based on what is being piped in.
## You can assign your own data type if you wish. 

Set-Location SQLSERVER:\SQL\$SQLServer
$Instance = Get-Item DEFAULT

## What do we have?

$Instance.GetType()

## A SMO Server Object

## NOTE: This is exactly the same as doing this

$Instance = New-Object Microsoft.SqlServer.Management.Smo.Server $SQLServer
$Instance.GetType()

## But tbh these days I use the dbatools module as it has better error handling adn pre-loads

$Instance = Connect-DbaSqlServer $SQLServer
$Instance.GetType()

## Lets create a database for this demo. This code will download a 4Mb .bak file 
## to your default backup directory and restore it as ProviderDemo using your default file paths

$defaultbackup = $Instance.BackupDirectory
$BackupFile = "$defaultbackup\ProviderDemo.bak" 
Invoke-WebRequest -Uri 'https://onedrive.live.com/download?cid=C802DF42025D5E1F&resid=C802DF42025D5E1F%21418412&authkey=ACrHu72Apu0dIsQ' -OutFile $BackupFile
$DataFile = $($Instance.DefaultFile) + 'ProviderDemo.mdf'
$LogFile = $($Instance.DefaultLog) + 'ProviderDemo.ldf'
$RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("ProviderDemo", $DataFile)
$RelocateLog = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("ProviderDemo_Log", $LogFile)
Restore-SqlDatabase -ServerInstance $SQLServer -Database ProviderDemo -BackupFile $BackupFile -ReplaceDatabase -RestoreAction Database -RelocateFile @($RelocateData,$RelocateLog)

#Using Script parameter you can see its just T-SQL

Restore-SqlDatabase -ServerInstance $SQLServer -Database ProviderDemo -BackupFile $BackupFile -ReplaceDatabase -RestoreAction Database -RelocateFile @($RelocateData,$RelocateLog) -script

## But for now we will stick with a local machine and the PSDrive
## Lets take a look at the databases on this machines default instance

Set-Location SQLSERVER:\SQL\$SQLServer\DEFAULT
Get-ChildItem .\Databases |ft -AutoSize -Wrap

## So we can navigate these as if they were a file structure and they 
## basically match the Object Explorer

$DbName = 'ProviderDemo' ## Change this if you are not using the demo database

## Database
Set-Location Databases\$DbName 
Get-ChildItem

## Tables
Set-Location Tables
Get-ChildItem

## A Table
Set-Location dbo.InstanceList
Get-ChildItem

## Columns
Set-Location Columns
Get-ChildItem

## Or Indexes

Set-Location .\..\Indexes
Get-ChildItem 

## OK thats cool, we can see those things but what else?
## Lets go back to databases

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases

## So we can display some properties just like in SSMS (Show in SSMS here)

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
Get-Item $DbName | Select-Object Name, Size, DataSpaceUsage, IndexSpaceUsage, SpaceAvailable

Get-Item $DbName | Get-Member

## Lets have a look at some tables

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
Get-ChildItem .\$DbName\Tables |
Select-Object Schema, Name, DataSpaceUsed, IndexSpaceUsed, RowCount, HasCompressedPartitions, HasClusteredColumnStoreIndex |
Format-Table -AutoSize

## You can output this to Out-GridView for a different experience which allows you to filter

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
Get-ChildItem .\$DbName\Tables |
Select-Object Schema, Name, DataSpaceUsed, IndexSpaceUsed, RowCount, HasCompressedPartitions, HasClusteredColumnStoreIndex |
Out-GridView

## This can be really useful for enabling user choice

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
Get-ChildItem .\$DbName\Tables |Out-GridView -Title 'Choose a table and press ok' -PassThru |
Select-Object Schema, Name, DataSpaceUsed, IndexSpaceUsed, RowCount, HasCompressedPartitions, HasClusteredColumnStoreIndex 

## How do I know what properties there are?
## Look in SSMS Object Explorer or

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
Get-ChildItem .\$DbName\Tables |Get-Member -MemberType Property

## Not sure which property you want? (Select * isnt bad here :-) )

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
Get-Item $DbName  | Select *

## Brilliant, we can get properties, we can enable user choice, I want to DO something

## Lets script out our table using Out-GridView to choose the table
Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
$MeTable = Get-ChildItem .\$DbName\Tables |Out-GridView -Title 'Choose a table and press ok' -PassThru 
$MeTable.script()

## And put the script in a file
## NOTE: Using $($Variable.Property) allows you to expand the property inside a string

$MeTable.script() | Out-File C:\Temp\$($MeTable.Name).sql
Invoke-Item C:\Temp\$($MeTable.Name).sql

## How do I know what I can do?
## Remember Get-Member ? You can use -MemberType Method
## NOTE: You WILL use Get-Member a lot - for the rest of your days with PowerShell :-)

$MeTable | Get-Member -MemberType Methods

## Looping
## There are a number of ways to loop through a collection
## Lets put our tables into a variable

Set-Location SQLSERVER:\SQL\$SqlServer\DEFAULT\Databases
$tables = Get-ChildItem .\$DbName\Tables

## Use ForEach-Object sometimes shortened to foreach and often to % (Pet Peeve :-) )
## the $_ refers to the item in the collection

$Tables | Foreach-Object {"$_"}

## Use the foreach method for PS V4 and above - the $_ refers to the item

$Tables.ForEach{"$_"}

## Use foreach NOTE: You can refer to the item in the collection by any name!!

foreach($Footballer in $tables)
{
    "$Footballer"
}

## You CAN but that doesnt mean it is a good thing - Use names that make it
## easy for the next Gal or Guy reading your script please

foreach ($table in $Tables)
{
    "$Table"
}

## Wow - You've looped through and printed the names
## NOPE - This isnt a PRINT statement :-)
## NOTE: In PowerShell EVERYTHING is an object (except when you format it out to the host)

## NOTE: The variables 'stick' during your session 
## so lets look at the last table in the collection

$table 

## what type of object is it?

$table.GetType()

## Look at its properties - You can use Get-Member $table | get-member -MemberType Properties

$table|Select *

## look at its methods
$table | get-member -MemberType Methods

## So now we can start to do useful things
## Lets look at our statistics

foreach ($table in $Tables)
{
    $Table | Select-Object Name,Statistics
}

## Hmm - we can loop within our loop

foreach ($table in $Tables)
{
    foreach($Stats in $table.Statistics)
    {
        $stats | Select Name, LastUpdated
    }
}

## But we dont know always which table belongs to which Statistic
## NOTE: Here is a cool trick to access other properties or calculate properties in your select

foreach ($table in $Tables)
{
    foreach($Stats in $table.Statistics)
    {
        $TableName = @{Name ='The Table Name'; Expression ={$table.Name}}
        $stats | Select $tablename ,Name, LastUpdated
    }
}

## SQL Community User Voice - about the https://sqlps.io/vote

## Manufactured example we could have used Parent - most objects have a parent property

foreach ($table in $Tables)
{
    foreach($Stats in $table.Statistics)
    {
        $stats | Select Parent ,Name, LastUpdated
    }
}

## Remember we had a UpdateStatistics method? (Code works on V4 and above only)
## Use $Tables | Where-Object {$_.Name -like 'Agent*'} on V3 
## NOTE: You can evaluate expresions for your foreach loop

foreach($table in $tables.Where{$_.Name -like 'Agent*'})
{
    $table.UpdateStatistics()
}

## Now lets check
## NOTE: Here is another way to loop through a collection and retrieve properties

$tables.Where{$_.Name -like 'Agent*'}.Statistics |Select-Object Parent ,Name, LastUpdated

## Hang on Didnt we just update those Statistics ?
## NOTE: The object doesnt update with changes - Just like SSMS doesn't - You have to press refresh :-)
## Theres a method for that

$tables.Where{$_.Name -like 'Agent*'}.Statistics.Refresh()
$tables.Where{$_.Name -like 'Agent*'}.Statistics |Select-Object Parent ,Name, LastUpdated

##  SQL Server Provider Lab

## 1 
## Using the SQLServer Provider list the logins on the default server
## 2
## List the logins that are disabled showing their Name, Default Database, Create Date and Login type
## 3
## List the name of the two oldest created Logins on the server
## 4
## Use Out-GridView to select 3 logins and display their name, if they have connect permissions and 
## their SID and then save that information to a file
## 5
## Using the SQL Provider list the members of the sysadmin role and
##  as good exams say, show your working out


## SQL Server Provider Answers

## 1

## To list the logins
$SQLServer = $env:COMPUTERNAME
$InstanceName = 'DEFAULT'
Set-Location SQLSERVER:\SQL\$SQLServer\$InstanceName
Get-ChildItem .\Logins

## 2
Set-Location SQLSERVER:\SQL\$SQLServer\$InstanceName\Logins
Get-ChildItem | Where-Object {$_.IsDisabled -eq $true} | Select Name, DefaultDatabase, CreateDate, LoginType

## 3

Set-Location SQLSERVER:\SQL\$SQLServer\$InstanceName\Logins
Get-ChildItem | Sort-Object CreateDate -descending | Select-Object -first 2 | Select-Object Name

## 4 

Set-Location SQLSERVER:\SQL\$SQLServer\$InstanceName\Logins
Get-ChildItem | Out-GridView -PassThru | Select Name, HasAccess,SID |Out-File c:\temp\answer4.txt
Invoke-Item c:\temp\answer4.txt 

## 5
Set-Location SQLSERVER:\SQL\$SQLServer\$InstanceName\
Get-ChildItem
Set-Location   Roles
Get-ChildItem | Get-Member
$sysadmin = Get-ChildItem | Where-Object {$_.Name -eq 'sysadmin'}
## also an acceptable answer 
$roles = Get-ChildItem
$sysadmin = $roles['sysadmin']
$sysadmin | Get-Member
$sysadmin.EnumMemberNames()


cd presentations:\
Return 'Oi Beardy, You may be an MVP but this is a demo, don''t run the whole thing, fool!!'

## We are going to use the development branch because it's cool and has all the latest funky
## The aim is for this to be released on Tuesday
## *Some things may not work* :-)
## You should use Install-Module dbatools -Scope CurrentUser

Import-Module GIT:\dbatools\dbatools.psd1
$cred = Import-Clixml C:\MSSQL\sa.cred

## Lets look at the commands
Get-Command -Module dbatools 

## How many Commands?
(Get-Command -Module dbatools).Count

## How do we find commands?
Find-DbaCommand -Tag Backup
Find-DbaCommand -Tag Restore
Find-DbaCommand -Tag Migration
Find-DbaCommand -Tag Agent
Find-DbaCommand -Pattern User 
Find-DbaCommand -Pattern linked

## How do we use commands?

## ALWAYS ALWAYS use Get-Help

Get-Help Test-DbaLinkedServerConnection -Full

## Here a neat trick

Find-DbaCommand -Pattern Index | Out-GridView -PassThru | Get-Help -Full 

## OK Migrations are a brilliant way to start
## Lets look at the two instances in SSMS

## Now lets migrate EVERYTHING from one to the other with one line of code :-)

Start-DbaMigration -Source ROB-XPS\SQL2016 -Destination ROB-XPS\Bolton -BackupRestore -NetworkShare \\ROB-XPS\MIGRATION

## Everyone tests their restores correct?
## Lets back up those new databases to a Network Share
Backup-DbaDatabase -SqlInstance Rob-XPS\Bolton -BackupDirectory \\ROB-XPS\Migration 

#Open up the default file location 
Import-Module SqlServer
Invoke-Item (Get-Item SQLSERVER:\SQL\Rob-XPS\Bolton).DefaultFile

# and test ALL of our backups :-)
Test-DbaLastBackup -SqlInstance Rob-XPS\Bolton | Out-GridView

## You 'Could' just verify them
Test-DbaLastBackup -SqlInstance Rob-XPS\Bolton -Destination Rob-XPS\SQL2016 -VerifyOnly | Out-GridView

## So you can see there are a lot of backup and restore and copy commands available. I urge you to explore them
## Use Find-DbaCommand
## Take a look at the Community presentations 

Start-Process 'https://github.com/sqlcollaborative/community-presentations'

## Lets look at how easy it is to get information about one or many sql server instances from the command line with one line of code

## What are my default paths ?

Get-DbaDefaultPath -SqlInstance ROB-XPS\Bolton , Rob-XPS\SQL2016 

## You could use Pester to repeatedly test instances

Describe "Testing my Defaults" {
    Context "Paths" {
        $cred = Import-Clixml C:\MSSQL\sa.cred
        $Instances = 'ROB-XPS\Bolton', 'ROB-XPS\SQL2016', 'Bolton'
        $testCases = @()
        $Instances.ForEach{$testCases += @{Instance = $_}}
        $default = [pscustomobject]@{Data = 'C:\MSSQL\DATA'
            Log = 'C:\MSSQL\LOGS'
            Backup = 'C:\MSSQL\Backup'
        }
        It "<Instance> Should have default paths" -TestCases $TestCases {
            param($Instance)
            $InstanceDefaults = Get-DbaDefaultPath -SqlInstance $Instance -SqlCredential $cred
            $InstanceDefaults.Data | Should Be $default.Data 
            $InstanceDefaults.Log | Should Be $default.Log  
            $InstanceDefaults.Backup | Should Be $default.Backup
        }
    }
}

## Yep It works with SQL on Linux too :-)


## Where are my Error logs?

Get-DBAErrorLogPath -Instance rob-xps\bolton -Agent

## I want to read my logs too

Get-DbaAgentLog -SqlInstance rob-xps\sql2016 | Out-GridView

Get-DbaSqlLog -SqlInstance ROb-xps\SQL2016  | Out-GridView

Get-DbaDbMailLog -SqlInstance rob-xps\SQL2016 ## I dont have any mail logs :-(

## What about my Jobs?

Get-DbaAgentJobHistory -SqlInstance rob-xps\sql2016 -StartDate (Get-Date).AddDays(-2)

## Backup history?
Get-DbaBackupHistory -SqlInstance Rob-XPS\Bolton 

#More Detail
Get-DbaBackupHistory -SqlInstance Rob-XPS\Bolton  | select -First 1 | Select *

#Restore History ?
Get-DbaRestoreHistory -SqlInstance Rob-XPS\BOLTON -Last

## more detail
Get-DbaRestoreHistory -SqlInstance Rob-XPS\BOLTON -Last | select -First 1 | Select *

# I dont have any but DbMail History
Get-DbaDbMailHistory -SqlInstance Rob-XPS\SQL2016 

## Who changed my database and what did they do?
## This relies on the default trace so it wont be permanent
Get-DbaSchemaChangeHistory -SqlInstance rob-xps\sql2016 -Database DBA-Admin

## Are my alerts set up ?

Get-DbaAgentAlert -SqlInstance Rob-xps\Bolton

## Excellent - Perhaps I need a pester test for those for my default setup

Describe "Testing my Defaults" {
    Context "Alerts" {
        $cred = Import-Clixml C:\MSSQL\sa.cred
        $Instances = 'ROB-XPS\Bolton', 'ROB-XPS\SQL2016', 'Bolton'
        $testCases = @()
        $Instances.ForEach{$testCases += @{Instance = $_}}
        It "<Instance> Should have at least 12 Alerts" -TestCases $TestCases {
            param($Instance)
            (Get-DbaAgentAlert -SqlInstance $Instance -SqlCredential $cred).Count |Should BeGreaterThan 11 

        }
        $Alerts = 'custom alert', 'Error Number 823', 'Severity 016', 'Severity 017', 'Severity 018', 'Severity 019', 'Severity 020', 'Severity 021', 'Severity 022', 'Severity 023', 'Severity 024', 'Severity 025'
        foreach ($alert in $Alerts) {
            It "<Instance> Should have Alert - $Alert" -TestCases $TestCases {
                param($Instance)
                (Get-DbaAgentAlert -SqlInstance $Instance -SqlCredential $cred).Name.Contains($Alert) | Should Be $True
            }
        }
    }
}

## SHow me the views in a database (now we will use the SQL on Linux server because we can - but they work on Windows too!!)

Get-DbaDatabaseView -SqlInstance bolton -SqlCredential $cred -Database WideWorldImporters -ExcludeSystemView

## Show Me UDFs in database or on an instance

Get-DbaDatabaseUdf -SqlInstance bolton -SqlCredential $cred -Database WideWorldImporters -ExcludeSystemUdf

## Show me Database Partition functions

Get-DbaDatabasePartitionFunction -SqlInstance bolton -SqlCredential $cred -Database WideWorldImporters 

# more detail

Get-DbaDatabasePartitionFunction -SqlInstance bolton -SqlCredential $cred -Database WideWorldImporters | Select *

## Show Database Partition Schemes

Get-DbaDatabasePartitionScheme -SqlInstance bolton -SqlCredential $cred -Database WideWorldImporters 

# more detail
Get-DbaDatabasePartitionScheme -SqlInstance bolton -SqlCredential $cred -Database WideWorldImporters | Select *


# Maybe you want to look at execution plans
# C:\Users\mrrob\OneDrive\Documents\GitHub\Presentations\DBAReports Demo\DBA Reports Demo\DBA Reports Demo\01 - DBA Reports Demo.sql

Get-DbaExecutionPlan -SqlInstance Rob-XPS\SQL2016 | Out-GridView

## My Favourite
## How do you get the last DBCC CheckDB date ? DBCC DBINFO([DBA-Admin]) WITH TABLERESULTS

## So How long to get the Last Known Good Check DB Date for many databases on many instances?

## This long for 3 instances and 32 databases :-)

Measure-Command {Get-DbaLastGoodCheckDb -SqlInstance ROB-XPS\SQL2016, ROB-XPS\BOLTON , Bolton -SqlCredential $cred | Out-GridView}

## Of course I wrote a Pester Test for this :-)
## You can find them on my blog or https:\\github.com\SQLDBAWithABeard\dbatools-scripts

Describe "SQL Server Tests" {
    Context "DBCC Checks" {
        $SQLServers = 'ROB-XPS\SQL2016', 'ROB-XPS\BOLTON' , 'Bolton'
        foreach ($Server in $SQLServers) {
            $DBCCTests = Get-DbaLastGoodCheckDb -SqlServer $Server -SqlCredential $cred -ExcludeDatabase tempdb -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            foreach ($DBCCTest in $DBCCTests) {
                It "$($DBCCTest.SQLInstance) database $($DBCCTest.Database) had a successful CheckDB" {
                    $DBCCTest.Status | Should Be 'Ok'
                }
                It "$($DBCCTest.SQLInstance) database $($DBCCTest.Database) had a CheckDB run in the last 7 days" {
                    $DBCCTest.DaysSinceLastGoodCheckdb | Should BeLessThan 7
                    $DBCCTest.DaysSinceLastGoodCheckdb | Should Not BeNullOrEmpty
                }   
                It "$($DBCCTest.SQLInstance) database $($DBCCTest.Database) has Data Purity Enabled" {
                    $DBCCTest.DataPurityEnabled| Should Be $true
                }    
            }
        }
    }
}

## Of course, those new databases wont have 

(Get-DbaAgentJob -SqlInstance rob-xps\bolton -Job 'DatabaseIntegrityCheck - SYSTEM_DATABASES', 'DatabaseIntegrityCheck - USER_DATABASES').Start()
Get-DbaAgentJob -SqlInstance rob-xps\bolton -Job 'DatabaseIntegrityCheck - SYSTEM_DATABASES', 'DatabaseIntegrityCheck - USER_DATABASES'

## There are a WHOLE load more Gets

Get-Command -module dbatools Get*

## How about Finding things

## Can you find me the Agent jobs without a schedule

Find-DbaAgentJob -SqlInstance bolton -SqlCredential $cred -NoSchedule

## Can you find me the Duplicate indexes please

Find-DbaDuplicateIndex -SqlInstance bolton -SqlCredential $cred -Database AdventureWorks2014

## Can you find that stored procedure please, you know, the one with the email address, I think its on that Linux instance 

Find-DbaStoredProcedure -SqlInstance bolton -SqlCredential $cred -Pattern '\w+@\w+\.\w+'

## Hmm, ok its on one of them

Find-DbaStoredProcedure -SqlInstance bolton, Rob-xps\SQL2016, Rob-xps\Bolton  -SqlCredential $cred -Pattern '\w+@\w+\.\w+'

## Can you find me the view with the sensor data?

Find-DbaView -SqlInstance bolton -SqlCredential $cred -Pattern sensor

## Can you find me the trigger with TotalPurchaseYTD

Find-DbaTrigger -SqlInstance bolton -SqlCredential $cred -Pattern TotalPurchaseYTD

## There are plenty more Finds - I like Find-DbALoginInGroup

Find-DbaCommand Find*

## What depends on this table. Which table? I'll know it when I see it (bottom one)

Get-DbaTable -SqlInstance bolton -SqlCredential $cred -Database WideWorldImporters | Out-GridView -PassThru | Get-DbaDependency

## What does that table depend on? (OrderLines)
$Depends = Get-DbaTable -SqlInstance bolton -SqlCredential $cred -Database WideWorldImporters | Out-GridView -PassThru | Get-DbaDependency -Parents 
$Depends

# but the object returns more than that lets look at the first 1
$Depends| Select -First 1 | Select *

## everyone uses sp_whoisactive

Invoke-DbaWhoisActive -SqlInstance bolton -SqlCredential $cred -ShowOwnSpid|Out-GridView

## How about something cool with Glenn Berrys Diagnostic Queries ?

Invoke-DbaDiagnosticQuery -SqlInstance Rob-XPS\SQL2016 | Out-GridView

## Great Rob - I want to save it to look at it and analyse it though

## OK - Andre thought of that too

## Oh and it works against a Linux Instance too :-) ## Takes about 4 minutes
$Suffix = 'Manchester_' + (Get-Date -Format yyyy-MM-dd_HH-mm-ss)
Invoke-DbaDiagnosticQuery -SqlInstance Bolton -SqlCredential $cred | Export-DbaDiagnosticQuery -Path C:\temp\Diagnostics -Suffix $Suffix
explorer c:\temp\diagnostics

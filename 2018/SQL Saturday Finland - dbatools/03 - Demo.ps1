#region Setup Variables
. .\vars.ps1
#endregion

#region Reset Admin

Get-DbaLogin -SqlInstance $sql1 |Format-Table

Reset-DbaAdmin -SqlInstance $SQL1 -Login TheBeard 

Get-DbaLogin -SqlInstance $sql1 |Format-Table

## connect in SSMS and run 

<#
    USE tempdb
    GO

    CREATE TABLE PlaceForTheStolenThings
    (
	StolenThingsID int NOT NULL, 
	UserName nvarchar(30) NULL, 
	Email nvarchar(50) NULL,
	IsAdmin bit NULL,
	UserPassword nvarchar(150) NULL, 
	ADGroupMembership nvarchar(MAX) NULL
    CONSTRAINT StolenThings PRIMARY KEY (StolenThingsID)
    )
    GO

    
    BEGIN TRAN
    INSERT INTO PlaceForTheStolenThings VALUES
    (1,'TheBoss','Boss@TheBeard.Local', 1,'WhyDoesItHaveToBeLikeThis','Domain Admin,Bosses Secret Group')

#>
#endregion

#region Wotcha doing ?

# Does resetting admin command mean any admin can create their own sysadmin account?
## Yes it does
## So why not source control your logins like Claudio Silva does http://redglue.eu/have-you-backed-up-your-sql-logins-today/?
Export-DbaLogin -SqlInstance $sql1

## You can do it to a file adn then source control it

Export-DbaLogin -SqlInstance $sql1 -FilePath c:\temp\sql1_users.sql

## But maybe you want to see what is going on

Get-DbaProcess -SqlInstance $sql1

Get-DbaProcess -SqlInstance $sql1 |Out-GridView

## Hmm what is that TheBeard doing?

Get-DbaProcess -SqlInstance $sql1 -Login TheBeard|Out-GridView

## Oh

## Email from manager

New-BurntToastNotification -Text  'FROM THE BOSS - Keep this CONFIDENTIAL', 'I NEED to know immediately what the user account TheBeard did on SQL1 DROP EVERYTHING and DO IT NOW','Angry Manager' -AppLogo C:\Users\enterpriseadmin.THEBEARD\Desktop\angryboss.jpg

## Hmm Better get onto this quick

Get-DbaProcess -SqlInstance $sql1 -Login TheBeard | Out-GridView

Read-DbaTraceFile -SqlInstance $sql1 -Login TheBeard | Out-GridView

Get-DbaSchemaChangeHistory -SqlInstance $sql1 -Database tempdb

## Maybe you like sp_WhoIsActive?

## easy to install
Install-DbaWhoIsActive -SqlInstance $sql1 -Database tempdb

## easy to use
Invoke-DbaWhoisActive -SqlInstance $sql1 | Out-GridView

## Thats it Get him off my instance

Get-DbaProcess -SqlInstance $sql1 -Login TheBeard | Stop-DbaProcess -confirm:$false

Get-DbaProcess -SqlInstance $sql1 -Login TheBeard

## In fact I don't want his login there

Get-DbaLogin -SqlInstance $sql1 -Login TheBeard | Remove-DbaLogin -Confirm:$false

## Much better :-)

#endregion

#region Clones

## Maybe we want to test query performance without requiring all the space needed for the data in the database

Invoke-DbaDatabaseClone -SqlInstance $sql0 -Database AdventureWorks2014 -CloneDatabase AdventureWorks2014_CLONE -UpdateStatistics

## Now run in SSMS

<#

    USE [AdventureWorks2014];
    GO
 
    SELECT *
    FROM [Sales].[SalesOrderHeader] [h]
    JOIN [Sales].[SalesOrderDetail] [d] ON [h].[SalesOrderID] = [d].[SalesOrderID]
    ORDER BY [SalesOrderDetailID];
    GO
 
    USE [AdventureWorks2014_CLONE];
    GO
 
    SELECT *
    FROM [Sales].[SalesOrderHeader] [h]
    JOIN [Sales].[SalesOrderDetail] [d] ON [h].[SalesOrderID] = [d].[SalesOrderID]
    ORDER BY [SalesOrderDetailID];
    GO
#>

#endregion

#region SPNs

Get-DbaSpn -ComputerName $sql0

setspn.exe -D "MSSQLSvc/SQL0.TheBeard.Local:1433" "TheBeard\EnterpriseAdmin"

Test-DbaSpn -ComputerName $sql0

Get-DbaSpn -ComputerName $sql0

(Test-DbaSpn -ComputerName $sql0).Where{$_.IsSet -eq $false} | Set-DbaSpn -WhatIf
(Test-DbaSpn -ComputerName $sql0).Where{$_.IsSet -eq $false} | Set-DbaSpn

Get-DbaSpn -ComputerName $sql0
#endregion

#region Find the thing

Find-DbaStoredProcedure -SqlInstance $SQL2017Container -Pattern employee  -SqlCredential $cred
$new | Find-DbaStoredProcedure -Pattern dbatools | Select * | Out-GridView
$new | Find-DbaStoredProcedure -Pattern '\w+@\w+\.\w+'

#endregion

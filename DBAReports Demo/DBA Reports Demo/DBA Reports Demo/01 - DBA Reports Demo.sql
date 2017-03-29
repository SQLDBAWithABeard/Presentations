/* 
Various queries for getting information out of the DBA Reports
Use 
where IL.Inactive = 0 
to only get active instances
*/


-- Generic information about Servers and locations and environments

USE [DEMOdbareports]
GO

Select IL.ServerName,
		IL.InstanceName,
		IL.Environment,
		IL.location
FROM dbo.InstanceList IL
--   where IL.Environment = 'Prod'
--   AND IL.Location = 'Bolton'

-- Generic infromation about servers and clients

Select
		DISTINCT C.ClientName,
		IL.ServerName
FROM dbo.InstanceList IL
JOIN
dbo.ClientDatabaseLookup CDL
ON
CDL.InstanceID = IL.InstanceID
JOIN dbo.Clients C
ON c.ClientID = cdl.ClientID
WHERE C.ClientName <> 'DBA-Team' ---- AND C.ClientName = '' -- AND IL.ServerName = '' 
group by C.ClientName ,ServerName


-- Generic SQL Instance Information Specifics can be picked from the SQLInfo table as required - The date checked value will show how up to date the data is

Select IL.ServerName,
		IL.InstanceName,
		IL.Environment,
		IL.location,
		SI.*
FROM dbo.InstanceList IL
JOIN info.SQLInfo SI
ON SI.instanceid = IL.InstanceID
--- Use the relevant where clause you require here

order by SI.ServerName


-- Generic Windows Information Specifics can be picked from the ServerOSInfo table as required - The date checked value will show how up to date the data is
Select 
		SOI.*
FROM info.serverinfo SOI

-- Pick your required where clause here

-- Generic Database Information Specifics can be picked from the Databases table as required - The date checked value will show how up to date the data is

Select IL.ServerName,
		IL.InstanceName,
		IL.Environment,
		IL.location,
		D.*
FROM dbo.InstanceList IL
JOIN info.Databases D
ON D.InstanceID = IL.InstanceID
where D.Name = 'Name of Database 175'

-- pick your required where clause here

/* Number of databases without a full backup*/


 SELECT 
 il.Environment
,il.Location
,COUNT(DISTINCT il.ServerName) as 'number of servers'
,COUNT(d.Name) as 'number of databases'
,CAST((SUM(d.SizeMB) / 1024) AS Decimal(7,2)) as 'Size Gb'
 FROM dbo.InstanceList il
 JOIN info.Databases d
 ON il.InstanceID = d.InstanceID
 WHERE d.LastBackupDate = '0001-01-01 00:00:00.0000000'
 GROUP BY Location,Environment


 /* Number of Full databases wihtout a transaction log backup */

 SELECT COUNT(DISTINCT il.ServerName) as 'number of servers'
,COUNT(d.Name) as 'number of databases'
,CAST((SUM(d.SizeMB) / 1024) AS Decimal(7,2)) as 'Size Gb'
,il.Environment
,il.Location
 FROM dbo.InstanceList il
 JOIN info.Databases d
 ON il.InstanceID = d.InstanceID
 WHERE d.LastLogBackupDate = '0001-01-01 00:00:00.0000000'
 and d.RecoveryModel = 'full'
 GROUP BY Location,Environment

---- Job Detail Information is in the AgentJobDetail table this holds information about every job that ran
Select IL.ServerName,
		IL.InstanceName,
		IL.Environment,
		IL.location,
		AJD.*
FROM dbo.InstanceList IL
JOIN info.AgentJobDetail AJD
ON AJD.InstanceID = IL.InstanceID

-- pick your required where clause here - Think about LastRuntime or outcome or server or job name
WHERE AJD.InstanceID 
IN 

(Select IL.InstanceID
FROM dbo.InstanceList IL
WHERE IL.Environment = 'Prod'          ---- This clause is looking for Prod Environment Servers 
AND IL.Location = 'Bolton'
and AJD.JobName LIKE '%Index%')
AND IL.InstanceName = 'JusticeForAll'

and AJD.LastRunTime > DATEADD(day,-1,GETDATE())    --- That finished since yesterday
ORDER by AJD.LastRunTime desc


---- Job Server INformation is in the AgentJobServer table this holds a roll up of each days job records

Select IL.ServerName,
		IL.InstanceName,
		IL.Environment,
		IL.location,
		AJS.*
FROM dbo.InstanceList IL
JOIN info.AgentJobServer AJS
ON AJS.InstanceID = IL.InstanceID

-- pick your required where clause here - Think about LastRuntime or outcome or server or job name
WHERE AJS.InstanceID 
IN  

(Select IL.InstanceID
FROM dbo.InstanceList IL
WHERE IL.Environment = 'Prod'          ---- This clause is looking for Prod Environment Servers in Bolton
and IL.Location = 'Bolton'
AND IL.InstanceName = 'JusticeForAll')

and AJS.Date > DATEADD(day,-1,GETDATE())    --- That were collected since yesterday
ORDER by IL.ServerName


-- Find the server a database is on

SELECT il.ServerName,
	il.InstanceName,
	il.Port,
	d.Name,
    il.Environment,
	c.ClientName,
	cdl.Notes
	FROM info.Databases d
	join dbo.InstanceList il
	on il.InstanceID = d.InstanceID
	join dbo.ClientDatabaseLookup cdl
	on d.DatabaseID = cdl.DatabaseID
	join dbo.clients c
	on cdl.ClientID = c.ClientID
	where d.name LIKE'%172%'
    AND IL.InActive = 0

	/*
This script display information about Client and the database they use

AUTHOR - ROb Sewell
DATE - 31/07/2015 - Initial

*/

SELECT C.ClientName
		,IL.ServerName
		,IL.InstanceName
      ,D.Name
	  ,IL.Environment
	  ,IL.Location
      ,[Notes]
  FROM [dbo].[ClientDatabaseLookup] as CDL
  JOIN [dbo].[Clients] AS C
  ON CDL.ClientID = C.ClientID
  Join [Info].[Databases] AS D
  ON CDL.DatabaseID = D.DatabaseID
  JOIN [dbo].[InstanceList] AS IL
  ON D.InstanceID = IL.InstanceID
  WHERE IL.Inactive = 0  -- Only active Servers
 --- AND ServerName = ''
AND ClientName like '%ll%'

and IL.Environment = 'PROD'	-- production only

and D.Name like '%20%'		-- find database including client name

  ORDER BY 
  ServerName



  --*************************************
  --List Clients
  --*************************************
  
--Check that clientname exists – beware of variant spellings
SELECT [ClientID]
      ,[ClientName]
  FROM [dbo].[Clients]
  order by clientname;

  /* Infomrmation */

Use [DEMOdbareports]
Go

/* Number of Servers */

SELECT COUNT(ServerName) as Servers
,Location
,Environment
 FROM dbo.InstanceList il
 GROUP BY Environment,Location

 /*Number of Servers, Number of Databases, Environment and Location */

 SELECT COUNT(DISTINCT il.ServerName) as 'number of servers'
,COUNT(d.Name) as 'number of databases'
,il.Environment
,il.Location
 FROM dbo.InstanceList il
 JOIN info.Databases d
 ON il.InstanceID = d.InstanceID
 GROUP BY Location,Environment


 /*Size, Number of Servers, Number of Databases, Environment and Location */

 SELECT COUNT(DISTINCT il.ServerName) AS 'number of servers'
,COUNT(d.Name) AS 'number of databases'
,CAST((SUM(d.SizeMB) / 1024) AS Decimal(7,2)) AS 'Size Gb'
 FROM dbo.InstanceList il
 JOIN info.Databases d
 ON il.InstanceID = d.InstanceID

 SELECT 
il.Location 
,il.Environment
,COUNT(DISTINCT il.ServerName) AS 'number of servers'
,COUNT(d.Name) AS 'number of databases'
,CAST((SUM(d.SizeMB) / 1024) AS Decimal(7,2)) AS 'Size Gb'
,il.Environment
,il.Location
 FROM dbo.InstanceList il
 JOIN info.Databases d
 ON il.InstanceID = d.InstanceID
 GROUP BY Environment,Location

 /* Number of Agent Jobs */

 SELECT COUNT(DISTINCT il.ServerName) as 'number of servers'
,SUM(ajs.NumberOfJobs) as 'Total Agent Jobs'
,il.Environment
,il.Location
FROM dbo.InstanceList il
JOIN info.AgentJobServer AJS
ON il.InstanceID = AJS.InstanceID
WHERE DATEDIFF( d, AJS.NumberofJobs, GETDATE() ) >300
GROUP BY Location,Environment


 

/* Databases by Recovery Model */

SELECT 
il.Environment
,d.RecoveryModel
,COUNT(d.Name) as 'number of databases'
 FROM dbo.InstanceList il
 JOIN info.Databases d
 ON il.InstanceID = d.InstanceID
 GROUP BY Environment,d.RecoveryModel

/* OS Operating System*/

SELECT 
SOI.OperatingSystem
,COUNT(DISTINCT il.ServerName) as 'Number of Servers'
 FROM dbo.InstanceList il
 JOIN info.ServerInfo SOI
 on IL.ServerName = SOI.ServerName
 GROUP BY soi.OperatingSystem
 ORDER BY soi.OperatingSystem



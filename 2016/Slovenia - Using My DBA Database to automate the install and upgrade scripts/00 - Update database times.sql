Use [demodbareports]
Go

-- Update Job detail table so that todays date is the latest :-)

-- Check
SELECT GetDATE() as today,
MAX(Date) as maxchecked,
MIN(Date) as Mindate,
MAX(lastruntime) as maxlastrun,
MIN(lastruntime) as minlastruntime,
ABS(DATEDIFF(Day,GetDate(),MAX(Date))) as diff
FROM [Info].[AgentJobDetail]

select COUNT(AgentJobDetailID)
FROM [Info].[AgentJobDetail]
select COUNT(AgentJobDetailID)
FROM [Info].[AgentJobDetail]
Where LastRunTime = '1900-01-01 00:00:00.000'

-- Update
DECLARE @Diff int = ABS((SELECT DATEDIFF(Day,GetDate(),MAX(Date))  FROM [Info].[AgentJobDetail]))
UPDATE [Info].[AgentJobDetail]
SET Date = DATEADD(Day,@Diff,Date)

UPDATE [Info].[AgentJobDetail]
SET LastRunTime = DATEADD(Day,@Diff,LastRunTime)
Where LastRunTime <>'1900-01-01 00:00:00.000'

-- Check again
SELECT GetDATE() as today,
MAX(Date) as maxchecked,
MIN(Date) as Mindate,
	MAX(lastruntime) as maxlastrun,
	MIN(lastruntime) as minlastruntime,
	ABS(DATEDIFF(Day,GetDate(),MAX(Date))) as diff
FROM [Info].[AgentJobDetail]

-- Update Job Server table so that todays date is the latest :-)
-- Check
select COUNT(AgentJobDetailID)
    FROM [Info].[AgentJobDetail]
	  select COUNT(AgentJobDetailID)
    FROM [Info].[AgentJobDetail]
	Where LastRunTime = '1900-01-01 00:00:00.000'

	SELECT GetDATE() as today,
MAX(Date) as maxchecked,
MIN(Date) as Mindate,
	ABS(DATEDIFF(Day,GetDate(),MAX(Date))) as diff
  FROM [Info].[AgentJobServer];

-- Update
DECLARE @Diff1 int = ABS((SELECT DATEDIFF(Day,GetDate(),MAX(Date))  FROM [Info].[AgentJobServer]));
UPDATE [Info].[AgentJobServer]
SET Date = DATEADD(Day,@Diff1,Date)

-- Check again
SELECT GetDATE() as today,
MAX(Date) as maxchecked,
MIN(Date) as Mindate,
ABS(DATEDIFF(Day,GetDate(),MAX(Date))) as diff
 FROM [Info].[AgentJobServer]

--- uypdate the databases table to make last used work correctly

SELECT 
      IL.ServerName
	  ,D.DatabaseID
	  ,D.Name
	  ,d.DateChecked
	  ,DATEDIFF(Day,LastReboot,GetDate())  as DaysSinceReboot
	  ,LastReboot
	  ,CAST(LastReboot as date) as LastRebootDate
	  ,CASE 
	  WHEN [lastRead] = '1900-01-01 00:00:00.000' THEN 99999
	  ELSE DATEDIFF(Day,[LastRead],GetDate())
	  END as DaysSinceLastRead
	  ,[LastRead]
	  ,CASE 
	  WHEN [lastwrite] = '1900-01-01 00:00:00.000' THEN 99999
	  ELSE DATEDIFF(Day,[lastwrite],GetDate()) 
	  END as DaysSinceLastWrite
	  ,[LastWrite]
      
  FROM 
  info.[Databases] d
  JOIN dbo.InstanceList IL
  ON 
  D.InstanceID = IL.InstanceID
  -- WHERE d.DateAdded > DATEADD(Day,-6,GetDate())
  Where [lastwrite] = '1900-01-01 00:00:00.000' AND [lastRead] = '1900-01-01 00:00:00.000' 
  ORDER BY DaysSinceLastWrite desc, DaysSinceLastRead desc
   UPDATE  info.[Databases]  SET DateChecked = GETDATE()
  UPDATE  info.[Databases]  SET [lastwrite] = '1900-01-01 00:00:00.000' 
  WHERE DatabaseID IN (24,25,26,200,201,202,203,204,205,2035,2034,2033,2032,2031)
   UPDATE  info.[Databases]  SET  [lastRead] = '1900-01-01 00:00:00.000' 
     WHERE DatabaseID IN (24,25,26,200,201,202,203,204,205,2035,2034,2033,2032,2031)
	
	 SELECT 
	  IL.Environment
	  ,IL.ServerName
	  ,COUNT(D.DatabaseID) as DatabaseCount
	,MAX(LastReboot) as LastReboot
	,MAX(DateChecked) as DateChecked
  FROM  dbo.InstanceList IL
  JOIN info.Databases d
  ON 
  D.InstanceID = IL.InstanceID
  WHERE D.DateChecked > DATEADD(Day,-6,GetDate())
  AND [lastwrite] = '1900-01-01 00:00:00.000'
  AND [lastRead] = '1900-01-01 00:00:00.000' 
 GROUP BY IL.ServerName ,IL.Environment 
 ORDER BY  DatabaseCount desc
  
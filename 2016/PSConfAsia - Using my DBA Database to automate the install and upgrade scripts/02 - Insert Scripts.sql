USE [ScriptInstall]
GO

INSERT INTO [dbo].[ScriptList]
           ([ScriptName]
           ,[ScriptDecription]
           ,[ScriptLocation])
     VALUES
           ('Ola'
           ,'OlaHalengans Script to backup, check integrity and index maintenance'
           ,'C:\MSSQL\Scripts\20 - Ola MaintenanceSolution (1).sql')
		   ,('Ola Restore Command Proc'
           ,'This is the stored procedure whcih will create the restore commands following the backup job run'
           ,'C:\MSSQL\Scripts\30 - RestoreCommand Proc.sql')
		   ,('Restore Command Job Steps'
           ,'Creates the restore command job steps for Ola''s Maintenance solution following the backup job run'
           ,'C:\MSSQL\Scripts\40 - RestoreCommand Job Steps.sql')
		   ,('sp_whoisactive'
           ,'What is running right now on the server'
           ,'C:\MSSQL\Scripts\100 - who_is_active_v11_11.sql')
		   ,('whoisactiveagentjob'
           ,'Creates Agent Job to run SP_WhoIsActive in a loop and log to table in DBA-Admin database'
           ,'C:\MSSQL\Scripts\110 - Create WhoisActive to Table job.sql')
		   ,('Add_Basic_Trace_XE'
           ,'Script to Add an Extended Event Session for a Basic Trace'
           ,'C:\MSSQL\Scripts\210 - ADD Basic Trace Extended Event.sql')
		   ,('OLAGDrive'
           ,'Script to create or alter Ola Maintenance Job to Local G Drive'
           ,'C:\MSSQL\Scripts\240 - OLA Backup - Local G.sql')
		   
GO

SELECT [ScriptID]
      ,[ScriptName]
      ,[ScriptDecription]
      ,[ScriptLocation]
  FROM [ScriptInstall].[dbo].[ScriptList]



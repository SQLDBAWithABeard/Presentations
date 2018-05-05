IF (SELECT @@SERVERNAME) <> 'ROB-SURFACEBOOK'

	    RAISERROR ('Oi Beardy -- This is the Wrong Connection!!!', -- Message text.  
               25, -- Severity.  
               1 -- State.  
               ) with log ;

GO

USE [ScriptInstall]
GO

EXEC [dbo].[usp_Load_Server] @Server = 'SQL2005Ser2003',@Environment = 'Development',@Location = 'Bolton'

-- Take a look at the instancelist table
SELECT[ServerName]
      ,[InstanceName]
      ,[Port]
      ,[Environment]
      ,[Location]
  FROM [ScriptInstall].[dbo].[InstanceList]

-- Take a look at the instancescriptlookup table
SELECT [InstanceID]
      ,[ScriptID]
      ,[NeedsUpdate]
  FROM [ScriptInstall].[dbo].[InstanceScriptLookup]

 -- OK Lets add a few more servers

EXEC [dbo].[usp_Load_Server] @Server = 'SQL2008Ser2008',@Environment = 'Development',@Location = 'Ljubljana'
EXEC [dbo].[usp_Load_Server] @Server = 'SQL2016N1', @Environment = 'Development',@Location = 'Bolton'
EXEC [dbo].[usp_Load_Server] @Server = 'SQL2016N2',@Environment = 'Development',@Location = 'Ljubljana'

-- Take a look at the instancelist table
SELECT[ServerName]
      ,[InstanceName]
      ,[Port]
      ,[Environment]
      ,[Location]
  FROM [ScriptInstall].[dbo].[InstanceList]



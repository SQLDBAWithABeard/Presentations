USE [ScriptInstall]
GO
/****** Object:  StoredProcedure [dbo].[usp_Load_Server]    Script Date: 08/10/2016 14:28:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rob Sewell
-- Create date: Long long ago
-- Description:	Inserts a server into a DBA Database and updates the script lookup table
-- =============================================
CREATE PROCEDURE [dbo].[usp_Load_Server]
	-- Add the parameters for the stored procedure here
	@Server nvarchar(50),
	@Instance nvarchar(50) = 'MSSQLSERVER',
	@Port int = 1433,
	@Environment nvarchar(25),
	@Location nvarchar(30)
AS
BEGIN

	SET NOCOUNT ON;
	declare @InstanceId int
INSERT INTO [dbo].[InstanceList]
           ([ServerName]
           ,[InstanceName]
           ,[Port]
           ,[Environment]
           ,[Location])
     VALUES
           (@Server			---- ENTER SERVER HERE
           ,@Instance		---- ENTER INSTANCE NAME HERE EVEN IF DEFAULT
           ,@Port				---- ENTER Port Here EVEN IF DEFAULT
		,@Environment		---- The environment - Examples Development,Disaster Recovery,Other,Production,Test
		   ,@Location					---- The Location - usually blank here
		   )                

set @InstanceId = SCOPE_IDENTITY()
insert into dbo.InstanceScriptLookup (
	InstanceID,
	ScriptID,
	NeedsUpdate
) 
	select 
		@InstanceId,
		s.ScriptID,
		0							-- This will update all scripts if set to 1 So DONT DO IT
	from dbo.ScriptList as s

END

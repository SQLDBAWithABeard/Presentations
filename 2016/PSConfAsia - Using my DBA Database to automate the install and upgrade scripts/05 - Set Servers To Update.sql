/*

Script to set update flag to 1 to auto install script for a set of Servers in the IN Clause to have the scripts installed

AUTHOR - Rob Sewell
DATE 08/09/2016

*/

Use [ScriptInstall]
Go

UPDATE [dbo].[InstanceScriptLookup] 
SET NeedsUpdate = 1
WHERE 
[dbo].[InstanceScriptLookup].ISLID IN

(SELECT
ISL.ISLID
FROM [dbo].[InstanceScriptLookup] AS ISL
Join
[dbo].[InstanceList] AS IL
ON
ISL.InstanceID = IL.InstanceID
JOIN
[dbo].[ScriptList] AS SL
ON
ISL.ScriptID = SL.ScriptID
WHERE
IL.ServerName 

IN 
(
'SQL2005Ser2003'
,'SQL2008Ser2008'
,'SQL2012Ser08AG1'
,'SQL2012Ser08AG2'
,'SQL2012Ser08AG3'
,'SQL2016N1'
,'SQL2016N2'
)

AND
SL.ScriptName IN (
'Ola'
,'Ola Restore Command Proc'
,'Restore Command Job Steps'
,'sp_whoisactive'
,'whoisactiveagentjob'
,'Add_Basic_Trace_XE'
,'OLAGDrive'
)
)

-- But we cant install Extended Events on SQL2005 or SQL 2008 so we had better remove those update flags

UPDATE [dbo].[InstanceScriptLookup] 
SET NeedsUpdate = 0
WHERE ISLID IN
(
SELECT ISLID
FROM [dbo].[InstanceScriptLookup] ISL
JOIN [dbo].[ScriptList] SL
ON SL.ScriptID = ISL.ScriptID
JOIN [dbo].[InstanceList] IL
ON IL.InstanceID = ISL.InstanceID		
WHERE (IL.ServerName = 'SQL2005Ser2003'
OR  IL.ServerName = 'SQL2008Ser2008')
AND SL.ScriptName = 'Add_Basic_Trace_XE'
)
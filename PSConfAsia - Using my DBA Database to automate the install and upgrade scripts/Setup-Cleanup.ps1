 $srv = New-Object Microsoft.SQLServer.Management.SMO.Server .
 if($srv.Databases['ScriptInstall'])
 {
    $srv.Databases['ScriptInstall'].Drop()
 }

 if($Srv.JobServer.Jobs['!AutoInstall DBA Scripts'])
 {
    $Srv.JobServer.Jobs['!AutoInstall DBA Scripts'].Drop()
 }
$servers = 'SQL2005Ser2003','SQL2008Ser2008','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2012Ser08AG3','SQL2014Ser12r2','SQL2016N1','SQL2016N2'
(Get-SqlAgentJob -ServerInstance $Servers).Where{$_.Category -eq'Database Maintenance'}.Drop()
(Get-SqlAgentJob -ServerInstance $Servers).Where{$_.Name -eq 'Log SP_WhoisActive to Table'}.Drop()
(Get-SqlAgentJob -ServerInstance $Servers).Where{$_.Category -eq'Database Maintenance'}|Select originatingserver,name

foreach($server in $Servers)
{
$Server
# To Load SQL Server Management Objects into PowerShell
   [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')  | out-null
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended')  | out-null
  $srv = New-Object Microsoft.SQLServer.Management.SMO.Server $Server
  $Srv.Databases['master'].StoredProcedures['sp_WhoIsActive'].Drop()
if($srv.versionmajor -ge '11')
    {
    if(Test-Path SQLSERVER:\XEvent\$Server)
        {
        $XEStore = get-childitem -path SQLSERVER:\XEvent\$Server -ErrorAction SilentlyContinue  | where {$_.DisplayName -ieq 'default'}
        $XEStore.Sessions['Basic_Trace'].Drop()
        }
    }
}

Get-ChildItem C:\temp\Reports\*.html|Remove-Item -Force
Get-ChildItem C:\temp\Reports\*.xml|Remove-Item -Force
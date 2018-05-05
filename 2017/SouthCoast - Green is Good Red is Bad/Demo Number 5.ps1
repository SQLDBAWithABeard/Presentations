## 
## I needed to check the following on over 100 SQL instances
## 
## SQL Agent
##             Should Be Running
##             Should be set to auto-start
## SQL Agent Jobs
##     There should be the following jobs
##             CommandLog Cleanup                                        
##             DatabaseBackup - SYSTEM_DATABASES - FULL                    
##             DatabaseBackup - USER_DATABASES - DIFF                    
##             DatabaseBackup - USER_DATABASES - FULL                      
##             DatabaseBackup - USER_DATABASES - LOG                     
##             DatabaseIntegrityCheck - SYSTEM_DATABASES                 
##             DatabaseIntegrityCheck - USER_DATABASES                   
##             IndexOptimize - USER_DATABASES                            
##             sp_delete_backuphistory                                   
##             sp_purge_jobhistory                                       
##             syspolicy_purge_history         
##     Each Job should
##             exist
##             have run successfully
##             be scheduled
## Files
##             There should be a backup share folder for the server
##             There should be a folder for each database
##             For databases in full recovery there should be a FULL DIFF and LOG folder
##             For system databases, databases in simple recovery and Log shipped databases there should be FULL and DIFF folders
##             Each FULL folder should have files less than 7 days old
##             Each DIFF folder should have files less than 24 hours old
##             Each LOG folder should have files less than 30 minutes old
## 
##    Not a quick task and as you can imagine prone to human mistakes

cd 'Presentations:\SouthCoast - Green is Good Red is Bad'
cls 
."GIT:\Functions\Test-OLAInstance.ps1"
## Now I can run against any number of Servers
$results = Test-OLAInstance -Instance rob-xps, 'ROB-XPS\SQL2016' -Share C:\MSSQL\BACKUP -NoDatabaseRestoreCheck -CheckForBackups 

#endregion

## embed into CI CD processes - get this cosumed by your build deploy release servers systems with
$Config.DBCCDatabase.Skip = $false
$Config.DBCCDatabase.NameSearch = 'ROB-XPS'
$filepath = 'C:\temp\dummyfile.xml'
$script = 'Git:\dbatools-scripts\Pester Test Last Known good DBCC CheckDB - Database Level.Tests.ps1'
Invoke-Pester -Script $script -Show None -OutputFile $filepath -OutputFormat NUnitXml 

code-insiders C:\temp\dummyfile.xml

## but remember our Test results object from before?

$results

## I can take the results object and convert it JSON (This is for the Powerbi :-) )
$results.TestResult | ConvertTo-Json -Depth 3 | Out-File C:\temp\ScotishOlaTestResults.json 

## But Powerbi is best
# Invoke-Item 'Git:\Presentations\PSConfAsia 2017 - Green is Good Red is Bad\Test Ola Report.pbix'
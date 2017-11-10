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

."GIT:\Functions\Test-OLAInstance.ps1"
## Now I can run against any number of Servers
$results = Test-OLAInstance -Instance rob-xps,'rob-xps\dave', 'ROB-XPS\SQL2016' -Share C:\MSSQL\BACKUP -NoDatabaseRestoreCheck -CheckForBackups 

## embed into CI CD processes - get this consumed by your build deploy release servers systems with
$filepath = 'C:\temp\dummyfile.xml'
$script = & 'Git:\dbatools-scripts-Stuttgart\Pester Test Last Known good DBCC CheckDB - Database Level.Tests.ps1'
Invoke-Pester -Script $script -Show None -OutputFile $filepath -OutputFormat NUnitXml 

code-insiders C:\temp\dummyfile.xml

## but remember our Test results object from before?

$results

## I can take the results object and convert it JSON (This is for the Powerbi :-) )
$results.TestResult | ConvertTo-Json -Depth 10 | Out-File C:\temp\OlaTestResults1.json 

## But Powerbi is best
Invoke-Item 'Git:\Presentations\SQL Glasgow\Test Ola Report.pbix'

## and let me show you how easy it is to do this for your self

Start-Process 'https://sqldbawithabeard.com/2017/10/29/a-pretty-powerbi-pester-results-template-file/'

## From that page you can download the template PowerBi Pbix file

## and then run which ever Pester that you want to

$Config = (Get-Content GIT:\dbatools-scripts\TestConfig.json) -join "`n" | ConvertFrom-Json
$PesterResults = Invoke-Pester .\dbatools-scripts\ -PassThru
$PesterResults.TestResult | Convertto-Json |Out-File C:\temp\dbatools-scripts-pester.json

## now we can put this into the template file

Start-Process .\PesterTestPowerBi.pbix 

## or use the tags and set up a process

$PesterResults = Invoke-Pester -Tag Instance -PassThru
$PesterResults.TestResult | Convertto-Json |Out-File C:\temp\instance-pester.json

Start-Process .\PesterTestPowerBi.pbix 

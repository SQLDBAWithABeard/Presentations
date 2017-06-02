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

## So I wrote a function to Paramtise the Pester tests
##   cls 
."GIT:\Functions\Test-OLAInstance.ps1"

## Now I can run against any number of Servers
$results = Test-OLAInstance -Instance rob-xps,'rob-xps\dave', 'ROB-XPS\SQL2016' -Share C:\MSSQL\BACKUP -NoDatabaseRestoreCheck -CheckForBackups 

$results

## I can take the results object and convert it JSON (This is for the Powerbi :-) )
$results.TestResult | ConvertTo-Json -Depth 10 | Out-File C:\temp\OlaTestResults.json 


## I can also create a HTML page for the results
## Unfortunately New Pester broke the old reportunit and it looked rubbish
## But we can do this

$SQLServers = 'rob-xps','rob-xps\dave', 'ROB-XPS\SQL2016'

$Path = 'Git:\Functions\Test-OLA.ps1'

foreach($Server in $SQLServers)
{
    ## Create Parameter block for running Pester
    $Script = @{
    Path = $Path;
    Parameters = @{ Instance = $Server;
    CheckForBackups =  $true;
    CheckForDBFolders =  $true;
    NoDatabaseRestoreCheck= $true;
    Share = 'C:\MSSQL\Backup';
    }
    }

## Set some variables
$Date = Get-Date -Format ddMMyyyHHmmss
$tempFolder = 'c:\temp\ReportsIndividual\'
$InstanceName = $Server.Replace('\','-')
$File = $tempFolder + $InstanceName 
$XML = $File + '.xml'

## Run Pester only showing failures and outputting ALL results to a file
Invoke-Pester -Script $Script -OutputFile $xml -OutputFormat NUnitXml -show fails
}
Push-Location $tempFolder

## Once Tests have run
#download and extract ReportUnit.exe
$url = 'http://relevantcodes.com/Tools/ReportUnit/reportunit-1.2.zip'
$fullPath = Join-Path $tempFolder $url.Split("/")[-1]
$reportunit = $tempFolder + '\reportunit.exe'
if((Test-Path $reportunit) -eq $false)
{
(New-Object Net.WebClient).DownloadFile($url,$fullPath)
Expand-Archive -Path $fullPath -DestinationPath $tempFolder
}
#run reportunit against report.xml and display result in browser
$HTML = $tempFolder  + 'index.html'
& .\reportunit.exe $tempFolder
ii $HTML

## But Powerbi is better I think :-)
## Why do I love PowerShell?
$Beard = @"
                                                                
                    @@,                   ,                     
                     @@8                ,@@,                    
                       @@@.           f@@C                      
                        .@@@       t@@@   0G                    
                    C@@f   8@@   ;@8.   @@@@@8                  
                  :@@i,@@@.      L0   t@@   ;@@@C               
                G@@C     @@@@      i@@@;       :@@@:            
             8@@0.          8@@  .@@:             @@            
            @@@8          :@@,    @@@:          @@@f            
              f@@@       @@@        18@@@     @@8               
                 0@@0.C@@@.    8@t      @@0@@@@                 
                   .@@0,      @80        C0,                    
                             @@,                                
                           8@@                                  
                          @@i                                   
                         @@@@@@@@@Gi                            
                                  ti.                           
                      tC.  8 @ t@G                              
                    t;0i.@1@.   @. i@@@;,,,,,,,,,               
                  @,8.@0@  .    f0@8..  C@C..;@@@               
              ,@ @@i@@@f          @.   f@@.    :8@t             
          .@G1@i @    8  C           @@,.    1@;                
      @@t;@f 1@       @ 0@ @@  @@@ GC @        1@iGC            
    88               ,G.88 @,. @@t@ 8 8                         
                     G :@, @ . @8 @  88                         
                     @ 1@, 8 . @  @@ @                          
                     @G.@,@@ : @  @@.f                          
                     G1 0,@@ @ @ t@8..                          
                    t:  ,@@@ @ @ @C8..1                         
                   @,:  @@@@ @ @ @0 ii8                         
                    G  C 0@1.@ 8 @@ @88                         
                    @  @ ,@, @ 8 @@ 18@                         
                   .:  tL.0, @ 8 @@  @G                         
                   G  G 8,0  @ G @@  @ G                        
                   8  8 @8@  @   @8, @ @                        
                  L. 8  t@0  L   @ @ @:@                        
                  f i, 1tf. L    L @ @8.t                       
                 G  @  @8@  8   0  @8@G @                       
               .f  @   @G. :.      , @ 8 @                      
              8.  i;  ti:  @       @@,f1. 1,                    
             @    C  18   C.   :   ;;   @                       
                    L.@        @    8@   @                      
                      @       G.    @     G                     
                      @      .i      @                          
                            8        1,                         
                            ;;                                  
                            ''                                  
"@
Write-Host $beard -ForegroundColor DarkBlue -BackgroundColor White
## Yep thats one reason
## Because it will interact with many, many, many systems
## Windows
Get-Process
Get-Service
## against Linux using POSH-SSH iex (New-Object Net.WebClient).DownloadString("https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev")
$linuxServer = '172.16.10.2'
New-SSHSession -ComputerName $linuxServer -Credential (Get-Credential) -AcceptKey -Force
Get-SSHSession
Invoke-SSHCommand -Command "uname -a" -Index 0
Invoke-SSHCommand -Command "pwd" -Index 0
Invoke-SSHCommand -Command "ls -l" -Index 0
Invoke-SSHCommand -Command "ps" -Index 0 
Remove-SSHSession -SessionId 0

## There is also PowerShell on Linux but I wont show you as it looks just the same!
## we can interact with
## Active Directory

Get-ADUser -Filter 'Name -like "*SQL*"' 
## Hyper-V
Get-VM 
## Sharepoint, Exchange , Citrix, VMWare, System Center
## Certificate Store
dir Cert:\CurrentUser
## The Registry
ls HKLM:\SOFTWARE\Microsoft\PowerShell\
## Azure
## SQL Server
$SQLServer = $env:COMPUTERNAME
Get-SqlErrorLog -ServerInstance $SQLServer -Since Midnight
## Everything is an object and you can do loads with an object :-)

## Lets have a  look at a SQL Server
$srv = Connect-DbaSqlServer -SqlServer $SQLServer
$Databases = $srv.Databases
## Select some properties of the datbaases
$MyDatabasesObject = $Databases | Select Name, CreateDate, Owner, AutoClose , AutoShrink, CompatibilityLevel , DataSpaceUsage, IndexSpaceUsage , PageVerify 

## What have we got?

$MyDatabasesObject | gm

## We can look at it like this

$MyDatabasesObject | Format-Table

$MyDatabasesObject | Format-List

$MyDatabasesObject | Out-File C:\temp\SomeDatabaseObjects.txt
notepad C:\temp\SomeDatabaseObjects.txt

$MyDatabasesObject | ConvertTo-Csv

$MyDatabasesObject | Export-Clixml C:\temp\SomeDatabaseObjects.xml
notepad c:\temp\somedatabaseobjects.xml

$MyDatabasesObject | ConvertTo-Json

$MyDatabasesObject | ConvertTo-Html

## I LOVE LOVE LOVE Out-GridView

gci Presentations:\ | Out-GridView

##
## Lets create some log files
$i = 0
while ($i -lt 500) {
New-Item "C:\temp\_Important_System_Log_File_Do_NOT_DELETE_$i.log" -ItemType File
$i ++
}

## Now lets pick just those files in Out Grid View and zip them up

gci c:\temp\*.log | ogv -PassThru | Compress-Archive -DestinationPath C:\temp\CompressedLogs\Logs1.zip -CompressionLevel Fastest 
explorer c:\temp\compressedlogs

## THATS just files and getting information beardy DO SOMETHING

## so lets look at a SQL Table
$srv = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $SQLServer
$tables = $srv.Databases['ProviderDemo'].Tables[1] 

## what type of object is it?

$tables.GetType()

## Look at its properties - You can use Get-Member $table | get-member -MemberType Properties

## So now we can start to do useful things
## Lets look at our statistics
## But we dont know always which table belongs to which Statistic
## NOTE: Here is a cool trick to access other properties or calculate properties in your select

foreach ($table in $Tables)
{
    foreach($Stats in $table.Statistics)
    {
        $TableName = @{Name ='The Table Name'; Expression ={$table.Name}}
        $stats | Select $tablename ,Name, LastUpdated
    }
}

foreach($table in $tables.Where{$_.Name -like 'Agent*'})
{
    $table.UpdateStatistics()
}

## Now lets check - Refresh the object first 
## NOTE: Here is another way to loop through a collection and retrieve properties

$table.Statistics.Refresh()
$table.Statistics |Select-Object Parent ,Name, LastUpdated

## I wanted to know if my birthday was in the AdventureWorks database
　
Import-Module dbatools
$srv = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $SQLServer
$db = $srv.Databases['AdventureWorks2014']

## Findi the biggest tables, bet it is in there

$db.Tables | Sort DataSpaceUsed -Descending | select Schema, Name ,DataSpaceUsed, RowCount -First 1

## We'll grab all of the data into Out-GridView
$query = "SELECT * FROM Person.Person"
$results = Invoke-sqlcmd2 -ServerInstance $SQLServer -Database AdventureWorks2014 -Query $query
$results | ogv

## Open SOurce and Community Baby

## PowerShell is open sourced now and available on Github

Start-Process 'https:\\github.com\PowerShell\PowerShell'

## The community are building Fantastic modules

## Look at dbatools

Start-Process 'https://dbatools.io/github'

## for example - Want to know if your Identity columns in your database are nearly full?

Test-DbaIdentityUsage -SqlInstance 'Rob-XPS','Rob-XPS\DAVE' | Out-GridView

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

Test-OLAInstance -Instance rob-xps,'rob-xps\dave' -Share C:\MSSQL\BACKUP -NoDatabaseRestoreCheck -CheckForBackups


## And you can go old school too :-)
function EndOfShow 
{
$i = 0
while ($i -lt 12)
{
cls
Write-Host "I LOVE POWERSHELL!" -ForegroundColor Black -BackgroundColor Yellow
SLeep -Milliseconds 200
cls
Write-Host "I LOVE POWERSHELL!" -ForegroundColor Yellow -BackgroundColor Black
SLeep -Milliseconds 200
cls
$i ++
}
$i = 0
while ($i -lt 4)
{
cls
Write-Host "I'm on Twitter" -ForegroundColor Black -BackgroundColor Yellow
SLeep -Milliseconds 700
cls
Write-Host "@SQLDBAWithBeard NO A!" -ForegroundColor Yellow -BackgroundColor Black
SLeep -Milliseconds 700
cls
$i ++
}
$i = 0
while ($i -lt 4)
{
cls
Write-Host "I'm a blogger" -ForegroundColor Black -BackgroundColor Yellow
SLeep -Milliseconds 700
cls
Write-Host "https://sqldbawithabeard.com YEP an A this time!!!" -ForegroundColor Yellow -BackgroundColor Black
SLeep -Milliseconds 700
cls
$i ++
}
Write-Host "@SQLDBAWithBeard NO A!" -ForegroundColor Yellow -BackgroundColor Black
Write-Host "https://sqldbawithabeard.com YEP an A this time!!!" -ForegroundColor Yellow -BackgroundColor Black
Write-Host $beard -ForegroundColor DarkYellow -BackgroundColor Black
}
EndOfShow 


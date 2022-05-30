## lets look at the available tags

$repo1 = Invoke-WebRequest https://mcr.microsoft.com/v2/mssql/server/tags/list
$repo2 = Invoke-WebRequest https://mcr.microsoft.com/v2/mssql/rhel/server/tags/list
$tags = $repo1.content + $repo2.content
$tags

# then we can pull the ones that we want
docker pull mcr.microsoft.com/mssql/server:2019-latest
docker pull mcr.microsoft.com/mssql/server:2017-latest

# get the back up

if (-not (Test-Path  $env:TEMP\Backups\AdventureWorks2017.bak)) {
    if(-not (Test-Path $env:TEMP\Backups)) {
        New-Item -ItemType Directory -Force -Path $env:TEMP\Backups
    }
    $Url = 'https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2017.bak'
    $OutputFile = '{0}\Backups\AdventureWorks2017.bak' -f $env:TEMP 
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($Url, $OutputFile)
}

# and run some containers
docker container run -d `
    -p 7432:1433 `
    --env ACCEPT_EULA=Y `
    --env MSSQL_SA_PASSWORD=dbatools.IO `
    --volume $env:TEMP\Backups\:/tmp/backups `
    --name 2017 `
    mcr.microsoft.com/mssql/server:2017-latest

docker container run -d `
    -p 7433:1433 `
    --env ACCEPT_EULA=Y `
    --env MSSQL_SA_PASSWORD=dbatools.IO `
    --volume $env:TEMP\Backups\:/tmp/backups `
    --name 2019 `
    mcr.microsoft.com/mssql/server:2019-latest

docker container run -d `
    -p 7444:1433 `
    --env ACCEPT_EULA=Y `
    --env MSSQL_SA_PASSWORD=dbatools.IO `
    --name WorkloadTools `
    mcr.microsoft.com/mssql/server:2019-latest
    
# lets set a credential for connecting

$securePassword = ('dbatools.IO' | ConvertTo-SecureString -AsPlainText -Force)
$continercredential = New-Object System.Management.Automation.PSCredential('sa', $securePassword)

# lets have a look at those containers in ADS

# We need a database

$datagrillen1 = Connect-DbaInstance -SqlInstance 'localhost,7432' -SqlCredential $continercredential
$datagrillen2 = Connect-DbaInstance -SqlInstance 'localhost,7433' -SqlCredential $continercredential


Restore-DbaDatabase -SqlInstance $datagrillen1 -Path /tmp/backups/AdventureWorks_FULL_COPY_ONLY.bak -DatabaseName AdventureWorks
Restore-DbaDatabase -SqlInstance $datagrillen2 -Path /tmp/backups/AdventureWorks_FULL_COPY_ONLY.bak -DatabaseName AdventureWorks

$query = "ALTER DATABASE AdventureWorks
SET COMPATIBILITY_LEVEL = 150"

Invoke-DbaQuery -SqlInstance $datagrillen2 -Query $query

# Take a look in ADS

# Now we have our instances with our databases we can create images

# first stop the containers

docker stop 2017 
docker stop 2019

# create an image
docker commit 2017 sqldbawithabeard/datagrillen1
docker commit 2019 sqldbawithabeard/datagrillen2

# tag the image
docker tag sqldbawithabeard/datagrillen1 sqldbawithabeard/datagrillen1:v0.2.0
docker tag sqldbawithabeard/datagrillen2 sqldbawithabeard/datagrillen2:v0.0.0


docker image ls -f "reference=sqldbawithabeard/in*"

# push the image

docker push sqldbawithabeard/datagrillen1:v0.2.0
docker push sqldbawithabeard/datagrillen2:v0.0.0


# remove the containers

docker rm 2017 2019 2022 WorkloadTools --force

# then we can run docker compose and start an environment

docker compose -f .devcontainer\docker-compose.yml up -d

# examine the instancs in ADS

# So that is awesome but how about we automate the thing ?

docker compose -f .devcontainer\docker-compose.yml down

cd  .\datagrillen1
docker build -t instance1 . --progress=plain --no-cache
docker tag instance1 sqldbawithabeard/datagrillen1:v0.2.0
docker push sqldbawithabeard/datagrillen1:v0.2.0

cd  ..\datagrillen2
docker build -t instance2 . # --progress=plain --no-cache
docker tag instance2 sqldbawithabeard/datagrillen2:v0.0.0
docker push sqldbawithabeard/datagrillen2:v0.0.0


#
# lets start some WorkLoadTools IN WINDWOS TERMINAL ROB

# lets set a credential for connecting

$securePassword = ('dbatools.IO' | ConvertTo-SecureString -AsPlainText -Force)
$continercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)

$WorkloadTools = Connect-DbaInstance -SqlInstance 'localhost,7444' -SqlCredential $continercredential
New-DbaDatabase -SqlInstance $WorkloadTools -Name WorkloadTools


# start replay 
$ConfigPath = (Get-Item 'Presentations:\2022\Data Grillen\Config\').FullName
cd 'C:\Program Files\WorkloadTools\'
.\SqlWorkload.exe --log $ConfigPath\Log\replay.log --File $ConfigPath\replay.json

# start baseline 
$ConfigPath = (Get-Item 'Presentations:\2022\Data Grillen\Config\').FullName
cd 'C:\Program Files\WorkloadTools\'
.\SqlWorkload.exe --log $ConfigPath\Log\baseline.log --File $ConfigPath\baseline.json



#region Workload
$securePassword = ('dbatools.IO' | ConvertTo-SecureString -AsPlainText -Force)
$continercredential = New-Object System.Management.Automation.PSCredential('sqladmin', $securePassword)

$datagrillen1 = Connect-DbaInstance -SqlInstance datagrillen1 -SqlCredential $continercredential
$datagrillen2 = Connect-DbaInstance -SqlInstance datagrillen2 -SqlCredential $continercredential

$Colours = [enum]::GetValues([System.ConsoleColor])
$Queries = Get-Content -Delimiter "------" -Path "AdventureWorksBOLWorkload.sql"
$x = 0
$db = Get-DbaDatabase -SqlInstance $datagrillen1 -Database AdventureWorks     
while ($x -lt 10000) {
    # Pick a Random Query from the input object 
    $Query = Get-Random -InputObject $Queries; 
    try {
        $db.Query($query) | Out-Null
    } catch {
        $message = "Error on 2019 - {0}" -f $_.Exception.GetBaseException().Message
        Write-PSFMessage -Level Significant -Message $message -FunctionName "Baseline Run"
    }
    
    $x ++
    $xcolour = Get-Random -InputObject $Colours
    Write-Host "Query Number $x is running on 2019" -ForegroundColor $xcolour
} 



#endregion
$ConfigPath = (Get-Item 'Presentations:\2022\Data Grillen\Config\').FullName
cd 'C:\Program Files\WorkloadTools\'
.\WorkloadViewer.exe  -L $ConfigPath\viewer.log -S localhost,7444  -D WorkLoadTools -M baseline -U sqladmin -P dbatools.IO -T localhost,7444 -E WorkLoadTools -N replay -V sqladmin -Q dbatools.IO


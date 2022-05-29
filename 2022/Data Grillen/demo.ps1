## lets look at the available tags

$repo1 = invoke-webrequest https://mcr.microsoft.com/v2/mssql/server/tags/list
$repo2 = invoke-webrequest https://mcr.microsoft.com/v2/mssql/rhel/server/tags/list
$tags = $repo1.content + $repo2.content
$tags

# then we can pull the ones that we want
docker pull mcr.microsoft.com/mssql/server:2019-latest
docker pull mcr.microsoft.com/mssql/server:2017-latest

# and run some containers
docker container run -d `
    -p 7432:1433 `
    --env ACCEPT_EULA=Y `
    --env MSSQL_SA_PASSWORD=dbatools.IO `
    --volume F:\BackupShare:/tmp/backups `
    --name 2017 `
    mcr.microsoft.com/mssql/server:2017-latest

docker container run -d `
    -p 7433:1433 `
    --env ACCEPT_EULA=Y `
    --env MSSQL_SA_PASSWORD=dbatools.IO `
    --volume F:\BackupShare:/tmp/backups `
    --name 2019 `
    mcr.microsoft.com/mssql/server:2019-latest

docker container run -d `
    -p 7444:1433 `
    --env ACCEPT_EULA=Y `
    --env MSSQL_SA_PASSWORD=dbatools.IO `
    --name WorkloadTools `
    mcr.microsoft.com/mssql/server:2019-latest
    
# lets set a credential for connecting

$securePassword = ('dbatools.IO' | ConvertTo-SecureString -asPlainText -Force)
$continercredential = New-Object System.Management.Automation.PSCredential('sa', $securePassword)

# lets have a look at those containers in ADS

# We need a database

$Instance1 = Connect-DbaInstance -SqlInstance 'localhost,7432' -SqlCredential $continercredential
$Instance2 = Connect-DbaInstance -SqlInstance 'localhost,7433' -SqlCredential $continercredential


Restore-DbaDatabase -SqlInstance $Instance1 -Path /tmp/backups/AdventureWorks_FULL_COPY_ONLY.bak -DatabaseName AdventureWorks
Restore-DbaDatabase -SqlInstance $Instance2 -Path /tmp/backups/AdventureWorks_FULL_COPY_ONLY.bak -DatabaseName AdventureWorks

$query = "ALTER DATABASE AdventureWorks
SET COMPATIBILITY_LEVEL = 150"

Invoke-DbaQuery -SqlInstance $Instance2 -Query $query

# Take a look in ADS

# Now we have our instances with our databases we can create images

# first stop the containers

docker stop 2017 
docker stop 2019

# create an image
docker commit 2017 sqldbawithabeard/instance1
docker commit 2019 sqldbawithabeard/instance2

# tag the image
docker tag sqldbawithabeard/instance1 sqldbawithabeard/instance1:v0.0.0
docker tag sqldbawithabeard/instance2 sqldbawithabeard/instance2:v0.0.0


docker image ls -f "reference=sqldbawithabeard/in*"

# push the image

docker push sqldbawithabeard/instance1:v0.0.0
docker push sqldbawithabeard/instance2:v0.0.0


# remove the containers

docker rm 2017 2019 2022 WorkloadTools --force

# then we can run docker compose and start an environment

docker compose -f .devcontainer\docker-compose.yml up -d

# examine the instancs in ADS

# So that is awesome but how about we automate the thing ?

docker compose -f .devcontainer\docker-compose.yml down

cd  .\Instance1
docker build -t instance1 . # --progress=plain --no-cache
docker tag instance1 sqldbawithabeard/instance1:v0.0.0
docker push sqldbawithabeard/instance1:v0.0.0

cd  ..\Instance2
docker build -t instance2 . # --progress=plain --no-cache
docker tag instance2 sqldbawithabeard/instance2:v0.0.0
docker push sqldbawithabeard/instance2:v0.0.0


#
# lets look at our docker


$WorkloadTools = Connect-DbaInstance -SqlInstance 'localhost,7444' -SqlCredential $continercredential
New-DbaDatabase -SqlInstance $WorkloadTools -Name WorkloadTools


# start replay 
$ConfigPath = (Get-Item 'Presentations:\2022\Data Grillen\Config\').FullName
.\SqlWorkload.exe --log $ConfigPath\Log\replay.log --File $ConfigPath\replay.json


# start baseline 
$ConfigPath = (Get-Item 'Presentations:\2022\Data Grillen\Config\').FullName
.\SqlWorkload.exe --log $ConfigPath\Log\baseline.log --File $ConfigPath\baseline.json



#region Workload


$Colours = [enum]::GetValues([System.ConsoleColor])
$Queries = Get-Content -Delimiter "------" -Path "AdventureWorksBOLWorkload.sql"
$x = 0
$db = Get-DbaDatabase -SqlInstance $Instance1 -Database AdventureWorks     
while ($x -lt 10000) {
    # Pick a Random Query from the input object 
    $Query = Get-Random -InputObject $Queries; 
    try {
        $db.Query($query) | Out-Null
    }
    catch {
        $message = "Error on 2017 - {0}" -f $_.Exception.GetBaseException().Message
        Write-PSFMessage -Level Significant -Message $message -FunctionName "Baseline Run"
    }
    
    $x ++
    $xcolour = Get-Random -InputObject $Colours
    Write-Host "Query Number $x is running on 2017" -ForegroundColor $xcolour
} 



#endregion
$ConfigPath = (Get-Item 'Presentations:\2022\Data Grillen\Config\').FullName
.\WorkloadViewer.exe  -L $ConfigPath\viewer.log -S localhost,7444  -D WorkLoadTools -M baseline -U sa -P dbatools.IO -T localhost,7444 -E WorkLoadTools -N replay -V sa -Q dbatools.IO

docker rm 2017 2019 2022 WorkloadTools --force
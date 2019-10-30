#region variables
Remove-Module PsReadLine
$PresentationFolder = 'Presentations:\2019\dbatools'
$EndDate = Get-Date -Year 2019 -Month 9 -Day 21 -Hour 13 -Minute 45 -Second 0
$location = 'Bangalore'

Set-Location $PresentationFolder7
. .\vars.ps1    

Push-Location -Path $PresentationFolder

Push-Location 'dockercompose:\dbatools-2-instances-AG'

#endregion

#region Need something to demo on

# how long does it take to install 2 instances of SQLServer?

docker-compose up -d

# Could you use this when you are learning?
# COuld your devs use it when they are workign on things

# its really easy to throw them away as well

docker-compose down

# and then we can bring them for proper this time

docker-compose up -d


# It just takes this file
code-insiders.cmd .\docker-compose.yml

Pop-Location
#endregion

Start-Process powershell.exe "-NoExit -Command & {Get-Service MSSQLSERVER, 'MSSQL`$DAVE'} | Start-Service" -Verb RunAs
Import-Module PSReadline
## Setting up reports from Pester Tests
## Welcome to PowerShell :-)
Return "This is a demo Beardy!"
psedit Git:\Functions\Test-OLA.ps1

$SQLServers = 'SQL2005Ser2003','SQL2012Ser08AG1','SQL2012Ser08AG2','SQL2014Ser12R2','SQL2016N1','SQL2016N2','SQL2016N3','SQLVnextN1','SQLvNextN2'

$dbs = 0
foreach ($S in $SQLServers)
{
     $srv = New-Object Microsoft.SqlServer.Management.Smo.Server $S
     $dbs += $srv.Databases.Count
}

Write-Output " We Have $($SQLServers.Count) Servers and $dbs Databases"
Write-Output "Let's Check ALL the Jobs, Schedules, results, Files in about 100 seconds!!"

Test-OLAInstance -Instance $SQLServers -Share 'C:\MSSQL\Backup' -CheckForBackups -NoDatabaseRestoreCheck
##   Test-OLAInstance -Instance 'SQLVnextN2' -Share 'C:\MSSQL\Backup' -CheckForBackups -NoDatabaseRestoreCheck

psedit Git:\Functions\Test-OLAInstance.ps1

Write-Output " But if you want a report, you may have to wait 3 minutes!!"
Test-OLAInstance -Instance $SQLServers  -Share 'C:\MSSQL\Backup' -CheckForBackups -NoDatabaseRestoreCheck -Report

## But you can also create a Different report like this

$Path = 'Git:\Functions\Test-OLA.ps1'

foreach($Server in $SQLServers)
{

    $Script = @{
    Path = $Path;
    Parameters = @{ Instance = $Server;
    CheckForBackups =  $true;
    CheckForDBFolders =  $true;
    NoDatabaseRestoreCheck= $true;
    Share = 'C:\MSSQL\Backup';
    }
    }

$Date = Get-Date -Format ddMMyyyHHmmss
$tempFolder = 'c:\temp\Reports\'
$InstanceName = $Server.Replace('\','-')
$File = $tempFolder + $InstanceName 
$XML = $File + '.xml'

Invoke-Pester -Script $Script -OutputFile $xml -OutputFormat NUnitXml
}
Push-Location $tempFolder
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
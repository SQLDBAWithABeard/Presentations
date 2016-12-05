## Setting up reports from Pester Tests

psedit Git:\Functions\Test-OLA.ps1

Test-OLAInstance -Instance 'ROB-SURFACEBOOK','ROB-SURFACEBOOK\DAVE' -Share 'C:\MSSQL\Backup' -CheckForBackups

psedit Git:\Functions\Test-OLAInstance.ps1

Test-OLAInstance -Instance 'ROB-SURFACEBOOK','ROB-SURFACEBOOK\DAVE' -Share 'C:\MSSQL\Backup' -CheckForBackups -Report

## But you can also create a Different report like this

$Path = 'Git:\Functions\Test-OLA.ps1'

$Servers = 'ROB-SURFACEBOOK','ROB-SURFACEBOOK\DAVE' 
foreach($Server in $Servers)
{

    $Script = @{
    Path = $Path;
    Parameters = @{ Instance = $Server;
    CheckForBackups =  $true;
    CheckForDBFolders =  $true;
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

Get-Service

# However a better way is to se thte results to a variable

$A = Get-Service -ComputerName sql0

$A | Gm

# This way the variable is held in memory

$a

## Now we can access the properties

$a.ServiceName 

# Using a foreach the $_ refers to "This"

$a.Foreach{$_.ServiceName }

## Use a loop

foreach($beard in $a)
{
$beard.ServiceName 
}

## use the pipe

$A | ForEach-Object {$_.ServiceName }

## Use select

$A | Select-Object ServiceName 

## NEVER forget that PowerShell Loves Objects and You should too

$a | Out-file C:\temp\Services.txt
notepad C:\temp\Services.txt

$A | Out-GridView -PassThru | Out-file C:\temp\ServiceOGV.txt
notepad C:\temp\ServiceOGV.txt

$a | ConvertTo-Csv | Out-File c:\temp\servicesCSV.csv
notepad c:\temp\servicesCSV.csv

Send-MailMessage -Body $a -From mrrobsewell@outlook.com -SmtpServer SMPT.Beard.Local -To Servicedesk@Beard.local -Subject "Oh no. It all failed" -Priority High

$a | ConvertTo-Html | Out-File c:\temp\services.html
Start-Process c:\temp\services.html

cd presentations:\

Import-Module Git:\dbareports\dbareports.psd1 ## I am using the development branch

Install-DbaReports -SqlServer ROB-XPS -
InstallDatabase dbareportsMay2017 -InstallPath c:\MSSQL\dbareports -LogFileFolder C:\MSSQL\dbareports\logs -Verbose

Get-DbrConfig

Install-DbaReportsClient -SqlServer ROB-XPS -InstallDatabase DEMOdbareports

Get-DbrConfig

Get-DbrInstanceList

Get-DbrAgentJob |ogv

Get-DbrAllInfo -SQLInstance SQL_Server_N-I01\Metallica 

Get-DbrAllInfo -SQLInstance SQL_Server_N-I01\Metallica -Filepath C:\Temp\

Get-ChildItem c:\temp\*metallica* | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Invoke-Item
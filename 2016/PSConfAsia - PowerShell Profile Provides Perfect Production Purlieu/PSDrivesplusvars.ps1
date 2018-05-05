Import-Module sqlserver
Write-Output 'I still think you look great'
New-PSDrive -Name 'Presentations' -PSProvider FileSystem -Root 'C:\users\mrrob\OneDrive\Documents\Presentations'
New-PSDrive -Name 'Functions' -PSProvider FileSystem -Root 'C:\users\mrrob\OneDrive\Documents\Scripts\Powershell Scripts\Functions'
New-PSDrive -Name 'Git' -PSProvider FileSystem -Root C:\Users\mrrob\OneDrive\Documents\GitHub
New-PSDrive -Name 'WIP' -PSProvider FileSystem -Root C:\Temp\WIP
#
## But it doesnt just have to be Filepaths
#
New-PSDrive -Name 'SQLDAVE' –PSProvider SQLSERVER –Root 'SQLSERVER:\SQL\localhost\DAVE'
New-PSDrive -Name 'JOBSERVER' –PSProvider SQLSERVER –Root 'SQLSERVER:\SQL\localhost\Default\JobServer'
##
## 
$SQLServer = 'SQL2014Ser12R2'
$DBADatabase = 'ROB-SURFACEBOOK'
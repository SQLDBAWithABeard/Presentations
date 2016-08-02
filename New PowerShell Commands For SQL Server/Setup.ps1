if((Get-Service mssqlserver).status -ne 'Running')
{
Get-Service mssqlserver|Start-Service
}
if((Get-Service sqlserveragent).status -ne 'Running')
{
Get-Service sqlserveragent|Start-Service
}
if((Get-Service mssql*Dave).status -ne 'Running')
{
Get-Service mssql*Dave|Start-Service
}
if((Get-Service sqlagent*dave).status -ne 'Running')
{
Get-Service sqlagent*dave|Start-Service
}
Get-Service mssqlserver
Get-Service sqlserveragent
Get-Service mssql*Dave
Get-Service sqlagent*dave

start-process powershell.exe
<#

. 'C:\Users\mrrob\OneDrive\Documents\Scripts\Powershell Scripts\Functions\Start-Demo.ps1'
Start-Demo -file 'C:\Users\mrrob\OneDrive\Documents\Presentations\New PowerShell Commands For SQL Server\one.ps1'

#>
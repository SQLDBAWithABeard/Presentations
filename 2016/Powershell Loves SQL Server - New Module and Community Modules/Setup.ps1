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

$Script = {
$SQLBoxes = 'SQL2005Ser2003','SQL2008Ser2008','SQL2014Ser2012R2','SQL2016N1','SQL2016N2'
$VMs = Get-vm $SQLBoxes
foreach($vm in $vms)
{
if($VM.State -eq 'Off')
{
$VM|Stop-VM 
}
}

Get-VM
}
Invoke-Command -ComputerName beardnuc -ScriptBlock $Script

Invoke-Pester 'C:\Users\mrrob\OneDrive\Documents\GitHub\Presentations\Powershell Loves SQL Server - New Module and Community Modules\test.ps1'

start-process powershell.exe
<#

Start-Demo -file 'C:\Users\mrrob\OneDrive\Documents\GitHub\Presentations\Powershell Loves SQL Server - New Module and Community Modules\one.ps1'

#>
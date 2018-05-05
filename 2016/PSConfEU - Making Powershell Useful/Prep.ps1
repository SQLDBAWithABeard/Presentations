#requires -Version 1
### prep 
if((Get-PSDrive -Name OldSCripts -ErrorAction SilentlyContinue))
{
  Remove-PSDrive -Name OldScripts
}
if((Get-PSDrive -Name Presentations -ErrorAction SilentlyContinue))
{
  Remove-PSDrive -Name Presentations
}
if ($env:COMPUTERNAME -eq 'ROB-SURFACEBOOK')
{
  New-PSDrive -Name OldScripts -PSProvider FileSystem -Root 'C:\Users\mrrob\OneDrive\Documents\Scripts\Powershell Scripts'
  New-PSDrive -Name Presentations -PSProvider FileSystem -Root 'C:\Users\mrrob\OneDrive\Documents\Presentations'
  New-PSDrive -Name Functions -PSProvider FileSystem -Root 'C:\users\mrrob\Documents\PowershellFunctionsISE'

  if ((Get-Service -Name MSSQLSERVER).status -eq 'Stopped')
  {
    Start-Service -Name MSSQLSERVER
  }
}
if ($env:COMPUTERNAME -eq 'ROB-Laptop')
{
  New-PSDrive -Name OldScripts -PSProvider FileSystem -Root 'E:\SkyDrive\Documents\Scripts\Powershell Scripts'
  New-PSDrive -Name Presentations -PSProvider FileSystem -Root 'E:\SkyDrive\Documents\Presentations'    
}
cls

Start-Demo -file 'Presentations:\Making PowerShell useful for your team - Dublin\dos.ps1'
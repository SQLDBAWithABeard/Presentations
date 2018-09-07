## Test Cases and Tags

cd 'Presentations:\PassSummit2017'

Invoke-Pester -Tag Backup
 
Invoke-Pester -Tag DiskSpace

Invoke-Pester -Tag DBCC
 
Invoke-Pester -Tag VLF

Invoke-Pester -Tag Latency
 
Invoke-Pester -Tag Memory

Invoke-Pester -Tag TempDB
Test-DbaTempdbConfig -SqlInstance ROb-XPS
 
Invoke-Pester -Tag ServerName
 
Invoke-Pester -Tag LinkedServer

Invoke-Pester -Tag Connection
 
Invoke-Pester -Tag JobOwner
 
Invoke-Pester -Tag PowerPlan
 
Invoke-Pester -Tag AdHoc
 
Invoke-Pester -Tag Owner

Invoke-Pester -Tag Server

Invoke-Pester -Tag Instance

Invoke-Pester

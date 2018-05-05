## Test Cases and Tags

cd 'Presentations:\SQL Saturday Gothenburg - Green is Good Red is Bad'
cls 
Invoke-Pester -Tag Backup

cls 
Invoke-Pester -Tag DiskSpace

cls
Invoke-Pester -tag Collation

cls
Invoke-Pester -Tag DBCC

cls 
Invoke-Pester -Tag VLF


cls 
Invoke-Pester -Tag Latency

cls 
Invoke-Pester -Tag Memory

cls
Invoke-Pester -Tag TempDB
Test-DbaTempDbConfiguration -SqlInstance ROb-XPS

cls 
Invoke-Pester -Tag ServerName

cls 
Invoke-Pester -Tag LinkedServer

cls 
Invoke-Pester -Tag JobOwner

cls 
Invoke-Pester -Tag PowerPlan

cls 
Invoke-Pester -Tag AdHoc

cls 
Invoke-Pester -Tag Compatability

cls 
Invoke-Pester -Tag Owner

cls
Invoke-Pester -Tag Server

cls
Invoke-Pester -Tag Instance

cls
Invoke-Pester
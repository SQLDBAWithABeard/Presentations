## Test Cases and Tags

cd 'Presentations:\SQL Grillen'
cls 
Invoke-Pester -Tag Backup

cls
Invoke-Pester -tag Collation

cls
Invoke-Pester -Tag DBCC

cls
Invoke-Pester -Tag Server

cls
Invoke-Pester
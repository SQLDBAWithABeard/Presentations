<# Download #>
#Invoke-Expression (Invoke-WebRequest https://git.io/vn1hQ)

#Write-Host "Hey! you are demoing, right? Please select a block of code!" -ForegroundColor Red -BackgroundColor Black
#return

#<#
#    If sql server authentication is needed
##>
##Works but clear text
#$username = "sqlAuth"
#$password = "123"
#$secstr = New-Object -TypeName System.Security.SecureString
#$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
#$SqlCredential = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr
#
###Better approach - Kudos to Jaap Braaser (@jaap_brasser) - http://www.jaapbrasser.com/quickly-and-securely-storing-your-credentials-powershell/
#$SqlCredential = Get-Credential -Message 'Please enter sql server credentials'
#$SqlCredential | Export-Clixml -Path "${env:\userprofile}\Hash.Cred"
#$SqlCredential = Import-CliXml -Path "${env:\userprofile}\Hash.Cred"
#$SqlCredential
#$SqlCredential = $NULL


#Build server list
$serverList = (Get-VM -ComputerName beardnuc | Where-Object {$_.Name -like '*SQL2016N1' -or $_.Name -Like '*SQL*2012*' -or $_.Name -Like '*SQL*2014*' -or $_.Name -Like '*SQL*2008*'  -or $_.Name -Like '*SQL*2005*'  -and $_.State -eq 'Running'}).Name
$centralServer = "rob-xps"
$centralDB = "dbatoolsBestPractices_SQL2"

Invoke-Sqlcmd2 -ServerInstance $centralServer -Query "CREATE DATABASE [$centralDB]"



#To measure elapsed time
$start = [System.Diagnostics.Stopwatch]::StartNew()

<#
    Test SqlNetworkLatency
#>
Write-Output "Will run Test-SqlNetworkLatency" 
$SqlNetworkLatency = Test-SqlNetworkLatency -SqlServer $serverList -SqlCredential $SqlCredential -Verbose | Out-DbaDataTable 
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $SqlNetworkLatency -Table NetworkLatency -AutoCreateTable

#You guys decide if it is a best practive to put in place on your estate or not! 
#Example: MaxMemory you can configure less or more.

<#
   MaxDop
#>
Write-Output "Will run Test-DbaMaxDop" 
$MaxDop = Test-DbaMaxDop -SqlServer $serverList -SqlCredential $SqlCredential -Detailed | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $Maxdop -Table MaxDop -AutoCreateTable

#$MaxDop | Format-Table -AutoSize -Wrap
#
#$MaxDop | Where-Object {$_.CurrentInstanceMaxDop -ne $_.RecommendedMaxDop -and $_.CurrentInstanceMaxDop -eq 0} | Format-Table -AutoSize -Wrap


<#
    MaxMemory
#>
Write-Output "Will run Test-DbaMaxMemory" 
$MaxMemory = Test-DbaMaxMemory -SqlServer $serverList -SqlCredential $SqlCredential | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $MaxMemory -Table MaxMemory -AutoCreateTable

#$MaxMemory | Format-Table -AutoSize -Wrap
#
## Some need attention :)
#$MaxMemory | Where-Object {$_.TotalMB -le $_.SqlMaxMB} | Format-Table -AutoSize -Wrap
#$MaxMemory | Where-Object {$_.RecommendedMB -ge $_.SqlMaxMB} | Format-Table -AutoSize -Wrap



<#
    TempDB
#>
Write-Output "Will run Test-SqlTempDbConfiguration" 
$tempDB = Test-SqlTempDbConfiguration -SqlServer $serverList -SqlCredential $SqlCredential -Verbose -Detailed | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $tempDB -Table TempDB -AutoCreateTable



<#
    Get databases owner 
#>
Write-Output "Will run Test-DbaDatabaseOwner" 
$DatabaseOwner = Test-DbaDatabaseOwner -SqlServer $serverList -SqlCredential $SqlCredential -Detailed -Verbose | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $DatabaseOwner -Table DatabaseOwner -AutoCreateTable


# Find databases where owner is not SA account
#$DatabaseOwner | Where-Object {$_.OwnerMatch -eq $false} | Format-Table -Wrap -AutoSize



#$DatabaseToChange = $DatabaseOwner | Where-Object {$_.CurrentOwner -eq ""} | Select-Object Server, Database
#
#ForEach ($dbToChange in $DatabaseToChange)
#{
#    #Write-Output "$($dbToChange.Server) | $($dbToChange.Database)"
#    #$exp = 
#    Set-DbaDatabaseOwner -SqlServer $($dbToChange.Server) -SqlCredential $SqlCredential -Databases $($dbToChange.Database) # -WhatIf -Verbose
#    #Write-Host $exp
#    #Invoke-Expression $exp
#}


<#
   Get jobs owner 
#>
Write-Output "Will run Test-DbaJobOwner" 
$JobsOwner = Test-DbaJobOwner -SqlServer $serverList -SqlCredential $SqlCredential -Detailed | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $JobsOwner -Table JobsOwner -AutoCreateTable


# Find jobs where owner is not SA account
#$JobsOwner | Where-Object {$_.OwnerMatch -eq $false} | Format-Table -Wrap -AutoSize
#
#($JobsOwner | Where-Object {$_.OwnerMatch -eq $false}).Count

<#
    Test ServerName
#>
Write-Output "Will run Test-DbaServerName" 
$DbaServerName = Test-DbaServerName -SqlServer $serverList  -Credential $SqlCredential -Detailed -Verbose | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $DbaServerName -Table ServerName -AutoCreateTable

#$ServerName | Format-Table -Wrap -AutoSize
#
#$ServerName | Where-Object {$_.IsEqual -eq $false} | Format-Table -Wrap -AutoSize


<#
    Test Database Compatibility Level
#>
Write-Output "Will run Test-DbaDatabaseCompatibility" 
$DatabaseCompatibilityLevel = Test-DbaDatabaseCompatibility -SqlServer $serverList -Credential $SqlCredential -Detailed -Verbose | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $DatabaseCompatibilityLevel -Table DatabaseCompatibilityLevel -AutoCreateTable

#$DatabaseCompatibilityLevel | Format-Table -Wrap -AutoSize
#
#$DatabaseCompatibilityLevel | Where-Object {$_.IsEqual -eq $false} | Format-Table -Wrap -AutoSize


<#
    Test Database Collation 
#>
Write-Output "Will run Test-DbaDatabaseCollation" 
$DatabaseCollation = Test-DbaDatabaseCollation -SqlServer $serverList -Credential $SqlCredential -Detailed -Verbose | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $DatabaseCollation -Table DatabaseCollation -AutoCreateTable

#$DatabaseCollation | Format-Table -Wrap -AutoSize
#
#$DatabaseCollation | Where-Object {$_.IsEqual -eq $false} | Format-Table -Wrap -AutoSize


<#
    Test PowerPlan configuration
#>
Write-Output "Will run Test-DbaPowerPlan" 
$PowerPlan = Test-DbaPowerPlan -ComputerName $serverList -Detailed -Verbose | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $PowerPlan -Table PowerPlan -AutoCreateTable


<#
    Test DbaFullRecoveryModel
#>
Write-Output "Will run Test-DbaFullRecoveryModel" 
$DbaFullRecoveryModel = Test-DbaFullRecoveryModel -SqlServer $serverList -SqlCredential $SqlCredential -Detailed -Verbose | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $DbaFullRecoveryModel -Table FullRecoveryModel -AutoCreateTable


<#
    Test DbaDiskAllocation
#>
Write-Output "Will run Test-DbaDiskAllocation" 
$DbaDiskAllocation = Test-DbaDiskAllocation -SqlServer $serverList -Detailed -Verbose | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $DbaDiskAllocation -Table DiskAllocation -AutoCreateTable

<#
    Test DbaDiskAlignment
#>
Write-Output "Will run Test-DbaDiskAlignment" 
$DbaDiskAlignment = Test-DbaDiskAlignment -SqlServer $serverList -Detailed -Verbose | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $DbaDiskAlignment -Table DiskAlignment -AutoCreateTable


<#
    Test DbaVirtualLogFile
#>
Write-Output "Will run Test-DbaVirtualLogFile" 
$DbaVirtualLogFile = Test-DbaVirtualLogFile -SqlServer $serverList -SqlCredential $SqlCredential -Verbose | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $DbaVirtualLogFile -Table VirtualLogFile -AutoCreateTable


<#
    Get DbaLastBackup
#>
Write-Output "Will run Test-DbaLastBackup" 
$DbaLastBackup = Get-DbaLastBackup -SqlServer $serverList -Credential $SqlCredential -Verbose | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $DbaLastBackup -Table LastBackup -AutoCreateTable


<#
    Get DbaLastGoodCheckDb
#>
Write-Output "Will run Test-DbaLastGoodCheckDb" 
$DbaLastGoodCheckDb = Get-DbaLastGoodCheckDb -SqlServer $serverList -Credential $SqlCredential -Verbose | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $DbaLastGoodCheckDb -Table LastGoodCheckDb -AutoCreateTable


<#
    Test DbaOptimizeForAdHoc
#>
Write-Output "Will run Test-DbaOptimizeForAdHoc" 
$DbaOptimizeForAdHoc = Test-DbaOptimizeForAdHoc -SqlServer $serverList -SqlCredential $SqlCredential -Verbose | Out-DbaDataTable
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $DbaOptimizeForAdHoc -Table OptimizeForAdHoc -AutoCreateTable


<#
    Test DbaValidLogin
#>
Write-Output "Will run Test-DbaValidLogin" 
$DbaValidLogin = Test-DbaValidLogin -SqlServer $serverList -SqlCredential $SqlCredential -Detailed -Verbose | Where {$_ -ne $null} | Out-DbaDataTable 
Write-DbaDataTable -SqlServer $centralServer -Database $centralDB -InputObject $DbaValidLogin -Table ValidLogin -AutoCreateTable

#Test-DbaValidLogin -SqlServer sql2012 -SqlCredential $SqlCredential -Detailed -Verbose | Out-DbaDataTable 

Write-Output "Number of servers: $($serverList.Count)"
$start.elapsed




<#
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Password0!" -p 15592:1433 --name beard2019 -d mcr.microsoft.com/mssql/server:2019-GA-ubuntu-16.04

# create sqladmin and disable SA

docker stop beard2019

docker commit beard2019 beard2019image

# base image created :-0

#>

#region Set Defaults
$cred = Import-Clixml -Path D:\Creds\THEBEARDROB\sqladmin.cred
$instanceSMO = Connect-DbaInstance -SqlInstance $instances[1]
$PSDefaultParameterValues = @{
    "*dba*:SqlCredential"            = $cred
    "*dba*:SourceSqlCredential"      = $cred
    "*dba*:DestinationSqlCredential" = $cred
    "*dba*:SqlInstance"              = $instanceSMO
}


#endregion

#region Install community tools
Install-DbaMaintenanceSolution -Database master -BackupLocation '/var/opt/mssql/backup/' -CleanupTime 248 -LogToTable -InstallJobs

Install-DbaWhoIsActive -Database master 

Install-DbaFirstResponderKit -Database master 

#endregion

#region users

#region DBAs
$DBAs = @{
    Name     = 'William Durkin'
    UserName = 'wdurkin'
}, @{
    Name     = 'Gianluca Sartori'
    UserName = 'gsartori'
}, @{
    Name     = 'André Kamman'
    UserName = 'akamman'
}, @{
    Name     = 'Chrissy LeMaire'
    UserName = 'clemaire'
}, @{
    Name     = 'Shawn Melton'
    UserName = 'smelton'
}, @{
    Name     = 'Cláudio Silva'
    UserName = 'csilva'
}, @{
    Name     = 'Jonathan Allen'
    UserName = 'fatherjack'
}, @{
    Name     = 'Andy Levy'
    UserName = 'alevy'
}, @{
    Name     = 'John Martin'
    UserName = 'jamrtin'
}, @{
    Name     = "Shane O'Neill"
    UserName = 'soneill'
}, @{
    Name     = 'Tracy Boggiano'
    UserName = 'tboggiano'
}, @{
    Name     = 'thebeard'
    UserName = 'thebeard'
}

$Password = ConvertTo-SecureString -AsPlainText 'NopeNoPasswordhere1!' -Force

$DBAs.ForEach{
    New-DbaLogin -SqlInstance $instanceSMO -Login $psitem.UserName -SecurePassword $Password -DefaultDatabase master 
    Set-DbaLogin -SqlInstance $instanceSMO -Login $psitem.UserName -AddRole sysadmin
}
#endregion

#region Apps
$Apps = @{
    Name     = 'Beard App 1'
    UserName = 'beardapp1'
}, @{
    Name     = 'Beard App 2'
    UserName = 'beardapp2'
}, @{
    Name     = 'Beard App 3'
    UserName = 'beardapp3'
}, @{
    Name     = 'Beard App 4'
    UserName = 'beardapp4'
}, @{
    Name     = 'Beard App 5'
    UserName = 'beardapp5'
}, @{
    Name     = 'Beard App 6'
    UserName = 'beardapp6'
}, @{
    Name     = 'Beard App 7'
    UserName = 'beardapp7'
}, @{
    Name     = 'Beard App 8'
    UserName = 'beardapp8'
}

$Apps.ForEach{
    New-DbaLogin -SqlInstance $instanceSMO -Login $psitem.UserName -SecurePassword $Password -DefaultDatabase tempdb 
}
#endregion

#region Support
$Support = @{
    UserName = 'Support1'
}, @{
    UserName = 'Support2'
}, @{
    UserName = 'Support3'
}, @{
    UserName = 'Support4'
}, @{
    UserName = 'Support5'
}, @{
    UserName = 'Support6'
}

$Support.ForEach{
    New-DbaLogin -SqlInstance $instanceSMO -Login $psitem.UserName -SecurePassword $Password -DefaultDatabase tempdb 
}

#endregion

#region Reporting
$Reporting = @{
    UserName = 'Reporting1'
}, @{
    UserName = 'Reporting2'
}, @{
    UserName = 'Reporting3'
}, @{
    UserName = 'Reporting4'
}
$Reporting.ForEach{
    New-DbaLogin -SqlInstance $instanceSMO -Login $psitem.UserName -SecurePassword $Password -DefaultDatabase tempdb 
}
#endregion
#endregion
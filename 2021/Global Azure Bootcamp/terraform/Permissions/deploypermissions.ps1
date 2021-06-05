#region Module install
$Modules = 'dbatools', 'ImportExcel'
foreach ($Module in $Modules) {
    if (-not (Get-Module $Module -ListAvailable)) {
        Install-Module $Module -Scope CurrentUser -Force
        Write-Host "Installing Module $module to Current User Scope"
    }
}
#endregion

#region Variables
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
$env:SYSTEM_DEFAULTWORKINGDIRECTORY 
$ExcelPath = $env:SYSTEM_DEFAULTWORKINGDIRECTORY + '/Permissions/sqlinstancepermissions.xlsx'
Test-Path $ExcelPath
$KeyVaultName = ''
#region Get secrets
$appid = (Get-AzKeyVaultSecret -vaultName $KeyVaultName -name "service-principal-guid").SecretValueText
$Clientsecret = (Get-AzKeyVaultSecret -vaultName $KeyVaultName -name "service-principal-secret").SecretValue
$credential = New-Object System.Management.Automation.PSCredential ($appid, $Clientsecret)
$tenantid = (Get-AzKeyVaultSecret -vaultName $KeyVaultName -name "sewells-tenant-Id").SecretValueText
#endregion
#endregion

#region Read Excel

$ExcelLogins = Import-Excel -Path $ExcelPath -WorksheetName Logins
$ExcelDatabasePerms = Import-Excel -Path $ExcelPath -WorksheetName Databases


#endregion

#region Create Admins

foreach ($login in $ExcelLogins | Where-Object { $psitem.Admin -eq $true }) {
    $message = "Processing admin user {0} for {1}" -f $login.Principal , $login.SqlInstance
    # Write-Host $message
    $AzureSQL = Connect-DbaInstance -SqlInstance $login.SqlInstance -Database master -SqlCredential $credential -Tenant $tenantid -TrustServerCertificate

    $Query = @"
    DECLARE @PrincipalName VARCHAR(250) = '{0}'
    DECLARE @Role VARCHAR(125) 
    DECLARE @SQL NVARCHAR(250)
    IF EXISTS (SELECT Name
    FROM sys.database_principals
    WHERE Name = @PrincipalName)
    BEGIN
        PRINT @PrincipalName + ' User Exists in ' + db_name() + ' on ' + @@SERVERNAME
    END
    ELSE
    BEGIN
        PRINT 'Adding ' + @PrincipalName + ' to database '  + db_name() + ' on instance' + @@SERVERNAME
        SELECT @SQL = 'CREATE USER [' + @PrincipalName + '] FROM EXTERNAL PROVIDER'
        -- PRINT @SQL
        EXEC sp_executesql @SQL
    END
    SELECT @Role = 'dbmanager'
    IF IS_ROLEMEMBER(@Role,@PrincipalName) = 1
BEGIN
    PRINT @PrincipalName + ' User Exists in ' + @Role + ' in database ' + db_name() + ' on instance ' + @@SERVERNAME
    
END
ELSE
BEGIN
    PRINT  'Adding ' + @PrincipalName + ' to ' + @Role + ' role in database ' + db_name() + ' on instance ' + @@SERVERNAME
    SELECT @SQL = 'ALTER ROLE ' + @Role + ' ADD MEMBER [' + @PrincipalName + ']'
    -- PRINT @SQL
    EXEC sp_executesql @SQL
END
SELECT @Role = 'loginmanager'
IF IS_ROLEMEMBER(@Role,@PrincipalName) = 1
BEGIN
PRINT @PrincipalName + ' User Exists in ' + @Role + ' in database ' + db_name() + ' on instance ' + @@SERVERNAME

END
ELSE
BEGIN
PRINT  'Adding ' + @PrincipalName + ' to ' + @Role + ' role in database ' + db_name() + ' on instance ' + @@SERVERNAME
SELECT @SQL = 'ALTER ROLE ' + @Role + ' ADD MEMBER [' + @PrincipalName + ']'
-- PRINT @SQL
EXEC sp_executesql @SQL
END

"@ -f $login.Principal
    # $Query
    Invoke-DbaQuery -SqlInstance $AzureSQL -Query $Query -MessagesToOutput
    $AzureSQL.ConnectionContext.Disconnect()
}


#endregion

#region Creating Database Users and Role Membership

foreach ($login in $ExcelDatabasePerms) {
    $AzureSQL = Connect-DbaInstance -SqlInstance $login.SqlInstance -Database $login.Database -SqlCredential $credential -Tenant $tenantid -TrustServerCertificate
    # $message = "Processing Database user {0} for role {1} in database {2} on {3}" -f $login.Principal, $login.Role, $login.Database , $login.SqlInstance
    # Write-Host $message
    $Query = @"
DECLARE @PrincipalName VARCHAR(250) = '{0}'
DECLARE @Role VARCHAR(125) = '{1}'
DECLARE @SQL NVARCHAR(250)
IF EXISTS (SELECT Name
FROM sys.database_principals
WHERE Name = @PrincipalName)
BEGIN
    PRINT @PrincipalName + ' User Exists in ' + db_name() + ' on ' + @@SERVERNAME
END
ELSE
BEGIN
    PRINT  'Creating ' + @PrincipalName + ' in database '  + db_name() + ' on instance' + @@SERVERNAME
    SELECT @SQL = 'CREATE USER [' + @PrincipalName + '] FROM EXTERNAL PROVIDER'
    -- PRINT @SQL
    EXEC sp_executesql @SQL
END
IF IS_ROLEMEMBER(@Role,@PrincipalName) = 1
BEGIN
    PRINT @PrincipalName + ' User Exists in ' + @Role + ' in database ' + db_name() + ' on instance ' + @@SERVERNAME
    
END
ELSE
BEGIN
    PRINT  'Adding ' + @PrincipalName + ' to ' + @Role + ' role in database ' + db_name() + ' on instance ' + @@SERVERNAME
    SELECT @SQL = 'ALTER ROLE ' + @Role + ' ADD MEMBER [' + @PrincipalName + ']'
    -- PRINT @SQL
    EXEC sp_executesql @SQL
END
"@ -f $login.Principal, $login.Role
    # $Query 
    Invoke-DbaQuery -SqlInstance $AzureSQL -Query $Query -MessagesToOutput
    $AzureSQL.ConnectionContext.Disconnect()
}


#endregion

#region Checking Admins are correct
$message = "#################  Checking Admin Users     ############## " 
Write-Host $message
foreach ($login in $ExcelLogins | Where-Object { $psitem.Admin -eq $false }) {
    $message = "Checking if user {0} should be admin on {1}" -f $login.Principal , $login.SqlInstance
    Write-Host $message
    $AzureSQL = Connect-DbaInstance -SqlInstance $login.SqlInstance -Database master -SqlCredential $credential -Tenant $tenantid -TrustServerCertificate

    $Query = @"
    DECLARE @PrincipalName VARCHAR(250) = '{0}'
    DECLARE @Role VARCHAR(125) 
    DECLARE @SQL NVARCHAR(250)
    IF EXISTS (SELECT Name
    FROM sys.database_principals
    WHERE Name = @PrincipalName)
    BEGIN
        PRINT 'The Beard is Sad! - ' + @PrincipalName + ' is a user in '  + db_name() + ' on instance ' + @@SERVERNAME + ' and will now be DROPPED'
        SELECT @SQL = 'DROP USER [' + @PrincipalName + ']'
        EXEC sp_executesql @SQL
    END
    ELSE
    BEGIN
        PRINT 'ALL Good ' + @PrincipalName + ' User Does NOT Exist in ' + db_name() + ' on ' + @@SERVERNAME
    END
"@ -f $login.Principal
    # $Query
    Invoke-DbaQuery -SqlInstance $AzureSQL  -Query $Query -MessagesToOutput
    $AzureSQL.ConnectionContext.Disconnect()
}

#endregion

#region Checking users and role membership is correct
$ExcelInstances = ($ExcelDatabasePerms | Select -Unique SqlInstance).SqlInstance

foreach ($Instance in $ExcelInstances) {
    $AzureSQL = Connect-DbaInstance -SqlInstance $Instance -Database master -SqlCredential $credential -Tenant $tenantid -TrustServerCertificate
    $databases = ($ExcelDatabasePerms | Select -Unique Database).Database
    $databaseUsers = Get-DbaDbRoleMember -SqlInstance $AzureSQL -Database $databases
    $message = "#################  Checking Excel Users are in {0} ############## " -f $Instance
    Write-Host $message
    foreach ($login in ($ExcelDatabasePerms | Select -Unique Principal).Principal) {
        if ($login -in $databaseUsers.UserName) {
            $db = ($databaseUsers | Where-Object { $PSItem.UserName -eq $login } | Select Database -Unique).Database -join ','
            $message = 'Excel login {0} is on Instance {1} in database(s){2} ' -f $login, $Instance, $db
            Write-Host $message
        }
        else {
            $message = 'Excel login {0} is NOT on Instance {1} ' -f $login , $Instance
            Write-Warning $message
        }
    }


    $message = "#################                             ############## "
    Write-Host $message

    $message = "#################  Checking {0} Users are in Excel ############## " -f $Instance
    Write-Host $message
    foreach ($dbuser in $databaseUsers) {
        if ($dbuser.UserName -notin (($ExcelDatabasePerms | Where-Object { $psitem.Database -eq $dbuser.Database -and $psitem.Principal -eq $dbuser.UserName }).Principal) ) {
            $message = "Removing User {0} from database {1} on Instance {2} " -f $dbuser.UserName, $dbuser.Database , $dbuser.ComputerName
            Write-Warning $message
            Remove-DbaDbUser -SqlInstance $AzureSQL -Database $dbuser.Database -User $dbuser.UserName -errorAction SilentlyContinue # because there is an EnumOwnedObjects error even though it works
        }
        else {
            $message = "All is good for User {0} is in database {1} on Instance {2} " -f $dbuser.UserName, $dbuser.Database , $dbuser.ComputerName
            Write-Host $message
        } 
    }
    $message = "#################                             ############## "
    Write-Host $message

    $message = "#################  Checking {0} Users are in roles in Excel ############## " -f $Instance
    Write-Host $message
    foreach ($dbuser in $databaseUsers) {
        if ($dbuser.UserName -notin (($ExcelDatabasePerms | Where-Object { $psitem.Database -eq $dbuser.Database -and $psitem.Principal -eq $dbuser.UserName -and $psitem.Role -eq $dbuser.Role }).Principal) ) {
            $message = "Removing User {0} from {3} role in database {1} on Instance {2} " -f $dbuser.UserName, $dbuser.Database , $dbuser.ComputerName, $dbuser.Role
            Write-Warning $message
            Remove-DbaDbRoleMember -SqlInstance $AzureSQL -Database $dbuser.Database -Role $dbuser.Role -User $dbuser.UserName -Confirm:$false
        }
        else {
            $message = "All is good for User {0} is in role {3} database {1} on Instance {2} " -f $dbuser.UserName, $dbuser.Database , $dbuser.ComputerName , $dbuser.role
            Write-Host $message
        }
    }
    $message = "#################                             ############## "
    Write-Host $message
    $AzureSQL.ConnectionContext.Disconnect()
}
#endregion

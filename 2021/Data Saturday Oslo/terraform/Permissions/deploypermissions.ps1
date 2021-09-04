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
$KeyVaultName = 'sewells-key-vault'
#region Get secrets
$appidsecret = (Get-AzKeyVaultSecret -vaultName $KeyVaultName -name "service-principal-guid").SecretValue
$appidcredential = New-Object System.Management.Automation.PSCredential ('dummy', $appidsecret)
$Client = $appidcredential.GetNetworkCredential().Password
$Clientsecret = (Get-AzKeyVaultSecret -vaultName $KeyVaultName -name "service-principal-secret").SecretValue
$credential = New-Object System.Management.Automation.PSCredential ($Client, $Clientsecret)
$tenantidsecret = (Get-AzKeyVaultSecret -vaultName $KeyVaultName -name "sewells-tenant-Id").SecretValue
$tenantidcredential = New-Object System.Management.Automation.PSCredential ('dummy', $tenantidsecret)
$tenantid = $tenantidcredential.GetNetworkCredential().Password
#endregion
Set-DbatoolsConfig -FullName sql.connection.experimental -Value $true

$azureAccount = Connect-AzAccount -Credential $Credential -ServicePrincipal -Tenant $tenantid
$azureToken = (Get-AzAccessToken -ResourceUrl https://database.windows.net).Token
#endregion

#region Read Excel

$ExcelLogins = Import-Excel -Path $ExcelPath -WorksheetName Logins
$ExcelDatabasePerms = Import-Excel -Path $ExcelPath -WorksheetName Databases


#endregion

#region Create Admins

foreach ($login in $ExcelLogins | Where-Object { $psitem.Admin -eq $true }) {
    $message = "Processing admin user {0} for {1}" -f $login.Principal , $login.SqlInstance
    # Write-Host $message
    $AzureSQL = Connect-DbaInstance -SqlInstance $login.SqlInstance -Database master -AccessToken $azureToken

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
    Invoke-DbaQuery -SqlInstance $AzureSQL  -Query $Query -MessagesToOutput
    $AzureSQL.ConnectionContext.Disconnect()
}


#endregion

#region Creating Database Users and Role Membership

foreach ($login in $ExcelDatabasePerms) {
    $AzureSQL = Connect-DbaInstance -SqlInstance $login.SqlInstance -Database $login.Database -AccessToken $azureToken
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
    Invoke-DbaQuery -SqlInstance $AzureSQL  -Query $Query -MessagesToOutput
    $AzureSQL.ConnectionContext.Disconnect()
}


#endregion

#region Checking Admins are correct
$message = "#################  Checking Admin Users     ############## " 
Write-Host $message
foreach ($login in $ExcelLogins | Where-Object { $psitem.Admin -eq $false }) {
    $message = "Checking if user {0} should be admin on {1}" -f $login.Principal , $login.SqlInstance
    Write-Host $message
    $AzureSQL = Connect-DbaInstance -SqlInstance $login.SqlInstance -Database master -AccessToken $azureToken

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
    Invoke-DbaQuery -SqlInstance $AzureSQL -Query $Query -MessagesToOutput
    $AzureSQL.ConnectionContext.Disconnect()
}

#endregion

#region Checking users and role membership is correct
$ExcelInstances = ($ExcelDatabasePerms | Select-Object -Unique SqlInstance).SqlInstance

foreach ($Instance in $ExcelInstances) {
    $AzureSQL = Connect-DbaInstance -SqlInstance $Instance -Database master -AccessToken $azureToken
    $databases = ($ExcelDatabasePerms | Select-Object -Unique Database).Database
    $azureDatabases = $AzureSQL.Databases.Name 
    $RoleMembersQuery = @"
SELECT 
@@SERVERNAME AS [InstanceName],
DB_NAME() AS [DatabaseName],
DP1.name AS RoleName,   
   isnull (DP2.name, 'No members') AS UserName   
 FROM sys.database_role_members AS DRM  
 RIGHT OUTER JOIN sys.database_principals AS DP1  
   ON DRM.role_principal_id = DP1.principal_id  
 LEFT OUTER JOIN sys.database_principals AS DP2  
   ON DRM.member_principal_id = DP2.principal_id  
WHERE DP1.type = 'R'
ORDER BY DP1.name;  
"@
    $databaseUsers = foreach ($azuredb in $azureDatabases) {
        $Connection = Connect-DbaInstance -SqlInstance $Instance -Database $azuredb -AccessToken $azureToken
        Invoke-DbaQuery -SqlInstance $Connection -Query $RoleMembersQuery
        $Connection.ConnectionContext.Disconnect()
    }
    $message = "#################  Checking Excel Users are in {0} ############## " -f $Instance
    Write-Host $message
    foreach ($login in ($ExcelDatabasePerms | Select-Object -Unique Principal).Principal) {
        if ($login -in $databaseUsers.UserName) {
            $db = ($databaseUsers | Where-Object { $PSItem.UserName -eq $login } | Select-Object DatabaseName -Unique).DatabaseName -join ','
            $message = 'Excel login {0} is on Instance {1} in database(s) {2} ' -f $login, $Instance, $db
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
    foreach ($dbuser in  $databaseUsers | Where-Object UserName -notin ('No members', 'dbo') | Where-Object DatabaseName -ne 'master') {
        if ($dbuser.UserName -notin (($ExcelDatabasePerms | Where-Object { $psitem.Database -eq $dbuser.DatabaseName -and $psitem.Principal -eq $dbuser.UserName }).Principal) ) {
            $message = "Removing User {0} from database {1} on Instance {2} " -f $dbuser.UserName, $dbuser.DatabaseName , $dbuser.InstanceName
            Write-Warning $message
            $Connection = Connect-DbaInstance -SqlInstance $Instance -Database $dbuser.DatabaseName -AccessToken $azureToken
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
"@ -f $dbuser.UserName
            # $Query
            Invoke-DbaQuery -SqlInstance $Connection -Query $Query -MessagesToOutput
            $Connection.ConnectionContext.Disconnect() 
        }
        else {
            $message = "All is good for User {0} is in database {1} on Instance {2} " -f $dbuser.UserName, $dbuser.DatabaseName , $dbuser.InstanceName
            Write-Host $message
        } 
    }
    $message = "#################                             ############## "
    Write-Host $message

    $message = "#################  Checking {0} Users are in roles in Excel ############## " -f $Instance
    Write-Host $message
    foreach ($dbuser in $databaseUsers | Where-Object UserName -notin ('No members', 'dbo') | Where-Object DatabaseName -ne 'master') {
        if ($dbuser.UserName -notin (($ExcelDatabasePerms | Where-Object { $psitem.Database -eq $dbuser.DatabaseName -and $psitem.Principal -eq $dbuser.UserName -and $psitem.Role -eq $dbuser.RoleName }).Principal) ) {
            $message = "Removing User {0} from {3} role in database {1} on Instance {2} " -f $dbuser.UserName, $dbuser.DatabaseName , $dbuser.InstanceName, $dbuser.RoleName
            Write-Warning $message
            $Connection = Connect-DbaInstance -SqlInstance $Instance -Database $dbuser.DatabaseName -AccessToken $azureToken
            $Query = @"
DECLARE @PrincipalName VARCHAR(250) = '{0}'
DECLARE @Role VARCHAR(125) = '{1}'
DECLARE @SQL NVARCHAR(250)

IF IS_ROLEMEMBER(@Role,@PrincipalName) = 1
BEGIN
    PRINT @PrincipalName + ' User Exists in ' + @Role + ' in database ' + db_name() + ' on instance ' + @@SERVERNAME + ' and shall be removed'
    SELECT @SQL = 'ALTER ROLE ' + @Role + ' DROP MEMBER [' + @PrincipalName + ']'
    -- PRINT @SQL
    EXEC sp_executesql @SQL
END
ELSE
BEGIN
    PRINT @PrincipalName + ' User Does not Exists in ' + @Role + ' in database ' + db_name() + ' on instance ' + @@SERVERNAME 
END
"@ -f $dbuser.UserName, $dbuser.RoleName
            Invoke-DbaQuery -SqlInstance $Connection -Query $Query -MessagesToOutput
            $Connection.ConnectionContext.Disconnect() 
        }
        else {
            $message = "All is good for User {0} is in role {3} database {1} on Instance {2} " -f $dbuser.UserName, $dbuser.DatabaseName , $dbuser.InstanceName , $dbuser.roleName
            Write-Host $message
        }
    }
    $message = "#################                             ############## "
    Write-Host $message
    $AzureSQL.ConnectionContext.Disconnect()
}
[System.Environment]::Exit(0)
#endregion

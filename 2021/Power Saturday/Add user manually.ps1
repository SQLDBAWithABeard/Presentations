$KeyVaultName = ''
$UserName = ''
$role = 'loginmanager'
$SQlinstance = 'beard-elasticsql.database.windows.net'
$database = 'Beard-Audit'
#region Get secrets
$appid = (Get-AzKeyVaultSecret -vaultName $KeyVaultName -name "service-principal-guid" -AsPlainText)
$Clientsecret = (Get-AzKeyVaultSecret -vaultName $KeyVaultName -name "service-principal-secret").SecretValue
$credential = New-Object System.Management.Automation.PSCredential ($appid, $Clientsecret)
$tenantid = (Get-AzKeyVaultSecret -vaultName $KeyVaultName -name "sewells-tenant-Id" -AsPlainText)
#endregion

Set-DbatoolsConfig -FullName sql.connection.experimental -Value $true
$azureAccount = Connect-AzAccount -Credential $Credential -ServicePrincipal -Tenant $tenantid
$azureToken = (Get-AzAccessToken -ResourceUrl https://database.windows.net).Token

$AzureSQL = Connect-DbaInstance -SqlInstance $SQlinstance -Database $database -AccessToken $azureToken 

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
SELECT @Role = '{1}'
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

"@ -f $UserName, $role
# $Query
Invoke-DbaQuery -SqlInstance $AzureSQL -Database $database -Query $Query -MessagesToOutput -WarningVariable ResultWarning

$Results = Invoke-DbaQuery -SqlInstance $AzureSQL -Database master -Query $Query -MessagesToOutput -WarningVariable ResultWarning -warningAction SilentlyContinue
while($ResultWarning){
    $date = Get-Date
    $AzureSQL = Connect-DbaInstance -SqlInstance $AzureSQL -Database master -AccessToken $azureToken 
    $Results = Invoke-DbaQuery -SqlInstance $AzureSQL -Database master -Query $Query -MessagesToOutput -WarningVariable ResultWarning -warningAction SilentlyContinue
    $message = "FAILED : {0} - Can't Add a User Yet" -f $date
    Write-Output $message
    Start-Sleep -Seconds 10
}

$AppIcon = New-BTImage -Source 'https://media.giphy.com/media/7Tie4mXtT5yOhhDCf9/giphy.gif' -AppLogoOverride
$HeroImage = New-BTImage -Source 'C:\Users\mrrob\OneDrive\Documents\GitHub\Presentations\2021\Controlling Permissions to Azure SQL Database and Azure SQL Managed Instance using Excel and Azure DevOps\interruptcat.jpg' -HeroImage

$Text1 = New-BTText -Text "We interrupt this session to"
$Text2 = New-BTText -Text 'inform you that the database is ready'

$Binding1 = New-BTBinding -Children $Text1, $Text2 -AppLogoOverride $AppIcon -HeroImage $HeroImage 
$Visual1 = New-BTVisual -BindingGeneric $Binding1

$Audio1 = New-BTAudio -Silent

$Action1 = New-BTAction -SnoozeAndDismiss

$Content1 = New-BTContent -Visual $Visual1 -Actions $Action1 -Audio $Audio1 -Scenario Alarm
Submit-BTNotification -Content $Content1


<#
Invoke-DbaQuery -SqlInstance $AzureSQL -Database master -Query $Query -MessagesToOutput -WarningVariable ResultWarning
$AzureSQL = Connect-DbaInstance -SqlInstance  -Database Beard-Audit -AccessToken $azureToken 
$UserName = ''

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
SELECT @Role = 'db_owner'
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
"@ -f $UserName
# $Query
Invoke-DbaQuery -SqlInstance $AzureSQL -Database Beard-Audit -Query $Query -MessagesToOutput -WarningVariable ResultWarning
#>
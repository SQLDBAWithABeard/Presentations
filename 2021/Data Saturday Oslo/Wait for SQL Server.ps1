#  Connect-AzAccount

$KeyVaultName = 'sewells-key-vault'
$SQlinstance = 'beard-elasticsql.database.windows.net'
$database = 'Beard-Audit'

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

$date = Get-Date
$message = "{0} - Checking if Azure SQL Server is available" -f $date
Write-Output $message

$there = $false
while(-not($there)){
    $date = Get-Date
    try {
    $AzureSQL = Connect-DbaInstance -SqlInstance $SQlinstance -Database $database  -SqlCredential $credential -Tenant $tenantid -TrustServerCertificate -ConnectTimeout 10 -WarningVariable ResultWarning 
       $there = $true 
    }
    catch {
    $there = $false
    }
    
    $message = "FAILED : {0} - SQL server is not ready yet" -f $date
    Write-Output $message
    Start-Sleep -Seconds 10
}

$AppIcon = New-BTImage -Source 'https://media.giphy.com/media/7Tie4mXtT5yOhhDCf9/giphy.gif' -AppLogoOverride
$HeroImage = New-BTImage -Source 'G:\OneDrive\Documents\GitHub\Presentations\2021\Controlling Permissions to Azure SQL Database and Azure SQL Managed Instance using Excel and Azure DevOps\interruptcat.jpg' -HeroImage

$Text1 = New-BTText -Text "We interrupt this session to"
$Text2 = New-BTText -Text 'inform you that the SQL Instance is ready'

$Binding1 = New-BTBinding -Children $Text1, $Text2 -AppLogoOverride $AppIcon -HeroImage $HeroImage 
$Visual1 = New-BTVisual -BindingGeneric $Binding1

$Audio1 = New-BTAudio -Silent

$Action1 = New-BTAction -SnoozeAndDismiss

$Content1 = New-BTContent -Visual $Visual1 -Actions $Action1 -Audio $Audio1 -Scenario Alarm
Submit-BTNotification -Content $Content1
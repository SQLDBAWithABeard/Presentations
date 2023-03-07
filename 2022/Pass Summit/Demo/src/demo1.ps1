# We could install the module beforehand in the dev container creation by adding it to a Post Create Script
Install-Module dbatools

# Just to show that we have a SQL Instance available to us inside the container
$cred = Get-Credential
$sqlInstance = Connect-DbaInstance -SqlInstance db -SqlCredential $cred
$sqlInstance

Get-DbaDatabase -SqlInstance $sqlInstance
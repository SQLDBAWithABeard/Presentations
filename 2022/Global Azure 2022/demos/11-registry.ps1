#region just incase
if (-not $env:Path.Contains('C:\users\mrrob\.azure\bin')) {
    Write-PSFMessage "Arggh - set the path to have the bicep" -Level Output
    $env:Path = $env:Path + ';C:\users\mrrob\.azure\bin'
}
Set-Location demos
#endregion

#region Deploy Admin Infrastructure

code '..\Bicep\myCustomResources\AdminRG.bicep'
$date = Get-Date -Format yyyyMMddHHmmsss
$deploymentname = 'deploy_adminRg_{0}' -f $date # name of the deployment seen in the activity log
$TemplateFile = '..\Bicep\myCustomResources\AdminRG.bicep'

New-AzDeployment -Name $deploymentname -Location eastus -TemplateFile $TemplateFile # -WhatIf

#endregion

#region publish files to the registry

Set-Location ..
$bicepfiles = Get-ChildItem Bicep -File -Recurse -Include *.bicep
$keyVaultName = 'beardy-admin-kv'
$tag = '0.0.1'

$loginserver = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name bearddemoacr-loginserver -AsPlainText
$registryName = $loginserver -replace '.azurecr.io',''
$loginUser = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name bearddemoacr-username -AsPlainText
$loginPassword = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name bearddemoacr-password -AsPlainText


#region deploy a new module to the registry

# ALSO CHECK AZ CLI LOGIN

$ShowAzureCli = $true

az login
# FIRST CHANGE THE TLS VERSION TO 1.0 for the StorageV2 bicep ROB
# and CHECK the tag in the resource group bicep

##

foreach ($file in $bicepfiles |Where-Object { $_.Name -eq 'StorageV2.bicep' -or $_.Name -eq 'ResourceGroup.bicep'} ) {
    $message = "publishing {0}" -f $file.Name
    Write-Output $message
    $relativepath = $file | Resolve-Path -Relative 
    $acrpath = $relativepath.Replace('.\' , '').Replace('\', '/').Replace($file.Name, $file.BaseName).Trim('/').ToLower()
    $target = 'br:{0}/{1}:{2}' -f $loginserver, $acrpath, $tag 
    $message = "publishing with - bicep publish {0} --target {1} " -f $relativepath, $target
    Write-Output $message
    bicep publish $relativepath --target $target
}

$repositoryname = 'bicep/storage/storagev2'
# we have a repository containing our module
Get-AzContainerRegistryRepository -RegistryName $registryName -Name $repositoryname
# and it is tagged 0.0.1
Get-AzContainerRegistryTag -RegistryName $registryName -RepositoryName $repositoryname 
#endregion
#endregion
#region Deploy RG and storage

$date = Get-Date -Format yyyyMMddHHmmsss
$deploymentname = 'deploy_testRg_{0}' -f $date # name of the deployment seen in the activity log
$TemplateFile = 'Bicep\myCustomResources\TheTestResourceGroup.bicep'
New-AzDeployment -Name $deploymentname -Location eastus -TemplateFile $TemplateFile # -WhatIf


# OH NO

# We set TLS to be 1.0 - The security team say minimum is 1.2

Get-AzStorageAccount -ResourceGroupName demo-rg -Name ateststorage01234567 | Select MinimumTlsVersion

#endregion

#region update code and publish a new version
# Lets fix that in the bicep


# FIRST CHANGE THE TLS VERSION TO 1.2 for the bicep ROB

#then we publish the module
$bicepfiles = Get-ChildItem Bicep -File -Recurse -Include *.bicep
$tag = '0.0.2'

foreach ($file in $bicepfiles |Where Name -eq 'StorageV2.bicep') {
    $message = "publishing {0}" -f $file.Name
    Write-Output $message
    $relativepath = $file | Resolve-Path -Relative 
    $acrpath = $relativepath.Replace('.\' , '').Replace('\', '/').Replace($file.Name, $file.BaseName).Trim('/').ToLower()
    $target = 'br:{0}/{1}:{2}' -f $loginserver, $acrpath, $tag 
    $message = "publishing with - bicep publish {0} --target {1} " -f $relativepath, $target
    Write-Output $message
    bicep publish $relativepath --target $target
}

# we have a repository containing our module
Get-AzContainerRegistryRepository -RegistryName $registryName -Name $repositoryname
# and tags 0.0.1 and 0.0.2
Get-AzContainerRegistryTag -RegistryName $registryName -RepositoryName $repositoryname 
#endregion

#region Deploy the resource group with the updated version

# now we can change our deployment bicep to use the 0.0.2 of the module

# GO and change the bicep Rob

$date = Get-Date -Format yyyyMMddHHmmsss
$deploymentname = 'deploy_testRg_{0}' -f $date # name of the deployment seen in the activity log
$TemplateFile = 'Bicep\myCustomResources\TheTestResourceGroup.bicep'
New-AzDeployment -Name $deploymentname -Location eastus -TemplateFile $TemplateFile # -WhatIf

# and now we are good :-)

Get-AzStorageAccount -ResourceGroupName demo-rg -Name ateststorage01234567 | Select MinimumTlsVersion

# of course, if we need to deploy with TLS 1.0 we can use version 0.0.1 of the module
#endregion




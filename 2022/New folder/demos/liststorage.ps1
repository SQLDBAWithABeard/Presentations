$films = 'Iron-Man', 'The-Incredible-Hulk', 'Iron-Man-2', 'Thor', 'Captain-America-The-First-Avenger', 'Marvels-The-Avengers', 'Iron-Man-3', 'Thor-The-Dark-World', 'Captain-America-The-Winter-Soldier', 'Guardians-of-the-Galaxy',	'Avengers-Age-of-Ultron', 'Ant-Man',	'Captain-America-Civil-War', 'Doctor-Strange',	'Guardians-of-the-Galaxy-2', 'Spider-Man-Homecoming', 'Thor-Ragnarok',	'Black-Panther',	'Avengers-Infinity-War', 'Ant-Man-and-the-Wasp', 'Captain-Marvel',	'Avengers-Endgame', 'Spider-Man-Far-From-Home', 'Black-Widow'
$filmrgs = foreach ($env in 'dev', 'uat', 'prod') {
    foreach ($film in $films) {
        '{0}-{1}-rg' -f $film, $env
    }
}

$myip = whatsmyip
$filmrgs | ForEach-Object {
    $rg = $_
    $storageaccount = Get-AzStorageAccount -ResourceGroupName $rg  
    Add-AzStorageAccountNetworkRule -ResourceGroupName $rg -Name $storageaccount.StorageAccountName -IPAddressOrRange $myip |Out-Null
    $ctx = New-AzStorageContext -StorageAccountName $storageaccount.StorageAccountName 
    $rgname = @{Name = 'ResourceGroup'; Exp = { $rg } }
    $stname = @{Name = 'StorageAccount'; Exp = { $storageaccount.StorageAccountName } }
    try {
    Get-AzStorageContainer -Context $ctx -ErrorAction Stop| Select $rgname , $stname, Name
        
    }
    catch {
        Write-Warning "Failed to get storage for $($storageaccount.StorageAccountName) in $rg"
    }
}
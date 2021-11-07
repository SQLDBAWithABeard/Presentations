$rgnames = 'PassBeard', 'PassBeards', 'PassBeard-Admin', 'beardednetwork-rg', 'beardynetwork-dev-rg', 'beardynetwork-uat-rg', 'beardynetwork-rg','demo-rg','beard-admin-rg'
$films = 'Iron-Man', 'The-Incredible-Hulk', 'Iron-Man-2', 'Thor', 'Captain-America-The-First-Avenger', 'Marvels-The-Avengers', 'Iron-Man-3', 'Thor-The-Dark-World', 'Captain-America-The-Winter-Soldier', 'Guardians-of-the-Galaxy',	'Avengers-Age-of-Ultron', 'Ant-Man',	'Captain-America-Civil-War', 'Doctor-Strange',	'Guardians-of-the-Galaxy-2', 'Spider-Man-Homecoming', 'Thor-Ragnarok',	'Black-Panther',	'Avengers-Infinity-War', 'Ant-Man-and-the-Wasp', 'Captain-Marvel',	'Avengers-Endgame', 'Spider-Man-Far-From-Home', 'Black-Widow'
$filmrgs = foreach ($env in 'dev', 'uat', 'prod') {
    foreach ($film in $films) {
        '{0}-{1}-rg' -f $film, $env
    }
}

$filmrgs | ForEach-Object -Parallel  {
    $r = Get-AzResourceGroup -Name $_ -ErrorAction SilentlyContinue
    if ($r) {
        $message = "We have a resource group called {0}" -f $_
        Write-PSFMessage $message -Level Output
        try {
            $message = "###   Removing resource group {0}" -f $_
            Write-PSFMessage $message -Level Output
            Remove-AzResourceGroup -Name $_ -Confirm:$false -Force | Out-Null
            $message = "###   Resource group {0} Removed" -f $_
            Write-PSFMessage $message -Level Output
        }
        catch {
            $message = "###   FAILED - REMOVING -Resource group {0}" -f $_
            Write-PSFMessage $message -Level Significant
        }
    }
    else {
        $message = "There is no resource group called {0}" -f $_
        Write-PSFMessage $message -Level Output
    }
} -ThrottleLimit 25

foreach ($rg in $rgnames) {
    $r = Get-AzResourceGroup -Name $rg -ErrorAction SilentlyContinue
    if ($r) {
        $message = "We have a resource group called {0}" -f $rg
        Write-PSFMessage $message -Level Output
        try {
            $message = "###   Removing resource group {0}" -f $rg
            Write-PSFMessage $message -Level Output
            Remove-AzResourceGroup -Name $rg -Confirm:$false -Force | Out-Null
            $message = "###   Resource group {0} Removed" -f $rg
            Write-PSFMessage $message -Level Output
        }
        catch {
            $message = "###   FAILED - REMOVING -Resource group {0}" -f $rg
            Write-PSFMessage $message -Level Significant
        }
    }
    else {
        $message = "There is no resource group called {0}" -f $rg
        Write-PSFMessage $message -Level Output
    }
}

